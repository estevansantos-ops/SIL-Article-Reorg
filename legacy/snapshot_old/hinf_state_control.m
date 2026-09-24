function [K,gamma]  =  hinf_state_control(A,B,J,C,D,xi,Lambda,IS)
epsi = 0;
tol = 1e-7;

N = size(Lambda,1);
Ma = max(IS);

i = 1;

n = size(A{i},2);               %% dimens?o do sistema
q = size(C{i},1);               %% dimens?o da entrada controlada
r = size(J{i},2);               %% dimens?o da entrada controlada
m = size(B{i},2);               %% dimens?o da entrada controlada

gamma = sdpvar(1); 

for i = 1:N
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
    LMIs = [LMIs, [Q{p}] >= eye(n)*epsi];     
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                  # LMI set 02
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                  # LMI set 03
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

for i = 1:N

    Acl = A{i}*G{IS(i)}+B{i}*Y{IS(i)};
    Ccl = C{i}*G{IS(i)}+D{i}*Y{IS(i)};
    
    M2 = [Q{i}*Lambda(i,i)+xi*(Acl+Acl') (Q{i}-xi*G{IS(i)}+Acl')' xi*Ccl' J{i}; 
          Q{i}-xi*G{IS(i)}+Acl' -G{IS(i)}-G{IS(i)}' Ccl' zeros(n,r);
          xi*Ccl Ccl -eye(q) zeros(q,r)
          J{i}' zeros(r,n) zeros(r,q) -eye(r)*gamma ];
      
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                  # LMI set 04
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
Objective = gamma;

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
     gamma = 0;
     Ac = 0;
     Bc = 0;
     Cc = 0;
else
    if  verF < -tol
       warning('tol violated') 
     
    end
        gamma = double(Objective);

        for k = 1:Ma
            G{k} = double(G{k});
            K{k} = double(Y{k})*inv(G{k});          
        end
    
end
