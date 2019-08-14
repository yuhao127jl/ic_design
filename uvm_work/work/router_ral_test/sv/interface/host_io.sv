
//--------------------------------------------------//
// host io interface
//--------------------------------------------------//
interface host_io(input logic clk);
  logic        wr_n;
  logic        rd_n;
  logic [15:0] address;
  wire  [15:0] data;

  clocking cb @(posedge clk);
    inout   data;
    output  address;
    output  wr_n;
    output  rd_n;
  endclocking

  clocking mon @(posedge clk);
    input  data;
    input  address;
    input  wr_n;
    input  rd_n;
  endclocking

  modport dut(input clk, input wr_n, input rd_n, address, inout data);

endinterface: host_io

