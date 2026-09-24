function [K,gammaInf]  =  h2inf_state_control_rob(A,B,J2,Jinf,C2,D2,Cinf,Dinf,xi,Lambda,mu,IS,gamma2)
epsi = 0;
tol = 1e-7;

N = size(Lambda,1);
Ma = max(IS);
Npol = max(size(A{1}));
i = 1;

n = size(A{i}{1},2);               %% dimens?o do sistema
q2 = size(C2{i},1);               %% dimens?o da entrada controlada
qinf = size(Cinf{i},1);               %% dimens?o da entrada controlada
r2 = size(J2{i}{1},2);               %% dimens?o da entrada controlada
rinf = size(Jinf{i}{1},2);               %% dimens?o da entrada controlada
m = size(B{i}{1},2);               %% dimens?o da entrada controlada

gamma2; 
gammainf = sdpvar(1); 

for i = 1:N
    P{i} = sdpvar(n);
    W{i} = sdpvar(r2);
    Q{i} = sdpvar(n); 
end

for l = 1:Ma
    G{l} = sdpvar(n,n,'full');
    Y{l} = sdpvar(m,n,'full');
end

% F{2} = zeros(4,1); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                           LMIs
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LMIs = lmi([]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                  # LMI Set 01
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for p = 1:N
    LMIs = [LMIs, [P{p}] >= eye(n)*epsi];     
    LMIs = [LMIs, [Q{p}] >= eye(n)*epsi];     
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                  # LMI set 02
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

for t = 1:Npol
    for i = 1:N       
        M1 = [W{i} J2{i}{t}';
              J2{i}{t} P{i}];
        LMIs = [LMIs, M1 >= eye(size(M1))*epsi];   
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                  # LMI set 03
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

for t = 1:Npol
    for i = 1:N

        Acl = A{i}{t}*G{IS(i)}+B{i}{t}*Y{IS(i)};
        Ccl = C2{i}*G{IS(i)}+D2{i}*Y{IS(i)};

        M2 = [P{i}*Lambda(i,i)+xi*(Acl+Acl') (P{i}-xi*G{IS(i)}+Acl')' xi*Ccl'; 
              P{i}-xi*G{IS(i)}+Acl' -G{IS(i)}-G{IS(i)}' Ccl';
              xi*Ccl Ccl -eye(q2)];

        for j = 1:N
            if j ~= i
                nAux = size(M2,1);
                Nmat = [P{i}*sqrt(Lambda(i,j)) zeros(n,nAux-n)];
                Mmat = -P{j};
                M2 = [M2 Nmat';Nmat Mmat];
            end
        end

        LMIs = [LMIs, M2 <= -eye(size(M2))*epsi];   
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                  # LMI set 04
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
for k = 1:Npol
    for i = 1:N

        Acl = A{i}{k}*G{IS(i)}+B{i}{k}*Y{IS(i)};
        Ccl = Cinf{i}*G{IS(i)}+Dinf{i}*Y{IS(i)};

        M2 = [Q{i}*Lambda(i,i)+xi*(Acl+Acl') (Q{i}-xi*G{IS(i)}+Acl')' xi*Ccl' Jinf{i}{k}; 
              Q{i}-xi*G{IS(i)}+Acl' -G{IS(i)}-G{IS(i)}' Ccl' zeros(n,rinf);
              xi*Ccl Ccl -eye(qinf) zeros(qinf,rinf)
              Jinf{i}{k}' zeros(rinf,n) zeros(rinf,qinf) -eye(rinf)*gammainf];

        for j = 1:N
            if j ~= i
                nAux = size(M2,1);
                Nmat = [Q{i}*sqrt(Lambda(i,j)) zeros(n,nAux-n)];
                Mmat = -Q{j};
                M2 = [M2 Nmat';Nmat Mmat];
            end
        end

        LMIs = [LMIs, M2 <= -eye(size(M2))*epsi];   
    end
end

aux = 0;
for p = 1:N
    
    aux = aux + mu(p)*trace(W{p});
end

LMIs = [LMIs, aux <= gamma2];
    
Objective = gammainf;

% Set some options for YALMIP and solver
options = sdpsettings('verbose',0,'solver','mosek');
% options = sdpsettings('verbose',1,'solver', 'sedumi', 'sedumi.eps', 1e-11, ...
%                 'sedumi.cg.qprec', 1, 'sedumi.cg.maxiter', 49, ...
%                 'sedumi.stepdif', 2);

% Solve the problem
sol = optimize(LMIs,Objective,options);
[verP,verD] = check(LMIs);
verF = min(verP);
% Analyze error flags
if (sol.problem == 1)||(sol.problem == -1)
     gamma2 = 0;
     Ac = 0;
     Bc = 0;
     Cc = 0;
else
    if  verF < -tol
       warning('tol violated') 
     
    end
        gammaInf = double(Objective);

        for k = 1:Ma
            G{k} = double(G{k});
            K{k} = double(Y{k})*inv(G{k});          
        end
    
end
