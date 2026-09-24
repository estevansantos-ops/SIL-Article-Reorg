A_lat1 = A_lat;
A_lat2 =  [ -15.2702    0.1991   -0.5384   -0.2483;
    18.4018   -13.4119     4.4821          0;
    -0.4426   -13.2824    -0.1078          0;
          0     1.0000          0          0];
      
 Np = linspace(0,1,1000);     
 for i = 1:length(Np)
     Aaux  = A_lat1*Np(i) + A_lat2*(1-Np(i));
    er(:,i) = eig(Aaux);  
 end
 
 Im = imag(er);
 Re = real(er);
 figure(1)
 hold on
 for  i = 1:length(Np)
    for j = 1:4
       plot(Re(j,i),Im(j,i),'o');
    end
 end
 
 