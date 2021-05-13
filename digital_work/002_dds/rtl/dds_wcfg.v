//*******************************************************************************
// Project		: 
// Module		: dds_wcfg.v
// Description	: fk = (fclk*2^22) / (2^10 * freq_ctrl_word)
// Designer		: 
// Version		: 
//*******************************************************************************

module dds_wcfg(
    input   wire            icb_wr,
    input   wire [7:0]      icb_wadr,
    input   wire [31:0]     icb_wdat,
    output  wire            icb_wack,

    input   wire            icb_rd,
    input   wire [7:0]      icb_radr,
    output  reg  [31:0]     icb_rdat,
    output  wire            icb_rack,

    output  wire [15:0]     sin_dout,
    output  wire [15:0]     cos_dout,

    input   wire            clk,
    input   wire            rst_
);

//**********************************************************
//
// Define
//
//**********************************************************
`define rv_cfg_dds_con0           8'd0
`define rv_cfg_dds_con1           8'd1


//****************************************************************
//
// Internal defination
//
//****************************************************************
wire [255:0]            icb_wbus;
wire [255:0]            icb_rbus;

wire                    dds_con0_wr;
wire                    dds_con1_wr;
wire [31:0]             dds_con0;
wire [31:0]             dds_con1;
reg  [31:0]             freq_ctrl_word;
reg                     dds_en;

reg  [31:0]             sum_fcw;


//****************************************************************
//
// reg file dec
//
//****************************************************************
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

assign dds_con0_wr = icb_wbus[`rv_cfg_dds_con0];
assign dds_con1_wr = icb_wbus[`rv_cfg_dds_con1];


always @(*)
begin
    case(1'b1)   // synopsys parallel_case
        icb_rbus[`rv_cfg_dds_con0]    : icb_rdat = dds_con0;
        icb_rbus[`rv_cfg_dds_con1]    : icb_rdat = dds_con1;
        default:                        icb_rdat = 32'd0;
    endcase
end


//****************************************************************
//
// write config
//
//****************************************************************
wire    [31:0]  freq_ctrl_word_in = dds_con0_wr ? icb_wdat[31:0] : freq_ctrl_word;
wire            dds_en_in         = dds_con1_wr ? icb_wdat[0]    : dds_en;

assign  dds_con0 = freq_ctrl_word;
assign  dds_con1 = {31'd0, dds_en};


//****************************************************************
//
// 
//
//****************************************************************
wire    [31:0]  sum_fcw_in        = dds_en ? sum_fcw + freq_ctrl_word : sum_fcw;
wire    [9:0]   addr              = sum_fcw[31:22];


//****************************************************************
//
// 
//
//****************************************************************
sin_tbl     sin( .addr(addr), .sin_dat(sin_dout));
cos_tbl     cos( .addr(addr), .cos_dat(cos_dout));


//**********************************************************
//
// always
//
//**********************************************************
always @(posedge clk or negedge rst_)
if(!rst_)
begin
    freq_ctrl_word              <= #1 32'd0;
    dds_en                      <= #1 1'd0;
    sum_fcw                     <= #1 32'd0;
end
else
begin
    freq_ctrl_word              <= #1 freq_ctrl_word_in;
    dds_en                      <= #1 dds_en_in;
    sum_fcw                     <= #1 sum_fcw_in;
end



endmodule
//*******************************************************************************
//
// END of Module
//
//*******************************************************************************
