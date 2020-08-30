
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.1  2001/07/29 08:57:02  rudi
//
//
//               1) Changed Directory Structure
//               2) Added restart signal (REST)
//
//               Revision 1.2  2001/06/05 10:22:37  rudi
//
//
//               - Added Support of up to 31 channels
//               - Added support for 2,4 and 8 priority levels
//               - Now can have up to 31 channels
//               - Added many configuration items
//               - Changed reset to async
//
//               Revision 1.1.1.1  2001/03/19 13:11:12  rudi
//               Initial Release
//
//
//
 
`include "wb_dma_defines.v"
 
module wb_dma_inc30r(clk, in, out);
input		clk;
input	[29:0]	in;
output	[29:0]	out;
 
// INC30_CENTER indicates the center bit of the 30 bit incrementor
// so it can be easily manually optimized for best performance
parameter	INC30_CENTER = 16;
 
reg	[INC30_CENTER:0]	out_r;
 
always @(posedge clk)
	out_r <= #1 in[(INC30_CENTER - 1):0] + 1;
 
assign out[29:INC30_CENTER] = in[29:INC30_CENTER] + out_r[INC30_CENTER];
assign out[(INC30_CENTER - 1):0]  = out_r;
 
endmodule
 
