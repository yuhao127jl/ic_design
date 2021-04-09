%% digital_frontend Digital frontend for DVB-T reciever.
%%
%%   y = digital_frontend (x) performs digital frontend filtering for
%%   the DVB-T reciever. It performs gain control, synchronization,
%%   and sample rate conversion if applicable.


function output = digital_frontend (input)

  global VISUALIZATION;
  
  %% Visualization
  if VISUALIZATION.signal 
  %figure(VISUALIZATION.figure.signal);
  %gset title "channel signal";
  %gplot real(input) title 'real' with lines, ...
  %imag(input) title 'imag' with lines;
  %scatterplot(input);
  end

  input = gain_control (input);
  synchronization (input);

  output = sample_rate_conversion (input);
