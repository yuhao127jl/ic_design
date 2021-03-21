%% gf_mul Multiplies two elements of a Galois field.
%%
%%   c = gf_mul(a,b) multiplies two numbers a and b using Galois field
%%   arithmetics.


function result = gf_mul (a,b)

  global GF;

  result = gf_exp(gf_log(a) + gf_log(b));
