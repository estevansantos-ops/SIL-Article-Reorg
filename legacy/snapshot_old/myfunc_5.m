function [A,B,C,D,K,x0] = myfunc_5(par,T)
load m_est.mat
u0 = 130;
g = 32.3;
th0 = -2*pi/180;

A = m_est.A;
B = m_est.B;
B(1,2) = par(1);
B(2,2) = par(2);
B(3,2) = par(3);


C = m_est.C;
D = zeros(4,2);
K = zeros(4,4);
x0 = [par(4);par(5);par(6);par(7)];
