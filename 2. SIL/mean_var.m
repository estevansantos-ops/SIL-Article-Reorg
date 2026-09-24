%% script para o cálculo da média e variância da condição inicial

load y0.mat


yaux = zeros(4,10);
for i = 1:10
    yaux(:,i) = y0{i};
end

me = mean(yaux,2);
Qe = zeros(4,4);

for i = 1:4
    for j = 1:4
        aux = cov(yaux(i,:),yaux(j,:));
        Qe(i,i) = aux(1,1);
        Qe(j,j) = aux(2,2);
        Qe(i,j) = aux(1,2);
        Qe(j,i) = aux(2,1);
    end    
end


