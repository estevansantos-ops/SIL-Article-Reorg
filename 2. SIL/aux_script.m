
for j = 1:n
    for k = 1:Nsteps      
        for i = 1:MC
           xAux(j,i) = xS{i}(j,k);
        end
        xMax(j,k) = max(xAux(j,:));
        xMin(j,k) = min(xAux(j,:));
    end
end
flag = flag + 1