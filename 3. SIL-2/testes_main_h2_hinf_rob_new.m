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



Q_latInf = [1 0 0 0;0 1 0 0;0 0 1 0;0 0 0 1];
R_latInf = 5000*[1 0;0 1];

C_latInf = sqrt([Q_latInf;zeros(2,4)]);
D_latInf = sqrt([zeros(4,2);R_latInf]);

Q_lat2 = Q_latInf;
R_lat2 = R_latInf;

C_lat2 = sqrt([Q_lat2;zeros(2,4)]);
D_lat2 = sqrt([zeros(4,2);R_lat2]);


Xi{1} = eye(2);
Xi{2} = [2 0; 0 1];
Xi{3} = [2 0;0 -1];

mu = [1/3 0 0 1/3 0 1/3];

Lambda = [-1 0.5 0 0.5 0 0;
          0 -1 0.5 0.5 0 0;
           0 0 -1 1 0 0;
          0.7 0 0 -2 1 0.3;
          1.4 0 0 0 -2 0.6;
          0 0 0 3 0 -3];
CL = [1 1 1 2 2 2];

N = 6;

%%% vertex 1
k = 1;
for i = 1:N
    A{i}{k} = A_lat;
    B{i}{k} = B_lat;
    C2{i} = C_lat2;
    D2{i} = D_lat2*(Xi{CL(i)});
    CInf{i} = C_latInf;
    DInf{i} = D_latInf*(Xi{CL(i)});
    J2{i}{k} = [-0.5;10;-1;3.5];
    JInf{i}{k} = B_lat*[1 ;0];
end

B{2}{k} = B_lat*[2 0;0 1];
B{3}{k} = B_lat*[2 0;0 -1];


% [K,gamma]  =  h2_state_control_rob(A,B,J2,C2,D2,100,Lambda,mu,CL);

%% for figure trade-off
% 
gamma2 = linspace(30,100,40);
xi = 1000;
Lambda = 0;
mu = 1;


% i  = max(find(gamma2(:)/max(gamma2) < 0.50 ));

% MD
i = 10
CL = [1     1     1     2     2     3];
% [K,gammaInf1]  =  h2inf_state_control_rob(A,B,J2,JInf,C2,D2,CInf,DInf,xi,Lambda,mu,CL,1000);
% [K, gammaInf2]  =  hinf_state_control_rob(A,B,JInf,CInf,DInf,xi,Lambda,CL);
[K2,gamma2]  =  h2_state_control_rob(A,B,J2,C2,D2,xi,Lambda,mu,CL);


%% LQR
% Klqr = lqr(A_lat,B_lat,C_lat2'*C_lat2,D_lat2'*D_lat2); 
% K{1} = -Klqr;
% K{2} = -Klqr;

%LTI
% i = 10
% [K,gammaInf(i)]  =  h2inf_state_control_rob(A,B,J2,JInf,C2,D2,CInf,DInf,100,0,1,1,gamma2(i))
% K{1} = K{1};
% K{2} = K{1};

%% MI
% i = 10;
% CL = ones(1,6);
% [K,gammaInf(i)]  =  h2inf_state_control_rob(A,B,J2,JInf,C2,D2,CInf,DInf,100,Lambda,mu,CL,gamma2(i))



k = 1;
for i = 1:N
   Acl{i} = A{i}{1}+B{i}{1}*K{CL(i)};
   Jcl{i} = JInf{i}{1};
   Ccl2{i} = C2{i}+D2{i}*K{CL(i)};
   CclInf{i} = CInf{i}+DInf{i}*K{CL(i)};
end

[gamma]  =  hinf_norm(Acl,Jcl,CclInf,Lambda,[])



Ts = 0.05;
P = eye(6)+Lambda*Ts; % first order approx

gammaInf1
gammaInf2
gamma

