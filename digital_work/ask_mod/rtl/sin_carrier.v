//*********************************************
// Project      : ASK Modulation
// DesignModule : sin_carrier.v  
// Description  :
// Designer     :
// Date         : 
//*********************************************
module sin_carrier(
input	wire			clk,
input	wire			ce,
input	wire 	    [4:0]	addr,  
output	wire signed [11:0]	sine,	// sine carrier
output	wire			sin_valid
);

//**************************************
// Internal Defination
//**************************************
reg signed	[11:0] sin_nco;
assign sine = sin_nco;
assign sin_valid = ce;

//**************************************
// sine carrier value
//**************************************
always @(*)
if(ce)
begin
	case(addr)
	5'd0 	: sin_nco = 12'b000000000000;
	5'd1 	: sin_nco = 12'b000111111101;
	5'd2 	: sin_nco = 12'b001111011010;
	5'd3 	: sin_nco = 12'b010101111001;
	5'd4 	: sin_nco = 12'b011011000000;
	5'd5 	: sin_nco = 12'b011110011011;
	5'd6 	: sin_nco = 12'b011111111011;
	5'd7 	: sin_nco = 12'b011111011011;
	5'd8 	: sin_nco = 12'b011100111100;
	5'd9 	: sin_nco = 12'b011000101001;
	5'd10	: sin_nco = 12'b010010110011;
	5'd11	: sin_nco = 12'b001011110010;
	5'd12	: sin_nco = 12'b000100000001;
	5'd13	: sin_nco = 12'b111011111111;
	5'd14	: sin_nco = 12'b110100001110;
	5'd15	: sin_nco = 12'b101101001101;
	5'd16	: sin_nco = 12'b100111010111;
	5'd17	: sin_nco = 12'b100011000100;
	5'd18	: sin_nco = 12'b100000100101;
	5'd19	: sin_nco = 12'b100000000101;
	5'd20	: sin_nco = 12'b100001100101;
	5'd21	: sin_nco = 12'b100101000000;
	5'd22	: sin_nco = 12'b101010000111;
	5'd23	: sin_nco = 12'b110000100110;
	5'd24	: sin_nco = 12'b111000000011;
	default : sin_nco = 12'b000000000000;
	endcase
end
else
begin
	sin_nco = 12'bxxxxxxxxxxxx;
end


endmodule
//*********************************************
//
// END Of Module
//
//*********************************************
