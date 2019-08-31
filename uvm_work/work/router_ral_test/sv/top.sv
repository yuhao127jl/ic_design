
`timescale 1ns / 1ps

//--------------------------
// uvm lib
//--------------------------
import uvm_pkg::*;
`include "uvm_macros.svh"

//--------------------------
// interface
//--------------------------
`include "./interface/router_io.sv"
`include "./interface/reset_io.sv"
`include "./interface/host_io.sv"

//--------------------------
// rtl
//--------------------------
`include "../rtl/router.sv"


//--------------------------
// uvm platform
//--------------------------
`include "input_agent/packet.sv"
`include "input_agent/packet_sequence.sv"
`include "input_agent/iMonitor.sv"
`include "input_agent/driver.sv"
`include "input_agent/input_agent.sv"

`include "output_agent/oMonitor.sv"
`include "output_agent/output_agent.sv"

`include "reset_agent/reset_sequence.sv"
`include "reset_agent/reset_driver.sv"
`include "reset_agent/reset_monitor.sv"
`include "reset_agent/reset_agent.sv"

`include "host_ral_agent/ral_host_regmodel.sv"
`include "host_ral_agent/host_sequence.sv"
`include "host_ral_agent/host_driver.sv"
`include "host_ral_agent/host_monitor.sv"
`include "host_ral_agent/host_agent.sv"
`include "host_ral_agent/reg_adapter.sv"


//`include "driver_rst_sequence.sv"
`include "virtual_reset_sequence.sv"

`include "scoreboard.sv"
`include "router_env.sv"
`include "router_test.sv"



//----------------------------------------------------------//
//
// testbench
//
//----------------------------------------------------------//
module top;

bit sys_clk;


//-----------------------------------------//
// CLOCK period
//-----------------------------------------//
parameter   CLK_PERIOD = 100;


//-----------------------------------------//
// interface
//-----------------------------------------//
router_io router_inf(sys_clk);
host_io   host_inf(sys_clk);
reset_io  reset_inf(sys_clk);


//-----------------------------------------//
// Instance of DUT
//-----------------------------------------//
router  router_dut(.io(router_inf), 
                   .host(host_inf));


//-----------------------------------------//
// system clock
//-----------------------------------------//
initial begin
    sys_clk = 1'b0;
    forever #10 sys_clk = ~sys_clk;
end


//-----------------------------------------//
// run test
//-----------------------------------------//
initial begin
    // enable RAL coverage
    uvm_reg::include_coverage("*", UVM_CVR_ALL);

    // virtual interface
    uvm_config_db#(virtual router_io)::set(null,"uvm_test_top", "m_vif", router_inf);
    uvm_config_db#(virtual host_io)::set(null,"uvm_test_top", "m_vif", host_inf);
    uvm_config_db#(virtual reset_io)::set(null,"uvm_test_top", "m_vif", reset_inf);

    //run test
    run_test();
end


//-----------------------------------------//
// Dump fsdb
//-----------------------------------------//
initial begin
    $fsdbDumpfile("router.fsdb");
    $fsdbDumpvars();
end



endmodule
//----------------------------------------------------------//
//
// End of Module
//
//----------------------------------------------------------//

