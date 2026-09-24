% Cessna 172 Modeling

%**************************************************************************
% Cessna Dimensional and Mass Data
%*************************************************************************
S = 174; %(ft^2) Wing area (check)
b = 36; % (ft) Wing span  (check)
c = 4.9; %(ft) Mean Aerodynamic Chord (check)

g = 32.2; % (ft/sec^2) Acceleration due to Earth Gravity
W = 2650; % (lb) Weight
m = W/g; % (Slugs) mass (check)
I_x = 948; %(Slug-ft^2) Moment of inertia about Roll axis (check)
I_y = 1346; % (Slug-ft^2) Moment of inertia about the Pitch axis (check)
I_z = 1967; % (Slug-ft^2) Moment of inertia about the Yaw axis 

% Flight Conditions
H = 5000; % (ft) Cruising Altitude
M = 0.201; %Mach number
u_0 = 130; % (ft/sec) Airpeed
Q = 49.6; % (lb/ft^2) Dynamic Pressure

%*************************************************************************
% Longitudinal coeficients
%*************************************************************************
C_L0 = 0.307; % Reference airspeed lift coefficient
C_D0 =  0.0270; % Reference airspeed drag coefficient
C_Lalfa = 4.4100;
C_Dalfa = 0.1210; 
C_malfa = -0.6130;
C_Lalfa_dot = 1.7000;
C_malfa_dot = -7.27001;
C_Lq = 3.9000;
C_mq = -12.4000;
C_LM = 0.2;
C_Ldelta_e = 0.43;
C_mdelta_e = -1.122;
C_m0 = 0.04;

C_Du = 0.0000;
C_mu = 0.0000;
C_Lu = 0.0000;

C_Ddelta_e = 0;
X_delta_T = 0.01221;
Z_delta_T = 0;

%*************************************************************************
% Lateral coeficients
%*************************************************************************
C_ybeta = -0.393;
C_lbeta = -0.0923;
C_nbeta = 0.0587;
C_lp = -0.484;
C_np = -0.0278;
C_lr = 0.0798;
C_nr = -0.0937;
C_ldelta_a = 0.229;
C_ndelta_a = -0.0216;
C_ydelta_r = 0.187;
C_ldelta_r = 0.0147;
C_ndelta_r = -0.0645;
C_yp = -0.0750;
C_yr = 0.214;
theta_0 = 0; % condição inicial para pitch.


%***********************************************************************
% Summary of longitudinal derivates
%***********************************************************************
% Variables
  % u is the Forward Velocity.
  % w is the Vertical Velocity.
  % q is the Pitch Rate.
  % w_dot is the Vertical Acceleration.
  % delta_e is the Elevator Deflection angle.
  % delta_T is the Thrust supplied by the power plants.

Xu = -((C_Du+2*C_D0)*Q*S)/(m*u_0);
%C_du is the change in the drag coefficient dependent on forward speed and 
%C_D0 is the reference airspeed drag coefficient

Xw = -((C_Dalfa-C_L0)*Q*S)/(m*u_0);
% C_Dalfa is the change in the drag coefficient dependent on angle of attack
% C_L0 is the reference airspeed lift coefficient

X_delta_e= -((Q*S*C_Ddelta_e)/m);

Zu = -((C_Lu+2*C_L0)*Q*S)/(m*u_0); % C_Lu is the change in the lift coefficient 
%dependent on the Mach number

Zw = -((C_Lalfa+2*C_D0)*Q*S)/(m*u_0);
% C_Lalfa is the change in the Lift Coefficient dependent on the angle of
% attack.

%Zwdot= -(C_Zalfa_dot*(c/(2*u_0)))*Q*S/(m*u_0);
% C_Zalta_dot is the Stability Coefficient due to the change in Z force
% dependent on the Pitch Rate. The Z force acts downward in the Yaw Axis direction.

%Z_alfa = u_0*Zw; 

%Z_alfa_dot = u_0*Zw_dot;

%Zq = -(C_Zq*(c/(2*u_0))*Q*S)/m
% C_Zq is the Stability Coefficient due to the change in Z force dependent
% on the Pitch Velocity q

Z_delta_e = -(C_Ldelta_e*Q*S)/m; %C_Zdelta_e is the Stability Coefficient due
% to the change in Elevator Deflection

Mu = (C_mu*(Q*S*c/(u_0*I_y))); % C_mu is the change in Pitch Moment dependent 
% on reference Airspeed. This is a function of the Mach number and the 
% elastic properties of the airframe.

Mw = (C_malfa*(Q*S*c)/(u_0*I_y)); % C_malfa is the Stability Coefficient 
%representing the change in Pitch Moment Coefficient due to Pitch Angle.

Mwdot= (C_malfa_dot*(c/(2*u_0))*(Q*S*c/(u_0*I_y))); % C_malfa_dot is the Stability
%Coefficient representing the change in Pitch Moment Coefficient due to 
%Pitch Rate.

%M_alfa=u_0*M_w;

%M_alfadot = u_0*M_wdot;

Mq = ((C_mq*(c/(2*u_0*I_y))*(Q*S*c))); % C_mq is the Stability Pitch Moment Coefficient 
% due to the Pitch Velocity.

M_delta_e = (C_mdelta_e*((Q*S*c)/I_y)); % C_mdelta_e is the Stability Pitch Moment 

% Coefficient due to the Elevator Deflection.

%*************************************************************************    
% Summary of lateral derivates
%*************************************************************************

Y_beta = ((Q*S*C_ybeta)/m); %(ft/s^2)

N_beta = ((Q*S*b*C_nbeta)/I_z); %(s^-2)

L_beta = ((Q*S*b*C_lbeta)/I_x); %(s^-2)

Yp = ((Q*S*b*C_yp)/(2*m*u_0)); %(ft/m)

Np = ((Q*S*b^2*C_np)/(2*I_z*u_0)); %(s^-1)

Lp = ((Q*S*b^2*C_lp)/(2*I_x*u_0)); %(s^-1)

Yr = ((Q*S*b*C_yr)/(2*m*u_0)); %(ft/s)

Nr = ((Q*S*b^2*C_nr)/(2*I_z*u_0)); %(s^-1)

Lr = ((Q*S*b^2*C_lr)/(2*I_x*u_0)); %(s^-1)

%Y_delta_a = ((Q*S*C_ydelta_a)/m); %(ft/s^2)

N_delta_a = ((Q*S*b*C_ndelta_a)/I_z); %(s^-2)

L_delta_a = ((Q*S*b*C_ldelta_a)/I_x); %(s^-2)

Y_delta_r = ((Q*S*C_ydelta_r)/m); %(ft/s^2)

N_delta_r = ((Q*S*b*C_ndelta_r)/I_z); %(s^-2)

L_delta_r = ((Q*S*b*C_ldelta_r)/I_x); %(s^-2)

% Longitudinal model, Ax+Bu %% states [Vt alp q theta] input [elevator
% throtle], lembrar que  w = alp x Vt 
% A_long = [Xu Xw 0 -g; 
%           Zu Zw u_0 0; 
%          (Mu+(Mwdot*Zu)) (Mw+(Mwdot*Zw)) (Mq+(Mwdot*u_0)) 0;
%          0 0 1 0];

A_long = [Xu Xw/u_0 0 -g; 
          Zu/u_0 Zw/u_0^2 1 0; 
         (Mu+(Mwdot*Zu)) (Mw+(Mwdot*Zw))/u_0 (Mq+(Mwdot*u_0)) 0;
         0 0 1 0];

B_long = [X_delta_e X_delta_T; Z_delta_e/u_0 Z_delta_T/u_0; (M_delta_e+(Mwdot*Z_delta_e)) 0; 0 0];
C_long = eye(4);
D_long = [0 0; 0 0; 0 0; 0 0];

eigenvalues = eig(A_long);
[eigenvectors eigenvalues] = eig(A_long);

%Lateral model, Ax+bu [beta p r phi]
A_lat= [(Y_beta/u_0) (Yp/u_0) -(1-(Yr/u_0)) ((g*cos(theta_0))/u_0); L_beta Lp Lr 0; N_beta Np Nr 0; 0 1 0 0];
B_lat = [0 Y_delta_r/u_0; L_delta_a L_delta_r;N_delta_a N_delta_r; 0 0];
% 
% A_lat= [-1 0 0 0;0 -1 0 0;0 0 -1 0;0 0 0 -1]*[(Y_beta/u_0) (Yp/u_0) -(1-(Yr/u_0)) ((g*cos(theta_0))/u_0); 
%         L_beta Lp Lr 0; 
%         N_beta Np Nr 0; 
%         0 1 0 0]*[-1 0 0 0;0 -1 0 0;0 0 1 0;0 0 0 -1];
% 
% B_lat = [-1 0 0 0;0 -1 0 0;0 0 1 0;0 0 0 1]*[0 Y_delta_r/u_0;
%         L_delta_a L_delta_r;
%         N_delta_a N_delta_r;
%         0 0];
    
inv(A_lat)*B_lat*[1 0;0 1]    
    
    
 C_lat = eye(4);
D_lat = [0 0; 0 0; 0 0; 0 0];

eigenvalues = eig(A_lat);
[eigenvectors eigenvalues] = eig(A_long);


% Q_long = [0 0 0 0;0 0.1 0 0;0 0 0.01 0;0 0 0 0.1];
Q_long = [1e-7 0 0 0;0 1 0 0;0 0 0.01 0;0 0 0 8];
% Q_long = zeros(4,4);
% R_long = 10*[1 0;0 1];
R_long = 10*[1 0;0 1];

i = 2;
Aext = [A_long zeros(4,i);[[0 1 0 0;0 0 0 1] zeros(i,i)]];
Bext = [B_long;zeros(i,2)];
Qext = [Q_long zeros(4,i);zeros(i,4) [1e-2 0;0 2]];

Kext = lqr(Aext,Bext,Qext,R_long);
Klong = lqr(A_long,B_long,Q_long,R_long);


% eig(A_long-B_long*Klong)
% 
Q_lat = [1 0 0 0;0 1 0 0;0 0 1 0;0 0 0 10];
R_lat = 5000*[1 0;0 1];

Klat = lqr(A_lat,B_lat,Q_lat,R_lat);


%% elevator trim %% nelson (2.48)
deleTrim = -(C_m0/C_mdelta_e);



