
//----------------------------------------------------------------------------
//
// Project      : Distb FIR filter
// Description  : 4 bit convert 12 bit output
// Designer     :
// Date         : 
//
//----------------------------------------------------------------------------

module distb_table
#(
  parameter TBL_WIDTH   = 4;
  parameter COEF_WIDTH  = 12;
)
(
  input [TBL_WIDTH-1:0]       tbl_in_4b,
  output reg[COEF_WIDTH-1:0]  tbl_out_12b
);

always @(tbl_in_4b)
begin
  case(tbl_in_4b)
    4'b0000 : tbl_out_12b = 12'd0;
    4'b0001 : tbl_out_12b = 12'd41;
    4'b0010 : tbl_out_12b = 12'd132;
    4'b0011 : tbl_out_12b = 12'd173;
    4'b0100 : tbl_out_12b = 12'd341;
    4'b0101 : tbl_out_12b = 12'd382;
    4'b0110 : tbl_out_12b = 12'd473;
    4'b0111 : tbl_out_12b = 12'd514;
    4'b1000 : tbl_out_12b = 12'd510;
    4'b1001 : tbl_out_12b = 12'd551;
    4'b1010 : tbl_out_12b = 12'd642;
    4'b1011 : tbl_out_12b = 12'd683;
    4'b1100 : tbl_out_12b = 12'd851;
    4'b1101 : tbl_out_12b = 12'd892;
    4'b1110 : tbl_out_12b = 12'd983;
    4'b1111 : tbl_out_12b = 12'd1024;
    default : tbl_out_12b = 12'd0;
  endcase
end


endmodule
//----------------------------------------------------------------------------
//
// END OF Module
//
//----------------------------------------------------------------------------
