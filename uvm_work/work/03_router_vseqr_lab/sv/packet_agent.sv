
class packet_agent extends uvm_agent;
  
  `uvm_component_utils(packet_agent)

  packet_sequencer pkt_seqr;
  packet_driver    pkt_driv;

  agent_config m_agent_cfg;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(agent_config)::get(this, "", "m_agent_cfg", m_agent_cfg)) begin
      `uvm_fatal("CONFIG_FATAL", "packet_agent can not get the configuration !!!")
    end

    is_active = m_agent_cfg.is_active;
    
    uvm_config_db#(int unsigned)::set(this, "pkt_driv", "pad_cycles", m_agent_cfg.pad_cycles);
    uvm_config_db#(virtual router_io)::set(this, "pkt_driv", "vif", m_agent_cfg.m_vif);

    if(is_active == UVM_ACTIVE) begin
      pkt_seqr = packet_sequencer::type_id::create("pkt_seqr", this);
      pkt_driv = packet_driver::type_id::create("pkt_driv", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    if(is_active == UVM_ACTIVE)
      pkt_driv.seq_item_port.connect(pkt_seqr.seq_item_export);
  endfunction
    
endclass

