function [x, y] = depuncturing (data)
  
  [n, should_be_one] = size (data);
  puncturing_mode = 2/3;
  m = puncturing_mode * n;
  
   x=zeros(m,1);
   y=zeros(m,1);
   for i = 1:2:m
        x(i+0) = data(3*(i-1)/2+1);
        x(i+1) = 0.5;
        y(i+0) = data(3*(i-1)/2+2);
        y(i+1) = data(3*(i-1)/2+3);
   end
     
