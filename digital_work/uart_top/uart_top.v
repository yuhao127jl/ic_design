//----------------------------------------------------------------------------
//
// Project      : uart_top
// Description  : uart tx rx
// Designer     :
// Date         : 
//
//----------------------------------------------------------------------------

module uart_top(
input             uart_baud_wr,
input             uart_con_wr,
input             uart_txbuf_wr,
input [15:0]      icb_wdat,

output [15:0]     uart_con,
output reg[15:0]  uart_baud,
output reg[15:0]  uart_txbuf,

output            uart_tx,
output            uart_rx,
output reg        uart_en,
output            uart_int,

input             sys_clk,
input             uart_baud_clk,
input             sys_rstn
);

//-------------------------------------------------------------
//
// param
//
//-------------------------------------------------------------
reg uart_txie;
reg uart_rxie;
reg uart_prty_en;
reg uart_prty_9bit;

reg [7:0]txbuf;

wire    icb_clk;
wire    uart_clk;
wire    uart_pnd_set;
reg     uart_pnd;

//-------------------------------------------------------------
//
// ICB write register
//
//-------------------------------------------------------------
wire uart_en_in = uart_con_wr ? icb_wdat[0] : uart_en;
wire uart_txie_in = uart_con_wr ? icb_wdat[1] : uart_txie;
wire uart_rxie_in = uart_con_wr ? icb_wdat[2] : uart_rxie;
wire uart_prty_en_in = uart_con_wr ? icb_wdat[3] : uart_prty_en;
wire uart_prty_9bit_in = uart_con_wr ? icb_wdat[9] : uart_prty_9bit;
wire uart_txpnd_clr = uart_con_wr & icb_wdat[10];
wire uart_rxpnd_clr = uart_con_wr & icb_wdat[11];

wire [15:0] uart_baud_in = uart_baud_wr ? icb_wdat[15:0] : uart_baud;
wire [7:0] txbuf_in = uart_txbuf_wr ? icb_wdat[7:0] : txbuf;


wire uart_pnd_in = uart_pnd_set | uart_pnd & ~uart_pnd_clr;

assign  uart_con = {uart_pnd, 5'd0, uart_prty_9bit, 5'd0, uart_prty_en, uart_rxie, uart_txie, uart_en};

assign uart_int = uart_pnd;


//-------------------------------------------------------------
//
// clock gating
//
//-------------------------------------------------------------
wire  clk_en = uart_en | uart_con_wr | uart_baud_wr | uart_txbuf_wr;
CLKLANQHDV4 clock_gate1(.Q(uart_clk), .CK(sys_clk), .E(clk_en), .TE(1'b0));

wire  icb_en = uart_con_wr | uart_baud_wr | uart_txbuf_wr;
CLKLANQHDV4 clock_gate2(.Q(icb_clk), .CK(sys_clk), .E(icb_en), .TE(1'b0));


//-------------------------------------------------------------
//
// reg
//
//-------------------------------------------------------------
reg baud_clk_div2;
reg baud_clk_div2_dly1;
reg baud_clk_div2_dly2;
reg baud_clk_div2_dly3;
wire      clksrc;
wire      frqdiv;
reg       frqdiv_ss;
reg       icsrc_ss;


//-------------------------------------------------------------
//
// sample pulse
//
//-------------------------------------------------------------
always @(negedge uart_baud_clk or negedge sys_rstn)
if(!sys_rstn)
begin
  baud_clk_div2 <= #1 1'b0;
end
else
begin
  baud_clk_div2 <= #1 ~baud_clk_div2;
end

always @(posedge uart_clk)
begin
  baud_clk_div2_dly1 <= #1 baud_clk_div2;
  baud_clk_div2_dly2 <= #1 baud_clk_div2_dly1;
  baud_clk_div2_dly3 <= #1 baud_clk_div2_dly2;
end






//-------------------------------------------------------------
//
// input clk select
//
//-------------------------------------------------------------
MUX4HD1X muxsrc(
  .Z(clksrc), 
  .A(clkisrc1), 
  .B(clkisrc2), 
  .C(clkisrc3), 
  .D(clkisrc4), 
  .S0(tmr_ssel[0]), 
  .S1(tmr_ssel[1]));

//-------------------------------------------------------------
//
// divider
// tmr_dsel[3]: 0 -> x1, 1 -> x256   
// tmr_dsel[2]: 0 -> x1, 1 -> x2    
// tmr_dsel[1:0]: 0 -> x2, 1 -> x8, 2 -> x32, 3 -> x64   
//
//-------------------------------------------------------------

//-------------------------------------------------------------
//
// timer
// inc_active is dual edge, so 1/2
//
//-------------------------------------------------------------

assign tmr_pnd_suspd = prd_mch | capt_edge;
assign tmr_ovf = prd_mch; 

//-------------------------------------------------------------
//
// capture posedge or negedge
//
//-------------------------------------------------------------
// different clock source, so sync proc
sync  sync02(.din(icsrc), .clk(tmr_clk), .dout(icsrc_s));
assign capt_edge = tmr_mode[1] & ( tmr_mode[0] ? (~icsrc_s & icsrc_ss) : (icsrc_s & ~icsrc_ss));
wire [15:0]tmr_prd_in = tmr_prd_wr ? icb_wdat[15:0] : 
                        capt_edge ? tmr_cnt :
                        tmr_prd;


//-------------------------------------------------------------
//
// always
//
//-------------------------------------------------------------
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


always @(posedge uart_clk or negedge sys_rstn)
if(!sys_rstn)
  begin
    tmr_pnd <= #1 1'b0;
  end
else
  begin
    tmr_pnd <= #1 tmr_pnd_in;
  end


always @(posedge uart_clk)
  begin
    frqdiv_ss <= #1 frqdiv_s;
    icsrc_ss  <= #1 icsrc_s;
    tmr_cnt <= #1 tmr_cnt_in;
    tmr_prd  <= #1 tmr_prd_in;
  end


endmodule
//----------------------------------------------------------------------------
//
// END OF Module
//
//----------------------------------------------------------------------------

