function [K,gammaInf]  =  h2inf_state_control_rob_lti(A,B,J2,Jinf,C2,D2,Cinf,Dinf,xi,gamma2)
epsi = 0;
tol = 1e-7;

Npol = max(size(A));
i = 1;

n = size(A{i},2);               %% dimens?o do sistema
q2 = size(C2{1},1);               %% dimens?o da entrada controlada
qinf = size(Cinf{1},1);               %% dimens?o da entrada controlada
r2 = size(J2{i},2);               %% dimens?o da entrada controlada
rinf = size(Jinf{i},2);               %% dimens?o da entrada controlada
m = size(B{i},2);               %% dimens?o da entrada controlada

gamma2; 
gammainf = sdpvar(1); 

i = 1;
P{i} = sdpvar(n);
W{i} = sdpvar(r2);
Q{i} = sdpvar(n); 

l = 1;
G{l} = sdpvar(n,n,'full');
Y{l} = sdpvar(m,n,'full');


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
p = 1;
LMIs = [LMIs, [P{p}] >= eye(n)*epsi];     
LMIs = [LMIs, [Q{p}] >= eye(n)*epsi];     

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                  # LMI set 02
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
t = 1;
% for t = 1:Npol
    M1 = [W{1} J2{t}';
          J2{t} P{1}];
    LMIs = [LMIs, M1 >= eye(size(M1))*epsi];   
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                  # LMI set 03
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
i = 1;
for t = 1:Npol
        Acl = A{t}*G{1}+B{t}*Y{1};
        Ccl = C2{t}*G{1}+D2{t}*Y{1};

        M2 = [xi*(Acl+Acl') (P{i}-xi*G{1}+Acl')' xi*Ccl'; 
              P{i}-xi*G{1}+Acl' -G{1}-G{1}' Ccl';
              xi*Ccl Ccl -eye(q2)];

        LMIs = [LMIs, M2 <= -eye(size(M2))*epsi];   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                  # LMI set 04
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
i = 1;
for k = 1:Npol
    Acl = A{k}*G{1}+B{k}*Y{1};
    Ccl = Cinf{k}*G{1}+Dinf{k}*Y{1};

    M2 = [xi*(Acl+Acl') (Q{i}-xi*G{1}+Acl')' xi*Ccl' Jinf{k}; 
          Q{i}-xi*G{1}+Acl' -G{1}-G{1}' Ccl' zeros(n,rinf);
          xi*Ccl Ccl -eye(qinf) zeros(qinf,rinf)
          Jinf{k}' zeros(rinf,n) zeros(rinf,qinf) -eye(rinf)*gammainf];

    LMIs = [LMIs, M2 <= -eye(size(M2))*epsi];   

end

aux = trace(W{p});

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

        k = 1;
            G{k} = double(G{k});
            K{k} = double(Y{k})*inv(G{k});          
    
end
