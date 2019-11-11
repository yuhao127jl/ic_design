#! /bin/bash

# general script for simulation

fsdbfile=router.fsdb
rtl_file_list=../bin/rtl.flist
file_list=$rtl_file_list

UVM_HOME=../../../../uvm_11d/

# format parameter define
para="";
opentimingcheck=notimingcheck;
gui_mode=0;
for i in $@; do
	if [ $i == "gui" ]; then
		gui_mode=1;
    fi
	para=${i}"+"${para};
done

echo ""
echo ""
echo "DEFINE PARAMETER: $para";
echo "opentimingcheck: $opentimingcheck"
echo ""
echo ""
sleep 0.3

# oper verdi gui
if [ $gui_mode == 1 ]; then
	verdi -2005 -sv +define+$para -f $file_list -ssf $fsdbfile -nologo &
	exit
fi


#    +define+UVM_NO_DPI $UVM_HOME/src/uvm_pkg.sv \
#    +UVM_TESTNAME=my_test \
#    +UVM_TESTNAME=my_test_add_ral \

# vcs compile
vcs \
	-R \
	-Mupdate \
	+plusarg_save \
	+ntb_random_seed_automatic \
	-P /eda/verdi/verdi3_2012/share/PLI/VCS/LINUX/novas.tab \
	/eda/verdi/verdi3_2012/share/PLI/VCS/LINUX/pli.a \
	+v2k \
	-assert svaext \
	-cm assert \
    +acc \
	+vpi \
    +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
    $UVM_HOME/src/uvm_pkg.sv \
    +incdir+$UVM_HOME/src $UVM_HOME/src/uvm.sv $UVM_HOME/src/dpi/uvm_dpi.cc -CFLAGS -DVCS \
    +UVM_TESTNAME=my_test_add_ral \
    +UVM_VERBOSITY=$UVM_VERBOSITY \
	+neg_tchk \
	-negdelay \
	-lca \
	+sdfverbose \
	-sverilog \
    -fsdb_old \
	+define+$para \
	-timescale=1ns/1ps \
	-debug_all \
	-f $file_list \
	-l vcs.log


