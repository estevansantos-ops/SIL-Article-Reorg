clc 

tic
Ts = 0.05;
MC = 1;                                                                  %% number of Monte Carlo Realizations
Ns = N; 
Tf = 8;
Nsteps = Tf/Ts+1;
n = 4;
q = 6;

P = eye(6) + Lambda*Ts;

Np = 5;
w_amp = 0.1;
for i = 1:N
    [Aclds{i},Jclds{i}] = c2d(Acls{i},JInfcl{i},Ts);    
end
rng('shuffle') 

flag = 2;
 %% salvar essa realização de theta
 
 if flag == 2
    load stateS.mat
    state = stateS;
    clear stateS
 end

for i = 1:MC

    if flag == 1
        state = zeros(1,Nsteps + 1);                                              %% c?lcula o modo inicial
         seed = rand(1);
        for j = 1 : Ns 
                 pi_aux = [0 cumsum(mu)];
                if seed > pi_aux(j) && seed <= pi_aux(j+1)
                   state(1) = j;
                end        
        end
    end

    x =  zeros(n,Nsteps + 1);
    z = zeros(q,Nsteps);

    x(:,1) = zeros(4,1);


    for k = 1:Nsteps
        if (k-1)*Ts < 2.5
             w(1,k) = -w_amp;
        else
            if (k-1)*Ts < 5
                w(1,k) = -w_amp;
            else
              w(1,k) = 0;
            end
        end


        [x(:,k+1),z(:,k)]  = dtmjls(x(:,k),w(:,k),Aclds,Jclds,CclInf,state(k));                             %% dtmjls        
        u(:,k) = K{CL(state(k))}*x(:,k);

       
        th(k) = 1*(state(k)==1||state(k)==2||state(k)==3) +  2*(state(k)==4||state(k)==5) + 3*(state(k)==6);

        uA(:,k) = u(:,k);
        if th(k) == 2
            uA(:,k) = [2 0;0 1]*u(:,k);
        elseif th(k) == 3
            uA(:,k) = [2 0;0 -1]*u(:,k);    
        end
        if flag == 1
            [state(k+1)]  = markov_chain(rand(1),P,state(k));                                                  %% next mode     
        end
    end
    thS{i} = th;
    xS{i} = x;                                                              %%trajet?ria dos estados na i-?sima realiza??o
    wS{i} = w;                                                              %%ru?do branco 
    zS{i} = z;                                                             %% sa?da ponderada do sistema na i-?sima realiza??o
    stateS{i} = state;
    uS{i} = u;
    uAS{i} = uA;
%     uAS{i} = u;
end


close all

tim = 0:Nsteps-1;
tim = tim * Ts;

set(0, 'FixedWidthFontName', 'Courier New');
set(gcf, 'PaperPositionMode', 'auto')
set(gca, 'Units','normalized','Position',[0.2 0.15 0.70 0.75]);
FS = 12;


 figure(1)
subplot(1,3,1);
 hold on
set(0, 'FixedWidthFontName', 'Courier New');

hold on
plot(tim,th,'k','LineWidth',2)
xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)
ylabel('\sffamily{$$\theta(t)$$}','Interpreter','latex','FontSize',FS)    
xlim([0 8])

subplot(1,3,2);
hold on
set(0, 'FixedWidthFontName', 'Courier New');
plot(tim,u(1,:),'k','LineWidth',2)
hold on
plot(tim,uA(1,:),'LineWidth',2,'Color',[0.8500 0.3250 0.0980])
xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)
ylabel('\sffamily{$$u_1(t),\upsilon_1(t)$$}','Interpreter','latex','FontSize',FS)    
legend('u_1(t)','\upsilon_1(t)')
xlim([0 8])

subplot(1,3,3);
hold on
set(0, 'FixedWidthFontName', 'Courier New');
plot(tim,u(2,:),'k','LineWidth',2)
hold on
plot(tim,uA(2,:),'LineWidth',2,'Color',[0.8500 0.3250 0.0980])
xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)
ylabel('\sffamily{$$u_2(t),\upsilon_2(t)$$}','Interpreter','latex','FontSize',FS)    
xlim([0 8])
legend('u_2(t)','\upsilon_2(t)')

 print('one_round_control','-depsc')



figure(2)
for i = 1:n
%     figure(i)
    subplot(2,2,i)
    hold on
    set(0, 'FixedWidthFontName', 'Courier New');
    plot(tim,x(i,1:end-1),'k','LineWidth',2)
    xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)
    
    switch i
    case 1
        ylabel('\sffamily{$$x_1(t)$$}','Interpreter','latex','FontSize',FS)
    case 2
        ylabel('\sffamily{$$x_2(t)$$}','Interpreter','latex','FontSize',FS)
    case 3
        ylabel('\sffamily{$$x_3(t)$$}','Interpreter','latex','FontSize',FS)
    case 4
        ylabel('\sffamily{$$x_4(t)$$}','Interpreter','latex','FontSize',FS)
        
    otherwise
        disp('other value')
    end 
     xlim([0 8])
end


 print('one_round_control_states','-depsc')
 
 v = B{1}*uA;
 
 
 for i = 1:length(v)
    vA(i) = norm(v(:,i))^2; 
 end
 
 


