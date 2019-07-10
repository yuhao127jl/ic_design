/*****************************************************************

 tb_uart_top.v module

******************************************************************

 Copyright © 2019 

******************************************************************

 created on:	07/10/2019 
 created by:	klin
 last edit on:	07/10/2019 
 last edit by:	klin
 revision:	001
 comments:	

******************************************************************
 //Project// (//Number//)

 This module implements the test bench for the uart_top.v module.

	// enter detailed description here;


******************************************************************/
`timescale	1ns/1ps

`define BIT(n)    (1<<n)


module tb_uart_top (); 

// *** Input, Inouts to UUT ***
reg	uart_baud_wr;
reg	uart_con_wr;
reg	uart_txbuf_wr;
reg	[15:0]icb_wdat;
reg	sys_clk;
reg	uart_baud_clk;
reg	sys_rstn;

// *** Outputs from UUT ***
wire	[15:0]  uart_con;
wire	[15:0]  uart_baud;
wire	[15:0]  uart_txbuf;
wire	uart_tx;
wire	uart_rx;
wire	uart_en;
wire	uart_int;

// *** Local Integer Declarations ***
parameter   CLK50M_PERIOD = 20;
parameter   CLK24M_PERIOD = 41.667;
parameter   CLK16M_PERIOD = 62.5;
parameter   CLK12M_PERIOD = 83.333;


// *** Local Integer Declarations ***
integer			j,i;


// Instantiate the UUT module:
uart_top	uut	(
			.uart_baud_wr (uart_baud_wr),
			.uart_con_wr (uart_con_wr),
			.uart_txbuf_wr (uart_txbuf_wr),
			.icb_wdat (icb_wdat),
			.uart_con (uart_con),
			.uart_baud (uart_baud),
			.uart_txbuf (uart_txbuf),
			.uart_tx (uart_tx),
			.uart_rx (uart_rx),
			.uart_en (uart_en),
			.uart_int (uart_int),
			.sys_clk (sys_clk),
			.uart_baud_clk (uart_baud_clk),
			.sys_rstn (sys_rstn)
			);

// Generate clock:
initial begin
  sys_clk = 0;
  forever #(CLK50M_PERIOD/2) sys_clk = ~sys_clk;
end

initial begin
  uart_baud_clk = 0;
  forever #(CLK24M_PERIOD/2) uart_baud_clk = ~uart_baud_clk;
end


// initial block
initial begin
	// initialize signals
	uart_baud_wr = 0;
	uart_con_wr = 0;
	uart_txbuf_wr = 0;
	icb_wdat = 0;
	sys_rstn = 0;

  // reset system
  #(30*CLK50M_PERIOD) sys_rstn = 1;
  $display("System reset now ...... \n");
	
  #(50*CLK50M_PERIOD);
	// Add more test bench stuff here
  uart_baud_config(1, 16'h3);
  uart_con_config(1, 16'h1);
  uart_txbuf_config(1, 16'h7);

  $display("First Tx config ......  \n");


	
  //#(100*CLK50M_PERIOD);
  //uart_baud_config(1, 16'h6);
  //uart_con_config(1, 16'h1);
  //uart_txbuf_config(1, 16'h73);
	
  #1000;
	$stop;
end


//************************************************
// task for reg config
//************************************************
task uart_con_config(input uartcon_wr, input [15:0] bus_wdat);
begin
  @(posedge sys_clk);
  $display("A\n");
  #1; 
  uart_con_wr = uartcon_wr;
  icb_wdat = bus_wdat;
  @(posedge sys_clk);
  $display("B\n");
  #1; 
  uart_con_wr = 1'b0;
  icb_wdat = bus_wdat;
end
endtask

task uart_baud_config(input uartbaud_wr, input [15:0] bus_wdat);
begin
  @(posedge sys_clk);
  $display("C\n");
  #1; 
  uart_baud_wr = uartbaud_wr;
  icb_wdat = bus_wdat;
  @(posedge sys_clk);
  #1; 
  $display("D\n");
  uart_baud_wr = 1'b0;
  icb_wdat = bus_wdat;
end
endtask

task uart_txbuf_config(input uarttxbuf_wr, input [15:0] bus_wdat);
begin
  @(posedge sys_clk);
  #1;
  $display("E\n");
  uart_txbuf_wr = uarttxbuf_wr;
  $display("gE\n");
  icb_wdat[7:0] = bus_wdat[7:0];
  $display("kE\n");
#20;
  $display("jE\n");
  #1;
  $display("F\n");
  uart_txbuf_wr = 1'b0;
end
endtask


//************************************************
// Dump FSDB wave
//************************************************
initial
begin
	$fsdbDumpfile("ic_design.fsdb");
	$fsdbDumpvars;
end


endmodule

