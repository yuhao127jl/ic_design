
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

    `uvm_component_utils(host_agent)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

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
