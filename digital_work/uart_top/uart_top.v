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
output [15:0]     uart_txbuf,

output reg        uart_tx,
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
reg [15:0]uart_baud_cnt;
reg [2:0] uart_div_cnt;
reg uart_rx_dly;

wire    icb_clk;
wire    uart_clk;
wire    uart_pnd_set;
reg     uart_pnd;
reg     uart_txpnd;
reg     uart_rxpnd;

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

wire [15:0] txbuf_in = uart_txbuf_wr ? icb_wdat[7:0] : txbuf;



assign  uart_con = {uart_pnd, 5'd0, uart_prty_9bit, 5'd0, uart_prty_en, uart_rxie, uart_txie, uart_en};
assign uart_txbuf = {8'd0, txbuf};

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
wire uart_baud_mch = (uart_baud == uart_baud_cnt) & baud_edge;
wire [15:0] uart_baud_cnt_in = uart_en & !(uart_txbuf_wr || (tx_state==5'd0)) ? uart_baud_cnt + baud_edge :
                              uart_baud_mch || (uart_txbuf_wr || (tx_state==5'd0)) ? 16'd0 : uart_baud_cnt;

wire uart_div_mch = (uart_div_cnt == (uart_div_sel ? 3'd2 : 3'd3));
wire [2:0] uart_div_cnt_in =  (uart_div_mch || (tx_state==5'd0)) ? 3'd0 : uart_div_cnt + uart_baud_mch;

wire uart_txbit_mch = uart_div_mch & baud_edge;


wire [4:0] tx_state_in = ~uart_en ? 5'd0 : send_state;

always @(*)
begin
  case(tx_state)
    5'd0: 
      begin
        if(uart_txbuf_wr) send_state = 5'd1;
      end
    5'd1, 5'd2, 5'd3, 5'd4, 5'd5, 5'd6, 5'd7, 5'd8, 5'd9:
        send_state = tx_state + uart_txbit_mch;
    5'd10:
        send_state = uart_prty_en ? tx_state + uart_txbit_mch : 5'd12;
    5'd11:
        send_state = tx_state + uart_txbit_mch;
    5'd12:
        send_state = 5'd0;
    default: send_state = 5'd0;
  endcase
end


always @(*)
begin
  case(tx_state)
    5'd2: uart_tx = 1'b0;
    5'd3: uart_tx = txbuf[0];
    5'd4: uart_tx = txbuf[1]; 
    5'd5: uart_tx = txbuf[2];
    5'd6: uart_tx = txbuf[3];
    5'd7: uart_tx = txbuf[4];
    5'd8: uart_tx = txbuf[5];
    5'd9: uart_tx = txbuf[6];
    5'd10: uart_tx = txbuf[7];
    5'd11: uart_tx = uart_prty_en ? uart_prty_9bit : 1'b1;
    5'd12: uart_tx = 1'b1;
    default: uart_tx = 1'b1;
  endcase
end

assign uart_txpnd_set = (uart_txpnd & uart_txie) | (uart_rxpnd & uart_rxie);
assign uart_txpnd_clr = uart_txpnd_clr | uart_txbuf_wr;
wire uart_txpnd_in = uart_txpnd_set | uart_txpnd & ~uart_txpnd_clr;


//-------------------------------------------------------------
//
// uart RX
//
//-------------------------------------------------------------
wire uart_rx_start = uart_rx_dly & ~uart_rx; // negedge edge







//-------------------------------------------------------------
//
// 
//
//-------------------------------------------------------------





//-------------------------------------------------------------
//
// 
//
//-------------------------------------------------------------



//-------------------------------------------------------------
//
// 
//
//-------------------------------------------------------------





//-------------------------------------------------------------
//
// uart pending 
//
//-------------------------------------------------------------
//assign uart_txpnd =    ;
//assign uart_rxpnd =    ;
//assign uart_pnd_set = (uart_txpnd & uart_txie) | (uart_rxpnd & uart_rxie);
//assign uart_pnd_clr = uart_pnd_clr | uart_txbuf_wr;
wire uart_pnd_in;
assign uart_int = (uart_txpnd & uart_txie) | (uart_txpnd & uart_txie);


//-------------------------------------------------------------
//
// always
//
//-------------------------------------------------------------
always @(posedge icb_clk or negedge sys_rstn)
if(!sys_rstn)
  begin
    uart_en         <= #1 1'b0;
    uart_txie       <= #1 1'b0;
    uart_rxie       <= #1 1'b0;
    uart_prty_en    <= #1 1'b0;
    uart_div_sel    <= #1 1'b0;
    uart_prty_9bit  <= #1 1'b0;
    txbuf           <= #1 8'd0;
    uart_baud       <= #1 16'd0;
  end
else
  begin
    uart_en         <= #1 uart_en_in;
    uart_txie       <= #1 uart_txie_in;
    uart_rxie       <= #1 uart_txie_in;
    uart_prty_en    <= #1 uart_prty_en_in;
    uart_div_sel    <= #1 uart_div_sel_in;
    uart_prty_9bit  <= #1 uart_prty_9bit_in;
    txbuf           <= #1 txbuf_in;
    uart_baud       <= #1 uart_baud_in;
  end



always @(posedge uart_clk or negedge sys_rstn)
if(!sys_rstn)
  begin
    uart_pnd        <= #1 1'b0;
    uart_baud_cnt   <= #1 16'd0;
    uart_div_cnt    <= #1 3'd0;
    tx_state        <= #1 5'd0;
    uart_rx_dly     <= #1 1'b0;
  end
else
  begin
    uart_pnd        <= #1 uart_pnd_in;
    uart_baud_cnt   <= #1 uart_baud_cnt_in;
    uart_div_cnt    <= #1 uart_div_cnt_in;
    tx_state        <= #1 tx_state_in;
    uart_rx_dly     <= #1 uart_rx;
  end


//always @(posedge uart_clk)
//  begin
//  
//  end


endmodule
//----------------------------------------------------------------------------
//
// END OF Module
//
//----------------------------------------------------------------------------

