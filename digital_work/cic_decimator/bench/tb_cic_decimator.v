/*****************************************************************

 tb_cic_decimator.v module

******************************************************************

 Copyright © 2019 

******************************************************************

 created on:	07/22/2019 
 created by:	Administrator
 last edit on:	07/22/2019 
 last edit by:	Administrator
 revision:	001
 comments:	

******************************************************************
 //Project// (//Number//)

 This module implements the test bench for the cic_decimator.v module.

	// enter detailed description here;


******************************************************************/
`timescale	1ns/1ps


module tb_cic_decimator (); 

// *** Input, Inouts to UUT ***
reg [7:0]       cic_din;
reg 			cic_clk;
reg 			cic_rstn;


// *** Outputs from UUT ***
wire [15:0]     cic_dout;


// Instantiate the UUT module:
cic_decimator	uut	(
			.cic_din (cic_din),
			.cic_dout (cic_dout),
			.cic_clk (cic_clk),
			.cic_rstn (cic_rstn)
			);

// Generate clock:
always #10 cic_clk = ~cic_clk;

// initial block
initial
begin
	// initialize signals
	cic_din = 0;
	cic_clk = 0;
	cic_rstn = 0;

	// wait 1 clk cycle, de-assert n_rst
	#800 cic_rstn = 1;

	$stop;
end


//**********************************
// DUMP Wave
//**********************************
initial
begin
	$fsdbDumpfile("ic_design.fsdb");
	$fsdbDumpvars;
end



endmodule
