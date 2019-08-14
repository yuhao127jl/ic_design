


//--------------------------------------------------//
// reset io interface
//--------------------------------------------------//
interface reset_io(input logic clk);
	logic		reset_n;

	modport reset_dut(input clk, input reset_n);

endinterface

