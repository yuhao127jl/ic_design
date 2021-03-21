%% map Performs OFDM/QAM mapping.
function data_out = map (data_in)

  % declarations
  map_qam_mode = 16;
  alpha = 1; 
  m = log2 (map_qam_mode);
  map_bit_ordering = 1:m;
  [n, should_be_m] = size (data_in);
  
  switch alpha
    case 1
      offset = 0;
    case 2
      offset = 1;
    case 4
      offset = 3;
  end
  
  % Perform actions
  data_out = zeros(n,1);
  for ii = 1:n
    bits = data_in(ii,:);

    symbol = [0 0];
    for jj = 1:2:m
      bit2 = bits(map_bit_ordering(jj));
      bit1 = bits(map_bit_ordering(jj+1));

      pair = [1 1] - 2*[bit1 bit2];

      if symbol == 0
	symbol = pair;
      else
	symbol = (pair + [2 2]) .* symbol;
      end
    end
    
    % add offset for non-uniform mapping
    symbol = symbol + offset .* sign(symbol);
    data_out(ii) = symbol * [1 ; 1i];
  end