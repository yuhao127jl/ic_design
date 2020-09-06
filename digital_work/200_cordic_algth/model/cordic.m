% ****************************************************************************
% Projet      :                                
% Filename    :    cordic.m                     
% Description :                                
% Author      :                                     
% Data        :    09/06/2020 
% ****************************************************************************
clc; clear all; close all;

x = 10;
y = 20;
x_n = zeros(12, 1);
y_n = zeros(12, 1);

% 
i = 1;
[x_n(i), y_n(i)] = cordic_atan(x, y, pi/(bitshift(2, i)));
fprintf('shift %d result is \t %f, %f \n', i, x_n(i), y_n(i));

% 
N = 4;
for i = 2:N
    if(y_n(i-1) > 0)
        [x_n(i), y_n(i)] = cordic_atan(x_n(i-1), y_n(i-1), pi/(bitshift(2, i)));
    else
        [x_n(i), y_n(i)] = cordic_atan(x_n(i-1), y_n(i-1), -pi/(bitshift(2, i)));
    end
    fprintf('shift %d result is \t %f, %f \n', i, x_n(i), y_n(i));
end






