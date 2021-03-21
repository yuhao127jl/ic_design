%% reference_signals_tb Testbench for Insertion and Removal of Reference Signals.
%%
%%   This testbench script runs without arguments and checks if the
%%   subsystem of insertion and removal of reference signals works.


% Set system to defined state
clear all;

% Initialization routines
dump_open;
global_settings;
dvbt_send_init;
dvbt_receive_init;

% Import globals
global DVBT_SETTINGS;
global DVBT_STATE_SENDER;
global DVBT_STATE_RECEIVER;

% Parameters and abbreviations
m = 5;
k = DVBT_SETTINGS.payload_carriers;
n = DVBT_SETTINGS.used_carriers;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf ('generating data.\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x = round (rand(k,m)) / DVBT_SETTINGS.refsig.alpha;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf ('inserting reference signals');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
y = zeros(n,m);
for l = 1:m
  fprintf ('.');
  y(:,l) = insert_reference_signals (x(:,l));
end
fprintf ('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf ('removing reference signals');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
z = zeros(k,m);
for l = 1:m
  fprintf ('.');
  z(:,l) = remove_reference_signals (y(:,l));
end
fprintf ('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf ('checking data:');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if max(max(z - x)) >= 100*eps
  fprintf (' error.\n');
  dump_close;
  error ('reference signal values incorrect.\n');
end
fprintf (' OK.\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cleanup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dump_close;
fprintf ('\n');
fprintf ('reference signals work.\n');

