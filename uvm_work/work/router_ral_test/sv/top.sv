
`timescale 1ns / 1ps

//--------------------------
// rtl
//--------------------------
`include "../rtl/router.sv"

//--------------------------
// interface
//--------------------------
`include "./interface/router_io.sv"
`include "./interface/reset_io.sv"
`include "./interface/host_io.sv"

//--------------------------
// uvm lib
//--------------------------
import uvm_pkg::*;
`include "uvm_macros.svh"

//--------------------------
// uvm platform
//--------------------------





//----------------------------------------------------------//
//
// testbench
//
//----------------------------------------------------------//
module top;








endmodule
//----------------------------------------------------------//
//
// End of Module
//
//----------------------------------------------------------//

