
x0 = y(:,1);


% Acl = m_est.A;
% Aaux(1,4) = -0.2483;
% Aaux(2,4) = 0;
% Aaux(3,4) = 0;

Acl = A_lat-B_lat*Klat;

[Acld,Bd] = c2d(Acl,B_lat,Ts);


Tf = 10;
Kf = Tf/Ts+1;
clear x
clear z2
clear z2y

x = x0;

for i = 1:Kf
   x(:,i+1) = Acld*x(:,i);
end


k = 0:Kf;
close all
i = 4;
figure(1)
plot(k*Ts,x(i,:))
hold on
plot(t,y(i,:),'r')

