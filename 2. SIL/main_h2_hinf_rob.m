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



mu = [1/3 0 0 1/3 0 1/3];

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
    C2{i} = C_lat2;
    D2{i} = D_lat2;
    CInf{i} = C_latInf;
    DInf{i} = D_latInf;
    J2{i}{k} = [-1;10;-1;5];
    JInf{i}{k} = B_lat*[1 ;0];
end

B{2}{k} = B_lat*[2 0;0 1];
B{3}{k} = B_lat*[2 0;0 -1];

k = 2;
for i = 1:N
    A{i}{k} = A_lat2;
    B{i}{k} = B_lat2;
    C2{i} = C_lat2;
    D2{i} = D_lat2;
    J2{i}{k} = [1;5;1;3];
    
    CInf{i} = C_latInf;
    DInf{i} = D_latInf;
    JInf{i}{k} = B_lat2*[1 ;0];
end

B{2}{k} = B_lat2*[2 0;0 1];
B{3}{k} = B_lat2*[2 0;0 -1];


[K,gamma]  =  h2_state_control_rob(A,B,J2,C2,D2,100,Lambda,mu,CL);



gamma2 = linspace(210,510,50);

for i = 1:length(gamma2)
    [K,gammaInf(i)]  =  h2inf_state_control_rob(A,B,J2,JInf,C2,D2,CInf,DInf,100,Lambda,mu,CL,gamma2(i));   %% 225 min,  
end

close all
figure(1)
 set(0, 'FixedWidthFontName', 'Courier New');
set(gcf, 'PaperPositionMode', 'auto')
set(gca, 'Units','normalized','Position',[0.2 0.15 0.70 0.75]);
FS = 12;
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontUnits','normalized','FontSize',0.1)

plot(gamma2/max(gamma2),gammaInf/max(gammaInf),'k','LineWidth',2)
xlim([0.2 1.1])
ylim([0 1.1])

ylabel('\sffamily{$$\gamma^2_{\infty}/\max(\gamma_{\infty}^2)$$}','Interpreter','latex','FontSize',FS) 
xlabel('\sffamily{$$\gamma^2_2/\max(\gamma_2^2)$$}','Interpreter','latex','FontSize',FS)

print('trade_off_mixed','-depsc')

% i  = max(find(gamma2(:)/max(gamma2) < 0.50 ));

i = 5
[K,gammaInf(i)]  =  h2inf_state_control_rob(A,B,J2,JInf,C2,D2,CInf,DInf,100,Lambda,mu,CL,gamma2(i))

% Kaux = lqr(A{1},

Ts = 0.05;
P = eye(6)+Lambda*Ts; % first order approx
