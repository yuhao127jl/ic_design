//--------------------------------------------------------------
//
// Project      : 16bit timer
// Description  :
// Designer     :
// Date         : 
//
//--------------------------------------------------------------

module timer(
input             tmr_cnt_wr,
input             tmr_con_wr,
input             tmr_prd_wr,
input [15:0]      icb_wdat,

input             clkisrc1,
input             clkisrc2,
input             clkisrc3,
input             clkisrc4,

input             icsrc,

output [15:0]     tmr_con,
output reg[15:0]  tmr_prd,
output reg[15:0]  tmr_cnt,
output            tmr_ovf,
output            tmr_int,

input             sys_clk,
input             sys_rstn
);

//-----------------------------------------------
//
// param
//
//-----------------------------------------------
reg [1:0]tmr_mode; // 0:no 1: timer 2: capture posedge 3: capture negedge
reg [1:0]tmr_ssel; // clk select
reg [3:0]tmr_dsel; // divider 

//reg [15:0]capt_cnt;

wire    icb_clk;
wire    tmr_clk;
wire    tmr_pnd_suspd;
reg     tmr_pnd;
wire    capt_edge;

//-----------------------------------------------
//
// ICB write register
// APB bus read & write
//
//-----------------------------------------------
wire [1:0]tmr_mode_in = tmr_con_wr ? icb_wdat[1:0] : tmr_mode; // 0:no 1: timer 2: capture posedge 3: capture negedge
wire [1:0]tmr_ssel_in = tmr_con_wr ? icb_wdat[3:2] : tmr_ssel; // clk select
wire [3:0]tmr_dsel_in = tmr_con_wr ? icb_wdat[7:4] : tmr_dsel; // divider 
wire      tmr_pnd_clr = tmr_con_wr & icb_wdat[10];

wire tmr_en = (|tmr_mode);

wire tmr_pnd_in = tmr_pnd_suspd | tmr_pnd & ~tmr_pnd_clr;

assign  tmr_con = {tmr_pnd, 4'd0, 3'd0, tmr_dsel[3:0], tmr_ssel[1:0], tmr_mode[1:0]};

assign tmr_int = tmr_pnd;

//-----------------------------------------------
//
// clock gating
//
//-----------------------------------------------
wire  clk_en = tmr_en | tmr_con_wr | tmr_prd_wr | tmr_cnt_wr;
CLKLANQHDV4(.Q(tmr_clk), .CK(sys_clk), .E(clk_en), .TE(1'b0));

wire  icb_en = tmr_con_wr | tmr_prd_wr | tmr_cnt_wr;
CLKLANQHDV4(.Q(icb_clk), .CK(sys_clk), .E(icb_en), .TE(1'b0));

//-----------------------------------------------
//
// reg
//
//-----------------------------------------------
wire      clksrc;
wire      frqdiv;
reg       frqdiv_ss;
reg       icsrc_ss;


//-----------------------------------------------
//
// APB Bus decode
//
//-----------------------------------------------
// ......

//-----------------------------------------------
//
// input clk select
//
//-----------------------------------------------
MUX4HD1X muxsrc(
  .Z(clksrc), 
  .A(clkisrc1), 
  .B(clkisrc2), 
  .C(clkisrc3), 
  .D(clkisrc4), 
  .S0(tmr_ssel[0]), 
  .S1(tmr_ssel[1]));

//-----------------------------------------------
//
// divider
// tmr_dsel[3]: 0 -> x1, 1 -> x256   
// tmr_dsel[2]: 0 -> x1, 1 -> x2    
// tmr_dsel[1:0]: 0 -> x2, 1 -> x8, 2 -> x32, 3 -> x64   
//
//-----------------------------------------------
FFDCRHD2X dff00(.Q(dff00_q),.QN(dff00_qn),.D(dff00_qn),.RN(tmr_en),.CK(clksrc));
FFDCRHD2X dff01(.Q(dff01_q),.QN(dff01_qn),.D(dff01_qn),.RN(tmr_en),.CK(dff00_q));
FFDCRHD2X dff02(.Q(dff02_q),.QN(dff02_qn),.D(dff02_qn),.RN(tmr_en),.CK(dff01_q));
FFDCRHD2X dff03(.Q(dff03_q),.QN(dff03_qn),.D(dff03_qn),.RN(tmr_en),.CK(dff02_q));
FFDCRHD2X dff04(.Q(dff04_q),.QN(dff04_qn),.D(dff04_qn),.RN(tmr_en),.CK(dff03_q));
FFDCRHD2X dff05(.Q(dff05_q),.QN(dff05_qn),.D(dff05_qn),.RN(tmr_en),.CK(dff04_q));
FFDCRHD2X dff06(.Q(dff06_q),.QN(dff06_qn),.D(dff06_qn),.RN(tmr_en),.CK(dff05_q));
FFDCRHD2X dff07(.Q(dff07_q),.QN(dff07_qn),.D(dff07_qn),.RN(tmr_en),.CK(dff06_q));

MUX2HD2X muxdvd00(.Z(mux2_clk0), .A(clksrc), .B(dff07_q), .S0(tmr_dsel[3]));

FFDCRHD2X dff10(.Q(dff10_q),.QN(dff10_qn),.D(dff10_qn),.RN(tmr_en),.CK(mux2_clk0));

MUX2HD2X muxdvd01(.Z(mux2_clk1), .A(mux2_clk0), .B(dff10_q), .S0(tmr_dsel[2]));

FFDCRHD2X dff20(.Q(dff20_q),.QN(dff20_qn),.D(dff20_qn),.RN(tmr_en),.CK(mux2_clk1));
FFDCRHD2X dff21(.Q(dff21_q),.QN(dff21_qn),.D(dff21_qn),.RN(tmr_en),.CK(dff20_q));
FFDCRHD2X dff22(.Q(dff22_q),.QN(dff22_qn),.D(dff22_qn),.RN(tmr_en),.CK(dff21_q));
FFDCRHD2X dff23(.Q(dff23_q),.QN(dff23_qn),.D(dff23_qn),.RN(tmr_en),.CK(dff22_q));
FFDCRHD2X dff24(.Q(dff24_q),.QN(dff24_qn),.D(dff24_qn),.RN(tmr_en),.CK(dff23_q));
FFDCRHD2X dff25(.Q(dff25_q),.QN(dff25_qn),.D(dff25_qn),.RN(tmr_en),.CK(dff24_q));
FFDCRHD2X dff26(.Q(dff26_q),.QN(dff26_qn),.D(dff26_qn),.RN(tmr_en),.CK(dff25_q));

MUX4HD1X mux20(
  .Z(frqdiv), 
  .A(dff20_qn), 
  .B(dff22_qn), 
  .C(dff24_qn), 
  .D(dff26_qn), 
  .S0(tmr_dsel[0]), 
  .S1(tmr_dsel[1]));

// different clock source, so sync proc
sync sync01(.din(frqdiv), .clk(tmr_clk), .dout(frqdiv_s));

// dual edge : posedge and negedge
wire inc_active = tmr_en & (frqdiv_ss ^ frqdiv_s);

//-----------------------------------------------
//
// timer
// inc_active is dual edge, so 1/2
//
//-----------------------------------------------
wire  prd_mch = (tmr_mode==2'd1) & (tmr_cnt == tmr_prd) & inc_active;
wire  [15:0] tmr_cnt_in = tmr_cnt_wr ? icb_wdat[15:0] :
                          prd_mch ? 16'd0 :
                          inc_active ? (tmr_cnt + inc_active) :
                          tmr_cnt;

assign tmr_pnd_suspd = prd_mch | capt_edge;
assign tmr_ovf = prd_mch; 

//-----------------------------------------------
//
// capture posedge or negedge
//
//-----------------------------------------------
// different clock source, so sync proc
sync  sync02(.din(icsrc), .clk(tmr_clk), .dout(icsrc_s));
assign capt_edge = tmr_mode[1] & ( tmr_mode[0] ? (~icsrc_s & icsrc_ss) : (icsrc_s & ~icsrc_ss));
wire [15:0]tmr_prd_in = tmr_prd_wr ? icb_wdat[15:0] : 
                        capt_edge ? tmr_cnt :
                        tmr_prd;


//-----------------------------------------------
//
// always
//
//-----------------------------------------------
always @(posedge icb_clk or negedge sys_rstn)
if(!sys_rstn)
  begin
    tmr_mode <= #1 2'd0;
    tmr_ssel <= #1 2'd0;
    tmr_dsel <= #1 4'd0;
  end
else
  begin
    tmr_mode <= #1 tmr_mode_in;
    tmr_ssel <= #1 tmr_ssel_in;
    tmr_dsel <= #1 tmr_dsel_in;
  end


always @(posedge tmr_clk or negedge sys_rstn)
if(!sys_rstn)
  begin
    tmr_pnd <= #1 1'b0;
  end
else
  begin
    tmr_pnd <= #1 tmr_pnd_in;
  end


always @(posedge tmr_clk)
  begin
    frqdiv_ss <= #1 frqdiv_s;
    icsrc_ss  <= #1 icsrc;
    tmr_cnt <= #1 tmr_cnt_in;
    tmr_prd  <= #1 tmr_prd_in;
  end


endmodule
//--------------------------------------------------------------
//
// END OF Module
//
//--------------------------------------------------------------

