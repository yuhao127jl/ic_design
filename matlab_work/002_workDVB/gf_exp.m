%% gf_exp Galois exponentiation function.
%%
%%   c = gf_exp(a) raises the primitive element of the Galois field
%%   to the power of the argument a.

function result = gf_exp (a)

  global GF;

  [m, n] = size (a);
  
  result = zeros (m, n);
  
  for i = 1:m
    for j = 1:n
      if a(i,j) == -Inf
	result(i,j) = GF.zero;
      else
	result(i,j) = GF.exp(1+rem(a(i,j),GF.q-1));
      end
    end
  end