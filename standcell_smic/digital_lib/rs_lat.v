
module rs_lat(
input       rn,
input       sn,
output      q,
output      qn
);

// nand( output , input , input)
nand nad0(qn, rn, q);
nand nad1(q, sn, qn);

endmodule
