clc 

tic
Ts = 0.05;
MC = 1000;                                                                  %% number of Monte Carlo Realizations
Ns = N;
Tf = 8;
Nsteps = Tf/Ts+1;
n = 4;
q = 6;


Np = 20;
w_amp = 0.1;

polyt = linspace(0,1,Np);


for t = 1:Np
    
    Aaux = A{1}{1}*polyt(t) + A{1}{2}*(1-polyt(t));
    Jaux = JInf{1}{1}*polyt(t) + JInf{1}{2}*(1-polyt(t));
   
    
    for i = 1:N
       Baux = B{i}{1}*polyt(t) + B{i}{2}*(1-polyt(t));
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

%         x(:,1) = zeros(n,1);
        x(:,1) = y(:,1);


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
            if t == 1
                xMax(j,k) = -1e7;
                xMin(j,k) = 1e7;
            end
            for i = 1:MC
               xMax(j,k) = max(xMax(j,k),xS{i}(j,k));
               xMin(j,k) = min(xMin(j,k),xS{i}(j,k));
            end
        end
    end

t    
end





iinit = min(find(yout(:,7) ~= 0))-1;
iend = min(find(tout(:)*5>=tout(iinit)*5+Tf));
t = tout(iinit:iend)*5;
t = t-min(t);
Ts = t(2)-t(1);
y = yout(iinit:iend,1:4)';
u = yout(iinit:iend,5:6)';
wr = yout(iinit:iend,7)';
Z = yout(iinit:iend,8)';


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
    set(0, 'FixedWidthFontName', 'Courier New');
    curve1 = xMax(i,:);
    curve2 = xMin(i,:);
    aux = tim;
    aux2 = [aux,fliplr(aux)];
    inBetween = [curve1, fliplr(curve2)];
    fill(aux2,inBetween,[0.8 0.8 0.8],'EdgeColor',[1 1 1]);
    xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)
    hold on
    plot(t,y(i,:),'Color',[0.3 0.3 0.3],'LineWidth',2) 
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
     xlim([0 6])
end




% 
% t_hinfty = t;
% y_hinfty = y;
% u_hinfty = u;
% w_hinfty = wr;
% th_hinfty = th;
% 
% save t_hinfty.mat t_hinfty
% save y_hinfty.mat y_hinfty
% save u_hinfty.mat u_hinfty
% save w_hinfty.mat w_hinfty
% save th_hinfty.mat th_hinfty

print('hinf_fig_curves','-depsc')


figure(5)
clear th
for i = 1:length(Z)
   th(i) = 1*(Z(i)==1||Z(i)==2||Z(i)==3) +  2*(Z(i)==4||Z(i)==5) + 3*(Z(i)==6);
end



auxz2 = 0;
auxW = 0;
for k = 1:length(t)
    cl = 1*(th(k) == 1) + 2*(th(k)  ~= 1);
    zAux = (CInf{1}+DInf{1}*K{cl})*y(:,k);
    auxz2 = auxz2 + zAux'*zAux;
    auxW = auxW + wr(:,k)'*wr(:,k);
end


sqrt(auxz2/auxW)


 set(0, 'FixedWidthFontName', 'Courier New');
set(gcf, 'PaperPositionMode', 'auto')
set(gca, 'Units','normalized','Position',[0.2 0.15 0.70 0.75]);
FS = 12;
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontUnits','normalized','FontSize',0.1)

 stairs(t,th,'LineWidth',2) 
 xlim([0 6])
ylabel('\sffamily{$$\theta(t)$$}','Interpreter','latex','FontSize',FS) 
xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)

print('hinf_fig_th','-depsc')


