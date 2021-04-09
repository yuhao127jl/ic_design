%% dvbt_receive DVB-T Receiver.

function data_out = dvbt_receive (data_channel_out)

  global DUMP;
  global DVBT_SETTINGS;
  global DVBT_STATE_RECEIVER;
  
  len_packet = DVBT_SETTINGS.packet_length.rs;
  len_symbol = DVBT_SETTINGS.symbol_length.ad_conv;
  [should_be_len_symbol, num_symbols] = size (data_channel_out);


  % Process OFDM symbols
  for k = 1:num_symbols
    data=data_channel_out(:,k);

    data = digital_frontend (data);
    data = ofdm_decode (data);
    data = remove_reference_signals (data);
    [symbols] = demap (data);
    data = inner_deinterleave (symbols);
    [x, y] = depuncturing (data);
    data = convolutional_decode (x, y);

    % put data into byte_stream
    data = bi2de (reshape(data, 8, DVBT_SETTINGS.symbol_length.bit_stream/8)', ...
		  'left-msb');
    if isempty (DVBT_STATE_RECEIVER.byte_stream)
      DVBT_STATE_RECEIVER.byte_stream = data;
    else
      DVBT_STATE_RECEIVER.byte_stream = ...
          [ DVBT_STATE_RECEIVER.byte_stream ; data ];
    end
  end

  % convert OFDM symbols into MUX packets
  [num_bytes, should_be_one] = size (DVBT_STATE_RECEIVER.byte_stream);
  num_packets=floor (num_bytes/len_packet);
  packets=zeros(len_packet,num_packets);
  for k = 1:num_packets
    packets(:,k) = DVBT_STATE_RECEIVER.byte_stream...
        (1+(k-1)*len_packet:k*len_packet);
  end
  if ~ isempty (DVBT_STATE_RECEIVER.byte_stream)
    DVBT_STATE_RECEIVER.byte_stream = DVBT_STATE_RECEIVER.byte_stream...
        (1+num_packets*len_packet:num_bytes);
  end

  % increment symbol counters
  DVBT_STATE_RECEIVER.l = DVBT_STATE_RECEIVER.l + 1;
  if DVBT_STATE_RECEIVER.l >= DVBT_SETTINGS.symbols_per_frame
    DVBT_STATE_RECEIVER.l = 0;
    DVBT_STATE_RECEIVER.m = DVBT_STATE_RECEIVER.m + 1;
    if DVBT_STATE_RECEIVER.m >= DVBT_SETTINGS.frames_per_superframe
    DVBT_STATE_RECEIVER.m = 0;
      % also reset packet counter
      DVBT_STATE_RECEIVER.n = 0;
     end
  end

  % Process MPEG transport MUX packets
  data_out = [];
  for k = 1:num_packets
    data = packets(:,k);
    
    data = outer_deinterleave (data);
    data = rs_decode (data);
    data = descramble (data);

    % put data into output
    if isempty (data_out)
      data_out = data;
    else
      data_out = [ data_out , data];
    end

    % increment packet counter
    DVBT_STATE_RECEIVER.n = DVBT_STATE_RECEIVER.n + 1;
  end

