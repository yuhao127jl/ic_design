// 2 clock domain , 1 pulse input / 1 pulse output
module handshake #(parameter SEL = 1'd1)
(
input           din,
input           clkin,
input           clkout,
input           rstn,

output          dout
);
reg di_0;
reg do_0;
reg do_1;
reg do_2;

wire sn = !(SEL ? di_0 : din);
wire rn = rstn & !do_1;
rs_lat rs(.rn(rn), .sn(sn), .q(lat_q), .qn());
assign dout = do_1 & !do_2;

always @(posedge clkin or negedge rstn)
if(!rstn)
    di_0 <= #1 1'd0;
else
    di_0 <= #1 din;

always @(negedge clkout) do_0 <= #0.3 lat_q;
always @(posedge clkout) do_1 <= #0.3 do_0;
always @(posedge clkout) do_2 <= #0.3 do_1;

endmodule

module rs_lat(
input       rn,
input       sn,
output      q,
output      qn
);

nand nad0(rn, q, qn);
nand nad1(sn, qn, q);

endmodule
