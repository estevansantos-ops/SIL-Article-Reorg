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


% Xi{1} = eye(2);
% Xi{2} = [2 0; 0 1];
% Xi{3} = [2 0;0 -1];

% 
Xi{1} = eye(2);
Xi{2} = eye(2);
Xi{3} = eye(2);

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
    D2{i} = D_lat2*Xi{CL(i)};
    CInf{i} = C_latInf;
    DInf{i} = D_latInf*Xi{CL(i)};
    J2{i}{k} = eye(4);
    JInf{i}{k} = B_lat*[1 ;0];
end

B{2}{k} = B_lat*[2 0;0 1];
B{3}{k} = B_lat*[2 0;0 -1];


%% vertex 2

k = 2;
for i = 1:N
    A{i}{k} = A_lat2;
    B{i}{k} = B_lat2;
    C2{i} = C_lat2;
    D2{i} = D_lat2*Xi{CL(i)};
    CInf{i} = C_latInf;
    DInf{i} = D_latInf*Xi{CL(i)};
    J2{i}{k} = eye(4);
    JInf{i}{k} = B_lat2*[1 ;0];
end

B{2}{k} = B_lat*[2 0;0 1];
B{3}{k} = B_lat*[2 0;0 -1];


% [K,gamma]  =  h2_state_control_rob(A,B,J2,C2,D2,100,Lambda,mu,CL);

%% for figure trade-off
% 
gamma2 = linspace(8,16,40);
xi = 1000;
% 
% for i = 1:length(gamma2)
%     [K{i},gammaInf(i)]  =  h2inf_state_control_rob(A,B,J2,JInf,C2,D2,CInf,DInf,xi,Lambda,mu,CL,gamma2(i));   %% 225 min,  
% end
% plot(gamma2/max(gamma2),gammaInf/max(gammaInf))

i = 5;
% i = 4;
% gamma2(i) = 7.6923;


% MD
CL = [1 1 1 2 2 3];
[KMD,gammaInfMD]  =  hinf_state_control_rob(A,B,JInf,CInf,DInf,xi,Lambda,CL);

%CL
CL = [1 1 1 2 2 2];
[KCL,gammaInfCL]  =  hinf_state_control_rob(A,B,JInf,CInf,DInf,xi,Lambda,CL); 

% % MI
CL = [1 1 1 1 1 1];
[KMI,gammaInfMI]  =  hinf_state_control_rob(A,B,JInf,CInf,DInf,xi,Lambda,CL);

%LTI
CL = [1 1 1 1 1 1];
[KLTI,gammaLTI]  =  hinf_state_control_rob(A,B,JInf,CInf,DInf,xi,0,CL); 


%% Cluster LTI
for i = 1:3
   for k = 1:2
       Aaux{1}{k} = A{i}{k};
       Baux{1}{k} = B{i}{k};
       JInfaux{1}{k} = JInf{i}{k};
       J2aux{1}{k} = J2{i}{k};
       C2aux{1} = C2{i};
       CInfaux{1} = CInf{i};
       D2aux{1} = D2{i};
       DInfaux{1} = DInf{i};
   end
   
   [Kaux,gammaLTI]   =  hinf_state_control_rob(Aaux,Baux,JInfaux,CInfaux,DInfaux,xi,0,1); 
   Kdet{i} = Kaux{1};
end

%% MD
CL = [1 1 1 2 2 3];
% CL = 1:6;
k = 1;
for i = 1:N
   Acl{i} = A{i}{k}+B{i}{k}*KMD{CL(i)};
   Jcl{i} = JInf{i}{k};
   Ccl2{i} = C2{i}+D2{i}*KMD{CL(i)};
   CclInf{i} = CInf{i}+DInf{i}*KMD{CL(i)};
end
[gammaMD]  =  hinf_norm(Acl,Jcl,CclInf,Lambda,[]);
sqrt(gammaInfMD)
sqrt(gammaMD)

[KMD{1};KMD{2};KMD{2}]

%% cluster
sqrt(gammaInfCL)
[KCL{1};KCL{2}]
CL = [1 1 1 2 2 2];
for i = 1:N
   Acl{i} = A{i}{k}+B{i}{k}*KCL{CL(i)};
   Jcl{i} = JInf{i}{k};
   Ccl2{i} = C2{i}+D2{i}*KCL{CL(i)};
   CclInf{i} = CInf{i}+DInf{i}*KCL{CL(i)};
end
[gammaCL]  =  hinf_norm(Acl,Jcl,CclInf,Lambda,[]);
sqrt(gammaCL)

%% MI
sqrt(gammaInfMI)
KMI{1}

CL = [1 1 1 1 1 1];
for i = 1:N
   Acl{i} = A{i}{k}+B{i}{k}*KMI{CL(i)};
   Jcl{i} = JInf{i}{k};
   Ccl2{i} = C2{i}+D2{i}*KMI{CL(i)};
   CclInf{i} = CInf{i}+DInf{i}*KMI{CL(i)};
end
[gammaMI]  =  hinf_norm(Acl,Jcl,CclInf,Lambda,[]);
sqrt(gammaMI)

% LTI
sqrt(gammaLTI)
KLTI{1}

CL = [1 1 1 1 1 1];
for i = 1:N
   Acl{i} = A{i}{k}+B{i}{k}*KLTI{CL(i)};
   Jcl{i} = JInf{i}{k};
   Ccl2{i} = C2{i}+D2{i}*KLTI{CL(i)};
   CclInf{i} = CInf{i}+DInf{i}*KLTI{CL(i)};
end
[gammaLTI]  =  hinf_norm(Acl,Jcl,CclInf,Lambda,[]);
sqrt(gammaLTI)


%% robust cluster 


CL = [1 1 1 2 2 3];
for i = 1:N
   Acl{i} = A{i}{k}+B{i}{k}*Kdet{CL(i)};
   Jcl{i} = JInf{i}{k};
   Ccl2{i} = C2{i}+D2{i}*Kdet{CL(i)};
   CclInf{i} = CInf{i}+DInf{i}*Kdet{CL(i)};
end
[gammaRC]  =  hinf_norm(Acl,Jcl,CclInf,Lambda,[]);
sqrt(gammaRC)



clc
sqrt(gammaMD)
sqrt(gammaCL)
sqrt(gammaMI)
sqrt(gammaLTI)
sqrt(gammaRC)

