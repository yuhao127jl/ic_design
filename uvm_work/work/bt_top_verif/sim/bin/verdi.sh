#! /bin/bash

fsdbfile=router.fsdb

rtl_file_list=../bin/rtl.flist
file_list=$rtl_file_list
UVM_HOME=/home/jieli/disk4/uvm_work/uvm_1p1d/uvm-1.1d

# format parameter define
para="";


echo ""
echo ""
echo "\tVerid GUI"
echo ""
echo ""


verdi -2005 -sv +define+$para  $UVM_HOME/src/uvm.sv \
$UVM_HOME/src/dpi/uvm_dpi.cc -CFLAGS +systemverilogext+sv \
+verilog2001ext+v -f $file_list -ssf $fsdbfile -nologo &


exit



