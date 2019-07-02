/*****************************************************************

 tb_timer.v module

******************************************************************

 Copyright © 2019 

******************************************************************

 created on:	05/12/2019 
 created by:	klin
 last edit on:	05/12/2019 
 last edit by:	klin
 revision:	001
 comments:	

******************************************************************
 //Project// (//Number//)

 This module implements the test bench for the timer.v module.

	// enter detailed description here;


******************************************************************/
`timescale	1ns/1ps


module tb_timer (); 

// *** Input, Inouts to UUT ***
reg tmr_cnt_wr;
tmr_con_wr;
tmr_prd_wr;
[15:0]  icb_wdat;
clkisrc1;
clkisrc2;
clkisrc3;
clkisrc4;
icsrc;
sys_clk;
sys_rstn;

// *** Outputs from UUT ***
wire [15:0] tmr_con;
[15:0] tmr_prd;
[15:0] tmr_cnt;
[15:0] tmr_con;
[15:0] tmr_prd;
tmr_ovf;
tmr_int;

// *** Local Variable Declarations ***
// Local Parameter Declarations:
// N/A
// Local Wire Declarations:
// N/A
// Local Register Declarations:
// N/A

// *** Local Integer Declarations ***
integer			j,i;
integer			results_file;	// for writing signal values

// Instantiate the UUT module:
timer	uut	(
			.tmr_cnt_wr (tmr_cnt_wr),
			.tmr_con_wr (tmr_con_wr),
			.tmr_prd_wr (tmr_prd_wr),
			.icb_wdat (icb_wdat),
			.tmr_con (tmr_con),
			.tmr_prd (tmr_prd),
			.tmr_cnt (tmr_cnt),
			.clkisrc1 (clkisrc1),
			.clkisrc2 (clkisrc2),
			.clkisrc3 (clkisrc3),
			.clkisrc4 (clkisrc4),
			.icsrc (icsrc),
			.tmr_con (tmr_con),
			.tmr_prd (tmr_prd),
			.tmr_ovf (tmr_ovf),
			.tmr_int (tmr_int),
			.sys_clk (sys_clk),
			.sys_rstn (sys_rstn)
			);

// Generate clock:
always #10 clkisrc1 = ~clkisrc1

always #10 clkisrc2 = ~clkisrc2

always #10 clkisrc3 = ~clkisrc3

always #10 clkisrc4 = ~clkisrc4

always #10 sys_clk = ~sys_clk

// initial block
initial
begin
	// initialize signals

	tmr_cnt_wr <= 0;
	tmr_con_wr <= 0;
	tmr_prd_wr <= 0;
	icb_wdat <= 0;
	clkisrc1 <= 0;
	clkisrc2 <= 0;
	clkisrc3 <= 0;
	clkisrc4 <= 0;
	icsrc <= 0;
	sys_clk <= 0;
	sys_rstn <= 0;

	// wait 1 clk cycle, de-assert n_rst
	CpuReset;

	// open results file, write header
	results_file=$fopen("tb_timer_results.txt");
	$fdisplay(results_file, " tb_timer testbench results");
	$fdisplay(results_file);
	$fwrite(results_file, "\n");
	$fdisplay(results_file, "\t\t\t", "address", "data");
	//$fdisplay(results_file, "\t%h\t\t%h", addr_for, data_out);
	
	// Add more test bench stuff here
	
	
	
	$fclose(results_file);
	$stop;
end


// Add more test bench stuff here as well


// Test Bench Tasks

task CpuReset;
begin
	@ (posedge clk);
	rst_n = 0;
	@ (posedge clk);
	rst_n = 1;
	@ (posedge clk);
end
endtask

endmodule
