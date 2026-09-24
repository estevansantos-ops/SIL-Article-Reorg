clc 

clear w

Ts = 0.01;

P = eye(6) + Lambda*Ts;

for i = 1:N
   [Aclds{i},Jclds{i}] = c2d(Acls{i},Jcls{i},Ts); 
end

w_amp = 0.1;

tic
MC = 100;                                                                  %% number of Monte Carlo Realizations
Ns = N;
Tf = 8;
Nsteps = Tf/Ts+1;
n = 4;
q = 6;
rng('shuffle') 


for i = 1:MC

    state = zeros(1,Nsteps + 1);                                              %% c?lcula o modo inicial
     seed = rand(1);
    for j = 1 : Ns 
             pi_aux = [0 cumsum(mu)];
            if seed > pi_aux(j) && seed <= pi_aux(j+1)
               state(1) = j;
            end        
    end

    x =  zeros(n,Nsteps + 1);
    z = zeros(q,Nsteps);
    
    x(:,1) = zeros(n,1);
    

    for k = 1:Nsteps
        if k < 2.5/Ts+1
             w(1,k) = w_amp;
        else
            w(1,k) = 0;
        end


        [x(:,k+1),z(:,k)]  = dtmjls(x(:,k),w(:,k),Aclds,Jclds,Ccls,state(k));                             %% dtmjls        

        
        [state(k+1)]  = markov_chain(rand(1),P,state(k));                                                  %% next mode     
    end
    xS{i} = x;                                                              %%trajet?ria dos estados na i-?sima realiza??o
    wS{i} = w;                                                              %%ru?do branco 
    zS{i} = z;                                                             %% sa?da ponderada do sistema na i-?sima realiza??o
    stateS{i} = state;
end


% average curves
for k = 1:Nsteps
    xAux = zeros(4,1);
    zAux = 0;
    for i = 1:MC
       xAux = xAux + xS{i}(:,k);
       zAux = zAux + zS{i}(:,k)'*zS{i}(:,k);
   end
   xAvg(:,k) = xAux/MC;
   zAvg(:,k) = zAux/MC;
end

%% max and min
for j = 1:n
    for k = 1:Nsteps
        xMax(j,k) = -1e7;
        xMin(j,k) = 1e7;
        for i = 1:MC
           xMax(j,k) = max(xMax(j,k),xS{i}(j,k));
           xMin(j,k) = min(xMin(j,k),xS{i}(j,k));
        end
    end
end


sqrt(sum(zAvg)/(w*w'))


