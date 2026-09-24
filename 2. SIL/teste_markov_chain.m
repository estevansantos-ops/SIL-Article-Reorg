clear all
clc

Lambda = [-1 1 0;0.2 -2 1.8; 1.5 1.5 -3];
Ts = 0.05;
M = expm(Lambda*Ts);
Maux = expm(Lambda*1e7);
% mu = Maux(1,:);
mu = [1 1 1]/3;

N = 10;
for i = 1:N
   Mi{i} =  expm(Lambda*(i-1)*Ts);
   Md{i} = M^(i-1);
   
   mu_i{i} = mu*Mi{i};
   mu_d{i} = mu*Md{i};
end



for i = 1:N
   mu_i{i}
   mu_d{i}
end





