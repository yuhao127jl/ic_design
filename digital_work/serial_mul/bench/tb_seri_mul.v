/*****************************************************************

 tb_seri_mul.v module

******************************************************************

 Copyright © 2019 

******************************************************************

 created on:	05/25/2019 
 created by:	klin
 last edit on:	05/25/2019 
 last edit by:	klin
 revision:	001
 comments:	

******************************************************************
 //Project// (//Number//)

 This module implements the test bench for the seri_mul.v module.

	// enter detailed description here;


******************************************************************/
`timescale	1ns/1ps
`define     HALF_PRIOD  10

module tb_seri_mul (); 

// *** Input, Inouts to UUT ***
reg	clk;
reg	rstn;
reg	[7:0]       mul_a;
reg	[7:0]       mul_b;
reg	en_mul;

// *** Outputs from UUT ***
wire	[15:0]     product;
wire	op_done;

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
seri_mul	uut	(
			.clk (clk),
			.rstn (rstn),
			.mul_a (mul_a),
			.mul_b (mul_b),
			.en_mul (en_mul),
			.product (product),
			.op_done (op_done)
			);

// Generate clock:
always #10 clk = ~clk;

// initial block
initial
begin
	// initialize signals
	clk = 0;
	rstn = 0;
	mul_a = 0;
	mul_b = 0;
	en_mul = 0;

  // reset system
  #1000 rstn = 1;

  // testcase
  tstcase_01;

	// open results file, write header
	results_file=$fopen("tb_seri_mul_results.txt");
	$fdisplay(results_file, "//----------------------------------------------\n");
	$fdisplay(results_file, "// tb_seri_mul testbench results");
	$fdisplay(results_file, "//----------------------------------------------\n");
	$fwrite(results_file, "\n");
	$fdisplay(results_file, "\t\t\t", "mul_a", "\t\t\t", "mul_b", "\t\t\t", "product");
	//$fdisplay(results_file, "\t\t\t%h\t\t\t%h\t\t\t%h", mul_a, mul_b, product);
	
	// Add more test bench stuff here
	
	
	
	$fclose(results_file);
	$stop;
end


// Add more test bench stuff here as well
task tstcase_01;
  begin
    #20; 
    mul_a = 8'd45;
    mul_b = 8'd89;
    en_mul = 1'b1;
    #20 en_mul = 1'b0;
    #(16*2*`HALF_PRIOD); 
    mul_a = 8'd35;
    mul_b = 8'd39;
    en_mul = 1'b1;
    #20 en_mul = 1'b0;
    #(16*2*`HALF_PRIOD); 
    mul_a = 8'd35;
    mul_b = 8'd39;
    en_mul = 1'b1;
    #20 en_mul = 1'b0;
    #(16*2*`HALF_PRIOD); 
    mul_a = 8'd35;
    mul_b = 8'd39;
    en_mul = 1'b1;
    #20 en_mul = 1'b0;
    #(16*2*`HALF_PRIOD); 
    mul_a = 8'd135;
    mul_b = 8'd39;
    en_mul = 1'b1;
    #20 en_mul = 1'b0;
    #(16*2*`HALF_PRIOD); 
    mul_a = 8'd135;
    mul_b = 8'd199;
    en_mul = 1'b1;
    #20 en_mul = 1'b0;
    #(16*2*`HALF_PRIOD); 
  end
endtask


// Dump FSDB wave
initial
begin
	$fsdbDumpfile("seri_mul.fsdb");
	$fsdbDumpvars;
end


endmodule
