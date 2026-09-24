function info = sil_setup(mode)
%SIL_SETUP Configura o ambiente do projeto SIL (search path + artefatos de build).
%
%   sil_setup            configura o path e redireciona os artefatos de build
%   sil_setup('reset')   remove o path do projeto e restaura os padroes do Simulink
%   info = sil_setup(...) devolve uma struct com o que foi configurado
%
%   O que este script faz, e por que:
%
%   1) PATH. Registra apenas as pastas de codigo/dado ATIVAS. A pasta legacy/
%      e deliberadamente MANTIDA FORA do path: ela contem ~25 arquivos .m com
%      os mesmos nomes dos canonicos (ex. legacy/snapshot_old/h2_norm.m). Se
%      legacy/ entrasse no path, o MATLAB poderia resolver uma chamada para a
%      versao antiga e o resultado numerico mudaria sem nenhum aviso.
%
%   2) BUILD. Redireciona o cache de simulacao (slprj/, *.slxc) e o codigo
%      gerado para build/, via Simulink.fileGenControl. Por padrao esses
%      artefatos nascem em pwd e se misturam ao fonte -- foi exatamente isso
%      que poluiu o projeto original com 235 arquivos de cache. O ajuste vale
%      apenas para a sessao atual do MATLAB, por isso precisa rodar sempre.
%
%   Uso tipico: abra o MATLAB nesta pasta (o startup.m chama isto sozinho) ou
%   entao faca cd para a raiz do projeto e rode sil_setup.
%
%   Ver tambem: startup, Simulink.fileGenControl

if nargin < 1
    mode = 'set';
end

root = fileparts(mfilename('fullpath'));

% Pastas que entram no search path. A ordem importa: src/ vem primeiro para
% que as funcoes de biblioteca tenham precedencia sobre qualquer homonimo.
pathFolders = { ...
    fullfile('src','model')              % modelo do Cessna 172 (A_lat, B_lat, LQR)
    fullfile('src','synthesis')          % sintese de controladores (LMIs)
    fullfile('src','analysis')           % calculo de normas H2 / Hinf
    fullfile('src','simulation')         % motor do MJLS: dtmjls, markov_chain
    fullfile('src','xplane')             % S-functions do link UDP com o X-Plane
    fullfile('experiments','sil1','design')
    fullfile('experiments','sil1','montecarlo')
    fullfile('experiments','sil1','postproc')
    fullfile('experiments','sil2','design')
    fullfile('experiments','sil2','montecarlo')
    fullfile('experiments','sil2','postproc')
    fullfile('data','sil1')              % load youtH2.mat etc. resolve pelo path
    fullfile('data','sil2')
    fullfile('results','sil1')           % open('h2_mc_states_control.fig')
    fullfile('results','sil2')
    'models'                             % modelos Simulink
    fullfile('bin','win64')              % S-functions MEX ja compiladas
    };

% Pastas que NUNCA devem entrar no path, porque contem homonimos das funcoes
% canonicas e sombreariam a biblioteca (ver comentario 1 no cabecalho).
% Observacao: build/ NAO entra nesta lista. O proprio
% Simulink.fileGenControl adiciona CacheFolder e CodeGenFolder ao search path
% por design, entao build/sim-cache e build/codegen aparecem no path e isso e
% esperado -- nao ha arquivo .m algum la para causar conflito.
shadowRisk = {'legacy'};

absFolders = cellfun(@(f) fullfile(root, f), pathFolders, 'UniformOutput', false);

switch lower(mode)
    case 'reset'
        % rmpath avisa se a pasta nao estiver no path; silencia so esse aviso.
        ws = warning('off', 'MATLAB:rmpath:DirNotFound');
        for k = 1:numel(absFolders)
            if exist(absFolders{k}, 'dir')
                rmpath(absFolders{k});
            end
        end
        warning(ws);
        if sil_has_simulink()
            Simulink.fileGenControl('reset');
        end
        fprintf('[sil_setup] path do projeto removido e artefatos de build restaurados ao padrao.\n');
        info = struct('root', root, 'mode', 'reset');
        return

    case 'set'
        % segue abaixo

    otherwise
        error('sil_setup:badMode', ...
              'Modo desconhecido "%s". Use ''set'' ou ''reset''.', mode);
end

%% 1) Search path -----------------------------------------------------------
missing  = {};
added    = {};
toAdd    = {};
for k = 1:numel(absFolders)
    if exist(absFolders{k}, 'dir')
        toAdd{end+1}  = absFolders{k};                                  %#ok<AGROW>
        added{end+1}  = pathFolders{k};                                 %#ok<AGROW>
    else
        missing{end+1} = pathFolders{k};                                %#ok<AGROW>
    end
end
% Uma unica chamada, e nao addpath dentro do laco: cada addpath faz prepend,
% de modo que chamadas sucessivas inverteriam a precedencia. Passando tudo de
% uma vez, a ordem da lista acima e preservada no inicio do path.
if ~isempty(toAdd)
    addpath(toAdd{:});
end

% Trava de seguranca: garante que legacy/ nao vazou para o path.
leaked = {};
p = strsplit(path, pathsep);
p = p(~cellfun(@isempty, p));
for k = 1:numel(shadowRisk)
    base  = fullfile(root, shadowRisk{k});
    guard = [base filesep];
    % Pega tanto a pasta em si quanto qualquer subpasta dela.
    isSelf  = strcmpi(p, base);
    isChild = strncmpi(p, guard, numel(guard));
    leaked  = [leaked, p(isSelf | isChild)];                            %#ok<AGROW>
end
if ~isempty(leaked)
    warning('sil_setup:shadowOnPath', ...
        ['Estas pastas deveriam estar FORA do path e nao estao:\n  %s\n' ...
         'Elas contem homonimos das funcoes canonicas e podem alterar ' ...
         'resultados silenciosamente. Remova-as com rmpath.'], ...
        strjoin(leaked, sprintf('\n  ')));
end

%% 2) Artefatos de build ----------------------------------------------------
cacheFolder   = fullfile(root, 'build', 'sim-cache');
codeGenFolder = fullfile(root, 'build', 'codegen');
buildOk = false;
buildMsg = 'Simulink nao disponivel nesta instalacao: cache ficara em pwd.';

if sil_has_simulink()
    try
        Simulink.fileGenControl('set', ...
            'CacheFolder',   cacheFolder, ...
            'CodeGenFolder', codeGenFolder, ...
            'createDir',     true);
        buildOk  = true;
        buildMsg = 'slprj/, *.slxc e codigo gerado vao para build/.';
    catch err
        buildMsg = sprintf('falhou (%s): artefatos continuam em pwd.', err.identifier);
    end
end

%% 3) Resumo ----------------------------------------------------------------
fprintf('\n[sil_setup] raiz do projeto: %s\n', root);
fprintf('[sil_setup] path: %d pastas registradas', numel(added));
if isempty(missing)
    fprintf('\n');
else
    fprintf(' (%d ausentes: %s)\n', numel(missing), strjoin(missing, ', '));
end
fprintf('[sil_setup] fora do path de proposito: %s/\n', strjoin(shadowRisk, '/, '));
fprintf('[sil_setup] build: %s\n', buildMsg);
fprintf('[sil_setup] ponto de partida sugerido: README.md e docs/ARQUITETURA.md\n\n');

info = struct( ...
    'root',          root, ...
    'mode',          'set', ...
    'added',         {added}, ...
    'missing',       {missing}, ...
    'shadowRisk',    {shadowRisk}, ...
    'cacheFolder',   cacheFolder, ...
    'codeGenFolder', codeGenFolder, ...
    'buildRedirected', buildOk);
end

% -------------------------------------------------------------------------
function tf = sil_has_simulink()
%SIL_HAS_SIMULINK true se o Simulink estiver instalado e licenciado.
tf = ~isempty(ver('simulink')) && license('test', 'Simulink');
end
