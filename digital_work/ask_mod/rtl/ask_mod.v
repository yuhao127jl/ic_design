//*********************************************
// Project      : ASK_Modulation
// DesignModule : ask_mod.v  
// Description  :
// Designer     :
// Date         : 
//*********************************************
module ask_mod(
input   wire                    clk,  // 50MHz
input   wire                    rstn,
input   wire                    ask_valid_i,  
input   wire            [1:0]   ask_din,

output  wire signed     [11:0]  ask_dout,
output  wire                    ask_valid_o
);

//**************************************
// Internal Defination
//**************************************
reg             [4:0]   addr;
wire signed     [11:0]  sine;
reg             [11:0]  ask;
wire                    sin_valid;      
wire            [4:0]   addr_in = (ask_valid_i) ? (addr==5'd24) ? 5'd0 :
                                  addr + 5'd1 : 5'd0;

//**************************************
// Instance sin_carrier
//**************************************
sin_carrier dds(
.clk            (clk),
.ce             (ask_valid_i),
.addr           (addr),
.sine           (sine),
.sin_valid      (sin_valid)
);


//**************************************
// 
//**************************************
always @(*)
if(ask_valid_i)
begin
        case(ask_din)
        2'd0:   ask <= #1 12'd0;

        // 0.3281 = 1/4 + 1/16 + 1/32
        2'd1:   ask <= #1 {{2{sine[11]}},sine[11:2]} + {{4{sine[11]}},sine[11:4]} + {{5{sine[11]}},sine[11:5]} ;

        // 0.6563 = 1/2 + 1/8 + 1/16
        2'd2:   ask <= #1 {sine[11],sine[11:1]} + {{3{sine[11]}},sine[11:3]} + {{4{sine[11]}},sine[11:4]} ;

        2'd3:   ask <= #1 sine;
        endcase
end
else
begin
        ask <= #1 12'd0;
end

assign ask_dout = ask;
assign ask_valid_o = ask_valid_i;

//**************************************
// Assignment
//**************************************
always @(posedge clk or negedge rstn)
if(!rstn)
begin
        addr <= #1 5'd0;
end
else
begin
        addr <= #1 addr_in;
end

endmodule
//*********************************************
//
// END Of Module
//
//*********************************************
