
A_aux = A_lat;
B_aux = B_lat*[1 0;0 1];


par(1) = A_aux(3,1);
par(2) = A_aux(3,2);
par(3) = A_aux(3,3);


aux = {};
T = 0;

m1 = idgrey('myfunc_3',par,'c',aux,T);
u =  zeros(length(t),2);


data = iddata(y,u,Ts);
opt = greyestOptions;
opt.EnforceStability = true;
m_est = greyest(data,m1,opt);
y_sim = lsim(m_est,u,t);
close all
for i = 1:4
   figure(i)
   plot(t,y_sim(:,i),'r');
   hold on
   plot(t,y(:,i),'b');
end


i = 1;
figure(i)
plot(t,y_sim(:,i),'r');
hold on
plot(t,y(:,i),'b');


eig(m_est.A)