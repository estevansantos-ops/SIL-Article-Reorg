% open('h2_trajectories_theoretical.fig')
load yH2.mat
mA = 0;
Npot = 10;
for i = 1:Npot
   mA = max(length(yH2{i}),mA);     
end

for i = 1:Npot
    yaux{i} = zeros(4,mA);
    mAaux = length(yH2{i});
    yaux{i}(:,1:mAaux) = yH2{i}(:,1:end);
end
    

 %% max and min
 flag = 1;
for j = 1:n
    for k = 1:mA
         i = 1;
        if i == 1
            xMax(j,k) = -1e7;
            xMin(j,k) = 1e7;
        end
       
            for i = 1:Npot
                if i ~= 7
                   xMax(j,k) = max(xMax(j,k),yaux{i}(j,k));
                   xMin(j,k) = min(xMin(j,k),yaux{i}(j,k));
                end
        end
    end
    flag = flag + 1;
end
   

tem = 1:length(xMax(1,:));
tem = (tem-1)*Ts;

for i = 1:n
%     figure(i)
    subplot(2,2,i)
    hold on
    curve1 = xMax(i,:);
    curve2 = xMin(i,:);
    aux = tem;
    aux2 = [aux,fliplr(aux)];
    inBetween = [curve1, fliplr(curve2)];
    fill(aux2,inBetween,[0.8 0.1 0.1],'EdgeColor',[1 1 1],'FaceAlpha',0.3);
    
     xlim([0 4])
end
