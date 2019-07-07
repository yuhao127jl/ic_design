/*****************************************************************

 tb_fir_distb_top.v module

******************************************************************

 Copyright © 2019 

******************************************************************

 created on:	07/08/2019 
 created by:	klin
 last edit on:	07/08/2019 
 last edit by:	klin
 revision:	001
 comments:	

******************************************************************
 //Project// (//Number//)

 This module implements the test bench for the fir_distb_top.v module.

	// enter detailed description here;


******************************************************************/
`timescale	1ns/1ps


module tb_fir_distb_top (); 

// *** Input, Inouts to UUT ***
reg	[IDATA_WIDTH-1:0]     fir_lp_in;
reg	sys_clk;
reg	sys_rstn;

// *** Outputs from UUT ***
wire	[ODATA_WIDTH-1:0]     fir_lp_out;


// *** Local Integer Declarations ***
integer			j,i;
integer			results_file;	// for writing signal values

// Instantiate the UUT module:
fir_distb_top	uut	(
			.fir_lp_in (fir_lp_in),
			.fir_lp_out (fir_lp_out),
			.sys_clk (sys_clk),
			.sys_rstn (sys_rstn)
			);

// Generate clock:
always #10 sys_clk = ~sys_clk;

// initial block
initial
begin
	// initialize signals
	fir_lp_in = 0;
	sys_clk = 0;
	sys_rstn = 0;

	
	// Add more test bench stuff here
	
	
	

end


// Add more test bench stuff here as well


// Dump FSDB wave
initial
begin
	$fsdbDumpfile("ic_design.fsdb");
	$fsdbDumpvars;
end


endmodule
