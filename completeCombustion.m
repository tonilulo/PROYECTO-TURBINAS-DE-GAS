function [n_CO2, n_H2O, n_O2, n_N2, f] = completeCombustion(a, b, c, lambda)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

M_fuel = a*12+b*1;
M_air = 0.79*2*14 + 0.21*2*16;

n_CO2 = a;
n_H2O = b/2;
n_O2 = (lambda-1)*(a+b/4);
n_N2 = 79/21*lambda*(a+b/4)+c/2;

% 1 kg/s fuel is assumed:

m_dot_fuel = 1;

n_dot_fuel = 

end

