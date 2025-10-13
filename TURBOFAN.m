clear;
close all;
clc

%% Input data

scenario1 = [1e5, 25+273, 0];   % P (Pa), T (K), v (m/s)
scenario2 = [0.3e5, -45+273, 250];   % P (Pa), T (K), v (m/s)

pi_fan = 1.8;  
pi_c = 16;

alpha = 5;              % By-Pass Ratio
hPR = 44.24e6;          % C10H22(l)

T_Fin = 25;             % ??
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

S_0 = 3; S_1 = 3.75;    % m^2

c_pa = 1005;            % J/(kg·K)
c_pg = 1150;            % J/(kg·K)

R_a = 287;
R_g = 287.6;            % ???

%% Computations

gamma_a = c_pa / (c_pa-R_a);
gamma_g = c_pg / (c_pg-R_g);


%% Scenario 1

% Freestream (0)
T0 = scenario1(2);
P0 = scenario1(1);
v0 = scenario1(3);
a0 = sqrt(gamma_a*R_a*T0);
M0 = v0/a0;

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

% Combustion chamber (4)
f = (c_pg*Tt4-c_pa*Tt3)/(eta_cc*hPR-c_pg*Tt4);
Pt4 = Pt3 + deltaP_34;

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
