%% inner_deinterleave Inner (block) Deinterleaver.

function [data_out] = inner_deinterleave (data_in)


  global DVBT_STATE_SENDER;
  global DVBT_STATE_RECEIVER;
  payload_carriers = 1512;
  map_bits = 4;
  block_size = 126;
  symbol_length = payload_carriers*map_bits;

  % Perform actions
  sblock_size=block_size*map_bits;
  
  [symbol_size, should_be_log2_qam_mode] = size (data_in);
  num_blocks=symbol_size/block_size;
  
  data_out = zeros (symbol_length, 1);

  % Step 1: Reverse Symbol Interleaver
  y = zeros (symbol_length/map_bits, map_bits);
  for i = 1:symbol_length/map_bits
    if rem(DVBT_STATE_RECEIVER.l, 2) == 0
      y(i,:) = data_in(1+DVBT_STATE_SENDER.inner_interleaver.Hq(i),:);
    else
      y(1+DVBT_STATE_SENDER.inner_interleaver.Hq(i),:) = data_in(i,:);
    end
  end

  for i = 1:num_blocks
    a = y(1+(i-1)*block_size:i*block_size,:);

    % Step 2: Reverse Bit Interleaver
    b=zeros (block_size, map_bits);
    h_param=[0 63 105 42 21 84];
    for e = 0:map_bits-1
      for w = 0:block_size-1
        % compute H(e,w)
        h=rem(w+h_param(1+e), block_size);
        b(1+h,1+e) = a(1+w,1+e);
      end
    end
    
    % Step 3: Demultiplexer
    a = zeros (block_size, map_bits);
        mapping=[0 2 1 3];
     
    for k = 1:map_bits
      a(:,k) = b(:,1+mapping(k));
    end

    data_out(1+(i-1)*sblock_size:i*sblock_size) =...
        reshape (a', sblock_size, 1);
  end
