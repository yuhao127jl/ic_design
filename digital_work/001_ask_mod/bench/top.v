`timescale 1 ns/ 1 ps

module ask_mod_tb();
// test vector input registers
reg [1:0] ask_din;
reg 	  ask_valid_i;
reg clk;
reg rstn;
// wires                                               
wire signed [11:0]  ask_dout;
wire 		    ask_valid_o;

//**********************************
// Instance
//**********************************                          
ask_mod ask_mod_inst (   
	.ask_valid_i(ask_valid_i),
	.ask_din(ask_din),
	.ask_valid_o(ask_valid_o),
	.ask_dout(ask_dout),
	.clk(clk),
	.rstn(rstn)
);

initial                                                
begin                                                  
	clk = 0;
	rstn = 0;
	ask_valid_i = 0;
	#100 rstn = 1; 
	$display("Running testbench");                       

	#200 ask_din = 2'd0;
	ask_valid_i = 1;

	repeat(500) #1000 ask_din = $random % 4;

	#1000 ask_din = 2'd1;
	#1000 ask_din = 2'd2;
	#1000 ask_din = 2'd3;
	#1000 ask_din = 2'd0;
	#1000 ask_din = 2'd1;
	#1000 ask_din = 2'd2;
	#1000 ask_din = 2'd3;
	#1000 ask_din = 2'd0;
	#1000 ask_din = 2'd1;
	#1000 ask_din = 2'd2;
	#1000 ask_din = 2'd3;
	#1000 ask_din = 2'd0;
	ask_valid_i = 0;
end 

//**********************************
// clock : 50MHz
//**********************************
always #10 clk = ~clk;
 
//**********************************
// DUMP Wave
//**********************************
initial
begin
	$fsdbDumpfile("ask.fsdb");
	$fsdbDumpvars;
end

                                                  
endmodule
