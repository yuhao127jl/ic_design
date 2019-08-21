%% channel_model Simulates a transmission channel.
%%
%%   y = channel_model(x) transmits a complex data vector with values in
%%   the range of -1:1 over a simulated transmission channel.
%%   The trivial channel model is implemented,
%%   i.e., the transmission function is identity.

function data_channel_out = channel_model (data_channel_in)

  % Perform actions
  %data_channel_out = data_channel_in;
  %for t = 280/2560: 280/2560: 2560
     % data_in(t) = data_channel_in;
  data_channel_out = awgn(data_channel_in ,50,'measured');
% Add white Gaussian noise.
%c = rayleighchan(1/10000,100);

%data_channel_out = filter(c,data_channel_in); % Pass signal through channel.
 % Display all properties of the channel object.

  
