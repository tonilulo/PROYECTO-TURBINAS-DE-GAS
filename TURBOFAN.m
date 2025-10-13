clear all;
close all;
clc

% EXCEL PARAMETERS
OPR_design = 35.5;
alpha = 10.7;
hPR = 43.26e6;%??

% CHOOSEN PARAMETERS
h0 = 11000;%??
M0 = 0.7;%??

Tt4 = 1700;       

% ASSUMED PARAMETERS
pi_fan = 1.8;  


pi_inlet = 0.99;
pi_burner = 0.9;

efficiency_Fan = 0.9;
efficiency_LPC = 0.9;
efficiency_HPC = 0.85;
efficiency_Burner = 0.97;

efficiency_MECH_HP = 0.99;
efficiency_MECH_LP = 0.99;

efficiency_HPT = 0.92;
efficiency_LPT = 0.92;

efficiency_Nozzle_CORE = 0.89;
efficiency_Nozzle_SEC = 0.9;


R_Cold = 287;%??
Cp_Cold = 1005;
Gamma_Cold = 1.4;%??
Cp_Hot = 1150;
Gamma_Hot = 1.3;%??
R_hot = Cp_Hot*(Gamma_Hot-1)/Gamma_Hot;


% --- Constant between iterations ----
% Freestream
T0 = 25+273.15;
P0 = 1e5;
v0 = M0 * sqrt(Gamma_Cold * R_Cold * T0);
Tt0 = T0 * (1 + ((Gamma_Cold -1)/2) * M0^2);
Pt0 = P0 * (1 + ((Gamma_Cold -1)/2) * M0^2)^(Gamma_Cold/(Gamma_Cold-1));

% Inlet
Tt2 = Tt0;
Pt2 = Pt0 * pi_inlet;

% % Fan
% Tt13 = Tt2 * ((1/efficiency_Fan)*(pi_fan^((Gamma_Cold-1)/Gamma_Cold) - 1) + 1);
% Pt13 = Pt2 * pi_fan;
% 
% pi_LPC_design = OPR_design/(pi_HPC_design*pi_fan);