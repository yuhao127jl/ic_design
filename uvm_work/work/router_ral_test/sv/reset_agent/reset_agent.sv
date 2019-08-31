

//------------------------------------------------------------------//
//
// reset Sequencer
//
//------------------------------------------------------------------//
typedef uvm_sequencer #(reset_tr) reset_sequencer;

//------------------------------------------------------------------//
//
// reset agent
//
//------------------------------------------------------------------//
class reset_agent extends uvm_agent;
    reset_sequencer                 seqr;
    reset_driver                    driv;
    reset_monitor                   rst_mon;
    virtual reset_io                reset_vif;

    `uvm_component_utils(reset_agent)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("RST_CFG", $sformatf("Reset agent %s setting for is_active is: %p", this.get_name(), is_active), UVM_MEDIUM);

		uvm_config_db#(virtual reset_io)::get(this, "", "rst_vif", reset_vif);
		if(reset_vif==null)
		begin
			`uvm_fatal("CFG_ERROR", "Interface for RESET not set");
		end

		uvm_config_db#(virtual reset_io)::set(this, "*", "rst_vif", reset_vif);
     
        if(is_active == UVM_ACTIVE) 
        begin
            seqr = reset_sequencer::type_id::create("seqr", this);
            driv = reset_driver::type_id::create("driv", this);
        end
        rst_mon = reset_monitor::type_id::create("rst_mon", this);
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
    endfunction


endclass

