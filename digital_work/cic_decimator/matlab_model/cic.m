%------------------------------------------------------------
%
% CIC fileter model
%
%------------------------------------------------------------

D = 2;  % delay param is 2
R = 32; % decimator rate is 32
N = 3;  % CIC level

xn = 100 .* ones(1,300);
q = quantizer([8 0], 'fixed');

ym = cicdecimate(D, N, R, xn, q);


