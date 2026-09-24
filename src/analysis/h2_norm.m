function [gamma]  =  h2_norm(A,J,C,mu,Nu,IS)
epsi = 0;
tol = 1e-7;

n = size(A{1},2);               %% dimens?o do sistema
r = size(J{1},2);               %% dimens?o da entrada controlada
q =  size(C{1},1);               %% dimens?o da entrada controlada


if isempty(IS)
    N = size(Nu,1);
    IS = 1:1:N;
else
    N = length(IS);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%      P1> 0; PN1> 0; X> 0; M > 0; Z2 > 0
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gamma = sdpvar(1); 
for i = 1:N
    P{IS(i)} = sdpvar(n);   
end


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
for i = 1:N
    LMIs = [LMIs, P{IS(i)} >= eye(size(P{IS(i)},1))*epsi];         
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                  # LMI set 02
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

for i = 1:N   
    AUX = zeros(n,n);
    
    for j = 1:N
       AUX = AUX + Nu(IS(i),IS(j))*P{IS(j)}; 
    end
   
    LMI2{IS(i)} = AUX+P{IS(i)}*A{IS(i)}+(P{IS(i)}*A{IS(i)})'+C{IS(i)}'*C{IS(i)} ;
    
    LMIs = [LMIs, LMI2{IS(i)} <= -eye(size(LMI2{IS(i)},1))*epsi]; 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%                  # stable LMI Set 
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
Objective = 0;

for i = 1:N
   Objective = Objective + mu(IS(i))*trace(J{IS(i)}'*P{IS(i)}*J{IS(i)}); 
end

% Set some options for YALMIP and solver
% options = sdpsettings('verbose',0,'solver','sedumi');
% options = sdpsettings('verbose',0,'solver','sedumi','sedumi.eps',1e-8,'sedumi.cg.qprec', 1, 'sedumi.cg.maxiter', 49,'sedumi.stepdif', 2); %% ,
options = sdpsettings('verbose',0,'solver','mosek');
options.mosek.MSK_DPAR_BASIS_TOL_S = 1e-9;
options.mosek.MSK_DPAR_BASIS_TOL_X = 1e-9;
% Solve the problem
sol = optimize(LMIs,Objective,options);
[verP,verD] = check(LMIs);
verF = min(verP);
% Analyze error flags
if (sol.problem == 1)||(sol.problem == -1)
     gamma = 0;
else
    if  verF < -tol
        warning('Violated Tolerance')
     
    end
             gamma = double(Objective);

end
