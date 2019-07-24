
// interface
`include "router_io.sv"
`include "host_io.sv"

// RTL module
`include "../rtl/router.sv"

// UVM lib
import uvm_pkg::*;
`include "uvm_macros.svh"

`include "packet.sv"
`include "packet_sequence.sv"
`include "reset_sequence.sv"
`include "iMonitor.sv"
`include "ms_scoreboard.sv"
`include "oMonitor.sv"
`include "driver.sv"
`include "input_agent.sv"
`include "reset_agent.sv"
`include "output_agent.sv"
`include "router_env.sv"
`include "test_collection.sv"

//---------------------------------------------------
//
// Testbench top
//
//---------------------------------------------------
module top;

bit sys_clk;

//----------------------------
// interface
//----------------------------
router_io inf(sys_clk);
host_io   host(sys_clk);

//----------------------------
// DUT
//----------------------------
//router dut(.reset_n (inf.reset_n),
//           .clock   (inf.clk),
//           .frame_n (inf.frame_n),
//           .valid_n (inf.valid_n),
//           .din     (inf.din),
//           .dout    (inf.dout),
//           .busy_n  (inf.busy_n),
//           .valido_n(inf.valido_n),
//           .frameo_n(inf.frameo_n),
//           .wr_n    (),
//           .address (),
//           .data    ()
//           );

router dut(inf, host);

//----------------------------
// system clock
//----------------------------
initial begin
    sys_clk = 1'b0;
    forever #10 sys_clk = ~sys_clk;
end

//----------------------------
// run_test : uvm
//----------------------------
initial begin
    uvm_config_db#(virtual router_io)::set(null,"uvm_test_top", "vif", inf);
    run_test();
end

//----------------------------
// Dump fsdb
//----------------------------
initial begin
    $fsdbDumpfile("router.fsdb");
    $fsdbDumpvars();
end

endmodule
//---------------------------------------------------
//
// End of Module
//
//---------------------------------------------------
