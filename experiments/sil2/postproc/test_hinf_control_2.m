close all
% open('hinf_mc_states_control.fig')
load  youtdet.mat
yout =  youtdet;


Npoint = max(size(yout));

for i = 1:Npoint    
    Tf = 8;
    tim = 0:Nsteps-1;
    tim = tim * Ts;
    tout = (0:length(yout(:,7))-1)*0.01;
    iinit = min(find(yout(:,7) ~= 0))-1;
%     iend = min(find(tout(:)*5>tout(iinit)*5+Tf));
%     iend = iinit+161;
    iend = max(length(yout(:,1)));
    t = tout(iinit:end)*5;
    t = t-min(t);
    Ts = t(2)-t(1);
    y = yout(iinit:iend,1:4)';
    u = yout(iinit:iend,5:6)';
    wr = yout(iinit:iend,7)';
    Z = yout(iinit:iend,8)';
    uA = yout(iinit:iend,9:10)';

   
end


figure(1)
plotSeq = [1 2];
for i = 1:2
%     figure(i)
    subplot(1,3,plotSeq(i))
    hold on
   
    plot(t,u(i,:),'r','LineWidth',2)
    plot(t,uA(i,:),'k','LineWidth',2)
     xlim([0 8])
end




