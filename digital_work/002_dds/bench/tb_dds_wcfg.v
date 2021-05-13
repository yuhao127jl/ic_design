/*****************************************************************

 tb_dds_wcfg.v module

******************************************************************

 created on:	11/29/2019 
 created by:	klin
 last edit on:	11/29/2019 
 last edit by:	klin
 revision:	v1.0
 Copyright © 2019 

******************************************************************

 This module implements the test bench for the dds_wcfg.v module.

******************************************************************/
`timescale	1ns/1ps

`define     RESET_TIME                80000
`define     PEROIDTIME                80000
`define     FREQ_CTRL_WORD            (1<<22)

`define     rv_cfg_dds_con0           8'd0
`define     rv_cfg_dds_con1           8'd1


module tb_dds_wcfg (); 


// *** Input, Inouts to UUT ***
reg	                icb_wr;
reg	[7:0]           icb_wadr;
reg	[31:0]          icb_wdat;
reg	                icb_rd;
reg	[7:0]           icb_radr;
reg	                clk;
reg	                rst_;

// *** Outputs from UUT ***
wire	            icb_wack;
wire	[31:0]      icb_rdat;
wire	            icb_rack;
wire	[15:0]      sin_dout;
wire	[15:0]      cos_dout;

reg                 simend;

//**********************************************************
//
// Instantiate the UUT module
//
//**********************************************************
dds_wcfg	dds_top(
    .icb_wr (icb_wr),
    .icb_wadr (icb_wadr),
    .icb_wdat (icb_wdat),
    .icb_wack (icb_wack),
    .icb_rd (icb_rd),
    .icb_radr (icb_radr),
    .icb_rdat (icb_rdat),
    .icb_rack (icb_rack),
    .sin_dout (sin_dout),
    .cos_dout (cos_dout),
    .clk (clk),
    .rst_ (rst_)
);

//**********************************************************
//
// Generate clock
//
//**********************************************************
always #10 clk = ~clk;


//**********************************************************
//
// initial block
//
//**********************************************************
initial
begin
	// initialize signals
	icb_wr = 0;
	icb_wadr = 0;
	icb_wdat = 0;
	icb_rd = 0;
	icb_radr = 0;
	clk = 0;
	rst_ = 0;
    simend = 0;

    #(`RESET_TIME) rst_ = 1;
    #(5*`PEROIDTIME);
	
    dds_wr(`rv_cfg_dds_con0, `FREQ_CTRL_WORD);
    #(2*`PEROIDTIME);
	
    dds_wr(`rv_cfg_dds_con1, 32'h00000001);
    #(5*`PEROIDTIME);

    dds_rd(`rv_cfg_dds_con0);
    dds_rd(`rv_cfg_dds_con1);
	
    #(100*`PEROIDTIME);
    simend = 1;
end

//**********************************************************
//
// read register file
//
//**********************************************************
reg  [31:0] rdat_regfile;
wire [31:0] rdat_regfile_in = icb_rack ? icb_rdat : rdat_regfile;

always @(posedge clk or negedge rst_)
if(!rst_)
begin
    rdat_regfile    <= #1 32'd0;
end
else
begin
    rdat_regfile    <= #1 rdat_regfile_in;
end


initial
begin
    while(1)
    begin
        @(posedge clk);
        if(icb_rack)
        begin
            $display("[ICB_RD]: addr = %d, rdat = %h ", icb_radr, icb_rdat);
        end

        if(simend) $finish;
    end
end


//**********************************************************
//
// 
//
//**********************************************************
task dds_wr(input [7:0] wadr, input [31:0] wdat);
begin
    @(posedge clk) #1;
    icb_wr = 1;
    icb_wadr = wadr;
    icb_wdat = wdat;
    @(posedge clk) #1;
    icb_wr = 0;
end
endtask


task dds_rd(input [7:0] radr);
begin
    @(posedge clk) #1;
    icb_rd = 1;
    icb_radr = radr;
    @(posedge clk) #1;
    icb_rd = 0;
end
endtask


//**********************************************************
//
// Dump FSDB wave
//
//**********************************************************
initial
begin
	$fsdbDumpfile("ic_design.fsdb");
	$fsdbDumpvars;
end


endmodule
