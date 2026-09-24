% close all
% open('hinfty_trajectories_theoretical.fig')
Tf = 8;
tim = 0:Nsteps-1;
tim = tim * Ts;

iinit = min(find(yout(:,7) ~= 0))-1;
iend = min(find(tout(:)*5>tout(iinit)*5+Tf));
t = tout(iinit:iend)*5;
t = t-min(t);
Ts = t(2)-t(1);
y = yout(iinit:iend,1:4)';
u = yout(iinit:iend,5:6)';
wr = yout(iinit:iend,7)';
Z = yout(iinit:iend,8)';


for i = 1:n
%     figure(i)
    subplot(2,2,i)
    hold on
    plot(t,y(i,:),'Color',[0.3 0.3 0.3],'LineWidth',2) 
     xlim([0 8])
end

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

 print('hinf_fig_curves','-depsc')






figure(5)
% 
% 
 set(0, 'FixedWidthFontName', 'Courier New');
set(gcf, 'PaperPositionMode', 'auto')
set(gca, 'Units','normalized','Position',[0.2 0.15 0.70 0.75]);
FS = 14;



fig=gcf;
set(findall(fig,'-property','FontSize'),'FontUnits','normalized','FontSize',0.1)

 stairs(t,th,'LineWidth',2) 
 xlim([0 4])
ylabel('\sffamily{$$\theta(t)$$}','Interpreter','latex','FontSize',FS) 
xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)

print('hinf_fig_th','-depsc')


