
module MUX4 #(parameter width = 16)
(
clk,
mout,
d0, s0,
d1, s1,
d2, s2,
d3
);

input   [width-1:0] d0, d1, d2, d3;
input               s0, s1, s2;
input               clk;
output  [width-1:0] mout;

assign mout = fout(s0, s1, s2, d0, d1, d2, d3);

function [width-1:0] fout;
input   f_s0, f_s1, f_s2;
input   [width-1:0] f_d0, f_d1, f_d2, f_d3;
begin
    case(1'b1) // parallel case
        f_s0:       fout = f_d0;
        f_s1:       fout = f_d1;
        f_s2:       fout = f_d2;
        default:    fout = f_d3;
    endcase
end

endfunction

//----------------------------------------
// not synthesize
wire [7:0] chk_sum = s0 + s1 + s2;
wire       chk_xz  = s0 + s1 + s2;
always @(posedge clk)
begin
    if(chk_sum>1)
    beign
        $display("MUX4 error, select signal above 1, simulation exit!\n");
        @(posedge clk);
        $finish;
    end
end


always @(chk_xz)
begin
    #0.2;
    if(chk_xz === 1'bx)
    begin
        force mout = { width{1'bx} };
    end
    else
    begin
        release mout;
    end
end



// not synthesize
//----------------------------------------


endmodule
