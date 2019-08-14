
//------------------------------------------------------------------//
//
// Sequencer
//
//------------------------------------------------------------------//
typedef uvm_sequencer #(packet) packet_sequencer;


//------------------------------------------------------------------//
//
// input agent
//
//------------------------------------------------------------------//
class input_agent extends uvm_agent;
    packet_sequencer                seqr;
    driver                          driv;
    virtual router_io               router_vif;
    int                             port_id = -1;
    iMonitor                        imon;
    uvm_analysis_port #(packet)     analysis_port;

    `uvm_component_utils(input_agent)

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
            seqr = packet_sequencer::type_id::create("seqr", this);
            driv = driver::type_id::create("driv", this);
        end

        imon = iMonitor::type_id::create("imon", this);
        analysis_port = new("analysis_port", this);

        uvm_config_db#(int)::get(this, "", "port_id", port_id);
		uvm_config_db#(virtual router_io)::get(this, "", "m_vif", router_vif);

        uvm_config_db#(int)::set(this, "*", "port_id", port_id);
		uvm_config_db#(virtual router_io)::set(this, "*", "m_vif", router_vif);
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

        imon.analysis_port.connect(this.analysis_port);
    endfunction 

endclass

