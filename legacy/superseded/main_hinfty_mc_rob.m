clear all
clc
Modelagem_Cessna_172

A_lat2 = [ -15.2702    0.1991   -0.5384   -0.2483;
   18.4018   -13.4119     4.4821          0;
   -0.4426   -13.2824    -0.1078          0;
         0     1.0000          0          0];
     
a = min(abs(eig(A_lat)));     
     
A_lat2 = A_lat2 - 1000*a*[1 0 0 0;0 1 0 0;0 0 1 0;0 0 0 0];      
     
B_lat2 = [    0    11.4419;
   61.1362    13.3434;
   61.6416    20.6720;
         0          0]*[20 0;0 17];

A_lat = [-1 0 0 0;0 1 0 0;0 0 1 0; 0 0 0 1]*A_lat*[-1 0 0 0;0 1 0 0;0 0 1 0; 0 0 0 1];
B_lat = [-1 0 0 0;0 1 0 0;0 0 1 0; 0 0 0 1]*B_lat*[20 0;0 17];




Q_lat = [1 0 0 0;0 1 0 0;0 0 1 0;0 0 0 10];
R_lat = 5000*[1 0;0 1];

C_lat = sqrt([Q_lat;zeros(2,4)]);
D_lat = sqrt([zeros(4,2);R_lat]);


mu = [1 0 0 0 0 0];

Lambda = [-1 0.5 0 0.5 0 0;
          0 -1 0.5 0.5 0 0;
           0 0 -1 1 0 0;
          0.7 0 0 -2 1 0.3;
          1.4 0 0 0 -2 0.6;
          0 0 0 3 0 -3];
CL = [1 1 1 2 2 2];
N = 6;

k = 1;
for i = 1:N
    A{i}{k} = A_lat;
    B{i}{k} = B_lat;
    C{i} = C_lat;
    D{i} = D_lat;
    J{i}{k} = B_lat*[1 ;0];
end

B{2}{k} = B_lat*[2 0;0 1];
B{3}{k} = B_lat*[2 0;0 -1];

k = 2;
for i = 1:N
    A{i}{k} = A_lat2;
    B{i}{k} = B_lat2;
    C{i} = C_lat;
    D{i} = D_lat;
    J{i}{k} = B_lat2*[1 ;0];
end

B{2}{k} = B_lat2*[2 0;0 1];
B{3}{k} = B_lat2*[2 0;0 -1];


[K,gamma]  =  hinf_state_control_rob(A,B,J,C,D,100,Lambda,CL)


Ts = 0.05;
P = eye(6)+Lambda*Ts; % first order approx

