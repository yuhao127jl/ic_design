%% scrambler_prbs Pseudo Random Bit Sequence for use of Scrambler.

function [byte_sequence, state_out] = scrambler_prbs (byte_length, state_in)


  % Perform actions
  bit_length = 8 * byte_length;
  shift_register = state_in;
  
  bit_sequence=zeros(bit_length,1);
  for i = 1:bit_length
    new_bit = xor (shift_register(14), shift_register(15));
    shift_register = [new_bit shift_register(1:14)];
    bit_sequence(i) = new_bit;
  end

  byte_sequence = bi2de(reshape(bit_sequence, 8, byte_length)', 'left-msb');
  state_out = shift_register;
