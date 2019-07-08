//--------------------------------------------------------------
//
// Project      : seri_mul
// Description  : 8 bit serial multiple
// Designer     :
// Date         : 
//
//--------------------------------------------------------------

module seri_mul 
(
input             clk,
input             rstn,
input [7:0]       mul_a,
input [7:0]       mul_b,
input             en_mul,

output reg [15:0] product,
output reg        op_done
);

//-----------------------------------------------
//
// Localparam
//
//-----------------------------------------------
localparam  IDLE     = 2'd0;
localparam  MUL_PRO  = 2'd1;
localparam  FINAL    = 2'd2;


//-----------------------------------------------
//
// Defination
//
//-----------------------------------------------
reg [7:0]   mula_tmp;
reg [15:0]   mulb_tmp;
reg [3:0]    sm_cnt;
reg [1:0]    state;
reg [15:0]   prod_tmp;

//???
//assign product = op_done ? prod_tmp : product;

//-----------------------------------------------
//
// always
//
//-----------------------------------------------
always @(posedge clk or negedge rstn)
if(!rstn)
  begin
    state     <= #1 IDLE;
    sm_cnt    <= #1 4'd0;
    mula_tmp  <= #1 8'd0;
    mulb_tmp  <= #1 16'd0;
    op_done   <= #1 1'b0;
    prod_tmp  <= #1 16'd0;
    product   <= #1 16'd0;
  end
else
begin
  case(state)
    IDLE:
      begin
        if(en_mul)
          begin
            state     <= #1 MUL_PRO;
          end
        sm_cnt    <= #1 4'd0;
        op_done   <= #1 1'b0;
        mula_tmp  <= #1 mul_a;
        mulb_tmp  <= #1 {8'd0, mul_b};
        prod_tmp  <= #1 16'd0;
      end

    MUL_PRO:
      begin
        if(sm_cnt==4'd8)
          begin
            state   <= #1 FINAL;
            sm_cnt  <= #1 4'd0;
            op_done <= #1 1'b1;
            product <= #1 prod_tmp;
          end
        else
          begin
            if(mula_tmp[0]==1'b1)
              begin
                prod_tmp <= #1 prod_tmp + mulb_tmp;
              end
            mula_tmp <= #1 mula_tmp >> 1; 
            mulb_tmp <= #1 mulb_tmp << 1;
            state <= #1 MUL_PRO;
            sm_cnt <= #1 sm_cnt + 4'd1;
          end
      end

    FINAL:
      begin
        state   <= #1 IDLE;
        op_done <= #1 1'b0;
        sm_cnt  <= #1 4'd0;
      end

    default: 
      begin
        sm_cnt    <= #1 4'd0;
        state     <= #1 IDLE;
        op_done   <= #1 1'b0;
        mula_tmp  <= #1 8'd0;
        mulb_tmp  <= #1 16'd0;
        prod_tmp  <= #1 16'd0;
      end
  endcase

end


endmodule
//--------------------------------------------------------------
//
// END OF Module
//
//--------------------------------------------------------------
