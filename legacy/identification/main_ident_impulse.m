
A_aux = A_lat-B_lat*Klat;
B_aux = B_lat;

% 

par(1) = A_lat(1,1);
par(2) = A_lat(1,3);
par(3) = A_lat(3,1);
par(4) = A_lat(3,3);


aux = {};
T = 0;

m1 = idgrey('myfunc_3',par,'c',aux,T);
u =  zeros(length(t),2);


data = iddata(y',u,Ts);
opt = greyestOptions;
opt.EnforceStability = false;
m_est = greyest(data,m1,opt);



% 
% A_lat(1,1) = m_est.par(1);
% A_lat(1,2)  = m_est.par(2);
% A_lat(1,3)  = m_est.par(3);
% A_lat(2,1)  = m_est.par(4);
% A_lat(2,2)  = m_est.par(5);
% A_lat(2,3)  = m_est.par(6);
A_lat(1,1)  = m_est.par(1);
A_lat(1,3)  = m_est.par(2);
A_lat(3,1)  = m_est.par(3);
A_lat(3,3)  = m_est.par(4);



