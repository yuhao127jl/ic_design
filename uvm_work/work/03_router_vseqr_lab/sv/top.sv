
//-------------------------------------------------------------------------------//
//
// RTL & Interface
//
//-------------------------------------------------------------------------------//
`include "router_io.sv"
`include "host_io.sv"
`include "../rtl/router.sv"


//-------------------------------------------------------------------------------//
//
// UVM lib
//
//-------------------------------------------------------------------------------//
import uvm_pkg::*;
`include "uvm_macros.svh"


//-------------------------------------------------------------------------------//
//
// Platform
//
//-------------------------------------------------------------------------------//
`include "my_transaction.sv"
`include "my_sequence.sv"
//  `include "my_sequence_lib.sv"
//  `include "da3_sequence.sv"
//  `include "sa6_sequence.sv"
//  `include "sa6_da3_sequence.sv"
`include "agent_config.sv"
`include "env_config.sv"
//  `include "driver_base_callback.sv"
//  `include "driver_error_callback.sv"
//  `include "driver_info_callback.sv"
`include "my_driver.sv"
`include "my_sequencer.sv"
`include "my_monitor.sv"
`include "out_monitor.sv"
`include "master_agent.sv"
`include "slave_agent.sv"

`include "packet_transaction.sv"
`include "packet_sequence.sv"
`include "packet_sequencer.sv"
`include "packet_driver.sv"
`include "packet_agent.sv"

`include "ral_host_regmodel.sv"
`include "host_sequence.sv"
`include "host_driver.sv"
`include "host_monitor.sv"
`include "host_adapter.sv"
`include "host_agent.sv"

`include "virtual_seq_test.sv"

`include "my_reference_model.sv"
`include "my_scoreboard.sv"
`include "my_env.sv"
`include "my_test.sv"
//  `include "my_transaction_da3.sv"
//  `include "my_driver_count.sv"
//  `include "my_test_driver_error.sv"
//  `include "my_test_driver_info.sv"

//-------------------------------------------------------------------------------------------------//
//
// testbench
//
//-------------------------------------------------------------------------------------------------//
module top;
  
//----------------------------------------------------------------------//
//
// system clock
//
//----------------------------------------------------------------------//
bit sys_clk;
initial 
begin
    sys_clk = 1'b0;
    forever #10 sys_clk = ~sys_clk;
end


//----------------------------------------------------------------------//
//
// interface
//
//----------------------------------------------------------------------//
router_io inf(sys_clk);
host_io   host_inf(sys_clk);


//----------------------------------------------------------------------//
//
// DUT
//
//----------------------------------------------------------------------//
//router dut(.reset_n (inf.reset_n),
//           .clock   (inf.clk),
//           .frame_n (inf.frame_n),
//           .valid_n (inf.valid_n),
//           .din     (inf.din),
//           .dout    (inf.dout),
//           .busy_n  (inf.busy_n),
//           .valido_n(inf.valido_n),
//           .frameo_n(inf.frameo_n)
//);
router router_dut(.io(inf), .host(host_inf));


//----------------------------------------------------------------------//
//
// run_test
//
//----------------------------------------------------------------------//
initial 
begin
    uvm_config_db#(virtual router_io)::set(null,"uvm_test_top", "top_if", inf);
    uvm_config_db#(virtual host_io)::set(null,"uvm_test_top", "host_if", host_inf);
    run_test();
end


//----------------------------------------------------------------------//
//
// dump wave
//
//----------------------------------------------------------------------//
initial 
begin
    $fsdbDumpfile("router.fsdb");
    $fsdbDumpvars();
    $fsdbDumpvars(0, top.router_dut);
end


endmodule
//-------------------------------------------------------------------------------------------------//
//
// End of Module
//
//-------------------------------------------------------------------------------------------------//
