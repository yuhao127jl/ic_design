function data_out = outer_interleave (data_in)

  % declarations
  global DVBT_STATE_SENDER;

  i = 12;
  m = 17;
  n = 204;
  l = 12*204;

  % outer interleave
  for mm = 1:m
    for ii = 1:i
      DVBT_STATE_SENDER.outer_interleaver.queue...
	  ((ii-1)*n + (mm-1)*i + ii) = data_in((mm-1)*i + ii);
    end
  end

  data_out = DVBT_STATE_SENDER.outer_interleaver.queue(1:n);
  DVBT_STATE_SENDER.outer_interleaver.queue = ...
      [ DVBT_STATE_SENDER.outer_interleaver.queue(n+1:l) ;
       zeros(n,1) ];
  