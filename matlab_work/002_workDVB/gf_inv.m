%% gf_inv Multiplicative inverse in Galois arithmetics.
%%
%%   c = gf_inv(a) returns the multiplicative inverser using Galois field


function result = gf_inv (a)

  global GF;
  
  result = gf_exp((GF.q-1) - gf_log(a));
