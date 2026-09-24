open('hinf_mc_states_control.fig')
load  youtHinf.mat

Npoint = max(size(youtHinf));

for i = 1:Npoint

    yout =  youtHinf{i};
    Tf = 8;
    tim = 0:Nsteps-1;
    tim = tim * Ts;
    tout = (0:length(yout(:,7))-1)*0.01;
    iinit = min(find(yout(:,7) ~= 0))-1;
%     iend = min(find(tout(:)*5>tout(iinit)*5+Tf));
    iend = iinit+161;
    t = tout(iinit:iend)*5;
    t = t-min(t);
    Ts = t(2)-t(1);
    y = yout(iinit:iend,1:4)';
    u = yout(iinit:iend,5:6)';
    wr = yout(iinit:iend,7)';
    Z = yout(iinit:iend,8)';
    uA = yout(iinit:iend,9:10)';

    yHinf{i} = y;
    uHinf{i} = u;
end


%%%
mA = 0;
for i = 1:10
   mA = max(length(yHinf{i}),mA);     
end


    


for j = 1:10
close all
open('hinf_mc_states_control.fig')    
plotSeq = [1 2 4 5];
for i = 1:n
%     figure(i)
    subplot(2,3,plotSeq(i))
    hold on
    plot(t,yHinf{j}(i,:),'k','LineWidth',2)
     xlim([0 8])
end

plotSeq = [3 6];
for i = 1:2
%     figure(i)

    subplot(2,3,plotSeq(i))
    hold on
    plot(t,uHinf{j}(i,:),'k','LineWidth',2)
     xlim([0 8])
end
end
% print('hinf_fig_curves','-depsc')



