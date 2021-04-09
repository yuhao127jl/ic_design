%% convolutional_encode Convolutional decoder
function [x, y] = convolutional_encode (data)

  
[n, should_be_one] = size (data);
trel = poly2trellis(7,[171 133]);% Trellis
code = convenc(data,trel);% Encode the message.
x = code(1:2:2*n-1);
y = code(2:2:2*n);