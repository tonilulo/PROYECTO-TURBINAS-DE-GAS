clear;
close all;
clc

%% Input data

scenario1 = [1e5, 25+273, 0];   % P (Pa), T (K), v (m/s)
scenario2 = [0.3e5, -45+273, 250];   % P (Pa), T (K), v (m/s)

pi_fan = 1.8;  
pi_c = 16;

alpha = 5;              % By-Pass Ratio
hPR = 44.24e6;          % C10H22(l)         ASSUMED!!!

T_Fin = 25;             % ??                TO CALCULATE h_f!!
Tt4 = 1600;         

eta_pf = 0.9;
eta_pc = 0.9;
eta_pt = 0.92;

eta_nc = 0.96;          % ??
eta_nb = 0.96;          % ??

eta_m = 0.99;

eta_cc = 0.97;

deltaP_34 = 0.05e5;     % Pa

m_dot = 220;            % kg/s

m_dot_core = m_dot/(1+alpha);
m_dot_sec  = alpha/(1+alpha)*m_dot;

S_0 = 3; S_1 = 3.75;    % m^2

c_pa = 1005;            % J/(kg·K)
c_pg = 1150;            % J/(kg·K)

R_a = 287;
R_g = 287.6;            % ???

%% Computations

gamma_a = c_pa / (c_pa-R_a);
gamma_g = c_pg / (c_pg-R_g);


%% Thermodynamic cycle

% Freestream (0)
T0 = scenario1(2);
P0 = scenario1(1);
v0 = scenario1(3);
a0 = sqrt(gamma_a*R_a*T0);
M0 = v0/a0;
rho0 = P0/(R_a*T0);

Tt0 = T0 * (1 + ((gamma_a -1)/2) * M0^2);
Pt0 = P0 * (1 + ((gamma_a -1)/2) * M0^2)^(gamma_a/(gamma_a-1));

% Inlet (1)
pi_inlet = 0.99;
Tt1 = Tt0;
Pt1 = Pt0 * pi_inlet;

% Fan (2)
tau_fan = pi_fan^((gamma_a-1)/(gamma_a*eta_pf));
Tt2 = Tt1 * tau_fan;
Pt2 = Pt1 * pi_fan;

% Compressor (3)
tau_c = pi_c^((gamma_a-1)/(gamma_a*eta_pc));
Tt3 = Tt2 * tau_c;
Pt3 = pi_c * Pt2;

% m_dot = rho*v*A
% rho = p/(RT)

% Combustion chamber (4)
f = (c_pg*Tt4-c_pa*Tt3)/(eta_cc*hPR-c_pg*Tt4);
Pt4 = Pt3 + deltaP_34;                              %% NOT CORRECT. STATIC PRESSURES

% High Pressure Turbine (5)
tau_HPT = 1 - c_pa*(Tt3-Tt2) / (eta_m*(1+f)*c_pg*Tt4);
Tt5 = tau_HPT*Tt4;
pi_HPT = (tau_HPT)^(gamma_g/((gamma_g-1)*eta_pt));
Pt5 = pi_HPT*Pt4;

% Low Pressure Turbine (6)
tau_LPT = 1 - c_pa*(Tt2-Tt1) / (eta_m*(1+f)*c_pg*Tt5);
Tt6 = tau_LPT*Tt5;
pi_LPT = (tau_LPT)^(gamma_g/((gamma_g-1)*eta_pt));
Pt6 = pi_LPT*Pt5;

% Core Nozzle (7)
Tt7 = Tt6;

M7 = 1;         % First, chocked nozzle is assumed
T7 = Tt7 / (1+gamma_g*R_g*M7^2/(2*c_pg));
v7 = M7*sqrt(gamma_g*R_g*T7);
T7s = ((T7-Tt6) / eta_nc) + Tt6;
P7 = Pt6 * (T7s/Tt6)^(gamma_g/(gamma_g-1));

if P7 > P0      % If not chocked nozzle, matched nozzle
    
    P7 = P0;
    T7s = Tt6 * (P7/Pt6)^((gamma_g+1)/gamma_g);
    T7 = eta_nc * (T7s-Tt6) + Tt6;
    v7 = sqrt((Tt6-T7) * 2*c_pg);
    M7 = v7 / sqrt(gamma_g*R_g*T7);

end

rho7 = P7/(R_g*T7);

% By-pass Nozzle (8)
Tt8 = Tt2;

M8 = 1;         % First, chocked nozzle is assumed
T8 = Tt8 / (1+gamma_a*R_a*M8^2/(2*c_pa));
v8 = M8*sqrt(gamma_a*R_a*T8);
T8s = ((T8-Tt2) / eta_nb) + Tt2;
P8 = Pt2 * (T8s/Tt2)^(gamma_a/(gamma_a-1));

if P8 > P0      % If not chocked nozzle, matched nozzle
    
    P8 = P0;
    T8s = Tt2 * (P8/Pt2)^((gamma_a+1)/gamma_a);
    T8 = eta_nb * (T8s-Tt2) + Tt2;
    v8 = sqrt((Tt2-T8) * 2*c_pa);
    M8 = v8 / sqrt(gamma_a*R_a*T8);

end

rho8 = P8/(R_a*T8);

%% Performance analysis

% Areas
A7 = ( (1+f)*m_dot_core )/(rho7*v7);  
A8 = ( m_dot_sec )/(rho8*v8);        

% Uninstalled thrust
F_core=(1+f)*m_dot_core*v7-m_dot_core*v0 + (P7 - P0)*A7;
F_sec=m_dot_sec*v8-m_dot_sec*v0  + (P8 - P0)*A8;
F=F_core + F_sec;

F_core_sp = F_core/m_dot_core;   % [m/s]
F_sec_sp= F_sec /m_dot_sec;    % [m/s]
F_sp= F/m_dot;             % [m/s]
FR= F_core/F_sec;
F_adim= F/(a0*m_dot);

% TSFC and F_sp
g0   = 9.81;
TSFC = f/((1+alpha)*F_sp); % [kg/(N·s)]
I_sp = ((1+alpha)/f)*(F_sp/g0);  % [s]

delta_e_k = 0.5*((1+f)/(1+alpha)*v7^2 + (alpha/(1+alpha))*v8^2 - v0^2); % [J/kg]

% Eficiencies
eta_T = (1+alpha)*delta_e_k/(f*hPR);
eta_P = (v0*F_sp)/delta_e_k;
eta_O = eta_T*eta_P;
