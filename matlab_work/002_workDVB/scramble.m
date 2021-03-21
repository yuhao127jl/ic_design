function data_out = scramble (data_in)
 global DVBT_STATE_SENDER;
 global prbs_register;
  n = 188;

  % insert the sync byte
  if rem(DVBT_STATE_SENDER.n,8) == 0
    % first packet: invert sync byte and reset prbs state
    sync_byte = hex2dec('B8');
    prbs_register = [1 0 0 1 0 1 0 1 0 0 0 0 0 0 0];
  else
    % following packets: leave sync byte and advance PRBS by one
    sync_byte = hex2dec('47');
  
  sync_bit_length = 8; % 8*187
  shift_register = prbs_register;
  sync_bit_sequence = zeros(sync_bit_length,1); 
  for i = 1:sync_bit_length
    new = xor (shift_register(14), shift_register(15));
    shift_register = [new shift_register(1:14)];
    sync_bit_sequence(i) = new;
  end
  ignore = bi2de(reshape(sync_bit_sequence, 8, 1)', 'left-msb');
  prbs_register = shift_register;
  end
 
  bit_length = 8*(n-1); % 8*187
  shift_register = prbs_register;
  bit_sequence = zeros(bit_length,1); 
  for i = 1:bit_length
    newbit = xor (shift_register(14), shift_register(15));
    shift_register = [newbit shift_register(1:14)];
    bit_sequence(i) = newbit;
  end
  prbs = bi2de(reshape(bit_sequence, 8, n-1)', 'left-msb'); 
  prbs_register = shift_register;
  %data out
  data_out=[sync_byte ; bitxor(data_in(2:n),prbs)]; 
