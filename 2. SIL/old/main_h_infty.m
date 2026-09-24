
iinit = min(find(yout(:,7) ~= 0))-1;

t = tout(iinit:end)*5;
t = t-min(t);
Ts = t(2)-t(1);
y = yout(iinit:end,1:4)';
u = yout(iinit:end,5:6)';
w = yout(iinit:end,7)';

x0 = y(:,1);

Acl = A_lat+B_lat*K{1};

[Acld,Bd] = c2d(Acl,B_lat,Ts);

% Bcld = Bd(:,1);

Bcld = Bd;
w = [w; zeros(size(w))];

clear x
clear zinf
clear zinfy

x = x0;



for i = 1:length(t)
   x(:,i+1) = Acld*x(:,i)+Bcld*w(:,i);
   zinf(i) =  x(:,i)'*(Q_lat+Klat'*R_lat*Klat)*x(:,i);
   wn(i) = w(:,i)'*w(:,i);
end

for i = 1:length(y(1,:))
   zinfy(i) =  y(:,i)'*(Q_lat+Klat'*R_lat*Klat)*y(:,i); 
end

close all
i = 4;
figure(1)
plot(t,x(i,1:end-1))
hold on
plot(t,y(i,:),'r')

figure(2)
plot(t,sqrt(cumsum(zinf)),'b')
hold on
plot(t,sqrt(cumsum(zinfy)),'r')

figure(3)
plot(t,zinf/sum(wn),'b')
hold on
plot(t,zinfy/sum(wn),'r')


sqrt((sum(zinf)*Ts)/(sum(wn)*Ts))
sqrt((sum(zinfy)*Ts)/(sum(wn)*Ts))

