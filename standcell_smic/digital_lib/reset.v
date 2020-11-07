//*******************************************************************************
// Project      : 
// Module       : reset.v
// Description  : 0: asynchronous   1: synchronous
// Designer     :
// Version      : 
//********************************************************************************

module reset(
clk,
in,

out
);

input clk;
input in;
output out;

CLKINVX1M inv_00( .Y(clk_n), .A(clk) );
AND2X1M and_00( .Y(and00_y), .A(dff00_a), .B(dff01_b) );
DFFRQX1M dff_00( .Q(dff00_a), .D(1'b1), .CK(clk), .RN(in) );
DFFRQX1M dff_01( .Q(dff01_b), .D(1'b1), .CK(clk_n), .RN(in) );
DFFRQX2M dff_02( .Q(out), .D(1'b1), .CK(clk), .RN(and00_y) );

//********************************************************************************
//
// END of Module
//
//********************************************************************************
endmodule

