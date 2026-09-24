% close all
% open('h2_trajectories_theoretical.fig')

% tim = 0:Nsteps-1;
% tim = tim * Ts;


Tf = 4;
iinit = max(find(yout(:,7) ~= 0))+1;
iend = min(find(tout(:)*5>tout(iinit)*5+Tf));
t = tout(iinit:iend)*5;
t = t-min(t);
Ts = t(2)-t(1);
y = yout(iinit:iend,1:4)';
u = yout(iinit:iend,5:6)';
wr = yout(iinit:iend,7)';
Z = yout(iinit:iend,8)';
uA = yout(iinit:iend,9:10)';


n = 4;
% close all
% figure(1)
hold on


figure(1)
for i = 1:n
%     figure(i)
    subplot(2,2,i)
    hold on
    plot(t,y(i,:),'Color',[0.3 0.3 0.3],'LineWidth',2) 
     xlim([0 4])
end
figure(2)
plotSeq = [1 3];
for i = 1:2
%     figure(i)
    subplot(2,2,plotSeq(i))
    hold on
    plot(t,u(i,:),'Color',[0.3 0.3 0.3],'LineWidth',2) 
     xlim([0 4])
end

plotSeq = [2 4];
for i = 1:2
%     figure(i)
    subplot(2,2,plotSeq(i))
    hold on
    plot(t,uA(i,:),'Color',[0.3 0.3 0.3],'LineWidth',2) 
     xlim([0 4])
end


for i = 1:length(Z)
   thP(i) = 1*(Z(i)==1||Z(i)==2||Z(i)==3) +  2*(Z(i)==4||Z(i)==5) + 3*(Z(i)==6);
end

auxz2 = 0;
for k = 1:length(t)
    cl = 1*(thP(k) == 1) + 2*(thP(k)  ~= 1);
    zAux = (C2{1}+D2{1}*K{cl})*y(:,k);
    auxz2 = auxz2 + zAux'*zAux;
end


sqrt(auxz2*Ts)


% print('h2_fig_curves','-depsc')







% 
% 
figure(2)
 set(0, 'FixedWidthFontName', 'Courier New');
set(gcf, 'PaperPositionMode', 'auto')
set(gca, 'Units','normalized','Position',[0.2 0.15 0.70 0.75]);
FS = 14;

fig=gcf;
set(findall(fig,'-property','FontSize'),'FontUnits','normalized','FontSize',0.1)

 stairs(t,thP,'LineWidth',2) 
 xlim([0 4])
ylabel('\sffamily{$$\theta(t)$$}','Interpreter','latex','FontSize',FS) 
xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)

% print('h2_fig_th','-depsc')



% figure(3)
%  set(0, 'FixedWidthFontName', 'Courier New');
% set(gcf, 'PaperPositionMode', 'auto')
% set(gca, 'Units','normalized','Position',[0.2 0.15 0.70 0.75]);
% FS = 14;
% 
% fig=gcf;
% set(findall(fig,'-property','FontSize'),'FontUnits','normalized','FontSize',0.1)
% 
%  plot(t,u(1,:),'LineWidth',2) 
%  hold on
%  plot(t,u(2,:),'--','LineWidth',2) 
%  xlim([0 4])
% ylabel('\sffamily{$$u_1(t), u_2(t)$$}','Interpreter','latex','FontSize',FS) 
% xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)

% print('h2_fig_th','-depsc')



% 
% t_h2 = t;
% y_h2 = y;
% u_h2 = u;
% th_h2 = th;
% 
% save t_h2.mat t_h2
% save y_h2.mat y_h2
% save u_h2.mat u_h2
% save th_h2.mat th_h2
% 
% 
% 
