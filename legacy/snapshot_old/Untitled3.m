Ts = 0.00001;
Tf = 10;
Kf = Tf/Ts+1;
[Acld,Bd] = c2d(Acl,B_lat,Ts);
clear z2
clear x
x(:,1) = x0;
for i = 1:Kf
   x(:,i+1) = Acld*x(:,i);
   z2(i) =  x(:,i)'*(Q_lat+Klat'*R_lat*Klat)*x(:,i);
end
sum(z2)*Ts

k = 0:Kf;
close all

plot(k(1:end-1)*Ts,z2)