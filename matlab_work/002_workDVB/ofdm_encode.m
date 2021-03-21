%% ofdm_encode OFDM encoder.
% data_in is 1705*1 matrix
% data_out is 2560*1 matrix

function data_out = ofdm_encode (data_in)
 %scatterplot(data_in);


  guard_length = 2048/4;
  m = guard_length + 2048; % 512+2048 = 2560
  k = 1705;

  % Perform actions
  frequency_domain = zeros(2048,1);
  frequency_domain(1+(2048-k+1)/2:(2048+k+1)/2) = data_in;
  time_domain = ifft(fftshift (frequency_domain)); % size is 2048*1

  % insert guard
  data_out = [ time_domain(1+2048-guard_length:2048) ; time_domain ];
  %subplot(2,1,1); plot(real(data_out));
  %subplot(2,1,2); plot(imag(data_out));


