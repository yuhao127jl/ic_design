%% gf_add Add two elements of a Galois field.
%%
%%   c = gf_add(a,b) adds two numbers a and b using Galois field
%%   arithmetics.


function result = gf_add (a, b)

  result = bitxor (a,b);
  