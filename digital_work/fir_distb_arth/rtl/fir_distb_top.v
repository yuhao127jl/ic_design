
//----------------------------------------------------------------------------
//
// Project      : Distb FIR filter
// Description  : distributed arithmetic filter
// Designer     :
// Date         : 
//
//----------------------------------------------------------------------------

module fir_distb_top
#(
  parameter IDATA_WIDTH         = 12;
  parameter PDATA_WIDTH         = 13;
  parameter FIR_TAP             = 8;
  parameter FIR_TAPHALF         = 4;
  parameter COEF_WIDTH          = 12;
  parameter ODATA_WIDTH         = 27;
)
(
//input                       fir_con_wr,
//input [15:0]                icb_wdat,

input [IDATA_WIDTH-1:0]     fir_lp_in,

output[ODATA_WIDTH-1:0]     fir_lp_out,

input                       sys_clk,
input                       sys_rstn,
);

//-------------------------------------------------------------
//
// coef parameter
//
//-------------------------------------------------------------
parameter c1 = 12'd41, c2 = 12'd132, c3 = 12'd341, c4 = 12'd510;


//-------------------------------------------------------------
//
// Local parameter
//
//-------------------------------------------------------------
localparam IDLE   = 1'b0;
localparam PROC   = 1'b1;


//-------------------------------------------------------------
//
// reg and wire
//
//-------------------------------------------------------------
reg [3:0] divfre_cnt4b;
reg [IDATA_WIDTH-1:0] fir_buf;
reg [PDATA_WIDTH-1:0] shift_buf[FIR_TAP-1:0];  // 
reg [PDATA_WIDTH-1:0] add_buf[FIR_TAPHALF-1:0]; 
reg [PDATA_WIDTH-1:0] state_shift_buf[FIR_TAPHALF-1:0];  

reg [ODATA_WIDTH-1:0] sum;
reg fir_state;

wire [3:0] tbl_4b;
wire [COEF_WIDTH-1:0] tbl_out_12b;

integer i, j, k, m;


//-------------------------------------------------------------
//
// ICB write register
//
//-------------------------------------------------------------
//wire fir_en_in = fir_con_wr ? icb_wdat[0] : fir_en;


//-------------------------------------------------------------
//
// clock gating
//
//-------------------------------------------------------------
//wire  clk_en = fir_en | fir_con_wr;
//CLKLANQHDV4 clock_gate1(.Q(fir_clk), .CK(sys_clk), .E(clk_en), .TE(1'b0));


//-------------------------------------------------------------
//
// delta function
//
//-------------------------------------------------------------
function [ODATA_WIDTH-1:0] delta;
  input [ODATA_WIDTH-1:0] i_iq;
  input [3:0] i_pipe;
begin
  case(i_pipe)
    4'b0000 : delta = i_iq;
    4'b0001 : delta = {i_iq[ODATA_WIDTH-2:0], 1'd0};
    4'b0010 : delta = {i_iq[ODATA_WIDTH-3:0], 2'd0};
    4'b0011 : delta = {i_iq[ODATA_WIDTH-4:0], 3'd0};
    4'b0100 : delta = {i_iq[ODATA_WIDTH-5:0], 4'd0};
    4'b0101 : delta = {i_iq[ODATA_WIDTH-6:0], 5'd0};
    4'b0110 : delta = {i_iq[ODATA_WIDTH-7:0], 6'd0};
    4'b0111 : delta = {i_iq[ODATA_WIDTH-8:0], 7'd0};
    4'b1000 : delta = {i_iq[ODATA_WIDTH-9:0], 8'd0};
    4'b1001 : delta = {i_iq[ODATA_WIDTH-10:0], 9'd0};
    4'b1010 : delta = {i_iq[ODATA_WIDTH-11:0], 10'd0};
    4'b1011 : delta = {i_iq[ODATA_WIDTH-12:0], 11'd0};
    4'b1100 : delta = {i_iq[ODATA_WIDTH-13:0], 12'd0};
    4'b1101 : delta = {i_iq[ODATA_WIDTH-14:0], 13'd0};
    4'b1110 : delta = {i_iq[ODATA_WIDTH-15:0], 14'd0};
    4'b1111 : delta = {i_iq[ODATA_WIDTH-16:0], 15'd0};
    default : delta = i_iq;
  endcase
end


//-------------------------------------------------------------
//
// divide 13
//
//-------------------------------------------------------------
wire [3:0] divfre_cnt4b_in = (divfre_cnt4b == PDATA_WIDTH) ? 4'd0 : divfre_cnt4b + 4'd1;
wire divfre13_pulse = (divfre_cnt4b == PDATA_WIDTH);


//-------------------------------------------------------------
//
// shift and sum
//
//-------------------------------------------------------------
wire [IDATA_WIDTH-1:0] fir_buf_in = divfre13_pulse ? fir_lp_in : fir_buf;

always @(posedge sys_clk or negedge sys_rstn)
if(!sys_rstn)
  begin
    for(i=0; i<=FIR_TAP-1; i=i+1)
      shift_buf[i] <= #1 13'd0;
  end
else
  begin
    if(divfre13_pulse)
      begin
        for(i=0; i<=FIR_TAP-1; i=i+1)
          shift_buf[i+1] <= #1 shift_buf[i];
        shift_buf[0] <= #1 {fir_buf[IDATA_WIDTH-1], fir_buf);
      end
  end

always @(posedge sys_clk or negedge sys_rstn)
if(!sys_rstn)
  begin
    for(j=0; j<=FIR_TAPHALF-1; j=j+1)
      add_buf[j] <= #1 13'd0;
  end
else
  begin
    if(divfre13_pulse)
      begin
        for(j=0; j<=FIR_TAPHALF-1; j=j+1)
          add_buf[j] <= #1 shift_buf[j] + shift_buf[FIR_TAP-1-j];
      end
  end

//-------------------------------------------------------------
//
// state machine
//
//-------------------------------------------------------------
always @(posedge sys_clk or negedge sys_rstn)
if(!sys_rstn)
  begin
    for(k=0; k<=FIR_TAPHALF-1; k=k+1)
      state_shift_buf[k] <= #1 13'd0;

    fir_state <= #1 IDLE;
  end
else
  begin
    case(fir_state)
      IDLE:
      begin
        for(k=0; k<=FIR_TAPHALF-1; k=k+1)
          state_shift_buf[k] <= #1 add_buf[k];
        
        fir_state <= #1 PROC;
      end

      PROC:
      begin
        if(divfre_cnt4b==4'b1101)
          fir_state <= #1 IDLE;
        else
          begin
            for(k=0; k<=PDATA_WIDTH-2; k=k+1)
              begin
                state_shift_buf[0][k] <= #1 state_shift_buf[0][k+1];
                state_shift_buf[1][k] <= #1 state_shift_buf[1][k+1];
                state_shift_buf[2][k] <= #1 state_shift_buf[2][k+1];
                state_shift_buf[3][k] <= #1 state_shift_buf[3][k+1];
              end
            fir_state <= #1 PROC;
          end
      end
    endcase

  end


//-------------------------------------------------------------
//
// Inst distb_table
//
//-------------------------------------------------------------
assign tbl_4b[0] = state_shift_buf[0][0];
assign tbl_4b[1] = state_shift_buf[1][0];
assign tbl_4b[2] = state_shift_buf[2][0];
assign tbl_4b[3] = state_shift_buf[3][0];

distb_table u_dist_tbl(
.tbl_in_4b  (tbl_4b),
.tbl_out_12b(tbl_out_12b)
);

wire [ODATA_WIDTH-1:0] sign_ex = { {15{tbl_out_12b[11]}}, tbl_out_12b[11:0] };

//-------------------------------------------------------------
//
// sum 
//
//-------------------------------------------------------------
wire [ODATA_WIDTH-1] sum_in = (divfre_cnt4b==4'b0000) ? 27'd0 :
                              (divfre_cnt4b==4'b1101) ? sum - delta(sign_ex, divfre_cnt4b-4'd1) :
                              sum + delta(sign_ex, divfre_cnt4b-4'd1) :
wire [ODATA_WIDTH-1:0] fir_lp_out_in = (divfre_cnt4b==4'b0000) ? sum : fir_lp_out;

//always @(posedge sys_clk or negedge sys_rstn)
//if(!sys_rstn)
//  begin
//    sum <= #1 27'd0;
//  end
//else
//  begin
//    if(divfre_cnt4b==4'b0000)
//      begin
//        sum <= #1 27'd0;
//      end
//    else
//      begin
//        if(divfre_cnt4b==4'b1101)
//          sum <= #1 sum - delta(sign_ex, divfre_cnt4b-4'd1);
//        else
//          sum <= #1 sum + delta(sign_ex, divfre_cnt4b-4'd1);
//      end
//  end




//-------------------------------------------------------------
//
// always
//
//-------------------------------------------------------------
always @(posedge sys_clk or negedge sys_rstn)
if(!sys_rstn)
  begin
    divfre_cnt4b    <= #1 4'd0;
    fir_buf         <= #1 12'd0;
    sum             <= #1 27'd0;
    fir_lp_out      <= #1 27'd0;
  end
else
  begin
    divfre_cnt4b    <= #1 divfre_cnt4b_in;
    fir_buf         <= #1 fir_buf_in;
    sum             <= #1 sum_in;
    fir_lp_out      <= #1 fir_lp_out_in;
  end



endmodule
//----------------------------------------------------------------------------
//
// END OF Module
//
//----------------------------------------------------------------------------

