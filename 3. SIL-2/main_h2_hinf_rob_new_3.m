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


Q_lat2 = [10 0 0 0;0 1 0 0;0 0 1 0;0 0 0 1];
R_lat2 = 2000*[1 0;0 1];

C_lat2 = sqrt([Q_lat2;zeros(2,4)]);
D_lat2 = sqrt([zeros(4,2);R_lat2]);

Q_latInf = [1 0 0 0;0 1 0 0;0 0 1 0;0 0 0 10];
R_latInf = 5000*[1 0;0 1];

C_latInf = sqrt([Q_latInf;zeros(2,4)]);
D_latInf = sqrt([zeros(4,2);R_latInf]);

Xi{1} = eye(2);
Xi{2} = [2 0; 0 1];
Xi{3} = [2 0;0 -1];
% Xi{1} = eye(2);
% Xi{2} = eye(2);
% Xi{3} = eye(2);

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
    J2{i}{k} = [-0.5;10;-1;3.5];
    JInf{i}{k} = B_lat;
end

B{4}{k} = B_lat*[2 0;0 1];
B{5}{k} = B_lat*[2 0;0 1];
B{6}{k} = B_lat*[2 0;0 -1];


%% vertex 2

k = 2;
for i = 1:N
    A{i}{k} = A_lat;
    B{i}{k} = B_lat;
    C2{i} = C_lat2;
    D2{i} = D_lat2*Xi{CL(i)};
    CInf{i} = C_latInf;
    DInf{i} = D_latInf*Xi{CL(i)};
    J2{i}{k} = [0.5;10;1;3.5];
    JInf{i}{k} = B_lat;
end

B{4}{k} = B_lat*[2 0;0 1];
B{5}{k} = B_lat*[2 0;0 1];
B{6}{k} = B_lat*[2 0;0 -1];


%% vertex 3
k = 3;
for i = 1:N
    A{i}{k} = A_lat2;
    B{i}{k} = B_lat2;
    C2{i} = C_lat2;
    D2{i} = D_lat2*Xi{CL(i)};
    J2{i}{k} = [-0.5;10;-1;3.5];
    
    CInf{i} = C_latInf;
    DInf{i} = D_latInf*Xi{CL(i)};
    JInf{i}{k} = B_lat2;
end

B{4}{k} = B_lat2*[2 0;0 1];
B{5}{k} = B_lat2*[2 0;0 1];
B{6}{k} = B_lat2*[2 0;0 -1];


%% vertex 4
k = 4;
for i = 1:N
    A{i}{k} = A_lat2;
    B{i}{k} = B_lat2;
    C2{i} = C_lat2;
    D2{i} = D_lat2*Xi{CL(i)};
    J2{i}{k} = [0.5;10;1;3.5];
    
    CInf{i} = C_latInf;
    DInf{i} = D_latInf*Xi{CL(i)};
    JInf{i}{k} = B_lat2;
end

B{4}{k} = B_lat2*[2 0;0 1];
B{5}{k} = B_lat2*[2 0;0 1];
B{6}{k} = B_lat2*[2 0;0 -1];

% [K,gamma]  =  h2_state_control_rob(A,B,J2,C2,D2,100,Lambda,mu,CL);

%% for figure trade-off
% H2min = 4; 16%
% i = 20;
xi = 220;
gamma2 = linspace(120,320,40);

% for i = 1:length(gamma2)
%     [K{i},gammaInf(i)]  =  h2inf_state_control_rob(A,B,J2,JInf,C2,D2,CInf,DInf,xi,Lambda,mu,CL,gamma2(i));   %% 225 min,  
% end
% plot(gamma2/max(gamma2),gammaInf/max(gammaInf))

i = 40;
gamma2(i) = 320;
% MD
CL = [1 1 1 2 2 3];
[KMD,gammaInfMD]  =  h2inf_state_control_rob(A,B,J2,JInf,C2,D2,CInf,DInf,xi,Lambda,mu,CL,gamma2(i));
% [KMD,gammaInfMD]  =  hinf_state_control_rob(A,B,JInf,CInf,DInf,xi,Lambda,CL);
% [KMD,gammaInfMD]  =  h2_state_control_rob(A,B,J2,C2,D2,xi,Lambda,mu,CL);
% 
%CL
CL = [1 1 1 2 2 2];
[KCL,gammaInfCL]  =  h2inf_state_control_rob(A,B,J2,JInf,C2,D2,CInf,DInf,xi,Lambda,mu,CL,gamma2(i)); 
% [KCL,gammaInfCL]  =  hinf_state_control_rob(A,B,JInf,CInf,DInf,xi,Lambda,CL); 
% [KCL,gammaInfCL]  =  h2_state_control_rob(A,B,J2,C2,D2,xi,Lambda,mu,CL); 

% % MI
CL = [1 1 1 1 1 1];
[KMI,gammaInfMI]  =  h2inf_state_control_rob(A,B,J2,JInf,C2,D2,CInf,DInf,xi,Lambda,mu,CL,gamma2(i));
% [KMI,gammaInfMI]  =  hinf_state_control_rob(A,B,JInf,CInf,DInf,xi,Lambda,CL);
% [KMI,gammaInfMI]  =  h2_state_control_rob(A,B,J2,C2,D2,xi,Lambda,mu,CL);

%%LTI
cont = 1;
CLaux = [1 4 6];
for i = 1:3
    for k = 1:max(size(A{1}))
        Alti{cont} = A{CLaux(i)}{k};
        Blti{cont} = B{CLaux(i)}{k};
        J2lti{cont} = J2{CLaux(i)}{k};
        JInflti{cont} = JInf{CLaux(i)}{k};
        C2lti{cont} = C2{CLaux(i)};
        CInflti{cont} = CInf{CLaux(i)};
        D2lti{cont} = D2{CLaux(i)};
        DInflti{cont} = DInf{CLaux(i)};
        cont = cont + 1;
    end
    
end

[KLTI,gammaLTI]  =  h2inf_state_control_rob_lti(Alti,Blti,J2lti,JInflti,C2lti,D2lti,CInflti,DInflti,xi,gamma2(i)); 
% [KLTI,gammaLTI]  =  hinf_state_control_rob_lti(Alti,Blti,JInflti,CInflti,DInflti,xi); 
% [KLTI,gammaLTI]  =  h2_state_control_rob_lti(Alti,Blti,J2lti,C2lti,D2lti,xi); 
% 

%% Cluster LTI
% Cluster 1
for k = 1:max(size(A{1}))
   Aaux{k} = A{1}{k};
   Baux{k} = B{1}{k};
   JInfaux{k} = JInf{1}{k};
   J2aux{k} = J2{1}{k};
   C2aux{k} = C2{1};
   CInfaux{k} = CInf{1};
   D2aux{k} = D2{1};
   DInfaux{k} = DInf{1};
end
[Kaux,gammaLTI]  =  h2inf_state_control_rob_lti(Aaux,Baux,J2aux,JInflti,C2aux,D2aux,CInfaux,DInfaux,xi,gamma2(i)); 
% [Kaux,gammaLTI]  =  hinf_state_control_rob_lti(Aaux,Baux,JInflti,CInfaux,DInfaux,xi); 
% [Kaux,gammaLTI]  =  h2_state_control_rob_lti(Aaux,Baux,J2lti,C2aux,D2aux,xi); 

 Kdet{1} = Kaux{1};
 CLaux = [4 6];
 cont = 1;
for i = 1:length(CLaux)
   for k = 1:max(size(A{1}))
       Aaux{cont} = A{CLaux(i)}{k};
       Baux{cont} = B{CLaux(i)}{k};
       JInfaux{cont} = JInf{CLaux(i)}{k};
       J2aux{cont} = J2{CLaux(i)}{k};
       C2aux{cont} = C2{CLaux(i)};
       CInfaux{cont} = CInf{CLaux(i)};
       D2aux{cont} = D2{CLaux(i)};
       DInfaux{cont} = DInf{CLaux(i)};
       cont = cont + 1;
   end
end
[Kaux,gammaLTI]  =  h2inf_state_control_rob_lti(Aaux,Baux,J2aux,JInflti,C2aux,D2aux,CInfaux,DInfaux,xi,gamma2(i)); 
%    [Kaux,gammaLTI]   =  hinf_state_control_rob(Aaux,Baux,JInfaux,CInfaux,DInfaux,xi,0,1);
% [Kaux,gammaLTI]  =  h2_state_control_rob_lti(Aaux,Baux,J2lti,C2aux,D2aux,xi); 
Kdet{2} = Kaux{1};

%% MD
CL = [1 1 1 2 2 3];
% CL = 1:6;
ka = 1:-0.1:0;
% ka = 1;
for j = 1:length(ka)
    for i = 1:N
        if ka == 1
           A{i}{2} = zeros(4,4);
           B{i}{2} = zeros(4,2);
        end
       Aaux = A{i}{1}*ka(j)+A{i}{2}*(1-ka(j));
       Baux = B{i}{1}*ka(j)+B{i}{2}*(1-ka(j));
       Acl{i} = Aaux+Baux*KMD{CL(i)};
       JclInf{i} = JInf{i}{1};
       Jcl2{i} = J2{i}{1};
       Ccl2{i} = C2{i}+D2{i}*KMD{CL(i)};
       CclInf{i} = CInf{i}+DInf{i}*KMD{CL(i)};
    end
    [gammaInfaux(j)]  =  hinf_norm(Acl,JclInf,CclInf,Lambda,[]);
    [gamma2aux(j)]  =  h2_norm(Acl,Jcl2,Ccl2,mu,Lambda,[]);
end
gammaMD = max(gammaInfaux);
gamma2MD = max(gamma2aux);


% [KMD{1};KMD{2};KMD{2}]

%% cluster
% sqrt(gammaInfCL)
% [KCL{1};KCL{2}]
CL = [1 1 1 2 2 2];
% CL = 1:6;
for j = 1:length(ka)
    for i = 1:N
       Aaux = A{i}{1}*ka(j)+A{i}{2}*(1-ka(j));
       Baux = B{i}{1}*ka(j)+B{i}{2}*(1-ka(j));
       Acl{i} = Aaux+Baux*KCL{CL(i)};
       JclInf{i} = JInf{i}{1};
       Jcl2{i} = J2{i}{1};
       Ccl2{i} = C2{i}+D2{i}*KCL{CL(i)};
       CclInf{i} = CInf{i}+DInf{i}*KCL{CL(i)};
    end
    [gammaInfaux(j)]  =  hinf_norm(Acl,JclInf,CclInf,Lambda,[]);
    [gamma2aux(j)]  =  h2_norm(Acl,Jcl2,Ccl2,mu,Lambda,[]);
end
gammaCL = max(gammaInfaux);
gamma2CL = max(gamma2aux);

%% MI
% sqrt(gammaInfMI)
% KMI{1}

CL = [1 1 1 1 1 1];
for j = 1:length(ka)
    for i = 1:N
       Aaux = A{i}{1}*ka(j)+A{i}{2}*(1-ka(j));
       Baux = B{i}{1}*ka(j)+B{i}{2}*(1-ka(j));
       Acl{i} = Aaux+Baux*KMI{CL(i)};
       JclInf{i} = JInf{i}{1};
       Jcl2{i} = J2{i}{1};       
       Ccl2{i} = C2{i}+D2{i}*KMI{CL(i)};
       CclInf{i} = CInf{i}+DInf{i}*KMI{CL(i)};
    end
    [gammaInfaux(j)]  =  hinf_norm(Acl,JclInf,CclInf,Lambda,[]);
    [gamma2aux(j)]  =  h2_norm(Acl,Jcl2,Ccl2,mu,Lambda,[]);
end
gammaMI = max(gammaInfaux);
gamma2MI = max(gamma2aux);


% LTI
% sqrt(gammaLTI)
% KLTI{1}

CL = [1 1 1 1 1 1];
for j = 1:length(ka)
    for i = 1:N
       Aaux = A{i}{1}*ka(j)+A{i}{2}*(1-ka(j));
       Baux = B{i}{1}*ka(j)+B{i}{2}*(1-ka(j));
       Acl{i} = Aaux+Baux*KLTI{CL(i)};
       JclInf{i} = JInf{i}{1};
       Jcl2{i} = J2{i}{1};
       Ccl2{i} = C2{i}+D2{i}*KLTI{CL(i)};
       CclInf{i} = CInf{i}+DInf{i}*KLTI{CL(i)};
    end
    [gammaInfaux(j)]  =  hinf_norm(Acl,JclInf,CclInf,Lambda,[]);
    [gamma2aux(j)]  =  h2_norm(Acl,Jcl2,Ccl2,mu,Lambda,[]);
end
gammaLTI = max(gammaInfaux);
gamma2LTI = max(gamma2aux);



%% robust cluster 
CL = [1 1 1 2 2 2];
for j = 1:length(ka)
    for i = 1:N
       Aaux = A{i}{1}*ka(j)+A{i}{2}*(1-ka(j));
       Baux = B{i}{1}*ka(j)+B{i}{2}*(1-ka(j));
       Acl{i} = Aaux+Baux*Kdet{CL(i)};
       JclInf{i} = JInf{i}{1};
       Jcl2{i} = J2{i}{1};
       Ccl2{i} = C2{i}+D2{i}*Kdet{CL(i)};
       CclInf{i} = CInf{i}+DInf{i}*Kdet{CL(i)};
    end
    [gammaInfaux(j)]  =  hinf_norm(Acl,JclInf,CclInf,Lambda,[]);
    [gamma2aux(j)]  =  h2_norm(Acl,Jcl2,Ccl2,mu,Lambda,[]);
end
gammaRC = max(gammaInfaux);
gamma2RC = max(gamma2aux);


clc
sqrt(gammaMD)
sqrt(gammaCL)
sqrt(gammaMI)
sqrt(gammaLTI)
sqrt(gammaRC)

sqrt(gammaRC)/sqrt(gammaCL)

% 
% sqrt(gamma2MD)
% sqrt(gamma2CL)
% sqrt(gamma2MI)
% sqrt(gamma2LTI)
% sqrt(gamma2RC)

sqrt(gamma2RC)/sqrt(gamma2CL)


load thZ.mat

th = thZ;

for i = 1:length(thZ)

    if(thZ(i)==2)
        thZ(i) = 4;
    end
    if(thZ(i)==3)
        thZ(i) = 6;
    end
    
end
tot = (0:length(th)-1)*0.05;
K = KCL;
% K = Kdet;
% for i = 1:3
%    K{i} = KLTI{1}; 
% end

