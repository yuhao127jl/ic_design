function data_out = descramble (data_in)

  global DVBT_SETTINGS;
  global DVBT_STATE_RECEIVER;
  

  n = 188;

  [should_be_n, should_be_one] = size (data_in);
  sync_byte = data_in(1);
   fid = fopen(['.' '/receive.txt'], 'w');
  
  switch sync_byte
    case hex2dec('B8') 
      if rem(DVBT_STATE_RECEIVER.n, 8) ~= 0
        fprintf (fid, 'descramble: resyncing c from %d to 0\n', ...
        DVBT_STATE_RECEIVER.n);
	  DVBT_STATE_RECEIVER.n = 0;
      end
      DVBT_STATE_RECEIVER.scrambler.prbs_register = ...
          [1 0 0 1 0 1 0 1 0 0 0 0 0 0 0];
    case hex2dec('47')
      [ignore, DVBT_STATE_RECEIVER.scrambler.prbs_register] = ...
          scrambler_prbs (1, DVBT_STATE_RECEIVER.scrambler.prbs_register);
    otherwise
      fprintf (fid, 'descramble: dropping invalid packet\n',sync_byte);
      data_out = [];
      return;
  end
  
   % Perform actions
  bit_length = 8 * (n-1);
  shift_register = DVBT_STATE_RECEIVER.scrambler.prbs_register;
  
  bit_sequence = zeros(bit_length,1);
  for i = 1:bit_length
    new_bit = xor (shift_register(14), shift_register(15));
    shift_register = [new_bit shift_register(1:14)];
    bit_sequence(i) = new_bit;
  end

  prbs = bi2de(reshape(bit_sequence, 8, n-1)', 'left-msb');
  DVBT_STATE_RECEIVER.scrambler.prbs_register = shift_register;
 
 
  data_out=[hex2dec('47') ;bitxor(data_in(2:n),prbs)];

  
  
  
  
  