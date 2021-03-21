function data_out = outer_deinterleave (data_in)
  
  % Global declarations
  global DVBT_STATE_RECEIVER;

   i = 12;
  m = 17;
  n = 204;
  l = 12*204;
  
  % Perform actions!!!!
  for mm = 1:m
    for ii = 1:i
      DVBT_STATE_RECEIVER.outer_interleaver.queue...
	  ((i-ii)*n + (mm-1)*i + ii) = data_in((mm-1)*i + ii);
    end
  end

  data_out = DVBT_STATE_RECEIVER.outer_interleaver.queue(1:n);
  DVBT_STATE_RECEIVER.outer_interleaver.queue = ...
      [ DVBT_STATE_RECEIVER.outer_interleaver.queue(n+1:l) ;
       zeros(n,1) ]; 