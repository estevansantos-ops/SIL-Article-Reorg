# Arquitetura do projeto

Documento de estudo: explica **como o projeto funciona de fato**, nao como
idealmente funcionaria. Foi reconstruido por leitura do codigo durante a
reorganizacao de Set/2026. Onde uma afirmacao nao pudesse ser verificada, isso
esta dito explicitamente.

---

## 1. O problema de controle

Dinamica **lateral** de um Cessna 172, 4 estados, 2 entradas (aileron e
rudder). Os atuadores sofrem falhas que comutam segundo uma **cadeia de Markov
de tempo continuo** com `N = 6` modos.

Que o sistema e de tempo continuo (e nao discreto) fica evidente nas LMIs: elas
usam a forma `P*A + (P*A)'` de Lyapunov continuo, e `Lambda` aparece como
**gerador** (matriz de taxas, diagonal negativa) nos termos `P{i}*Lambda(i,i)`
e `sqrt(Lambda(i,j))` — nao como matriz de probabilidades de transicao.

Ha tres colapsos de indice importantes, e confundi-los e a principal fonte de
erro na leitura do codigo:

| De | Para | Como | Onde aparece |
|---|---|---|---|
| 6 modos de Markov | 3 condicoes de falha | `th = 1*(Z<=3) + 2*(Z==4\|Z==5) + 3*(Z==6)` | scripts de Monte Carlo |
| 6 modos de Markov | 2 controladores | `CL = [1 1 1 2 2 2]` (o `IS` das funcoes) | scripts de projeto |
| tempo continuo | tempo discreto | `Ts = 0.05; P = eye(6) + Lambda*Ts` | fim dos scripts de projeto |

A discretizacao `P = I + Lambda*Ts` e uma aproximacao de primeira ordem de
`expm(Lambda*Ts)` — o proprio autor deixou o script
`experiments/sil1/montecarlo/teste_markov_chain.m` para justificar essa
escolha, comparando `mu*expm(Lambda*(i-1)*Ts)` com `mu*(expm(Lambda*Ts))^(i-1)`.

### O modelo de falha

As tres condicoes de falha entram como ganhos multiplicativos na entrada:

| `th` | Matriz | Efeito fisico |
|---|---|---|
| 1 | `Xi{1} = eye(2)` | nominal |
| 2 | `Xi{2} = [2 0; 0 1]` | efetividade do aileron dobrada |
| 3 | `Xi{3} = [2 0; 0 -1]` | aileron dobrado **e rudder com sinal invertido** |

O modo 3 e o caso critico (inversao de sinal), e e justamente sobre ele que o
revisor pediu esclarecimento em `02.sucker_comments.txt`. Nos scripts de Monte
Carlo isso aparece como a diferenca entre `u` (comando calculado) e `uA`
(comando efetivamente aplicado).

---

## 2. As quatro camadas de codigo

```
src/model/       Modelagem_Cessna_172.m   -> A_lat, B_lat, Q_lat, R_lat, Klat
                                             (nenhum .mat, nenhuma dependencia)
     |
src/synthesis/   h2/hinf/h2inf_state_control[_rob][_lti].m
                 LMIs em YALMIP -> [K, gamma]
     |
src/analysis/    h2_norm.m, hinf_norm.m
                 validacao a posteriori: recebe a malha JA fechada
     |
src/simulation/  dtmjls.m (um passo do MJLS) + markov_chain.m (sorteio do modo)
```

Toda funcao de sintese devolve `gamma` **ao quadrado**; os scripts imprimem
`sqrt(gamma)`. Toda funcao de sintese usa YALMIP com MOSEK
(`sdpsettings('verbose',0,'solver','mosek')`); `sedumi` aparece so em linha
comentada.

O padrao das LMIs e sempre o mesmo: variaveis de folga `G{l}` (n x n cheia) e
`Y{l}` (m x n cheia), com recuperacao do ganho no final por
`K{k} = double(Y{k}) * inv(G{k})`.

As funcoes de `src/analysis/` nao fecham a malha — quem chama faz isso, tipicamente
varrendo os vertices do politopo e tomando o pior caso:

```matlab
Acl{i} = A{i}{k} + B{i}{k}*K{CL(i)};
gammaAux(k) = hinf_norm(Acl, JInf, CclInf, Lambda, []);
gammaPiorCaso = max(gammaAux);
```

---

## 3. O acoplamento pelo workspace base

Esta e a caracteristica estrutural mais importante do projeto, e a que mais
surpreende quem chega agora.

**Nao existe nenhuma chamada a `sim()`, `open_system()` ou `load_system()` em
todo o projeto.** As etapas nao se chamam umas as outras: elas se comunicam
deixando variaveis no workspace base do MATLAB, e a simulacao no Simulink e
disparada manualmente. O contrato implicito e:

| Etapa | Consome do workspace | Produz no workspace |
|---|---|---|
| script de projeto (`main_*`) | nada (faz `clear all`) | `A{i}{k}`, `B{i}{k}`, `J2`, `JInf`, `C2`, `D2`, `CInf`, `DInf`, `K`, `CL`, `Lambda`, `mu`, `N`, `P`, `Ts` |
| Monte Carlo (`discrete_markov_*`) | tudo o que esta acima | `xMax`, `xMin`, `uMax`, `uMin`, `Nsteps`, `n` |
| modelo `.slx` | `K{1}`, `K{2}` | `yout`, `tout` |
| pos-processamento (`test_*`) | `yout` ou um `.mat`, mais `Ts`, `n`, `Nsteps` | figuras |

Que o modelo le `K{1}`/`K{2}` e grava `yout` foi confirmado inspecionando o XML
interno de `Guiagem_Cessna_2024_H2_MC.slx` e
`Guiagem_Cessna_2024_Hinf_MC_2.slx` (o `.slx` e um arquivo zip).

**Consequencias praticas.** A ordem de execucao importa e nunca e verificada.
Rodar um `test_*` em um MATLAB recem-aberto falha por variavel inexistente —
ou, pior, usa valores residuais de uma execucao anterior e produz um grafico
plausivel mas errado. `test_hinf_norm_values.m` e o caso extremo: precisa de
`CInf`, `DInf`, `K`, `Nsteps` e `Ts` todos vivos no workspace, ou seja, exige
que `main_h2_hinf_rob_new_2.m` tenha rodado imediatamente antes.

### Convencao do vetor `yout`

Os `.slx` logam uma matriz de 10 colunas. A decodificacao esta espalhada pelos
scripts de pos-processamento:

| Colunas | Conteudo |
|---|---|
| 1:4 | estados |
| 5:6 | `u` — comando calculado pelo controlador |
| 7 | `w` — perturbacao (usada para achar o instante inicial da janela util) |
| 8 | `Z` — modo de Markov corrente, 1..6 |
| 9:10 | `uA` — comando efetivamente aplicado, ja com a falha `Xi{th}` |

O tempo e reescalado por 5 (`t = tout(iinit:iend)*5`): o modelo roda 5x mais
lento que o X-Plane, o que resulta no `Ts = 0.05` efetivo.

---

## 4. A progressao dos scripts de Monte Carlo

A familia `discrete_markov_system_response*` em
`experiments/sil1/montecarlo/` nao e um conjunto de alternativas: e um
**historico evolutivo**, cada arquivo acrescentando algo ao anterior. Ler nesta
ordem e a forma mais rapida de entender o projeto:

| Arquivo | O que acrescenta |
|---|---|
| `discrete_markov_system_response.m` | base: recebe a malha ja fechada (`Acls{i}`), `MC=1000`, `Ts=0.05` |
| `..._calculations.m` | sem plots, `Ts=0.01`, recalcula `P` localmente; valida `gamma` numericamente |
| `..._rob.m` | passa a **fechar a malha** a partir dos vertices e do `K`; varre um **segmento** entre 2 vertices |
| `..._h2_rob_poly.m` / `..._hinf_rob_poly.m` | o segmento vira um **simplexo de 4 vertices** (coordenadas baricentricas, `Np=5` -> 125 combinacoes, por isso `MC` cai para 200) |
| `..._h2_rob_poly_control_input.m` | acrescenta o **envelope do sinal de controle** (`u` e `uA`), ou seja o efeito visivel da falha. Tem o switch `flag2` que carrega `stateR.mat` para repetir uma realizacao fixa da cadeia |

Ortogonal a esse eixo ha o eixo H2 vs H-inf: as variantes `_h2*` usam
`J2`/`C2`/`D2` com `w_amp = 0` (excitacao pela condicao inicial, equivalente ao
impulso); as `_hinf*` usam `JInf`/`CInf`/`DInf` com `w_amp = 0.1`.

`experiments/sil2/montecarlo/discrete_markov_system_response_one_round.m` e o
ponto final: `MC = 1`, uma unica realizacao com os instantes de transicao
marcados — escrito para responder ao pedido do revisor em
`02.sucker_comments.txt`.

---

## 5. A ponte com o X-Plane

Duas S-functions em C (`src/xplane/`), ambas geradas pelo S-Function Builder,
fazem so empacotamento e desempacotamento de bytes. **Os sockets UDP nao estao
em C** — sao blocos UDP Send/Receive dentro dos `.slx`.

| S-function | Direcao | O que faz |
|---|---|---|
| `Dados_XPlane_Matlab` | X-Plane -> MATLAB | decodifica o datagrama `DATA` de 365 bytes em 32 saidas (velocidades, atitude, taxas, posicao, throttle) por offsets fixos |
| `Dados_Matlab_XPlane_longitudinal` | MATLAB -> X-Plane | monta o pacote com cabecalho ASCII `"DATA0"`, indice de grupo 8 (controles de voo) e 25 (throttle) |

Configuracao do link, de `docs/01.Readme.txt`: MATLAB local
`161.24.191.100:49001`, X-Plane `161.24.191.101:49000`.

**Qual arquivo e a fonte de verdade.** Os `.c` principais e os `.tlc` sao
inteiramente gerados e trazem o aviso `This file will be overwritten by the
S-function Builder block`. A logica escrita a mao vive **so** nos
`*_wrapper.c`, entre os marcadores
`SFUNWIZ_wrapper_Outputs_Changes_BEGIN` e `_END`. Mas mesmo esse codigo esta
tambem armazenado dentro do bloco no `.slx` — na pratica, **o `.slx` e a fonte
de verdade**, e os arquivos em `src/xplane/` sao o resultado do ultimo Build.

`rtwmakecfg.m` e chamado automaticamente pelo Simulink Coder: ele localiza os
blocos S-Function Builder via `find_system`, monta o caminho
`./SFB__<FunctionName>__SFB.mat` e injeta os `includePath`/`sourcePath`
armazenados ali no makefile. Neste projeto os dois `SFB__*.mat` tem 320 bytes e
listas praticamente vazias, ou seja carregam pouca informacao.

`legacy/scratch/markov.c` **nao tem relacao com a cadeia de Markov do
projeto** — apesar do nome. E uma copia do exemplo `simomex.c` da MathWorks com
`S_FUNCTION_NAME` trocado; o corpo continua sendo o sistema de 3 estados do
demo. A cadeia de Markov de verdade esta em `src/simulation/markov_chain.m`.

---

## 6. Pegadinhas conhecidas

Catalogadas durante a leitura do codigo. **Nenhuma foi corrigida** — a
reorganizacao nao alterou uma linha de codigo. Estao aqui para que voce nao
perca tempo redescobrindo.

### Que podem produzir resultado errado em silencio

1. **`markov_chain.m` sem `else`.** O sorteio do modo usa
   `if seed > pi_aux(j) && seed <= pi_aux(j+1)`. Como `P = I + Lambda*Ts` e uma
   aproximacao, as linhas podem nao somar exatamente 1; se `seed` cair fora,
   `mode` fica indefinido e a iteracao seguinte quebra.

2. **`hinf_norm.m` mistura `C{i}` e `C{IS(i)}`.** Os blocos de `C` usam o
   indice do laco enquanto todo o resto usa `IS(i)`. Fica latente porque os
   scripts sempre chamam com `IS = []` (que vira `1:N`, e ai `i == IS(i)`).
   Passar um `IS` esparso da resultado errado sem aviso.

3. **Nas funcoes `_lti`, o laco de vertices do canal H2 esta comentado** e fixo
   em `t = 1`. So o primeiro vertice de `J2` entra na cota da norma H2 —
   inconsistente com as versoes `_rob`, que varrem `1:Npol`.

4. **`test_hinf_states_3.m` sobrescreve o `x_pract.eps` gerado por
   `test_hinf_states_2.m`** e mantem os `ylabel` do script anterior
   (`x_2`/`x_4`) mesmo plotando `x_1` e `x_3`.

5. **Envelope nao inicializado em `..._h2_rob_poly.m`**: o bloco que calcula
   max/min esta comentado, de modo que `xMaxThe = xMax` usa valores residuais do
   workspace. A variante `_hinf_rob_poly.m` corrigiu isso pre-inicializando
   `xMax = -1e7*ones(4,Nsteps)`.

### Que quebram de forma visivel

6. **Ramo de falha do solver nao atribui as saidas.** Em todas as
   `*_state_control*`, quando `sol.problem` indica inviabilidade o codigo faz
   `gamma = 0; Ac = 0; Bc = 0; Cc = 0;` — mas `Ac`/`Bc`/`Cc` nao sao saidas da
   funcao e `K` nunca e atribuido. Resultado: *"Output argument K not
   assigned"*. Nas funcoes mistas e pior: o ramo de falha zera `gamma2`, mas a
   saida chamada e `gammaInf`.

7. **`discrete_markov_system_response_one_round.m` nao roda com o `flag` que
   vem no arquivo.** A linha 21 traz `flag = 2`, que dispara
   `load stateS.mat` — e `stateS.mat` nao existe, nem nunca existiu no projeto
   original (verificado contra o estado anterior a reorganizacao; o unico `.mat`
   parecido e `stateR.mat`).

   Isso **nao e dado perdido**. O `flag` e um switch de reprodutibilidade, e o
   proprio script produz o arquivo: na linha 81 ele faz `stateS{i} = state;`.
   O fluxo pretendido era rodar uma vez com `flag = 1` (sorteia a cadeia),
   salvar a realizacao a mao e depois voltar para `flag = 2` para repetir
   exatamente a mesma sequencia de falhas. O `.mat` simplesmente nunca foi
   salvo, ou nao foi copiado junto.

   **Como rodar.** A correcao mais simples e `flag = 1`. Se voce quiser uma
   realizacao fixa e reproduzivel, ha duas opcoes:

   - Reaproveitar o `stateR.mat` da campanha 1, que e o analogo direto e
     **dimensionalmente compativel**: e um `double` `1 x 162`, e os dois scripts
     usam `Ts = 0.05`, `Tf = 8`, logo `Nsteps + 1 = 162` nos dois. Trocar
     `load stateS.mat; state = stateS;` por `load stateR.mat; state = stateR;`
     funciona direto.
   - Gerar o proprio: rodar com `flag = 1`, depois
     `save stateS.mat state` — note **`state`, nao `stateS`**.

   E aqui esta a pegadinha dentro da pegadinha: `stateS` e um **cell array**
   (`stateS{i} = state`), enquanto a linha 26 faz `state = stateS;`. Se alguem
   salvasse `stateS` como esta e recarregasse, `state` viraria um cell e
   `state(k)` — usado como indice em `dtmjls(...,state(k))` e em
   `K{CL(state(k))}` — falharia. O caminho equivalente da campanha 1 funciona
   justamente porque `stateR` foi salvo como **numerico**, nao como cell.

   Para referencia, decodifiquei o `stateR.mat` (MAT v5 comprimido, criado em
   20/Jan/2025). Ele contem os modos `{1, 4, 5, 6}` e 10 transicoes:

   | Passo | Tempo | Transicao |
   |---|---|---|
   | 38 | 1,90 s | 4 -> 5 |
   | 42 | 2,10 s | 5 -> 1 |
   | 51 | 2,55 s | 1 -> 4 |
   | 57 | 2,85 s | 4 -> 1 |
   | 95 | 4,75 s | 1 -> 4 |
   | 99 | 4,95 s | 4 -> 6 |
   | 126 | 6,30 s | 6 -> 4 |
   | 136 | 6,80 s | 4 -> 5 |
   | 146 | 7,30 s | 5 -> 1 |
   | 150 | 7,50 s | 1 -> 4 |

   Essa realizacao passa pelas tres condicoes de falha, incluindo o modo 6
   (inversao de sinal do rudder) entre 4,95 s e 6,30 s — exatamente o caso que o
   revisor pediu em `02.sucker_comments.txt`.

8. **`legacy/superseded/testes_main_h2_hinf_rob_new.m`** usa `K{CL(i)}` sem
   definir `K` (a sintese devolve `K2`) e imprime variaveis cuja atribuicao
   esta comentada.

9. **`dtmjls.m` tem dimensao fixa 4** (`0.01*eye(4)*randn(4,1)`) e injeta esse
   ruido de estado sempre, independentemente de `w`. E `dx` na verdade e
   `x(k+1)`, nao uma derivada.

### Menores

10. `warning('tol violated')` sem abortar: um `K` inviavel e devolvido
    normalmente.
11. `K = Y*inv(G)` em vez de `Y/G` — mal condicionado se `G` for quase singular.
12. `epsi = 0` em todas as funcoes: as LMIs sao nao-estritas, contando com a
    folga numerica do MOSEK.
13. `W{i} = sdpvar(r)` declarado e nunca usado em `hinf_state_control_rob.m`
    (residuo de copia da versao H2): acrescenta variaveis livres inuteis ao SDP.
14. `h2_state_control_rob_lti.m` devolve a norma **H2** em uma variavel chamada
    `gammaInf`.

---

## 7. O que nao foi verificado

Honestidade sobre os limites desta documentacao:

- **Nada foi executado.** A reorganizacao foi feita sem MATLAB disponivel. O
  `sil_setup.m` nunca rodou; a documentacao da API
  (`Simulink.fileGenControl` com `'createDir'`) foi conferida contra a
  referencia da MathWorks, mas nao em execucao.
- **O interior dos `.slx` nao foi auditado.** Confirmei por busca no XML que os
  modelos referenciam `K{1}`, `K{2}` e `yout`; nao verifiquei se tambem leem
  `Lambda`, `P` ou `CL`, nem inspecionei os blocos UDP e a geracao da cadeia de
  Markov dentro do modelo.
- **`models/Guiagem_Cessna_2024_Hinf_MC.slx` foi recuperado por tamanho**, nao
  por inspecao de conteudo. Veja o item 2 da secao de cuidados do `README.md`.
- **Qual das tres copias de `Guiagem_Cessna_2024_Hinf_MC_2.slx` e a mais
  recente nao pode ser determinado.** Os mtimes de todos os arquivos sao
  identicos (foram copiados em bloco) e nao havia controle de versao. A copia
  escolhida foi a de `3. SIL-2/`, por ser a pasta cujos scripts a referenciam
  ativamente; as outras duas estao em `legacy/model_snapshots/` com o tamanho
  no nome.
- **Os valores numericos publicados nao foram reproduzidos.** Em particular,
  `main_h2_hinf_rob_new_sil1.m` tem o comentario `%% 225 min` ao lado da chamada
  de sintese: refazer esses resultados custa horas de solver.
