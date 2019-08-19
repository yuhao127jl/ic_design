
//----------------------------------------------------------//
//
// router_test_base
//
//----------------------------------------------------------//
class router_test_base extends uvm_test;
    `uvm_component_utils(router_test_base)

    router_env env;
    virtual router_io router_vif;
    virtual host_io host_vif;
    virtual reset_io reset_vif;

    // access to the command line processor 
    uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
    
	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
    virtual	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

        env = router_env::type_id::create("env", this);

        // get virtual interface
        uvm_config_db#(virtual router_io)::get(this, "", "m_vif", router_vif);
        uvm_config_db#(virtual host_io)::get(this, "", "m_vif", host_vif);
        uvm_config_db#(virtual reset_io)::get(this, "", "m_vif", reset_vif);

        // set virtual interface --- router_io
        uvm_config_db#(virtual router_io)::set(this, "env.i_agent[*]", "rt_iagt_vif", router_vif);
        uvm_config_db#(virtual router_io)::set(this, "env.o_agent[*]", "rt_oagt_vif", router_vif);
        uvm_config_db#(virtual router_io)::set(this, "env.v_rst_seqr.*", "v_rst_vif", router_vif);

        // set virtual interface --- host_io
        uvm_config_db#(virtual host_io)::set(this, "env.h_agent", "h_vif", host_vif);

        // set virtual interface --- reset_io
        uvm_config_db#(virtual reset_io)::set(this, "env.r_agent", "rst_vif", reset_vif);

        // setup the DPI HDL path
        uvm_config_db#(string)::set(this, "env", "hdl_path", "top.router_dut");
    endfunction

	//-----------------------------------------//
	// end_of_elaboration_phase
	//-----------------------------------------//
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);

        // Turn on functional coverage for regmodel
        env.regmodel.set_coverage(UVM_CVR_ALL);
    endfunction

	//-----------------------------------------//
	// main phase
	//-----------------------------------------//
    virtual	task main_phase(uvm_phase phase);
        uvm_objection objection;
		super.main_phase(phase);

        objection = phase.get_objection();
        objection.set_drain_time(this, 1us);
    endtask

	//-----------------------------------------//
	// final phase
	//-----------------------------------------//
    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        
        uvm_top.print_topology();

        factory.print();
    endfunction 


endclass


//----------------------------------------------------------//
//
// test_host_bfm
//
//----------------------------------------------------------//
class test_host_bfm extends router_test_base;
    `uvm_component_utils(test_host_bfm)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
    
	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
    virtual	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

        // turn off all sequencer execution at the configure&mainphase
        uvm_config_db#(uvm_object_wrapper)::set(this, "env.*.configure_phase", "default_sequence", null);
        uvm_config_db#(uvm_object_wrapper)::set(this, "env.*.main_phase", "default_sequence", null);

        // only execute the host_bfm_sequence at main_phase
        uvm_config_db#(uvm_object_wrapper)::set(this, "env.h_agent.seqr.main_phase", "default_sequence", host_bfm_sequence::get_type());
        
    endfunction


endclass


//----------------------------------------------------------//
//
// test_host_ral
//
//----------------------------------------------------------//
class test_host_ral extends router_test_base;
    `uvm_component_utils(test_host_ral)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
    
	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
    virtual	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

        // turn off all sequencer execution at the configure & main phase
        uvm_config_db#(uvm_object_wrapper)::set(this, "env.*.configure_phase", "default_sequence", null);
        uvm_config_db#(uvm_object_wrapper)::set(this, "env.*.main_phase", "default_sequence", null);

        // only execute the host_ral_test_sequence at main_phase
        uvm_config_db#(uvm_object_wrapper)::set(this, "env.h_agent.seqr.main_phase", "default_sequence", host_ral_test_sequence::get_type());
        
    endfunction


endclass


//----------------------------------------------------------//
//
// test_ral_selftest
//
//----------------------------------------------------------//
class test_ral_selftest extends router_test_base;
    `uvm_component_utils(test_ral_selftest)
    string                  seq_name = "uvm_reg_bit_bah_seq";
    uvm_reg_sequence        selftest_seq; 
    virtual_reset_sequence  v_reset_seq;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
    
	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
    virtual	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

        uvm_config_db#(uvm_object_wrapper)::set(this, "*", "default_sequence", null);
    endfunction

	//-----------------------------------------//
	// run phase
	//-----------------------------------------//
    virtual	task run_phase(uvm_phase phase);
        phase.raise_objection(this, "Starting reset tests");

        v_reset_seq = virtual_reset_sequence::type_id::create("v_reset_seq", this);
        v_reset_seq.start(env.v_rst_seqr);
        clp.get_arg_value("+seq=", seq_name);
        $cast(selftest_seq, factory.create_object_by_name(seq_name));
        selftest_seq.model = env.regmodel;
        selftest_seq.start(env.h_agent.seqr);
        
        phase.drop_objection(this, "Done whit register tests");
    endtask

endclass


