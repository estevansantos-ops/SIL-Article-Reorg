
for jk = 1:3

    if jk == 1
        load  youtCL.mat
        yout =  youtCL;
        
         plotSeq = [1 4];
    end  

    if jk == 2
        load  youtdet.mat
        yout =  youtdet;
        plotSeq = [2 5];
    end
    
    if jk == 3
        load  youtLTI.mat
        yout =  youtLTI;
        plotSeq = [3 6];
    end        
    

    
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



    tim = 0:Nsteps-1;
    tim = tim * Ts;

    for i = 1:length(Z)
         thA(i) = 1*(Z(i)==1||Z(i)==2||Z(i)==3) +  2*(Z(i)==4||Z(i)==5) + 3*(Z(i)==6);
    end

    auxz2 = 0;
    auxW = 0;
    for k = 1:length(t)
        cl = 1*(thA(k) == 1) + 2*(thA(k)  ~= 1);
        zAux = (CInf{Z(k)}+DInf{Z(k)}*K{cl})*y(:,k);
        auxz2 = auxz2 + zAux'*zAux;
        auxW = auxW + wr(:,k)'*wr(:,k);
    end
    sqrt(auxz2/auxW)
    
end        
    
