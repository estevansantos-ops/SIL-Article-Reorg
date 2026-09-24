
max_roll = max(yout(:,4));
iinit = find(yout(:,4) == max_roll);

t = tout(iinit:end)*5;
t = t-min(t);

Ts = t(2)-t(1);
y = yout(iinit:end,1:4)';


x0 = y(:,1);

% Acl = m_est.A
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
   z2(i) =  x(:,i)'*(Q_lat+Klat'*R_lat*Klat)*x(:,i);
end

for i = 1:length(y(1,:))
   z2y(i) =  y(:,i)'*(Q_lat+Klat'*R_lat*Klat)*y(:,i); 
end

k = 0:Kf;

close all
i = 4;
figure(1)
plot(k*Ts,x(i,:))
hold on
plot(t,y(i,:),'r')

figure(2)
plot(k(1:end-1)*Ts,z2,'b')
hold on
plot(t,z2y,'r')


x0'*Plyap*x0
sum(z2)*Ts
sum(z2y)*Ts

