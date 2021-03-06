`ifndef __MY_ENV__SV__
`define __MY_ENV__SV__

//----------------------------------------------------------//
//
// my_env not add RAL 
//
//----------------------------------------------------------//
class my_env extends uvm_env;
  
  `uvm_component_utils(my_env)

  master_agent m_agent;
  slave_agent s_agent;
  env_config   m_env_cfg;

  my_reference_model ref_model;
  my_scoreboard sb;

  uvm_tlm_analysis_fifo#(my_transaction) r2s_fifo;
  uvm_tlm_analysis_fifo#(my_transaction) s_a2s_fifo;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    this.r2s_fifo = new("r2s_fifo", this);
    this.s_a2s_fifo = new("s_a2s_fifo", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(env_config)::get(this, "", "env_cfg", m_env_cfg)) begin
      `uvm_fatal("CONFIG_FATAL","ENV can not get the configuration !!!")
    end
    //m_agent_cfg = m_env_cfg.m_agent_cfg;
    uvm_config_db#(agent_config)::set(this, "m_agent", "m_agent_cfg", m_env_cfg.m_agent_cfg);

    uvm_config_db#(agent_config)::set(this, "s_agent", "m_agent_cfg", m_env_cfg.m_agent_cfg);

    if(m_env_cfg.is_coverage) begin
      `uvm_info("COVERAGE_ENABLE", "The function coverage is enabled for this testcase", UVM_MEDIUM)
    end
    if(m_env_cfg.is_check) begin
      `uvm_info("CHECK_ENABLE", "The check function is enabled for this testcase", UVM_MEDIUM)
      sb = my_scoreboard::type_id::create("sb", this);
    end

    m_agent = master_agent::type_id::create("m_agent", this);
    s_agent = slave_agent::type_id::create("s_agent", this);
    ref_model = my_reference_model::type_id::create("ref_model", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENV", "Connect the agent and reference model...", UVM_MEDIUM)
    m_agent.m_a2r_export.connect(ref_model.i_m2r_imp);
    s_agent.s_a2s_export.connect(this.s_a2s_fifo.blocking_put_export);
    ref_model.r2s_port.connect(this.r2s_fifo.blocking_put_export);
    if(m_env_cfg.is_check) begin
      sb.r2s_port.connect(this.r2s_fifo.blocking_get_export);
      sb.s_a2s_port.connect(this.s_a2s_fifo.blocking_get_export);
    end
  endfunction

endclass

//-------------------------------------------------------------------------------//
//
// env add RAL model
//
//-------------------------------------------------------------------------------//
class my_env_add_ral extends uvm_env;
  
  `uvm_component_utils(my_env_add_ral)

  master_agent m_agent;
  slave_agent s_agent;
  host_agent h_agent;
  env_config   m_env_cfg;

  my_reference_model ref_model;
  my_scoreboard sb;

  ral_block_host_regmodel     regmodel;
  host_adapter                adapter;
  
  //-----------------------------------------//
  // reg predictor
  //-----------------------------------------//
  typedef uvm_reg_predictor #(host_tr) hreg_predictor;
  hreg_predictor              hreg_predt;

  uvm_tlm_analysis_fifo#(my_transaction) r2s_fifo;
  uvm_tlm_analysis_fifo#(my_transaction) s_a2s_fifo;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    this.r2s_fifo = new("r2s_fifo", this);
    this.s_a2s_fifo = new("s_a2s_fifo", this);
  endfunction

  //-----------------------------------------//
  // build phase
  //-----------------------------------------//
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(env_config)::get(this, "", "env_cfg", m_env_cfg)) begin
      `uvm_fatal("CONFIG_FATAL","ENV can not get the configuration !!!")
    end
    //m_agent_cfg = m_env_cfg.m_agent_cfg;
    // config_db set m_agent
    uvm_config_db#(agent_config)::set(this, "m_agent", "m_agent_cfg", m_env_cfg.m_agent_cfg);

    // config_db set s_agent
    uvm_config_db#(agent_config)::set(this, "s_agent", "m_agent_cfg", m_env_cfg.m_agent_cfg);

    // config_db set h_agent
    uvm_config_db#(agent_config)::set(this, "h_agent", "m_agent_cfg", m_env_cfg.m_agent_cfg);

    if(m_env_cfg.is_coverage) begin
      `uvm_info("COVERAGE_ENABLE", "The function coverage is enabled for this testcase", UVM_MEDIUM)
    end
    if(m_env_cfg.is_check) begin
      `uvm_info("CHECK_ENABLE", "The check function is enabled for this testcase", UVM_MEDIUM)
      sb = my_scoreboard::type_id::create("sb", this);
    end

    m_agent = master_agent::type_id::create("m_agent", this);
    s_agent = slave_agent::type_id::create("s_agent", this);
    h_agent = host_agent::type_id::create("h_agent", this);
    adapter = host_adapter::type_id::create("adapter", this);
    ref_model = my_reference_model::type_id::create("ref_model", this);
    hreg_predt = hreg_predictor::type_id::create("hreg_predt", this);

    uvm_config_db#(ral_block_host_regmodel)::get(this, "", "regmodel", regmodel);
    if(regmodel == null) begin
        string hdl_path;
        `uvm_info("HOST_CFG", "Self constructing regmodel", UVM_MEDIUM);
        if(!uvm_config_db#(string)::get(this, "", "hdl_path", hdl_path))
        begin
            `uvm_warning("HOST_CFG", "HDL path for DPI backdoor not set!");
        end
        `uvm_info("REG_MODEL", "", UVM_MEDIUM);
        regmodel = ral_block_host_regmodel::type_id::create("regmodel", this);
        regmodel.build();
        regmodel.lock_model();
        regmodel.set_hdl_path_root(hdl_path);
    end

    uvm_config_db#(ral_block_host_regmodel)::set(this, h_agent.get_name(), "regmodel", regmodel);
        
  endfunction

  //-----------------------------------------//
  // connect phase
  //-----------------------------------------//
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENV", "Connect the agent and reference model...", UVM_MEDIUM)
    m_agent.m_a2r_export.connect(ref_model.i_m2r_imp);
    s_agent.s_a2s_export.connect(this.s_a2s_fifo.blocking_put_export);
    ref_model.r2s_port.connect(this.r2s_fifo.blocking_put_export);
    if(m_env_cfg.is_check) begin
      sb.r2s_port.connect(this.r2s_fifo.blocking_get_export);
      sb.s_a2s_port.connect(this.s_a2s_fifo.blocking_get_export);
    end

    // setup the regmodel's address map to apply the proper adapter to
    // the corresponding sequencer.
    regmodel.default_map.set_sequencer(h_agent.seqr, adapter);

    // set the predictor's map to the regmodel's map
    hreg_predt.map = regmodel.get_default_map();

    // set the predictor's adapter to the adapter being used by the sequencer
    hreg_predt.adapter = adapter;

    // connect the host_agent's analysis_port to the predictor's bus_in analysis_port
    h_agent.analysis_port.connect(hreg_predt.bus_in);

  endfunction

endclass


//-------------------------------------------------------------------------------//
//
// env add packet_agent (virtual sequence)
//
//-------------------------------------------------------------------------------//
class my_env_vseq extends uvm_env;
  
  `uvm_component_utils(my_env_vseq)

  master_agent m_agent;
  slave_agent s_agent;
  env_config   m_env_cfg;

  // >>>
  packet_agent pkt_agent;

  my_reference_model ref_model;
  my_scoreboard sb;

  // >>>
  virtual_sequencer_test vseqr;

  uvm_tlm_analysis_fifo#(my_transaction) r2s_fifo;
  uvm_tlm_analysis_fifo#(my_transaction) s_a2s_fifo;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    this.r2s_fifo = new("r2s_fifo", this);
    this.s_a2s_fifo = new("s_a2s_fifo", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(env_config)::get(this, "", "env_cfg", m_env_cfg)) begin
      `uvm_fatal("CONFIG_FATAL","ENV can not get the configuration !!!")
    end
    //m_agent_cfg = m_env_cfg.m_agent_cfg;
    uvm_config_db#(agent_config)::set(this, "m_agent", "m_agent_cfg", m_env_cfg.m_agent_cfg);

    uvm_config_db#(agent_config)::set(this, "s_agent", "m_agent_cfg", m_env_cfg.m_agent_cfg);
    uvm_config_db#(agent_config)::set(this, "pkt_agent", "m_agent_cfg", m_env_cfg.m_agent_cfg);

    if(m_env_cfg.is_coverage) begin
      `uvm_info("COVERAGE_ENABLE", "The function coverage is enabled for this testcase", UVM_MEDIUM)
    end
    if(m_env_cfg.is_check) begin
      `uvm_info("CHECK_ENABLE", "The check function is enabled for this testcase", UVM_MEDIUM)
      sb = my_scoreboard::type_id::create("sb", this);
    end

    m_agent = master_agent::type_id::create("m_agent", this);
    s_agent = slave_agent::type_id::create("s_agent", this);
    pkt_agent = packet_agent::type_id::create("pkt_agent", this);
    ref_model = my_reference_model::type_id::create("ref_model", this);
    vseqr = virtual_sequencer_test::type_id::create("vseqr", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENV", "Connect the agent and reference model...", UVM_MEDIUM)
    m_agent.m_a2r_export.connect(ref_model.i_m2r_imp);
    s_agent.s_a2s_export.connect(this.s_a2s_fifo.blocking_put_export);
    ref_model.r2s_port.connect(this.r2s_fifo.blocking_put_export);
    if(m_env_cfg.is_check) begin
      sb.r2s_port.connect(this.r2s_fifo.blocking_get_export);
      sb.s_a2s_port.connect(this.s_a2s_fifo.blocking_get_export);
    end

    // >>>
    vseqr.m_seqr = m_agent.m_seqr;
    vseqr.pkt_seqr = pkt_agent.pkt_seqr;
  endfunction

endclass

`endif
