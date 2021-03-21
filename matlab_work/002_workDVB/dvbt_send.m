%% dvbt_send DVB-T Sender.

function data_channel_in = dvbt_send (data_in)

  % Global declarations
  global DVBT_STATE_SENDER;

  % Abbreviations
  len_packet = 188;
  payload_carriers = 1512;
  qam_mode = 16;
  map_bits = log2(qam_mode);
  puncturing_mode = 2/3;
  
  len_symbol = payload_carriers *map_bits *puncturing_mode; % 1512*4*2/3

  % Parameter checking
  [should_be_len_packet, num_packets] = size (data_in);

  % Process MPEG-2 MUX packets
  for k = 1:num_packets
    data=data_in(:,k);
  
    % scramble, RS encode and outer interleave
    data = scramble (data);
    data = rs_encode (data);
    data = outer_interleave (data);


    % put data into bit_stream
    data = reshape(de2bi(data, 8, 'left-msb')',8*204,1);
    if isempty (DVBT_STATE_SENDER.bit_stream)
      DVBT_STATE_SENDER.bit_stream = data;
    else
      DVBT_STATE_SENDER.bit_stream = ...
          [ DVBT_STATE_SENDER.bit_stream ; data ];
    end
    % increment packet counter
    DVBT_STATE_SENDER.n = DVBT_STATE_SENDER.n + 1;
  end

  % convert MUX packets into OFDM symbols
  [num_bits, should_be_one] = size (DVBT_STATE_SENDER.bit_stream);
  num_symbols = floor (num_bits/len_symbol);
  ofdm_symbols = zeros (len_symbol, num_symbols);
  for k = 1:num_symbols
    ofdm_symbols(:,k) = DVBT_STATE_SENDER.bit_stream...
        (1+(k-1)*len_symbol:k*len_symbol); 
  end
  if ~ isempty (DVBT_STATE_SENDER.bit_stream)
    DVBT_STATE_SENDER.bit_stream = DVBT_STATE_SENDER.bit_stream...
        (1+num_symbols*len_symbol:num_bits); % The last few bits
  end

  % Process OFDM symbols
  data_channel_in = [];
  for k = 1:num_symbols
    data = ofdm_symbols(:,k);
    
    [x, y] = convolutional_encode (data);
    data = puncturing (x, y);
    [symbols] = inner_interleave (data);
    data = map (symbols);

    data = insert_reference_signals (data);

    data = ofdm_encode(data);
    %subplot(2,1,1); plot(real(data));title('Data for sending');
    %subplot(2,1,2); plot(imag(data));


    % put data into channel
    if isempty (data_channel_in)
      data_channel_in = data;
    else
      data_channel_in = [ data_channel_in , data ];
    end
    % increment symbol counters
    DVBT_STATE_SENDER.l = DVBT_STATE_SENDER.l + 1;
    if DVBT_STATE_SENDER.l >= 68
      DVBT_STATE_SENDER.l = 0;
      DVBT_STATE_SENDER.m = DVBT_STATE_SENDER.m + 1;
      if DVBT_STATE_SENDER.m >= 4
	DVBT_STATE_SENDER.m = 0;
	% also reset packet counter
	DVBT_STATE_SENDER.n = 0;
      end
    end
  end