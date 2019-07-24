/*****************************************************************

 tb_cic3_dsf.v module

******************************************************************

 Copyright © 2019 

******************************************************************

 created on:	07/23/2019 
 created by:	Administrator
 last edit on:	07/23/2019 
 last edit by:	Administrator
 revision:	001
 comments:	

******************************************************************
 //Project// (//Number//)

 This module implements the test bench for the cic3_dsf.v module.

	// enter detailed description here;


******************************************************************/
`timescale	1ns/1ps


module tb_cic3_dsf (); 

// *** Input, Inouts to UUT ***
reg	clki;
reg	rst_n;
reg	clko;
reg	[1:0]srat;
reg	[1:0]din;

// *** Outputs from UUT ***
wire	[31:0]dout;


// *** Local Integer Declarations ***
integer			j,i;


// Instantiate the UUT module:
cic3_dsf	uut	(
			.clki (clki),
			.rst_n (rst_n),
			.clko (clko),
			.srat (srat),
			.din (din),
			.dout (dout)
			);


// Generate clock:
always #10 clki = ~clki;
always #10 clko = ~clko;


// initial block
initial
begin
	// initialize signals
	clki = 0;
	rst_n = 0;
	clko = 0;
	srat = 0;
	din = 0;

	// system reset
	#1000 rst_n = 1;
	$display("System Reset Now .........");
	#400;
	
	// Add more test bench stuff here
	
	
	
	$stop;
end


// Add more test bench stuff here as well


// Dump FSDB wave
initial
begin
	$fsdbDumpfile("ic_design.fsdb");
	$fsdbDumpvars;
end


endmodule
