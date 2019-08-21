
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

    `uvm_component_utils(host_agent)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // get host_io interface 
		uvm_config_db#(virtual host_io)::get(this, "", "h_vif", host_vif);
		if(host_vif==null)
		begin
			`uvm_fatal("CFG_ERROR", "DUT Interface for host_agent not set");
		end

        // set host_io interface
		uvm_config_db#(virtual host_io)::set(this, "*", "h_vif", host_vif);

        if(is_active == UVM_ACTIVE) 
        begin
            seqr = host_sequencer::type_id::create("seqr", this);
            driv = host_driver::type_id::create("driv", this);
        end

        mon = host_monitor::type_id::create("mon", this);
        analysis_port = new("analysis_port", this);
	endfunction

	//-----------------------------------------//
	// connect phase
	//-----------------------------------------//
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(is_active == UVM_ACTIVE) 
        begin
            driv.seq_item_port.connect(seqr.seq_item_export);
        end

        mon.analysis_port.connect(this.analysis_port);
	endfunction



endclass
