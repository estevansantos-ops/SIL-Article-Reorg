clc 

clear w

Ts = 0.05;

for i = 1:N
   [Aclds{i},Jclds{i}] = c2d(Acls{i},Jcls{i},Ts); 
   
end

w_amp = 0.1;

tic
MC = 1000;                                                                  %% number of Monte Carlo Realizations
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

% %% std
% for j = 1:n
%     for k = 1:Nsteps
%         for i = 1:MC
%            aux(i) =  xS{i}(j,k);
%         end
%         xMax(j,k) = xAvg(j,k)+var(aux);
%         xMin(j,k) = xAvg(j,k)-var(aux);
%     end
% end

close all



tim = 0:Nsteps-1;
tim = tim * Ts;
% 
% iinit = min(find(yout(:,7) ~= 0))-1;
% iend = find(tout(:)*5==tout(iinit)*5+Tf);
% t = tout(iinit:iend)*5;
% t = t-min(t);
% Ts = t(2)-t(1);
% y = yout(iinit:iend,1:4)';
% u = yout(iinit:iend,5:6)';
% wr = yout(iinit:iend,7)';
% Z = yout(iinit:iend,8)';

% 
% t_hinfty = t;
% y_hinfty = y;
% u_hinfty = u;
% wr_hinfty = wr;
% th_hinfty = th;

% save t_hinfty.mat t_hinfty
% save y_hinfty.mat y_hinfty
% save u_hinfty.mat u_hinfty
% save w_hinfty.mat w_hinfty
% save th_hinfty.mat th_hinfty

% figure(5)
% clear th
% for i = 1:length(Z)
%    th(i) = 1*(Z(i)==1||Z(i)==2||Z(i)==3) +  2*(Z(i)==4||Z(i)==5) + 3*(Z(i)==6);
% end


load t_hinfty.mat
load y_hinfty.mat
load u_hinfty.mat
load w_hinfty.mat
load th_hinfty.mat

t = t_hinfty;
y = y_hinfty;
u = u_hinfty;
wr = w_hinfty;
th = th_hinfty;





 set(0, 'FixedWidthFontName', 'Courier New');
set(gcf, 'PaperPositionMode', 'auto')
set(gca, 'Units','normalized','Position',[0.2 0.15 0.70 0.75]);
FS = 12;



fig=gcf;
set(findall(fig,'-property','FontSize'),'FontUnits','normalized','FontSize',0.1)

 stairs(t,th,'LineWidth',2) 
 xlim([0 8])
ylabel('\sffamily{$$\theta(t)$$}','Interpreter','latex','FontSize',FS) 
xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)

print('hfinty_fig_th','-depsc')

FS = 12;

clear yaux

Nmavg = 1;%% moving average
yaux(1,:) = movmean(y(1,1:end),Nmavg);
yaux(2,:) = movmean(y(2,1:end),Nmavg);
yaux(3,:) = movmean(y(3,1:end),Nmavg);
yaux(4,:) = movmean(y(4,1:end),Nmavg);

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
    hold on
%     plot(t,y(i,:),'Color',[0.3 0.3 0.3],'LineWidth',1.2) 
    plot(t,yaux(i,:),'Color',[0.3 0.3 0.3],'LineWidth',1.2) 
    plot(tim,xAvg(i,:),'r','LineWidth',2)
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
     
end

print('hfinty_fig_curves','-depsc')


%norm calculation
W = w.*w;
sqrt(trapz(tim,zAvg)/trapz(tim,W))

auxZ = 0;
auxW = 0;


for k = 1:length(t)
    CL = 1*(th(k)==1)+2*(th(k)~= 1);
    auxZ = auxZ + yaux(:,k)'*(Q_lat + K{CL}'*R_lat*K{CL})*yaux(:,k);
    auxW = auxW + wr(k)'*wr(k);
end

sqrt(auxZ/auxW)







