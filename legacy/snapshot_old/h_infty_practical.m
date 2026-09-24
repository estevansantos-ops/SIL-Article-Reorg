
iinit = min(find(yout(:,7) ~= 0))-1;

t = tout(iinit:end)*5;
t = t-min(t);
Ts = t(2)-t(1);
y = yout(iinit:end,1:4)';
u = yout(iinit:end,5:6)';
w = yout(iinit:end,7)';
th = yout(iinit:end,8)';



for i = 1:length(y(1,:))
   zinfy(i) =  y(:,i)'*(Q_lat+Klat'*R_lat*Klat)*y(:,i); 
end


i = 3;
hold on
plot(t,y(i,:),'r')
