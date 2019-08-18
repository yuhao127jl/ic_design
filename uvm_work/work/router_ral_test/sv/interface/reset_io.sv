

//--------------------------------------------------//
// reset io interface
//--------------------------------------------------//
interface reset_io(input logic clk);
    logic reset_n;

    clocking mst@(posedge clk);
        output reset_n;
    endclocking

    clocking mon@(posedge clk);
        input reset_n;
    endclocking 

	modport dut(input reset_n);

endinterface
