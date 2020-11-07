//*******************************************************************************
// Project      : 
// Module       : clkdiv.v
// Description  : synchronous clock divider
// Designer     :
// Version      : 
//********************************************************************************

module clkdiv #(parameter dw = 8, rv = 0) (
divs,
clko,
plso,

clki,
rst_
);

input clki;
input rst_;
input [dw-1:0] divs;

output clko;
(* keep *) output plso;

//*********************************************************************
//
// Internal Defination
//
//*********************************************************************
reg [dw-1:0] sys_dx_ss;
reg [dw-1:0] sys_dx_r;
reg          sys_dx_rr;
reg          sys_dx_fr;


//*********************************************************************
//
// clock divider
//
//*********************************************************************
wire sys_dx_ovf = (sys_dx_r == sys_dx_ss);
wire sys_dx_hovf = (sys_dx_r == {1'b0, sys_dx_ss[dw-1:1]});

wire [dw-1:0] sys_dx_r_in = (sys_dx_ovf | (sys_dx_ss == 'd0) ) ? 'd0 : sys_dx_r + 'd1;

wire sys_dx_rr_in = (sys_dx_ovf | sys_dx_rr) & !sys_dx_hovf;
wire sys_dx_fr_in = (sys_dx_rr_in | sys_dx_ss[0]);

assign #1.3 plso = sys_dx_ovf;
M_TLATNCA clock_gat0(.ECK(sys_clk_p1), .E(sys_dx_ovf), .CK(clki));
M_OR2     or2_u0(.A(sys_clk_p1), .B(sys_dx_rr & sys_dx_fr), .Y(clko));



//*********************************************************************
//
// always
//
//*********************************************************************
always @(posedge clko or negedge rst_)
if(!rst_)
    sys_dx_ss       <= #1 dv;
else
    sys_dx_ss       <= #1 divs;


always @(posedge clki)
    sys_dx_r        <= #1 sys_dx_r_in;


always @(posedge clki)
    sys_dx_rr       <= #1 sys_dx_rr_in;


always @(posedge clki)
    sys_dx_fr       <= #1 sys_dx_fr_in;


//*********************************************************************
//
// for simulation only
//
//*********************************************************************
// synopsys translate_off
initial begin
    sys_dx_r = 13;
end
// synopsys translate_on


//********************************************************************************
//
// END of Module
//
//********************************************************************************
endmodule
