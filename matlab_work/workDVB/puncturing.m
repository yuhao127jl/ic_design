function data = puncturing (x, y)

  payload_carriers = 1512;
  map_bits = 4;
  puncturing_mode = 2/3;
  n = payload_carriers*map_bits * puncturing_mode; 
 

 data=zeros(3*n/2,1);
    for i = 1:2:n
        data(3*(i-1)/2+1) = x(i);
        data(3*(i-1)/2+2) = y(i);
        data(3*(i-1)/2+3) = y(i+1);
    end
