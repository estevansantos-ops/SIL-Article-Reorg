# Controle robusto H2/H-infinito de um Cessna 172 com falhas Markovianas (SIL)

Projeto de pesquisa em MATLAB/Simulink. Projeta controladores de realimentacao
de estados para a dinamica **lateral** de um Cessna 172 cujos atuadores
(aileron e rudder) sofrem falhas modeladas como uma **cadeia de Markov de tempo
continuo**, e valida o resultado em **software-in-the-loop com o X-Plane** via
UDP.

Formalmente o sistema e um MJLS (*Markov Jump Linear System*) continuo com
incerteza politopica. A sintese e feita por LMIs em YALMIP + MOSEK.

---

## Comece por aqui

```matlab
cd('<raiz do projeto>')   % o startup.m roda sozinho se o MATLAB abrir aqui
sil_setup                 % registra o path e redireciona os artefatos de build
```

Depois leia [`docs/ARQUITETURA.md`](docs/ARQUITETURA.md) — ele explica a cadeia
de execucao, o acoplamento pelo workspace base e as pegadinhas conhecidas.

Requisitos: MATLAB, Simulink, Control System Toolbox,
[YALMIP](https://yalmip.github.io/) e **MOSEK** (o solver esta fixo em
`sdpsettings('solver','mosek')` em todas as rotinas de sintese).

---

## Estrutura

| Pasta | Conteudo | No path? |
|---|---|---|
| `src/model/` | Modelo do Cessna 172: `A_lat`, `B_lat`, ganhos LQR de referencia | sim |
| `src/synthesis/` | **Sintese de controladores** (LMIs que produzem `K`) | sim |
| `src/analysis/` | Calculo de normas H2 / H-inf da malha fechada (`h2_norm`, `hinf_norm`) | sim |
| `src/simulation/` | Motor do MJLS: `dtmjls` (um passo) e `markov_chain` (sorteio do modo) | sim |
| `src/xplane/` | S-functions em C do link UDP com o X-Plane + `rtwmakecfg.m` | sim |
| `models/` | Modelos Simulink (`.slx`), um por variante de controlador | sim |
| `experiments/sil1/` | Campanha 1: projeto, Monte Carlo e pos-processamento | sim |
| `experiments/sil2/` | Campanha 2: comparacao de 5 estrategias de controle | sim |
| `data/sil1`, `data/sil2` | Dados `.mat` (praticos e intermediarios) | sim |
| `results/sil1`, `results/sil2` | Figuras `.fig` e `.eps` publicadas | sim |
| `bin/win64/` | S-functions MEX ja compiladas (rodar sem compilador C) | sim |
| `build/` | **Gerado.** Cache de simulacao e codigo gerado | sim, pelo proprio Simulink |
| `legacy/` | **Arquivo morto.** Versoes superadas, duplicatas, rascunhos | **nao** |
| `docs/` | Documentacao, incluindo os READMEs originais do autor | nao |

### Os controladores

Todas as rotinas de `src/synthesis/` tem a mesma forma: recebem o sistema por
modo de Markov, resolvem um problema de LMIs e devolvem `[K, gamma]`, onde `K`
e um *cell array* de ganhos e `gamma` e a norma **ao quadrado** (os scripts
sempre imprimem `sqrt(gamma)`).

Os sufixos sao o eixo organizador. Leia-os como uma progressao:

| Arquivo | Critério | Incerteza | Ganho resultante |
|---|---|---|---|
| `h2_state_control.m` | H2 | nenhuma | um por modo de Markov |
| `hinf_state_control.m` | H-inf | nenhuma | um por modo de Markov |
| `h2_state_control_rob.m` | H2 | politopica (`Npol` vertices) | um por modo/cluster |
| `hinf_state_control_rob.m` | H-inf | politopica | um por modo/cluster |
| `h2inf_state_control_rob.m` | **misto** H2/H-inf | politopica | um por modo/cluster |
| `h2_state_control_rob_lti.m` | H2 | politopica | **um unico**, sem Markov |
| `hinf_state_control_rob_lti.m` | H-inf | politopica | um unico, sem Markov |
| `h2inf_state_control_rob_lti.m` | misto | politopica | um unico, sem Markov |

- **`_rob`** = incerteza politopica. Os argumentos deixam de ser `A{i}` e
  passam a ser `A{i}{t}`: modo `i`, vertice `t`. As LMIs sao replicadas em
  todos os vertices compartilhando a mesma matriz de Lyapunov (estabilidade
  quadratica).
- **`_lti`** = a cadeia de Markov e removida. Sem `Lambda`, sem `mu`, sem `IS`;
  uma unica matriz de Lyapunov e **um unico ganho** valido para todos os modos.
  Serve de linha de base para mostrar o ganho do projeto Markoviano.
- **misto (`h2inf_`)** = minimiza a norma H-inf sujeita a um **orcamento** de
  norma H2 passado como entrada (`gamma2`). Varrer `gamma2` e o que gera a
  curva de trade-off (`results/sil1/trade_off_mixed.eps`).

O argumento `IS` (chamado `CL` nos scripts de projeto) e o mapa
modo-de-Markov -> indice-de-ganho. Com 6 modos e `CL = [1 1 1 2 2 2]`, os seis
modos sao atendidos por apenas dois controladores.

---

## Cadeia de execucao

Nao existe nenhuma chamada a `sim()` no projeto. O acoplamento entre etapas e
feito pelo **workspace base do MATLAB**, e a simulacao no Simulink e disparada
a mao. A cadeia da campanha 1, lado H2:

```
experiments/sil1/design/main_h2_hinf_rob_new_sil1.m
    |  deixa no workspace: A{i}{k}, B{i}{k}, K, CL, Lambda, mu, N, P, Ts
    v
experiments/sil1/montecarlo/discrete_markov_system_response_h2_rob_poly_control_input.m
    |  Monte Carlo teorico -> envelope cinza de estados e de comando
    v
models/Guiagem_Cessna_2024_H2_MC.slx        <- abrir e rodar a mao
    |  le K{1} e K{2} do workspace, grava yout; salvar como youtH2.mat
    v
experiments/sil1/postproc/test_h2.m
       desenha as trajetorias praticas em vermelho -> h2_fig_curves.eps
```

O lado H-inf e simetrico (`..._hinf_rob_poly_control_input.m` ->
`Guiagem_Cessna_2024_Hinf_MC_2.slx` -> `test_hinf_sil1.m`).

A campanha 2 usa `main_h2_hinf_rob_new_2.m` como script de pre-simulacao (ele
termina em `K = KCL`) e os scripts `test_hinf_*` de `experiments/sil2/postproc/`
para o pos-processamento.

**Consequencia pratica:** a ordem importa e nao e verificada. Os scripts de
pos-processamento usam variaveis como `Ts`, `n` e `Nsteps` sem defini-las, e
`test_hinf_norm_values.m` precisa de `CInf`, `DInf` e `K` no workspace. Rodar
um `test_*` em um MATLAB recem-aberto falha ou, pior, usa valores residuais de
outra execucao.

---

## Cuidados herdados do estado original

1. **`legacy/` esta fora do search path de proposito.** Ela contem ~25 arquivos
   `.m` com os mesmos nomes dos canonicos (por exemplo
   `legacy/snapshot_old/h2_norm.m`). Se voce adicionar `legacy/` ao path,
   o MATLAB pode resolver uma chamada para a versao antiga e o resultado
   numerico muda **sem nenhum aviso**. O `sil_setup` verifica isso e emite
   warning se detectar vazamento.

2. **`models/Guiagem_Cessna_2024_Hinf_MC.slx` foi recuperado de um backup.**
   O arquivo com esse nome no projeto original tinha 8,5 kB (um stub vazio,
   contra ~89 kB dos modelos irmaos); a unica copia integra era o
   `.slx.original` ao lado. O stub esta preservado em
   `legacy/broken/`. **Abra este modelo no Simulink e confirme que ele esta
   completo antes de confiar nele** — a recuperacao foi feita por tamanho e
   nao por inspecao do conteudo.

3. **Duas versoes divergentes de `h2_state_control_rob.m` e
   `hinf_state_control_rob.m` foram consolidadas** na versao correta (a que
   varre `for t = 1:Npol`). A versao descartada fixava o numero de vertices em
   2 e **descartava silenciosamente** os vertices 3 em diante, devolvendo um
   `gamma` otimista. Detalhes e as versoes antigas em
   [`docs/MIGRACAO.md`](docs/MIGRACAO.md) e `legacy/duplicates/`.

4. **`discrete_markov_system_response_one_round.m` esta quebrado**: faz
   `load stateS.mat`, e esse arquivo nao existe em nenhum lugar do projeto.

Outras pegadinhas conhecidas (tratamento de falha do solver, indexacao de `C`
em `hinf_norm`, `x_pract.eps` sobrescrito) estao catalogadas em
[`docs/ARQUITETURA.md`](docs/ARQUITETURA.md).

---

## Artefatos de build

`sil_setup` chama `Simulink.fileGenControl` e manda `slprj/`, os arquivos
`.slxc` e o codigo gerado para `build/`, que e ignorado pelo Git. O
redirecionamento **vale so para a sessao atual do MATLAB** — e por isso que o
setup precisa rodar sempre que o MATLAB abrir.

O `.gitignore` tem uma segunda linha de defesa (`slprj/`, `*.slxc`, `*.mexw64`)
para o caso de alguem rodar um modelo sem ter chamado o `sil_setup`.

As MEX de `bin/win64/` sao a excecao deliberada: sao artefatos compilados
versionados para que o projeto rode em uma maquina sem compilador C. Para
regenera-las, abra o bloco S-Function Builder correspondente dentro de um
`.slx` e clique em Build — e o bloco, nao o arquivo `.c`, que e a fonte de
verdade desse codigo.

---

## Historico

O projeto original vivia em duas pastas irmas, `2. SIL/` e `3. SIL-2/`, com
codigo duplicado entre elas, 235 arquivos de cache de build versionados junto
ao fonte e um snapshot manual (`2. SIL/old/`). O commit `30da51d` preserva esse
estado exato; todo arquivo pode ser rastreado com:

```bash
git log --follow -- <caminho novo>
```

O mapa completo de-para esta em [`docs/MIGRACAO.md`](docs/MIGRACAO.md).
