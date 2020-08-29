
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.3  2001/10/19 04:35:04  rudi
//
//               - Made the core parameterized
//
//               Revision 1.2  2001/08/15 05:40:30  rudi
//
//               - Changed IO names to be more clear.
//               - Uniquifyed define names to be core specific.
//               - Added Section 3.10, describing DMA restart.
//
//               Revision 1.1  2001/08/07 08:00:43  rudi
//
//
//               Split up priority encoder modules to separate files
//
//
//
//
//
//
 
`include "wb_dma_defines.v"
 
// Priority Encoder
//
// Determines the channel with the highest priority, also takes
// the valid bit in consideration
 
module wb_dma_pri_enc_sub(valid, pri_in, pri_out);
 
parameter [3:0]	ch_conf = 4'b0000;
parameter [1:0]	pri_sel = 2'd0;
 
input		valid;
input	[2:0]	pri_in;
output	[7:0]	pri_out;
 
wire	[7:0]	pri_out;
reg	[7:0]	pri_out_d;
reg	[7:0]	pri_out_d0;
reg	[7:0]	pri_out_d1;
reg	[7:0]	pri_out_d2;
 
assign pri_out = ch_conf[0] ? pri_out_d : 8'h0;
 
// Select Configured Priority
always @(pri_sel or pri_out_d0 or pri_out_d1 or  pri_out_d2)
	case(pri_sel)		// synopsys parallel_case full_case
	   2'd0: pri_out_d = pri_out_d0;
	   2'd1: pri_out_d = pri_out_d1;
	   2'd2: pri_out_d = pri_out_d2;
	endcase
 
// 8 Priority Levels
always @(valid or pri_in)
	if(!valid)		pri_out_d2 = 8'b0000_0001;
	else
	if(pri_in==3'h0)	pri_out_d2 = 8'b0000_0001;
	else
	if(pri_in==3'h1)	pri_out_d2 = 8'b0000_0010;
	else
	if(pri_in==3'h2)	pri_out_d2 = 8'b0000_0100;
	else
	if(pri_in==3'h3)	pri_out_d2 = 8'b0000_1000;
	else
	if(pri_in==3'h4)	pri_out_d2 = 8'b0001_0000;
	else
	if(pri_in==3'h5)	pri_out_d2 = 8'b0010_0000;
	else
	if(pri_in==3'h6)	pri_out_d2 = 8'b0100_0000;
	else			pri_out_d2 = 8'b1000_0000;
 
// 4 Priority Levels
always @(valid or pri_in)
	if(!valid)		pri_out_d1 = 8'b0000_0001;
	else
	if(pri_in==3'h0)	pri_out_d1 = 8'b0000_0001;
	else
	if(pri_in==3'h1)	pri_out_d1 = 8'b0000_0010;
	else
	if(pri_in==3'h2)	pri_out_d1 = 8'b0000_0100;
	else			pri_out_d1 = 8'b0000_1000;
 
// 2 Priority Levels
always @(valid or pri_in)
	if(!valid)		pri_out_d0 = 8'b0000_0001;
	else
	if(pri_in==3'h0)	pri_out_d0 = 8'b0000_0001;
	else			pri_out_d0 = 8'b0000_0010;
 
endmodule
 
 
