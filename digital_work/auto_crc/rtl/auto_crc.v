//*******************************************************************************
// Project      : 
// Module       : auto_crc.v
// Description  : automated crc gen
// Designer     :
// Version      : 
//********************************************************************************

module auto_crc(
input   wire            icb_wr,
input   wire [7:0]      icb_wadr,
input   wire [31:0]     icb_wdat,
output  wire            icb_wack,

input   wire            icb_rd,
input   wire [7:0]      icb_radr,
output  reg  [31:0]     icb_rdat,
output  wire            icb_rack,

input	wire			data_i,

output	wire			data_o,

input   wire            clk,
input   wire            rst_
);


//---------------------------- automated crc ----------------------------//
`define rv_cfg_crc_con            8'd0
`define rv_cfg_crc_poly           8'd1
`define rv_cfg_crc_init           8'd2




//*********************************************************************
//
// Internal Defination
//
//*********************************************************************
wire [255:0] icb_wbus;
wire [255:0] icb_rbus;

wire         crc_con_wr;
wire         crc_poly_wr;
wire         crc_init_wr;

wire [31:0]  crc_con0;
wire [31:0]  crc_poly;
wire [31:0]  crc_init;

reg			  	crc_en;
reg		[2:0] 	crc_len;      // 0 : 0   1: 8bit crc   2: 16bit crc   3: 24bit crc   4: 32bit crc
reg			  	crc_skipaddr;	
reg		[31:0]	crc_init;
reg		[31:0]	crc_poly;

reg		[31:0]	lsfr;

//*********************************************************************
//
// reg file dec
//
//*********************************************************************
icb_dec #(.aw(8)) icb_dec(
    .icb_wr         (icb_wr             ),
    .icb_wadr       (icb_wadr           ),
    .icb_rd         (icb_rd             ),
    .icb_radr       (icb_radr           ),

    .icb_wbus       (icb_wbus           ),
    .icb_rbus       (icb_rbus           ) 
);

assign icb_wack = icb_wr;
assign icb_rack = icb_rd;

assign crc_con_wr 	= icb_wbus[`rv_cfg_crc_con];
assign crc_poly_wr 	= icb_wbus[`rv_cfg_crc_poly];
assign crc_init_wr 	= icb_wbus[`rv_cfg_crc_init];


always @(*)
begin
    case(1'b1)   // synopsys parallel_case
        icb_rbus[`rv_cfg_crc_con]    	: icb_rdat = crc_con;
        icb_rbus[`rv_cfg_crc_poly]    	: icb_rdat = crc_poly;
        icb_rbus[`rv_cfg_crc_init]    	: icb_rdat = crc_init;
        default:                          icb_rdat = 32'd0;
    endcase
end


//*********************************************************************
//
// icb read
//
//*********************************************************************
wire	      	crc_en_in			= crc_con_wr ? icb_wdat[0] : crc_en;
wire	[2:0] 	crc_len_in			= crc_con_wr ? icb_wdat[3:1] : crc_len;
wire	      	crc_skipaddr_in		= crc_con_wr ? icb_wdat[4] : crc_skipaddr;

wire	[31:0] 	crc_poly_in			= crc_poly_wr ? icb_wdat[31:0] : crc_poly;
wire	[31:0] 	crc_init_in			= crc_init_wr ? icb_wdat[31:0] : crc_init;

wire	[5:0]	crc_bitnum			= {crc_len, 3'd0};


//*********************************************************************
//
// clock gating
//
//*********************************************************************
wire clk_en = crc_en | crc_con_wr | crc_poly_wr | crc_init_wr;
CLKLANQHDV4 clock_gate(.Q(crc_clk), .CK(clk), .E(clk_en), .TE(1'b0));


//*********************************************************************
//
// automated crc
//
//*********************************************************************
wire	[31:0] lsfr_in = 





//********************************************************************************
//
// END of Module
//
//********************************************************************************
endmodule
