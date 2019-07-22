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


// *** Local Integer Declarations ***
parameter   CLK50M_PERIOD = 20;
parameter   CLK48M_PERIOD = 20.833;
parameter   CLK24M_PERIOD = 41.667;
parameter   CLK16M_PERIOD = 62.5;
parameter   CLK12M_PERIOD = 83.333;


// Instantiate the UUT module:
cic_decimator	uut	(
			.cic_din (cic_din),
			.cic_dout (cic_dout),
			.cic_clk (cic_clk),
			.cic_rstn (cic_rstn)
			);

// Generate clock:
always #(CLK16M_PERIOD/2) cic_clk = ~cic_clk;


// initial block
initial
begin
	// initialize signals
	cic_din = 0;
	cic_clk = 0;
	cic_rstn = 0;

	// wait 1 clk cycle, de-assert n_rst
	#800 cic_rstn = 1;
  $display("\nSystem reset now .........");
	#100;

	// input step signal
	step_signal_gen();
	
	#(300*CLK16M_PERIOD);
	$stop;
end

//cic internal register
initial begin
  force tb_cic_decimator.uut.samp_cnt[4:0] = 5'd0;
  #2;
  release tb_cic_decimator.uut.samp_cnt[4:0];
end


//**********************************
// Task --- signal gen
//**********************************
// step
task step_signal_gen();
begin
	repeat(100) begin
		@(posedge cic_clk) cic_din = 8'd0;
	end
	repeat(300) begin
		@(posedge cic_clk) cic_din = 8'd100;
	end

	@(posedge cic_clk) cic_din = 8'd0;
end
endtask


// sine wave
//task sine_signal_gen();
//begin
//	repeat(100) begin
//		@(posedge cic_clk) cic_din = 8'd0;
//	end
//end
//endtask




//**********************************
// DUMP Wave
//**********************************
initial
begin
	$fsdbDumpfile("ic_design.fsdb");
	$fsdbDumpvars;
end



endmodule
