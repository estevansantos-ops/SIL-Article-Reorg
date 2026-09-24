function [K,gammaInf]  =  hinf_state_control_rob_lti(A,B,Jinf,Cinf,Dinf,xi)
epsi = 0;
tol = 1e-7;

Npol = max(size(A));
i = 1;

n = size(A{i},2);               %% dimens?o do sistema
qinf = size(Cinf{1},1);               %% dimens?o da entrada controlada
rinf = size(Jinf{i},2);               %% dimens?o da entrada controlada
m = size(B{i},2);               %% dimens?o da entrada controlada

gammainf = sdpvar(1); 

i = 1;
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
LMIs = [LMIs, [Q{p}] >= eye(n)*epsi];     

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
