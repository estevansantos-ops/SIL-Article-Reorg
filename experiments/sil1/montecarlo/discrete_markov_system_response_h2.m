close all
open('h2_mc_states_control.fig')
Tf = 4;
Nsteps = Tf/Ts+1;

n = 4;
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

Ts = 0.05;


tim = 0:Nsteps-1;
tim = tim * Ts;




% figure(5)
% clear th
for i = 1:length(Z)
   thA(i) = 1*(Z(i)==1||Z(i)==2||Z(i)==3) +  2*(Z(i)==4||Z(i)==5) + 3*(Z(i)==6);
end

%  set(0, 'FixedWidthFontName', 'Courier New');
% set(gcf, 'PaperPositionMode', 'auto')
% set(gca, 'Units','normalized','Position',[0.2 0.15 0.70 0.75]);
% FS = 12;
% 
% fig=gcf;
% set(findall(fig,'-property','FontSize'),'FontUnits','normalized','FontSize',0.1)
% 
%  stairs(t,th,'LineWidth',2) 
%  xlim([0 8])
% ylabel('\sffamily{$$\theta(t)$$}','Interpreter','latex','FontSize',FS) 
% xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)
% 
% print('h2_fig_th','-depsc')

FS = 12;

figure(1)
plotSeq = [1 2 4 5];
for i = 1:n
%     figure(i)
    subplot(2,3,plotSeq(i))
    hold on
    plot(t,y(i,:),'Color',[0.3 0.3 0.3],'LineWidth',2) 
     xlim([0 4])
end


plotSeq = [3 6];
for i = 1:2
%     figure(i)
    subplot(2,3,plotSeq(i))
    hold on
    plot(t,u(i,:),'Color',[0.3 0.3 0.3],'LineWidth',2) 
%     plot(t,uA(i,:),'Color',[0.7 0.7 0.7],'LineWidth',2) 
     xlim([0 4])
end

%norm calculation
auxZ = 0;
auxW = 0;
auxz2 = 0;

for k = 1:length(t)
    CL = 1*(thA(k)==1)+2*(thA(k)~= 1);
    zAux = (C2{Z(k)}+D2{Z(k)}*K{CL})*y(:,k);
    auxz2 = auxz2 + zAux'*zAux;
end
sqrt(auxz2*Ts)








