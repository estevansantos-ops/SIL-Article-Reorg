close all
open('h2_mc_states_control.fig')
load  youtH2.mat

Npoint = max(size(youtH2));

for i = 1:Npoint

    yout =  youtH2{i};
    Tf = 4;
    Nsteps = Tf/Ts+1;
    tim = 0:Nsteps-1;
    tim = tim * Ts;
    tout = (0:length(yout(:,7))-1)*0.01;
   

    iinit = max(find(yout(:,7) ~= 0))+1;

%     iend = min(find(tout(:)*5>tout(iinit)*5+Tf));
    iend = iinit + 81;
    t = tout(iinit:iend)*5;
    t = t-min(t);
    Ts = t(2)-t(1);
    y = yout(iinit:iend,1:4)';
    u = yout(iinit:iend,5:6)';
    wr = yout(iinit:iend,7)';
    Z = yout(iinit:iend,8)';
    uA = yout(iinit:iend,9:10)';

    yH2{i} = y;
    uH2{i} = u;
end


%%%
mA = 0;
for i = 1:10
   mA = max(length(yH2{i}),mA);     
end

for i = 1:10
    yaux{i} = zeros(4,mA);
    uaux{i} = zeros(2,mA);
    mAaux = length(yH2{i});
    yaux{i}(:,1:mAaux) = yH2{i}(:,1:end);
    uaux{i}(:,1:mAaux) = uH2{i}(:,1:end);
end
    

 %% max and min
 flag = 1;
 clear xMax
 clear xMin
 clear uMax
 clear uMin
for j = 1:n
    for k = 1:mA
         i = 1;
        if i == 1
            xMax(j,k) = -1e7;
            xMin(j,k) = 1e7;       
        end
        for i = 1:10
           xMax(j,k) = max(xMax(j,k),yaux{i}(j,k));
           xMin(j,k) = min(xMin(j,k),yaux{i}(j,k));    
        end
    end
    flag = flag + 1;
end
flag = 1;
for j = 1:2
    for k = 1:mA
         i = 1;
        if i == 1

            uMax(j,k) = -1e7;
            uMin(j,k) = 1e7;            
        end
        for i = 1:10

          uMax(j,k) = max(uMax(j,k),uaux{i}(j,k));
           uMin(j,k) = min(uMin(j,k),uaux{i}(j,k));           
        end
    end
    flag = flag + 1;
end
   

tem = 1:length(xMax(1,:));
tem = (tem-1)*Ts;

j = 6;
plotSeq = [1 2 4 5];
for i = 1:n
%     figure(i)
    subplot(2,3,plotSeq(i))
    hold on
    curve1 = xMax(i,:);
    curve2 = xMin(i,:);
    aux = tem;
    aux2 = [aux,fliplr(aux)];
    inBetween = [curve1, fliplr(curve2)];
    fill(aux2,inBetween,[0.8 0.1 0.1],'EdgeColor',[1 1 1],'FaceAlpha',0.3);
    plot(t,yH2{j}(i,:),'k','LineWidth',2)
     xlim([0 4])
     if i == 2
        ylim([-22 10]) 
     end
     if i == 4
        ylim([-1 4]) 
     end
end

plotSeq = [3 6];
for i = 1:2
%     figure(i)
    subplot(2,3,plotSeq(i))
    hold on
    curve1 = uMax(i,:);
    curve2 = uMin(i,:);
    aux = tem;
    aux2 = [aux,fliplr(aux)];
    inBetween = [curve1, fliplr(curve2)];
    fill(aux2,inBetween,[0.8 0.1 0.1],'EdgeColor',[1 1 1],'FaceAlpha',0.3);
    plot(t,uH2{j}(i,:),'k','LineWidth',2)
    xlim([0 4])
end

print('h2_fig_curves','-depsc')



