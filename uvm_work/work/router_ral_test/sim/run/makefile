
all: clean comp run

UVM_HOME=../../../../uvm_11d/

comp:
	$(VCS)

run:
	$(SIMV)

VCS =   vcs -sverilog -fsdb_old -timescale=1ns/1ns \
		-P /eda/verdi/verdi3_2012/share/PLI/VCS/LINUX/novas.tab \
		/eda/verdi/verdi3_2012/share/PLI/VCS/LINUX/pli.a \
        +acc +vpi \
        +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
		+define+UVM_NO_DPI $(UVM_HOME)/src/uvm_pkg.sv \
        +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm.sv \
        $(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS \
		+incdir+../../sv/ \
		+incdir+../../sv/interface/ 	\
		+incdir+../../sv/input_agent/ 	\
		+incdir+../../sv/output_agent/ 	\
		+incdir+../../sv/reset_agent/ 	\
		+incdir+../../sv/host_ral_agent/\
		+incdir+../../rtl/ \
		../../sv/top.sv  \

SIMV= ./simv +UVM_TESTNAME=test_host_ral +UVM_VERBOSITY=$(UVM_VERBOSITY) -l vcs.log

clean:
	rm -rf *~ core csrc simv* vc_hdrs.h ucli.key urg* *.log

#VCS =   vcs -sverilog -ntb_opts -timescale=1ns/1ns 
#VCS =	vcs -sverilog -fsdb_old  -timescale=1ns/1ns \
