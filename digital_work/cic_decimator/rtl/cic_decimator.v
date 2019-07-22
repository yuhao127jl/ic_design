
//----------------------------------------------------------------------------
//
// Project      : cic_decimator
// Description  : 3-level cic decimator filter
//              : Decimator Rate=32, D=2 
// Designer     :
// Date         : 
//
//----------------------------------------------------------------------------

module cic_decimator(
input [7:0]       cic_din,

output [15:0]     cic_dout,

input             cic_clk,
input             cic_rstn
);

//-------------------------------------------------------------
//
// local parameter
//
//-------------------------------------------------------------
localparam STATE_HOLD   = 1'b0;
localparam STATE_SAMPLE = 1'b1;


//-------------------------------------------------------------
//
// reg and wire
//
//-------------------------------------------------------------
reg [4:0]samp_cnt;
reg      state;
reg [7:0] cic_buf;
reg [25:0] int_buf0;
reg [25:0] int_buf1;
reg [25:0] int_buf2;
reg [25:0] comb_buf00, comb_buf01, comb_buf02;
reg [25:0] comb_buf10, comb_buf11, comb_buf12;
reg [25:0] comb_buf20, comb_buf21, comb_buf22;
reg [25:0] comb_buf3;


//-------------------------------------------------------------
//
// decimator 
//
//-------------------------------------------------------------
wire [4:0] samp_cnt_in = (samp_cnt==5'd31) ? 5'd0 : samp_cnt + 5'd1;
wire deci_samp_pulse = (samp_cnt==5'd8);
//wire deci_samp_pulse = (samp_cnt>8 && samp_cnt<16);
//wire deci_samp_pulse = (~samp_cnt[4] & samp_cnt[3]);
wire [25:0] sxt_din = {{18{cic_buf[7]}}, cic_buf}; // sign extend


// Intergrator
wire [25:0] int_buf0_in = int_buf0 + sxt_din;
wire [25:0] int_buf1_in = int_buf1 + int_buf0;
wire [25:0] int_buf2_in = int_buf2 + int_buf1;


// Comb
wire [25:0] comb_buf01_in = deci_samp_pulse ? comb_buf00 : comb_buf01;
wire [25:0] comb_buf02_in = deci_samp_pulse ? comb_buf01 : comb_buf02;
wire [25:0] comb_buf10_in = deci_samp_pulse ? comb_buf00 - comb_buf02 : comb_buf10;
wire [25:0] comb_buf11_in = deci_samp_pulse ? comb_buf10 : comb_buf11;
wire [25:0] comb_buf12_in = deci_samp_pulse ? comb_buf11 : comb_buf12;
wire [25:0] comb_buf20_in = deci_samp_pulse ? comb_buf10 - comb_buf12 : comb_buf20;
wire [25:0] comb_buf21_in = deci_samp_pulse ? comb_buf20 : comb_buf21;
wire [25:0] comb_buf22_in = deci_samp_pulse ? comb_buf21 : comb_buf22;

wire [25:0] comb_buf3_in =  deci_samp_pulse ? comb_buf20 - comb_buf22 : comb_buf3;

assign cic_dout = comb_buf3[25:10];

//-------------------------------------------------------------
//
// FSM
//
//-------------------------------------------------------------
always @(negedge cic_clk or negedge cic_rstn)
if(!cic_rstn)
begin
  state <= #1 STATE_HOLD;
  comb_buf00 <= #1 26'd0;
end
else
begin
  case(state)
    STATE_HOLD:
    begin
      if(samp_cnt==5'd31)
        begin
          state <= #1 STATE_SAMPLE;
        end
    end

    STATE_SAMPLE:
    begin
      comb_buf00 <= int_buf2;
      state <= #1 STATE_HOLD;
    end
    default: state <= #1 STATE_HOLD;
  endcase
end


//-------------------------------------------------------------
//
// always
//
//-------------------------------------------------------------
always @(negedge cic_clk)
begin
  samp_cnt <= #1 samp_cnt_in;
end


always @(posedge cic_clk or negedge cic_rstn)
if(!cic_rstn)
begin
  cic_buf     <= #1 8'd0;
  int_buf0    <= #1 26'd0;
  int_buf1    <= #1 26'd0;
  int_buf2    <= #1 26'd0;
  comb_buf01  <= #1 26'd0;
  comb_buf02  <= #1 26'd0;
  comb_buf10  <= #1 26'd0;
  comb_buf11  <= #1 26'd0;
  comb_buf12  <= #1 26'd0;
  comb_buf20  <= #1 26'd0;
  comb_buf21  <= #1 26'd0;
  comb_buf22  <= #1 26'd0;
  comb_buf3   <= #1 26'd0;
end
else
begin
  cic_buf     <= #1 cic_din;
  int_buf0    <= #1 int_buf0_in;
  int_buf1    <= #1 int_buf1_in;
  int_buf2    <= #1 int_buf2_in;
  comb_buf01  <= #1 comb_buf01_in;
  comb_buf02  <= #1 comb_buf02_in;
  comb_buf10  <= #1 comb_buf10_in;
  comb_buf11  <= #1 comb_buf11_in;
  comb_buf12  <= #1 comb_buf12_in;
  comb_buf20  <= #1 comb_buf20_in;
  comb_buf21  <= #1 comb_buf21_in;
  comb_buf22  <= #1 comb_buf22_in;
  comb_buf3   <= #1 comb_buf3_in;
end





endmodule
//----------------------------------------------------------------------------
//
// END OF Module
//
//----------------------------------------------------------------------------
