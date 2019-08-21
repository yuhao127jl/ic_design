%% inner_interleave Inner (block) Interleaver.
function [data_out] = inner_interleave (data_in)

  % declarations
  global DVBT_STATE_SENDER;
  payload_carriers = 1512;
  map_bits = 4;
  block_size = 126;
  symbol_length = payload_carriers*map_bits;

  % Perform actions
  sblock_size=block_size*map_bits; %126*4
  
  [symbol_size, should_be_one] = size (data_in);
  num_blocks=symbol_size/sblock_size;
  y = zeros (symbol_length/map_bits, map_bits);%1512*m
  for i = 1:num_blocks
    x=data_in(1+(i-1)*sblock_size:i*sblock_size);
    %divided the input data into groups, every group has 126*4 bit 

    % Step 1: Demultiplexer
    a=reshape (x, map_bits, 126)';
    b=zeros (126, map_bits);
    mapping=[0 2 1 3];% 16QAM mode
    b(:,1+mapping) = a;
    
    [should_be_ii_block_size, should_be_log2_qam_mode] = size (b); %126*4

    % Step 2: Bit Interleaver
    a=zeros (126, map_bits);
    h_param=[0 63 105 42 21 84];
    for e = 0:map_bits-1
      for w = 0:125
        % compute H(e,w)
        h=rem(w+h_param(1+e), 126);
        a(1+w,1+e)=b(1+h,1+e);
      end
    end
    % grouped to one bit stream
    y(1+(i-1)*126:i*126,:) = a;
  end
  
   % Step 3: Symbol Interleaver
  data_out = zeros (1512, map_bits);

   % interleaver in one step: 1512/126 = 12
   groups = 1512/126;
    for i = 1:1512
    if rem(DVBT_STATE_SENDER.l, 2) == 0
      data_out(1+DVBT_STATE_SENDER.inner_interleaver.Hq(i),:) = y(i,:);
    else
      data_out(i,:) = y(1+DVBT_STATE_SENDER.inner_interleaver.Hq(i),:);
    end
  end  