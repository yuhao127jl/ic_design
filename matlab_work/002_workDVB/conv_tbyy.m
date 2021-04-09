%% convolutional_tb Testbench for Convolutional Encoder and Decoder
%%
%%   This testbench script runs without arguments and checks if the
%%   subsystem of convolutional encoder and decoder works.

% Set system to defined state
clear all;

% Initialization routines
dump_open;
global_settings;
dvbt_send_init;
dvbt_receive_init;

% Import globals
global DVBT_SETTINGS;


% Parameters and abbreviations
m = 1;
n = DVBT_SETTINGS.symbol_length.bit_stream;

fprintf ('generating data.\n');
x = round(rand(n,m));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf ('encoding (simple)');
DVBT_SETTINGS.convolutional_code.use_kammeyer = 0;
y_simple_x = zeros(n,m);
y_simple_y = zeros(n,m);
  [y_simple_x, y_simple_y] = convolutional_encode (x);
fprintf ('\n');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf ('decoding (simple)');
DVBT_SETTINGS.convolutional_code.use_kammeyer = 0;
z_simple = zeros(n,m);
for l = 1:m
  fprintf ('.');
  DVBT_STATE_RECEIVER.convolutional_code = ...
      DVBT_SETTINGS.convolutional_code.init_register;
  z_simple(:,l) = convolutional_decode (y_simple_x(:,l), y_simple_y(:,l));
end
fprintf ('\n');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf ('checking data:');
fprintf (' (simple)');
if any(any(z_simple ~= x))
  fprintf (' error in simple codec.\n');
  error ('convolutional code incorrect.');
end
fprintf (' OK.\n');

fprintf ('convolutional code works.\n');

