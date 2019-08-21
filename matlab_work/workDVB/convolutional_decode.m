function  data = convolutional_decode (x,y)
trel = poly2trellis(7,[171 133]);
[n, m] = size (x);

for j = 1:2:2*n-1
h(j) = x((j+1)/2);
end
for j = 2:2:2*n
h(j) = y(j/2);
end

ncode = h.';


data = vitdec(ncode,trel,3,'trunc','hard');
