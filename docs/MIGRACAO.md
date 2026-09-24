# Migracao: de `2. SIL/` + `3. SIL-2/` para a estrutura atual

Registro completo da reorganizacao. O objetivo aqui e que qualquer decisao
possa ser auditada ou revertida.

**Nenhuma linha de codigo foi alterada.** A reorganizacao consistiu
exclusivamente em mover, renomear e remover arquivos. Isso foi verificado com
`git diff --numstat` contra o commit baseline: todos os arquivos preexistentes
aparecem como rename puro (0 linhas adicionadas, 0 removidas).

## Ponto de partida

| | |
|---|---|
| Commit baseline | `30da51d` — estado original exato, 498 arquivos |
| Arquivos apos a migracao | 235 (+ 5 novos: `README.md`, `sil_setup.m`, `startup.m`, `.gitignore`, `.gitattributes`) |
| Removidos | 264 |

Para ver o historico de qualquer arquivo atravessando a renomeacao:

```bash
git log --follow -- src/synthesis/h2_state_control_rob.m
git show 30da51d:"2. SIL/main_h2_hinf_rob_new.m"      # conteudo original
git diff 30da51d HEAD --stat                          # resumo da migracao
```

---

## Decisoes tomadas

### D1. Biblioteca compartilhada + experimentos por campanha

As duas pastas originais eram **duas campanhas do mesmo projeto** (`2. SIL` ->
`sil1`, `3. SIL-2` -> `sil2`) com a biblioteca duplicada entre elas. A estrutura
nova separa o que e reutilizavel (`src/`) do que e especifico de cada campanha
(`experiments/sil1/`, `experiments/sil2/`), com uma unica copia de cada funcao
de biblioteca.

Isso tambem resolve uma dependencia cruzada que existia no original:
`3. SIL-2/discrete_markov_system_response_one_round.m` chama `dtmjls` e
`markov_chain`, que so existiam em `2. SIL/`. A pasta `3. SIL-2` **nao era
auto-contida** — so funcionava com as duas pastas no path.

### D2. Duplicatas byte-identicas: mantida uma copia

Sete arquivos eram byte-identicos entre as duas pastas (verificado por
SHA256). Foi mantida a copia de `2. SIL/` e removida a de `3. SIL-2/`:

`h2_norm.m`, `hinf_norm.m`, `h2_state_control.m`, `hinf_state_control.m`,
`h2inf_state_control_rob.m`, `Modelagem_Cessna_172.m`, `rtwmakecfg.m`

### D3. Duplicatas divergentes: adotada a versao generalizada

`h2_state_control_rob.m` e `hinf_state_control_rob.m` existiam nas duas pastas
com conteudos diferentes. A diferenca e pequena e importante:

```diff
+ Npol = max(size(A{1}));     % linha 7, so na versao de 3. SIL-2

- for t = 1:2                 % versao de 2. SIL
+ for t = 1:Npol              % versao de 3. SIL-2
```

A versao de `2. SIL` fixava o numero de vertices do politopo em 2. Com um
politopo de 3 ou mais vertices ela **descarta silenciosamente** os vertices
excedentes: nenhum erro e emitido, o `gamma` devolvido e otimista e o
certificado de robustez nao cobre todo o politopo.

Adotada a versao de `3. SIL-2`. Tres razoes:

1. E estritamente mais correta, e **compativel**: com `Npol == 2` os dois
   codigos produzem o mesmo resultado numerico.
2. `h2inf_state_control_rob.m` — que e byte-identico nas duas pastas — **ja
   usava `Npol`**. Ou seja `Npol` era o idioma estabelecido do projeto, e os
   dois arquivos de `2. SIL` eram os que tinham ficado para tras.
3. Os scripts de projeto ativos de `3. SIL-2` montam os vertices com
   `max(size(A{1}))`, coerentes com a versao `Npol`.

Verifiquei que nenhum script ativo chama essas funcoes com mais de 2 vertices,
portanto **nao se espera mudanca de resultado numerico**. As versoes antigas
estao preservadas em `legacy/duplicates/` com o sufixo `.sil1-Npol-fixo-2.m`
para permitir o diff lado a lado.

### D4. S-functions do X-Plane: adotada a regeneracao mais recente

Os oito arquivos `Dados_*` existiam nas duas pastas. A unica diferenca de
conteudo e o comentario de data de geracao (`2. SIL`: Jul/2024; `3. SIL-2`:
Fev/2025) mais um `#define SOURCEFILES` trivial. A **logica escrita a mao nos
`*_wrapper.c` e identica**. Adotada a regeneracao de Fev/2025.

### D5. Modelo corrompido recuperado do backup

`2. SIL/Guiagem_Cessna_2024_Hinf_MC.slx` tinha **8.560 bytes**, contra ~89.000
dos modelos irmaos: um zip valido, porem um stub praticamente vazio. O
`.slx.original` ao lado tinha 89.392 bytes e era a **unica copia integra**.

O arquivo de 8.560 bytes em `2. SIL/old/` tem hash identico, o que mostra que a
truncagem e anterior ao snapshot `old/` e nunca foi corrigida. Se alguem tivesse
apagado os `.original` por parecerem backup redundante, esse modelo estaria
perdido.

`models/Guiagem_Cessna_2024_Hinf_MC.slx` agora e a copia de 89.392 bytes. O
stub esta em `legacy/broken/`. **A recuperacao foi feita por tamanho, nao por
inspecao do conteudo** — abra o modelo no Simulink e confirme antes de confiar.

### D6. Tres copias de `Guiagem_Cessna_2024_Hinf_MC_2.slx`

Existiam em `2. SIL/` (89.925 B), `2. SIL/*.slx.original` (90.624 B),
`3. SIL-2/` (90.058 B), mais uma copia manual do Windows
(`...-FIREBIRD - Copy.slx`, 89.498 B, byte-identica a versao de `2. SIL/old/`).

**Nao e possivel determinar qual e a mais recente**: os mtimes de todos os
arquivos do projeto sao identicos (copia em bloco) e nao havia controle de
versao. Escolhida a de `3. SIL-2/` por ser a pasta cujos scripts a referenciam
ativamente (`main_h2_hinf_rob_new_2.m` termina em `K = KCL` justamente para
alimenta-la) e por ter seu proprio cache `slprj` e `.slxc` ao lado.

As outras tres estao em `legacy/model_snapshots/`, **com o tamanho no nome**,
para que a comparacao possa ser retomada no Simulink.

### D7. Renomeacoes: so onde havia colisao

Colocar as duas campanhas no mesmo search path cria conflito quando dois
arquivos diferentes tem o mesmo nome — o MATLAB resolveria para um deles
arbitrariamente. Quatro arquivos precisaram de sufixo:

| Original | Novo | Por que |
|---|---|---|
| `2. SIL/main_h2_hinf_rob_new.m` | `main_h2_hinf_rob_new_sil1.m` | 4.187 B — **script de projeto**: monta politopo de 4 vertices, gera `K` e a figura de trade-off, alimenta o Monte Carlo |
| `3. SIL-2/main_h2_hinf_rob_new.m` | `main_h2_hinf_rob_new_sil2.m` | 9.132 B — **script de comparacao**: projeta 5 estrategias (MD, cluster, MI, LTI, robust cluster) e calcula normas de pior caso. Nao deixa `K` pronto para o Simulink |
| `2. SIL/test_hinf.m` | `test_hinf_sil1.m` | 2.551 B — envelope max/min das 10 realizacoes praticas sobre a `.fig` salva |
| `3. SIL-2/test_hinf.m` | `test_hinf_sil2.m` | 1.026 B — plota os 4 estados e `u` de uma realizacao |

Os dois `teste.slx` divergentes viraram `teste.sil1.slx` e `teste.sil2.slx` em
`legacy/scratch/`.

**Todo o resto manteve o nome original.** Em particular, nenhuma funcao de
biblioteca foi renomeada — assim nenhum call site precisou ser editado. Os
nomes pouco descritivos que sobraram (`main_h2_hinf_rob_new_2.m`,
`main_h2_hinf_rob_new_3.m`) foram mantidos de proposito, para preservar a
correspondencia com as anotacoes originais do autor; o que cada um faz esta na
tabela da secao seguinte.

### D8. `legacy/` fora do search path

A pasta contem ~25 arquivos `.m` homonimos dos canonicos (o snapshot
`2. SIL/old/` era quase uma copia completa da pasta pai). Se `legacy/` entrar no
path, o MATLAB pode resolver uma chamada para a versao antiga e **o resultado
numerico muda sem aviso**. `sil_setup.m` nao a adiciona e emite warning se
detectar vazamento.

Consequencia: os scripts dentro de `legacy/` nao rodam como estao. Isso e
intencional — sao arquivo morto, nao codigo mantido.

### D9. Artefatos de build redirecionados e removidos do versionamento

235 dos 498 arquivos do projeto original eram cache de build (`slprj/`,
`*.slxc`) versionados junto ao fonte. Tres medidas:

1. `sil_setup.m` chama `Simulink.fileGenControl` e manda cache e codigo gerado
   para `build/`.
2. `.gitignore` bloqueia `build/`, `slprj/`, `*.slxc`, `*.mexw64`, autosaves e
   relatorios de geracao de codigo.
3. O cache existente foi removido da arvore (segue recuperavel no baseline).

As duas MEX de `bin/win64/` sao **excecao deliberada** no `.gitignore`: sao
artefatos compilados, mas versionados para que o projeto rode em uma maquina sem
compilador C.

### D10. `.gitattributes` adicionado

Com `core.autocrlf = true` nesta maquina, o Git avisou que iria reescrever fins
de linha em arquivos `.eps`. O `.gitattributes` desliga qualquer conversao
(`* -text`) e marca `.slx`, `.mat`, `.fig`, `.mexw64`, `.eps` e `.jpg` como
binarios, protegendo-os de corrupcao em checkouts futuros.

---

## Mapa de-para

### `src/` — biblioteca

| Novo | Origem |
|---|---|
| `src/model/Modelagem_Cessna_172.m` | `2. SIL/` (identico em `3. SIL-2/`, D2) |
| `src/model/myfunc_3.m` | `2. SIL/` |
| `src/synthesis/h2_state_control.m` | `2. SIL/` (D2) |
| `src/synthesis/hinf_state_control.m` | `2. SIL/` (D2) |
| `src/synthesis/h2inf_state_control_rob.m` | `2. SIL/` (D2) |
| `src/synthesis/h2_state_control_rob.m` | **`3. SIL-2/`** (D3) |
| `src/synthesis/hinf_state_control_rob.m` | **`3. SIL-2/`** (D3) |
| `src/synthesis/h2_state_control_rob_lti.m` | `3. SIL-2/` (so existia la) |
| `src/synthesis/hinf_state_control_rob_lti.m` | `3. SIL-2/` (so existia la) |
| `src/synthesis/h2inf_state_control_rob_lti.m` | `3. SIL-2/` (so existia la) |
| `src/analysis/h2_norm.m` | `2. SIL/` (D2) |
| `src/analysis/hinf_norm.m` | `2. SIL/` (D2) |
| `src/simulation/dtmjls.m` | `2. SIL/` |
| `src/simulation/markov_chain.m` | `2. SIL/` |
| `src/xplane/Dados_*.c`, `*_wrapper.c`, `*.tlc`, `SFB__*.mat` | **`3. SIL-2/`** (D4) |
| `src/xplane/rtwmakecfg.m` | `2. SIL/` (D2) |
| `bin/win64/Dados_*.mexw64` | **`3. SIL-2/`** (D4) |

### `models/`

| Novo | Origem | Bytes |
|---|---|---|
| `Guiagem_Cessna_2024.slx` | `2. SIL/` | 69.074 |
| `Guiagem_Cessna_2024_LQR.slx` | `2. SIL/` | 69.006 |
| `Guiagem_Cessna_2024_H2.slx` | `2. SIL/` | 68.933 |
| `Guiagem_Cessna_2024_Hinf.slx` | `2. SIL/` | 70.863 |
| `Guiagem_Cessna_2024_H2_MC.slx` | `2. SIL/` | 87.379 |
| `Guiagem_Cessna_2024_Hinf_MC.slx` | **`2. SIL/...slx.original`** (D5) | 89.392 |
| `Guiagem_Cessna_2024_Hinf_MC_2.slx` | **`3. SIL-2/`** (D6) | 90.058 |

Nomenclatura: `H2`/`Hinf`/`LQR` = criterio de projeto; `MC` = versao com
chaveamento Markoviano e injecao de falha, usada nas campanhas Monte Carlo;
`_2` = revisao 2.

### `experiments/sil1/` — campanha 1 (todos de `2. SIL/`)

| Novo | O que faz |
|---|---|
| `design/main_h2_hinf_rob_new_sil1.m` | **Etapa (1) da cadeia.** Projeto misto H2/H-inf, politopo de 4 vertices, `CL=[1 1 1 2 2 2]`, varredura `gamma2`; gera `K` e `trade_off_mixed.eps` |
| `montecarlo/discrete_markov_system_response_h2_rob_poly_control_input.m` | **Etapa (2) da cadeia**, lado H2 |
| `montecarlo/discrete_markov_system_response_hinf_rob_poly_control_input.m` | idem, lado H-inf (o mais novo da familia) |
| `montecarlo/` (outros 8 `discrete_markov_*`) | historico evolutivo da familia — ver `ARQUITETURA.md`, secao 4 |
| `montecarlo/teste_markov_chain.m` | valida a discretizacao `P = I + Lambda*Ts` |
| `montecarlo/mean_var.m` | estatistica da condicao inicial a partir de `y0.mat` |
| `postproc/test_h2.m` | envelope pratico em vermelho sobre `h2_mc_states_control.fig` -> `h2_fig_curves.eps` |
| `postproc/test_hinf_sil1.m` | idem, lado H-inf -> `hinf_fig_curves.eps` |
| `postproc/test_hinf_2.m` | variante de diagnostico, uma realizacao por vez |
| `postproc/main_h_infty.m` | norma H-inf **empirica** de uma realizacao pratica |
| `postproc/h_infty_practical.m` | fragmento que plota o estado 3 sobre uma figura ja aberta |

### `experiments/sil2/` — campanha 2 (todos de `3. SIL-2/`)

| Novo | O que faz |
|---|---|
| `design/main_h2_hinf_rob_new_sil2.m` | compara 5 estrategias (MD, cluster, MI, LTI, robust cluster), 2 vertices; produz a tabela de normas. **Nao deixa `K` pronto** |
| `design/main_h2_hinf_rob_new_2.m` | **script de pre-simulacao**: mesma comparacao com 4 vertices e pesos assimetricos; carrega `thZ.mat` e termina em `K = KCL` |
| `design/main_h2_hinf_rob_new_3.m` | igual ao `_2`, mudando so `JInf{i}{k} = B_lat` (disturbio nas duas entradas) |
| `design/main_h2_rob_new.m` | versao so-H2 da comparacao |
| `design/main_hinf_rob_new.m` | versao so-H-inf da comparacao |
| `montecarlo/discrete_markov_system_response_one_round.m` | `MC = 1`, uma realizacao com as transicoes marcadas. **Quebrado**: `load stateS.mat`, arquivo inexistente |
| `postproc/test_hinf_sil2.m` | 4 estados + `u` de uma realizacao |
| `postproc/test_hinf_control.m` | compara `u` vs `uA` das 3 estrategias -> `control_pract.eps` |
| `postproc/test_hinf_control_2.m` | versao reduzida, so `youtdet` |
| `postproc/test_hinf_norm_values.m` | norma H-inf empirica das 3 estrategias. **Maior acoplamento do projeto** |
| `postproc/test_hinf_states.m` | figura 2x3 com `x2` e `x4` |
| `postproc/test_hinf_states_2.m` | figura 1x2 sobrepondo as 3 estrategias -> `x_pract.eps` |
| `postproc/test_hinf_states_3.m` | igual ao `_2` com `x1`/`x3`. **Sobrescreve `x_pract.eps`** e mantem rotulos errados |

### `data/`

`data/sil1/` (de `2. SIL/`): `youtH2`, `youtHinf`, `y0`, `stateR`,
`t_h2`/`y_h2`/`u_h2`/`th_h2`, `t_hinfty`/`y_hinfty`/`u_hinfty`/`w_hinfty`/`th_hinfty`,
`yH2`, `yHinf`, `gamma2`, `gammaInf`, `m_est_2`.

`data/sil2/` (de `3. SIL-2/`): `thZ`, `thS`, `youtCL`, `youtdet`, `youtLTI`.

Classificacao dos principais:

| Arquivo | Status |
|---|---|
| `youtH2`, `youtHinf`, `youtCL`, `youtdet`, `youtLTI` | **necessarios** — dados praticos do SIL, nenhum script os grava (vieram do `.slx` + `save` manual) |
| `y0`, `thZ`, `stateR` | **necessarios** — dados praticos / realizacao fixa da cadeia |
| `SFB__*.mat` | **necessarios** para o build (lidos por `rtwmakecfg.m`); ficam em `src/xplane/` |
| `t_hinfty`, `y_hinfty`, `u_hinfty`, `w_hinfty`, `th_hinfty` | intermediarios, ainda lidos por `discrete_markov_system_response.m` |
| `t_h2`, `y_h2`, `u_h2`, `th_h2` | intermediarios orfaos — gravados so em linhas comentadas |
| `yH2`, `yHinf` | orfaos — substituidos por `youtH2`/`youtHinf` |
| `gamma2`, `gammaInf` | orfaos — resultado da varredura de LMIs salvo a mao (horas de solver) |
| `m_est_2` | orfao — modelo identificado por `greyest` |
| `thS` | orfao |

Os `.mat` de dados praticos **nao sao reproduziveis sem o hardware-in-the-loop**
com o X-Plane. Sao os arquivos mais insubstituiveis do projeto.

### `results/`

`results/sil1/`: `h2_mc*.fig` (4), `hinf_mc*.fig` (3), `untitled.fig`,
`h2_fig_*.eps`, `hinf_fig_*.eps`, `hfinty_fig_*.eps`, `trade_off_mixed.eps`.

`results/sil2/`: `fig1..3_control.fig`, `control_pract.eps`, `x_pract.eps`.

Os `.fig` nao sao decorativos: `test_h2.m` e `test_hinf_sil1.m` fazem
`open('h2_mc_states_control.fig')` e desenham as trajetorias praticas **em cima**
da figura teorica. Apagar esses `.fig` quebra o pos-processamento.

### `legacy/` — arquivo morto, fora do path

| Pasta | Conteudo |
|---|---|
| `snapshot_old/` (98 arq.) | a antiga `2. SIL/old/`, sem o `slprj`. Quase tudo e duplicata ou versao anterior da pasta pai; o conteudo **genuinamente unico** sao 6 `.fig`: `trade_off_mixed.fig` (o unico `.fig` editavel da curva de trade-off), `h2_trajectories[_theoretical].fig`, `hinfty_trajectories[_theoretical].fig`, `hinfty_mc.fig` |
| `superseded/` (8 arq.) | scripts de projeto superados: `main.m`, `main_h2_mc.m`, `main_hinfty_mc.m` (sem politopo, pre-robustez), `main_h2_rob.m`, `main_hinfty_mc_rob.m` (criterio unico), `main_h2_hinf_rob.m` (2 vertices, substituido), `main_lqr_test.m`, `testes_main_h2_hinf_rob_new.m` (sandbox que nao roda) |
| `identification/` (4 arq.) | fase de identificacao grey-box: `main_aileron.m`, `main_ident_impulse.m`, `main_ident_test.m`, `myfunc_5.m` (sem nenhuma referencia no projeto, e depende de um `m_est.mat` que nao existe) |
| `scratch/` (9 arq.) | rascunhos: `aux_script.m`, `Untitled3.m`, `eig_test.m`, `samp.slx`, `teste.sil1.slx`, `teste.sil2.slx`, e o trio `markov.c`/`markov.mexw64`/`markov` (demo `simomex.c` da MathWorks, **sem relacao com a cadeia de Markov**) |
| `duplicates/` (2 arq.) | as versoes antigas de `h2_state_control_rob.m` e `hinf_state_control_rob.m` (D3) |
| `broken/` (1 arq.) | o `Guiagem_Cessna_2024_Hinf_MC.slx` truncado de 8.560 B (D5) |
| `model_snapshots/` (3 arq.) | as outras copias de `Guiagem_Cessna_2024_Hinf_MC_2.slx`, com o tamanho no nome (D6) |

---

## Removidos

Todos recuperaveis com `git show 30da51d:"<caminho original>"`.

| Quantos | O que | Por que |
|---|---|---|
| 235 | `slprj/` das tres pastas | cache de simulacao, regenerado automaticamente |
| 12 | `*.slxc` | cache do Simulink |
| 7 | `.m` de `3. SIL-2/` | byte-identicos aos canonicos (D2) |
| 10 | `Dados_*` e `SFB__*` de `2. SIL/` | regeneracao anterior, difere so no timestamp (D4) |

Total: 264.

---

## Verificacoes feitas

- **Nenhuma mudanca de conteudo**: `git diff --cached -M --numstat` contra o
  baseline mostra 0/0 para todo arquivo preexistente.
- **Nenhuma colisao de nome** entre as pastas que entram no search path
  (`src/`, `experiments/`, `data/`, `results/`, `models/`, `bin/`).
- **Posicionamento das versoes canonicas** conferido comparando SHAs de blob do
  Git contra o baseline, arquivo por arquivo, para os 13 casos em que havia
  escolha entre duas origens.
- **Duplicatas confirmadas identicas** por SHA256 antes de qualquer remocao.
- **Regras do `.gitignore`** testadas com `git check-ignore -v`, incluindo as
  excecoes (`bin/win64/*.mexw64` e `build/.gitkeep` **nao** sao ignorados).

## Nao verificado

- **Nada foi executado**: nao havia MATLAB disponivel. `sil_setup.m` nunca
  rodou; a chamada a `Simulink.fileGenControl` foi escrita contra a documentacao
  da MathWorks, nao contra uma execucao real.
- A integridade interna dos `.slx`, em especial o modelo recuperado em D5.
- Qual copia de `Guiagem_Cessna_2024_Hinf_MC_2.slx` e de fato a mais recente (D6).

## Primeiro teste recomendado

```matlab
cd('<raiz do projeto>')
sil_setup                              % deve listar 17 pastas e confirmar o redirect
which h2_state_control_rob             % deve apontar para src/synthesis/
which -all discrete_markov_system_response   % deve devolver UM caminho so
run('experiments/sil1/design/main_h2_hinf_rob_new_sil1.m')
```

Depois confira que `build/` recebeu o `slprj` ao abrir e rodar um modelo, e que
nada de novo apareceu na raiz do projeto.
