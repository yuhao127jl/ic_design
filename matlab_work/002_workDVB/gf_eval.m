%% gf_eval Evaluate a polynome using Galois-field arithmetics.
%%
%%   y = gf_eval(poly, x) evaluates the polynome stored in the vector
%%   poly at the value x using Galois-field arithmetics.

function result = gf_eval (polynome, x)

  global GF;

  result = GF.zero;
  for ii = length(polynome):-1:1
    result = gf_add (gf_mul (result, x), polynome(ii));
  end
  