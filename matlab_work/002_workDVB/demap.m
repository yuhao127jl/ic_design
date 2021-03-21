%% demap Performs OFDM/QAM demapping.
function data_out = demap (data_in)

  %declarations
 [n, should_be_one] = size (data_in);
  map_qam_mode = 16;
  alpha = 1; 
  m = log2 (map_qam_mode);
  map_bit_ordering = 1:m;
  
    switch alpha
    case 1
      offset = 0;
    case 2
      offset = 1;
    case 4
      offset = 3;
    end
  
  % Perform actions
  data_out = zeros(n,m);
  for ii = 1:n
    symbol = [real(data_in(ii)) imag(data_in(ii))];
    bits = zeros(1,m);

    % remove offset of non-uniform mapping
    symbol = symbol - offset .* sign(symbol);
    weight = 2^(m/2-1);
    confidence = 2^(m/2-1);
    for jj = 1:2:m
      bit1 = -0.5*(symbol(1) / confidence) + 0.5;
      bit2 = -0.5*(symbol(2) / confidence) + 0.5;

      bits(map_bit_ordering(jj)) = bit2;
      bits(map_bit_ordering(jj+1)) = bit1;

      symbol = abs(symbol) - weight;
      weight = weight / 2;
    end
    
    data_out(ii,:) = bits;    
  end
  data_out = round(data_out);

