clear all
clc
Modelagem_Cessna_172

A_lat = [ -15.2702    0.1991   -0.5384   -0.2483;
   18.4018   -13.4119     4.4821          0;
   -0.4426   -13.2824    -0.1078          0;
         0     1.0000          0          0];
     
a = min(abs(eig(A_lat)));     
     
A_lat = A_lat - 1000*a*[1 0 0 0;0 1 0 0;0 0 1 0;0 0 0 0];      
     
B_lat = [    0    11.4419;
   61.1362    13.3434;
   61.6416    20.6720;
         0          0]*[20 0;0 17];


Q_lat = [0.1 0 0 0;0 1 0 0;0 0 0.1 0;0 0 0 10];
R_lat = 2000*[1 0;0 1];

C_lat = sqrt([Q_lat;zeros(2,4)]);
D_lat = sqrt([zeros(4,2);R_lat]);


mu = [1/3 0 0 1/3 0 1/3];

Lambda = [-1 0.5 0 0.5 0 0;
          0 -1 0.5 0.5 0 0;
           0 0 -1 1 0 0;
          0.7 0 0 -2 1 0.3;
          1.4 0 0 0 -2 0.6;
          0 0 0 3 0 -3];
CL = [1 1 1 2 2 2];
N = 6;

for i = 1:N
    A{i} = A_lat;
    B{i} = B_lat;
    C{i} = C_lat;
    D{i} = D_lat;
    J{i} = [-0.1;8;-0.01;3];
end

B{2} = B_lat*[2 0;0 1];
B{3} = B_lat*[2 0;0 -1];


[K,gamma]  =  h2_state_control(A,B,J,C,D,10,Lambda,mu,CL);

% [K,gamma]  =  h2_state_control(A,B,J,C,D,10,0,1,1)
% [Klat,Plyap] = lqr(A_lat,B_lat,Q_lat,R_lat)

Ts = 0.05;
P = eye(6)+Lambda*Ts; % first order approx

for i = 1:N
   Acls{i} = A{i}+B{i}*K{CL(i)};
   Ccls{i} = C{i}+D{i}*K{CL(i)};
   Jcls{i} = J{i};
end

[H2]  =  h2_norm(Acls,Jcls,Ccls,mu,Lambda,1:6);


gamma
H2

