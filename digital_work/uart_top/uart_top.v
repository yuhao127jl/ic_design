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
// reg and wire
//
//-------------------------------------------------------------
reg uart_txie;
reg uart_rxie;
reg uart_prty_en;
reg uart_prty_9bit;
reg uart_div_sel;

reg [7:0]txbuf;

wire    icb_clk;
wire    uart_clk;
wire    uart_pnd_set;
reg     uart_pnd;

reg baud_clk_div2;
reg baud_clk_div2_dly1;
reg baud_clk_div2_dly2;
reg baud_clk_div2_dly3;
wire baud_edge;

reg [4:0] tx_state;
reg [4:0] send_state;

reg [4:0] rx_state;
reg [4:0] rece_state;
//-------------------------------------------------------------
//
// ICB write register
//
//-------------------------------------------------------------
wire uart_en_in = uart_con_wr ? icb_wdat[0] : uart_en;
wire uart_txie_in = uart_con_wr ? icb_wdat[1] : uart_txie;
wire uart_rxie_in = uart_con_wr ? icb_wdat[2] : uart_rxie;
wire uart_prty_en_in = uart_con_wr ? icb_wdat[3] : uart_prty_en;
wire uart_div_sel_in = uart_con_wr ? icb_wdat[4] : uart_div_sel;
wire uart_prty_9bit_in = uart_con_wr ? icb_wdat[9] : uart_prty_9bit;
wire uart_txpnd_clr = uart_con_wr & icb_wdat[10];
wire uart_rxpnd_clr = uart_con_wr & icb_wdat[11];

wire [15:0] uart_baud_in = uart_baud_wr ? icb_wdat[15:0] : uart_baud;

wire [7:0] txbuf_in = uart_txbuf_wr ? icb_wdat[7:0] : txbuf;



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

assign baud_edge = baud_clk_div2_dly2 ^ baud_clk_div2_dly3;


//-------------------------------------------------------------
//
// uart TX
//
//-------------------------------------------------------------
wire uart_baud_mch = (uart_baud == uart_baud_cnt);
wire [15:0] uart_baud_cnt_in = !(uart_txbuf_wr & (tx_state==5'd0)) ? uart_baud_cnt + baud_edge :
                               (uart_txbuf_wr & (tx_state==5'd0)) ? 16'd0 : uart_baud_cnt;
wire uart_div_mch = (uart_div_cnt == (uart_div_sel ? 3'd2 : 3'd3));
wire [2:0] uart_div_cnt_in =  T1 ? uart_div_cnt + uart_baud_mch :
                              T2 ? 3'd0 : uart_div_cnt;

wire uart_txbit_mch = uart_div_mch & baud_edge;


wire [4:0] tx_state_in = ~uart_en ? 5'd0 : tx_state;

always @(*)
begin
  case(tx_state)
    5'd0: 
      begin
        if(uart_txbuf_wr) tx_state <= #1 5'd1;
        else              tx_state <= #1 5'd0;
      end

    5'd1, 5'd2, 5'd3, 5'd4, 5'd5, 5'd6, 5'd7, 5'd8, 5'd9:
      begin
        tx_state <= tx_state + uart_txbit_mch;
      end
    
    5'd10:
    begin
    	if(
    end
    5'd11:


    5'd12:



    default: 
  
  endcase

end

always @(*)
begin
  case(tx_state)
    5'd2: uart_tx = txbuf[0];
    5'd3: uart_tx = txbuf[1]; 
    5'd4: uart_tx = txbuf[2];
    5'd5: uart_tx = txbuf[3];
    5'd6: uart_tx = txbuf[4];
    5'd7: uart_tx = txbuf[5];
    5'd8: uart_tx = txbuf[6];
    5'd9: uart_tx = txbuf[7];
    
    5'd10:
    5'd11:
    5'd12:

    default: uart_tx = 1'b1;
  
  endcase

end


//-------------------------------------------------------------
//
// uart RX
//
//-------------------------------------------------------------
wire uart_rx_start = uart_rx_dly & ~uart_rx; // negedge edge







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
// timer
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
// uart pending 
//
//-------------------------------------------------------------
assign uart_txpnd =    ;
assign uart_rxpnd =    ;
assign uart_pnd_set = (uart_txpnd & uart_txie) | (uart_rxpnd & uart_rxie);
assign uart_pnd_clr = uart_pnd_clr | uart_txbuf_wr;
wire uart_pnd_in = uart_pnd_set | uart_pnd & ~uart_pnd_clr;

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
    uart_pnd        <= #1 1'b0;
    uart_baud_cnt   <= #1 16'd0;
    tx_state        <= #1 5'd0;
    uart_rx_dly     <= #1 1'b0;
  end
else
  begin
    uart_pnd        <= #1 tmr_pnd_in;
    uart_baud_cnt   <= #1 uart_baud_cnt_in;
    tx_state        <= #1 tx_state_in;
    uart_rx_dly     <= #1 uart_rx;
  end


always @(posedge uart_clk)
  begin
    uart_baud   <= #1 uart_baud_in;
    txbuf       <= #1 txbuf_in;
  
  end


endmodule
//----------------------------------------------------------------------------
//
// END OF Module
//
//----------------------------------------------------------------------------

