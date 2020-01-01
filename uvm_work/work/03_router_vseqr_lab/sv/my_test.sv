`ifndef __MY_TEST__SV__
`define __MY_TEST__SV__

//-------------------------------------------------------------------------------//
//
// test not add RAL model
//
//-------------------------------------------------------------------------------//
class my_test extends uvm_test;
  
  `uvm_component_utils(my_test)

  my_env m_env;
  env_config m_env_cfg;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    m_env_cfg = new("m_env_cfg");
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = my_env::type_id::create("m_env", this);

//    my_sequence_lib::add_typewide_sequence(da3_sequence::get_type());
//    my_sequence_lib::add_typewide_sequence(sa6_sequence::get_type());

//    uvm_config_db#(uvm_object_wrapper)::set(this, "*.m_seqr.run_phase", 
//                           "default_sequence", my_sequence_lib::get_type());
    uvm_config_db#(uvm_object_wrapper)::set(this, "*.m_seqr.run_phase", 
                           "default_sequence", my_sequence::get_type());

    uvm_config_db#(int)::set(this, "*.m_seqr", "item_num", 200);

    m_env_cfg.is_coverage = 1;
    m_env_cfg.is_check    = 1;
    m_env_cfg.m_agent_cfg.is_active=UVM_ACTIVE;
    m_env_cfg.m_agent_cfg.pad_cycles = 10;

    if(!uvm_config_db#(virtual router_io)::get(this, "", "top_if", m_env_cfg.m_agent_cfg.m_vif)) begin
      `uvm_fatal("CONFIG_EFFOR", "test can not get the interface !!!")
    end

    uvm_config_db#(env_config)::set(this, "m_env", "env_cfg", m_env_cfg);


  endfunction

  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    uvm_top.print_topology(uvm_default_table_printer);
  endfunction

  /*
  virtual task run_phase(uvm_phase phase);
    my_sequence m_seq;
    phase.raise_objection(this);
    m_seq = my_sequence::type_id::create("m_seq");
    m_seq.start(m_env.m_agent.m_seqr);
    phase.drop_objection(this);
  endtask
  */
endclass


//-------------------------------------------------------------------------------//
//
// test add RAL model
//
//-------------------------------------------------------------------------------//
class my_test_add_ral extends uvm_test;
  
  `uvm_component_utils(my_test_add_ral)

  my_env_add_ral m_env;
  env_config m_env_cfg;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    m_env_cfg = new("m_env_cfg");
  endfunction

  //-----------------------------------------//
  // build phase
  //-----------------------------------------//
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = my_env_add_ral::type_id::create("m_env", this);

//    my_sequence_lib::add_typewide_sequence(da3_sequence::get_type());
//    my_sequence_lib::add_typewide_sequence(sa6_sequence::get_type());

//    uvm_config_db#(uvm_object_wrapper)::set(this, "*.m_seqr.run_phase", 
//                           "default_sequence", my_sequence_lib::get_type());
    uvm_config_db#(uvm_object_wrapper)::set(this, "*.m_seqr.run_phase", 
                           "default_sequence", my_sequence::get_type());

    // execute the host_ral_test_sequence at main_phase
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.h_agent.seqr.main_phase",
                            "default_sequence", host_ral_test_sequence::get_type());

    uvm_config_db#(int)::set(this, "*.m_seqr", "item_num", 200);

    m_env_cfg.is_coverage = 1;
    m_env_cfg.is_check    = 1;
    m_env_cfg.m_agent_cfg.is_active=UVM_ACTIVE;
    m_env_cfg.m_agent_cfg.pad_cycles = 10;

    if(!uvm_config_db#(virtual router_io)::get(this, "", "top_if", m_env_cfg.m_agent_cfg.m_vif)) begin
      `uvm_fatal("CONFIG_EFFOR", "test can not get the router_io interface !!!")
    end
    if(!uvm_config_db#(virtual host_io)::get(this, "", "host_if", m_env_cfg.m_agent_cfg.h_vif)) begin
      `uvm_fatal("CONFIG_EFFOR", "test can not get the host_io interface !!!")
    end

    uvm_config_db#(env_config)::set(this, "m_env", "env_cfg", m_env_cfg);

    // setup the DPI HDL path
    uvm_config_db#(string)::set(this, "m_env", "hdl_path", "top.router_dut");

  endfunction

  //-----------------------------------------//
  // start_of_elaboration_phase
  //-----------------------------------------//
  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    uvm_top.print_topology(uvm_default_table_printer);
  endfunction

endclass

//-------------------------------------------------------------------------------//
//
// test add virtual sequence
//
//-------------------------------------------------------------------------------//
class vseq_test extends uvm_test;
  
  `uvm_component_utils(vseq_test)

  my_env_vseq m_env;
  env_config m_env_cfg;

  // >>>
  virtual_sequencer_test vseqr;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    m_env_cfg = new("m_env_cfg");
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = my_env_vseq::type_id::create("m_env", this);

    //uvm_config_db#(uvm_object_wrapper)::set(this, "*.m_seqr.run_phase", 
    //                       "default_sequence", my_sequence_lib::get_type());
    //uvm_config_db#(uvm_object_wrapper)::set(this, "*.m_seqr.run_phase", 
    uvm_config_db#(uvm_object_wrapper)::set(this, "*.vseqr.main_phase", 
                           "default_sequence", virtual_sequence_test::get_type());

    uvm_config_db#(int)::set(this, "*.m_seqr", "item_num", 200);

    m_env_cfg.is_coverage = 1;
    m_env_cfg.is_check    = 1;
    m_env_cfg.m_agent_cfg.is_active=UVM_ACTIVE;
    m_env_cfg.m_agent_cfg.pad_cycles = 10;

    if(!uvm_config_db#(virtual router_io)::get(this, "", "top_if", m_env_cfg.m_agent_cfg.m_vif)) begin
      `uvm_fatal("CONFIG_EFFOR", "test can not get the interface !!!")
    end

    uvm_config_db#(env_config)::set(this, "m_env", "env_cfg", m_env_cfg);

  endfunction


  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    uvm_top.print_topology(uvm_default_table_printer);
  endfunction


endclass








`endif
