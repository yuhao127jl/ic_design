%% rs_tb Testbench for Reed/Solomon Encoder and Decoder
%%
%%   This testbench script runs without arguments and checks if the
%%   subsystem of Reed/Solomon encoder and decoder works.

% Set system to defined state
clear all;

% Initialization routines
dump_open;
global_settings;
%dvbt_send_init;
dvbt_receive_init;

% Import globals
global GF;
global DVBT_SETTINGS;
global DVBT_STATE_SENDER;
global DVBT_STATE_RECEIVER;

% Parameters and abbreviations
m = 49;
k = DVBT_SETTINGS.rs.k;
n = DVBT_SETTINGS.rs.n;
t = DVBT_SETTINGS.rs.t;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf ('generating data.\n');% index means the number of the 204 packets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = floor(rand(k,m)*255.99);
for index = 1:m
  if rem(index,8) == 0
    x(1,index) = DVBT_SETTINGS.scrambler.inv_sync_byte;
  else
    x(1,index) = DVBT_SETTINGS.scrambler.sync_byte;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf ('Reed/Solomon encode');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
y = zeros(n,m);
for index = 1:m
  fprintf ('.');
  y(:,index) = rs_encode (x(:,index));
end
fprintf ('\n');
fprintf ('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf ('Checking encode');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%for index = 1:m
  %fprintf ('.');
  %if any(any(rs_syndrome (y(:,index)) ~= 0))
   % error ('incorrectly encoded data.');
  %end
%end
%fprintf ('OK\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Error simulation\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for index = 1:m
  num_errors = rem(index, (t+1));
  for err = 1:num_errors
    pos = floor(1+rand(1,1)*(n-0.01));
    y(pos,index) = floor (rand(1,1) * 255.99);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf ('Reed/Solomon decode');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
z = zeros(k,m);
for index = 1:m
  fprintf ('.');
  z(:,index) = rs_decode (y(:,index));
end
fprintf ('OK\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf ('checking data:');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(any(z ~= x))
  fprintf (' error.\n');
  error ('Reed/Solomon incorrect.\n');
else
fprintf (' OK.\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cleanup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf ('\n');
fprintf ('Reed/Solomon works.\n');
