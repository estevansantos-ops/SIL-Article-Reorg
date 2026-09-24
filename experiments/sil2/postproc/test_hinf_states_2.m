close all
figure(1)

set(0, 'FixedWidthFontName', 'Courier New');
set(gcf, 'PaperPositionMode', 'auto')
set(gca, 'Units','normalized','Position',[0.2 0.15 0.70 0.75]);
FS = 12;
subplot(1,2,1);
 hold on
set(0, 'FixedWidthFontName', 'Courier New')

jkvec = [3 2 1];

for k = 1:3
    jk = jkvec(k);
    if jk == 1
        load  youtCL.mat
        yout =  youtCL;
        
    end  

    if jk == 2
        load  youtdet.mat
        yout =  youtdet;
    end
    
    if jk == 3
        load  youtLTI.mat
        yout =  youtLTI;
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


    ax = gca
    tim = 0:Nsteps-1;
    tim = tim * Ts;

   STATEs = [2 4];
    for i = 1:2
    %     figure(i)
        subplot(1,2,i)
        hold on
%          plot(tim,th/2)
        if jk == 1
          p(i,jk)  = plot(t,y(STATEs(i),:),'k','LineWidth',1.75,'DisplayName', 'Strategy (i)')
          hold on
        end
        
        if jk == 2
          p(i,jk) =  plot(t,y(STATEs(i),:),'r','LineWidth',2.5,'DisplayName', 'Strategy (ii)')
            hold on
        end
        
       if jk == 3
         p(i,jk) =   plot(t,y(STATEs(i),:),'LineWidth',2,'Color',[0.5 0.5 0.5],'DisplayName', 'Strategy (iii)')
            hold on
        end
      
        xlim([0 5])
        
        if i == 1
             xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)
             ylabel('\sffamily{$$x_2(t)$$}','Interpreter','latex','FontSize',FS)    
        end
        
        if i == 2
             xlabel('\sffamily{$$t [s]$$}','Interpreter','latex','FontSize',FS)
             ylabel('\sffamily{$$x_4(t)$$}','Interpreter','latex','FontSize',FS)    
        end

%         lgd.Direction = "reverse";
         
    end

end        
  
% legend('Strategy (iii)', 'Strategy (ii)', 'Strategy (i)',[p1,p2,p3])

subplot(1,2,1)
legend([p(1,1),p(1,2),p(1,3)])
subplot(1,2,2)
legend([p(2,1),p(2,2),p(2,3)])
% legend('Strategy (iii)', 'Strategy (ii)', 'Strategy (i)');
 print('x_pract','-depsc')


