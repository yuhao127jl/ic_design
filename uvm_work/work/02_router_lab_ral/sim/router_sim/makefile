
all: clean comp run

UVM_HOME=../../../../uvm_11d

comp:
	$(VCS)

run:
	$(SIMV)

VCS =   vcs -sverilog -fsdb_old -timescale=1ns/1ns \
		-P /eda/verdi/verdi3_2012/share/PLI/VCS/LINUX/novas.tab \
		/eda/verdi/verdi3_2012/share/PLI/VCS/LINUX/pli.a \
        +acc +vpi \
        +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
		$(UVM_HOME)/src/uvm_pkg.sv \
        +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm.sv \
        $(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS \
		+incdir+../../sv/ \
		+incdir+../../rtl/ \
		../../sv/top.sv  \

SIMV= ./simv +UVM_TESTNAME=my_test_add_ral +UVM_VERBOSITY=$(UVM_VERBOSITY) -l vcs.log

clean:
	rm -rf *~ core csrc simv* vc_hdrs.h ucli.key urg* *.log

#		+define+UVM_NO_DPI $(UVM_HOME)/src/uvm_pkg.sv \
#VCS =   vcs -sverilog -ntb_opts -timescale=1ns/1ns 
#VCS =	vcs -sverilog -fsdb_old  -timescale=1ns/1ns \
