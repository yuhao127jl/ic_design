
module MUX2S1(
input a, b, s0,
output y
);

udp_mux2s1(y, a, b, s0);


endmodule

//---------------------------------------------
//  MUX 2 to 1
//---------------------------------------------
primitive udp_mux2s1(y, a, b, s0);
output y;
input   a, b, s0;

table
    //input0  input1   sel  :   output
       0        ?       0   :     0
       1        ?       0   :     1
       ?        0       1   :     0
       ?        1       1   :     1
endtable 

endprimitive


//---------------------------------------------
// 1
//---------------------------------------------
/*
module mux2s1(
input a, b, s0,
output y
);

assign y = s0 ? b : a;

endmodule
*/


//---------------------------------------------
// 2
//---------------------------------------------
/*
module mux2s1(
input a, b, s0,
output y
);
reg y;

always @(*)
begin
    case(s0)
        1'0: y = a;
        1'1: y = b;
        default: y = 1'bx;
    endcase
end
*/

endmodule




