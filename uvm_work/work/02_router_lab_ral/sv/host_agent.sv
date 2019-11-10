
//------------------------------------------------------------------//
//
// Host Sequencer
//
//------------------------------------------------------------------//
typedef uvm_sequencer #(host_tr) host_sequencer;


//------------------------------------------------------------------//
//
// host agent
//
//------------------------------------------------------------------//
class host_agent extends uvm_agent;
    uvm_analysis_port #(host_tr)     analysis_port;
	host_sequencer					 seqr;
    host_driver                      driv;
    host_monitor                     mon;
    virtual host_io                  host_vif; // virtual interface
    agent_config                     m_agent_cfg;

    `uvm_component_utils(host_agent)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(agent_config)::get(this, "", "m_agent_cfg", m_agent_cfg)) 
        begin
          `uvm_fatal("CONFIG_FATAL", "host_agent can not get the configuration !!!")
        end

        // get host_io interface 
		//uvm_config_db#(virtual host_io)::get(this, "", "h_vif", host_vif);
		//if(host_vif==null)
		//begin
		//	`uvm_fatal("CFG_ERROR", "DUT Interface for host_agent not set");
		//end

        // set host_io interface
		//uvm_config_db#(virtual host_io)::set(this, "*", "h_vif", m_agent_cfg.h_vif);

        //is_active = m_agent_cfg.is_active;
        if(m_agent_cfg.is_active == UVM_ACTIVE) 
        begin
          seqr = host_sequencer::type_id::create("seqr", this);
          driv = host_driver::type_id::create("driv", this);
          uvm_config_db#(virtual host_io)::set(this, "driv", "h_vif", m_agent_cfg.h_vif);
          $display("host io ---> host_driver ");
          uvm_config_db#(virtual host_io)::set(this, "seqr", "h_vif", m_agent_cfg.h_vif);
        end

        mon = host_monitor::type_id::create("mon", this);
        uvm_config_db#(virtual host_io)::set(this, "mon", "h_vif", m_agent_cfg.h_vif);
        analysis_port = new("analysis_port", this);
	endfunction

	//-----------------------------------------//
	// connect phase
	//-----------------------------------------//
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(m_agent_cfg.is_active == UVM_ACTIVE) 
        begin
          driv.seq_item_port.connect(seqr.seq_item_export);
        end

        mon.analysis_port.connect(this.analysis_port);
	endfunction


endclass

