close all
figure(1)

set(0, 'FixedWidthFontName', 'Courier New');
set(gcf, 'PaperPositionMode', 'auto')
set(gca, 'Units','normalized','Position',[0.2 0.15 0.70 0.75]);
FS = 10;

subplot(2,3,1);
 hold on
set(0, 'FixedWidthFontName', 'Courier New')
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

   


   
    for i = 1:2
    %     figure(i)
        subplot(2,3,plotSeq(i))
        hold on

        plot(t,u(i,:),'k','LineWidth',2)
        plot(t,uA(i,:),'r','LineWidth',2)
%         plot(tim,-th/80)
        if i == 1
            ylim([-0.25 0])
            legend('u_1(t)','\upsilon_1(t)')
        switch jk
            case 1                
                xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)
                 ylabel('\sffamily{$$u^{(1)}_1(t),\upsilon^{(1)}_1(t)$$}','Interpreter','latex','FontSize',FS)   
            case 2
                 ylabel('\sffamily{$$u^{(2)}_1(t),\upsilon^{(2)}_1(t)$$}','Interpreter','latex','FontSize',FS)
                 xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)
            case 3
                ylabel('\sffamily{$$u^{(3)}_1(t),\upsilon^{(3)}_1(t)$$}','Interpreter','latex','FontSize',FS)
                xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)
            otherwise
                disp('other value')
        end
        
        else
             ylim([-0.05 0.07])
           switch jk
            case 1
                xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)
                 ylabel('\sffamily{$$u^{(1)}_2(t),\upsilon^{(1)}_2(t)$$}','Interpreter','latex','FontSize',FS)   
            case 2
                 ylabel('\sffamily{$$u^{(2)}_2(t),\upsilon^{(2)}_2(t)$$}','Interpreter','latex','FontSize',FS)
                 xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)
            case 3
                ylabel('\sffamily{$$u^{(3)}_2(t),\upsilon^{(3)}_2(t)$$}','Interpreter','latex','FontSize',FS)
                xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)
            otherwise
                disp('other value')
           end 
            legend('u_2(t)','\upsilon_2(t)')
        end
        xlim([0 5])
        
    end
  
end        
    

 print('control_pract','-depsc')


