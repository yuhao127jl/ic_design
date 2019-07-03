/*****************************************************************

 tb_timer.v module

******************************************************************

 UC Davis Confidential Copyright © 2019 

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

******************************************************************/
`timescale	1ns/1ps


module tb_timer (); 

// *** Input, Inouts to UUT ***
reg tmr_cnt_wr;
reg tmr_con_wr;
reg tmr_prd_wr;
reg [15:0]  icb_wdat;
reg clkisrc1;
reg clkisrc2;
reg clkisrc3;
reg clkisrc4;
reg icsrc;
reg sys_clk;
reg sys_rstn;

// *** Outputs from UUT ***
wire [15:0] tmr_con;
wire [15:0] tmr_prd;
wire [15:0] tmr_cnt;
wire        tmr_ovf;
wire        tmr_int;

// *** Local Integer Declarations ***
parameter   CLK_PERIOD    = 20;
parameter   CLK50M_PERIOD = 20;
parameter   CLK16M_PERIOD = 62.5;
parameter   CLK24M_PERIOD = 41.667;
parameter   CLK12M_PERIOD = 83.333;

// Instantiate the UUT module:
timer	uut	(
			.tmr_cnt_wr (tmr_cnt_wr),
			.tmr_con_wr (tmr_con_wr),
			.tmr_prd_wr (tmr_prd_wr),
			.icb_wdat (icb_wdat),
			.clkisrc1 (clkisrc1),
			.clkisrc2 (clkisrc2),
			.clkisrc3 (clkisrc3),
			.clkisrc4 (clkisrc4),
			.icsrc (icsrc),
			.tmr_con (tmr_con),
			.tmr_prd (tmr_prd),
			.tmr_cnt (tmr_cnt),
      .tmr_ovf (tmr_ovf),
      .tmr_int (tmr_int),
			.sys_clk (sys_clk),
			.sys_rstn (sys_rstn)
			);

// Generate clock:
initial begin
  sys_clk = 0;
  forever #(CLK_PERIOD/2) sys_clk = ~sys_clk;
end

initial begin
  clkisrc1 = 0;
  forever #(CLK50M_PERIOD/2) clkisrc1 = ~clkisrc1;
end

initial begin
  clkisrc2 = 0;
  forever #(CLK16M_PERIOD/2) clkisrc2 = ~clkisrc2;
end

initial begin
  clkisrc3 = 0;
  forever #(CLK24M_PERIOD/2) clkisrc3 = ~clkisrc3;
end

initial begin
  clkisrc4 = 0;
  forever #(CLK12M_PERIOD/2) clkisrc4 = ~clkisrc4;
end

//always #(CLK50M_PERIOD/2) clkisrc1 = ~clkisrc1;
//always #(CLK16M_PERIOD/2) clkisrc2 = ~clkisrc2;
//always #(CLK24M_PERIOD/2) clkisrc3 = ~clkisrc3;
//always #(CLK12M_PERIOD/2) clkisrc4 = ~clkisrc4;
//always #(CLK50M_PERIOD/2) sys_clk = ~sys_clk;

// initial block
initial
begin
	// initialize signals
	tmr_cnt_wr = 0;
	tmr_con_wr = 0;
	tmr_prd_wr = 0;
	icb_wdat = 0;
	icsrc = 0;
	sys_rstn = 0;

  // reset the block	
  #300 sys_rstn = 1;

	// Add more test bench stuff here
  tmr_cnt_config(1, 16'h00);
  #(2*CLK_PERIOD);
  tmr_prd_config(1, 16'h20);
  #(2*CLK_PERIOD);
  tmr_con_config(1, 16'h01);
  #(2*CLK_PERIOD);
	
  // wait for interrupt
  wait(tmr_int==1)
    begin
      tmr_con_config(1, 16'h400);// clr pnding
    end
  
  #(10*CLK_PERIOD);
	
	$stop;
end


//**********************************
// task for reg config
//**********************************
task tmr_cnt_config(input tmrcnt_wr, input [15:0] bus_wdat);
begin
  @(posedge sys_clk);
  #1; 
  tmr_cnt_wr = tmrcnt_wr;
  icb_wdat = bus_wdat;
  @(posedge sys_clk);
  #1; 
  tmr_cnt_wr = 1'b0;
  icb_wdat = bus_wdat;
end
endtask

task tmr_con_config(input tmrcon_wr, input [15:0] bus_wdat);
begin
  @(posedge sys_clk);
  #1; 
  tmr_con_wr = tmrcon_wr;
  icb_wdat = bus_wdat;
  @(posedge sys_clk);
  #1; 
  tmr_con_wr = 1'b0;
  icb_wdat = bus_wdat;
end
endtask

task tmr_prd_config(input tmrprd_wr, input [15:0] bus_wdat);
begin
  @(posedge sys_clk);
  #1; 
  tmr_prd_wr = tmrprd_wr;
  icb_wdat = bus_wdat;
  @(posedge sys_clk);
  #1;
  tmr_prd_wr = 1'b0;
  icb_wdat = bus_wdat;
end
endtask


//**********************************
// DUMP Wave
//**********************************
initial
begin
	$fsdbDumpfile("ic_design.fsdb");
	$fsdbDumpvars;
end




endmodule
