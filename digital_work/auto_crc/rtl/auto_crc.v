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
wire	[31:0] lsfr_in = !crc_en ? crc_init :
						 
wire	lsfr_xor	= lsfr[crc_bitnum-1] ^ data_i;

wire	lsfr_pos00	= lsfr_xor & crc_poly[0];
wire	lsfr_pos01	= lsfr_xor ^ (lsfr[0] & crc_poly[1]);
wire	lsfr_pos02	= lsfr_xor ^ (lsfr[1] & crc_poly[2]);
wire	lsfr_pos03	= lsfr_xor ^ (lsfr[2] & crc_poly[3]);
wire	lsfr_pos04	= lsfr_xor ^ (lsfr[3] & crc_poly[4]);

wire	lsfr_pos05	= lsfr_xor ^ (lsfr[4] & crc_poly[5]);
wire	lsfr_pos06	= lsfr_xor ^ (lsfr[5] & crc_poly[6]);
wire	lsfr_pos07	= lsfr_xor ^ (lsfr[6] & crc_poly[7]);
wire	lsfr_pos08	= lsfr_xor ^ (lsfr[7] & crc_poly[8]);

wire	lsfr_pos09	= lsfr_xor ^ (lsfr[8] & crc_poly[9]);
wire	lsfr_pos10	= lsfr_xor ^ (lsfr[9] & crc_poly[10]);
wire	lsfr_pos11	= lsfr_xor ^ (lsfr[10] & crc_poly[11]);
wire	lsfr_pos12	= lsfr_xor ^ (lsfr[11] & crc_poly[12]);

wire	lsfr_pos13	= lsfr_xor ^ (lsfr[12] & crc_poly[13]);
wire	lsfr_pos14	= lsfr_xor ^ (lsfr[13] & crc_poly[14]);
wire	lsfr_pos15	= lsfr_xor ^ (lsfr[14] & crc_poly[15]);
wire	lsfr_pos16	= lsfr_xor ^ (lsfr[15] & crc_poly[16]);

wire	lsfr_pos13	= lsfr_xor ^ (lsfr[12] & crc_poly[13]);
wire	lsfr_pos14	= lsfr_xor ^ (lsfr[13] & crc_poly[14]);
wire	lsfr_pos15	= lsfr_xor ^ (lsfr[14] & crc_poly[15]);
wire	lsfr_pos16	= lsfr_xor ^ (lsfr[15] & crc_poly[16]);

always @(posedge crc_clk or negedge rst_)
if(!rst_)
begin


end
else
begin


end



//********************************************************************************
//
// END of Module
//
//********************************************************************************
endmodule
