%% ofdm_decode OFDM decoder.
function data_out = ofdm_decode (data_in)

  % Global declarations
  global DVBT_SETTINGS;
  global VISUALIZATION;  

  % Abbreviations
  m = DVBT_SETTINGS.symbol_length.ad_conv;
  n = DVBT_SETTINGS.symbol_length.fft;
  g = DVBT_SETTINGS.ofdm.guard_length;
  k = DVBT_SETTINGS.ofdm.carrier_count;

  % Perform actions
  time_domain = data_in(1+g:m);

  if DVBT_SETTINGS.ofdm.use_fftshift
    frequency_domain = fftshift (fft (time_domain));
    data_out = frequency_domain(1+(n-k+1)/2:(n+k+1)/2);
  else
    frequency_domain = fft (time_domain);
    data_out = [ frequency_domain(1+n-(k-1)/2:n) ; ...
	frequency_domain(1:(k+1)/2) ];
  end
  
    %scatterplot(data_out);
  end
