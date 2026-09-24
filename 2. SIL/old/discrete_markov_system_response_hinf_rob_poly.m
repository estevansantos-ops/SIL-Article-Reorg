clc 

tic
Ts = 0.05;
MC = 200;                                                                  %% number of Monte Carlo Realizations
Ns = N;
Tf = 8;
Nsteps = Tf/Ts+1;
n = 4;
q = 6;


Np = 5;
w_amp = 0.1;

polyt1 = linspace(0,1,Np);


% for t1 = 1:Np
%     for t2 = 1:Np
%         lim2 = 1 - polyt1(t1);        
%         polyt2 = linspace(0,lim2,Np);        
%         for t3 = 1:Np
%             lim3 = 1 - polyt2(t2)- polyt1(t1);        
%             polyt3 = linspace(0,lim3,Np);            
%             a(1) = polyt1(t1);
%             a(2) = polyt2(t2);
%             a(3) = polyt3(t3);
%             a(4) = 1 - a(1) - a(2) - a(3)
%             sum(a)
%         end
%     end
% end
% 

xMax = -1e7*ones(4,Nsteps);
xMin = 1e7*ones(4,Nsteps);

flag = 1;
for t1 = 1:Np
    for t2 = 1:Np
        lim2 = 1 - polyt1(t1);        
        polyt2 = linspace(0,lim2,Np);        
        for t3 = 1:Np
            lim3 = 1 - polyt2(t2)- polyt1(t1);        
            polyt3 = linspace(0,lim3,Np);            
            a(1) = polyt1(t1);
            a(2) = polyt2(t2);
            a(3) = polyt3(t3);
            a(4) = 1 - a(1) - a(2) - a(3);

    
            Aaux = A{1}{1}*a(1) + A{1}{2}*a(2) +   A{1}{3}*a(3) +  A{1}{4}*a(4);
            Jaux = JInf{1}{1}*a(1) + JInf{1}{2}*a(2) +   JInf{1}{3}*a(3) +  JInf{1}{4}*a(4);


            for i = 1:N
               Baux = B{i}{1}*a(1) + B{i}{2}*a(2) +   B{i}{3}*a(3) +  B{i}{4}*a(4);
               Acls{i} = Aaux+Baux*K{CL(i)};
               Ccls{i} = CInf{i}+DInf{i}*K{CL(i)};
               Jcls{i} = Jaux;
            end

            for i = 1:N
                [Aclds{i},Jclds{i}] = c2d(Acls{i},Jcls{i},Ts);    
            end
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

                x(:,1) = zeros(4,1);


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


            %% max and min
            for j = 1:n
                for k = 1:Nsteps
                    for i = 1:MC
                       xMax(j,k) = max(xMax(j,k),xS{i}(j,k));
                       xMin(j,k) = min(xMin(j,k),xS{i}(j,k));
                    end
                end
            end
            flag = flag + 1
        
        end
    end
end


xMaxThe = xMax;
xMinThe = xMin;



close all

tim = 0:Nsteps-1;
tim = tim * Ts;

set(0, 'FixedWidthFontName', 'Courier New');
set(gcf, 'PaperPositionMode', 'auto')
set(gca, 'Units','normalized','Position',[0.2 0.15 0.70 0.75]);
FS = 12;



for i = 1:n
%     figure(i)
    subplot(2,2,i)
    hold on
    set(0, 'FixedWidthFontName', 'Courier New');
    curve1 = xMaxThe(i,:);
    curve2 = xMinThe(i,:);
    aux = tim;
    aux2 = [aux,fliplr(aux)];
    inBetween = [curve1, fliplr(curve2)];
    fill(aux2,inBetween,[0.8 0.8 0.8],'EdgeColor',[1 1 1]);
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

% print('h2_fig_curves','-depsc')
