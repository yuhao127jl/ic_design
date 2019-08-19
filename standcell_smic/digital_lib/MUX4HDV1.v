
module MUX4HDV1(
input           A,
input           B,
input           C,
input           D,

input           S0,
input           S1,

output          Y
);

wire [1:0] sel;
assign  sel = { S1, S0 };

always @(*)
begin
    case(sel)
        2'b00:  Y = A;
        2'b01:  Y = B;
        2'b10:  Y = C;
        2'b11:  Y = D;
    endcase
end

endmodule 
