
class reset_monitor extends uvm_monitor;
	virtual reset_io 	reset_vif;
	uvm_analysis_port #(reset_tr) analysis_port;
    uvm_event reset_event = uvm_event_pool::get_global("reset");
    
	`uvm_component_utils(reset_monitor)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	
		uvm_config_db#(virtual reset_io)::get(this, "", "m_vif", reset_vif);
		if(reset_vif==null)
		begin
			`uvm_fatal("CFG_ERROR", "Interface for reset driver not set");
		end
		analysis_port = new("analysis_port", this);
    endfunction
	
	//-----------------------------------------//
	// run phase
	//-----------------------------------------//
	virtual task run_phase(uvm_phase phase);
		reset_tr tr;
		
		forever begin
			tr = reset_tr::type_id::create("tr", this);
			detect(tr);
			analysis_port.write(tr);
        end
    endtask

	//-----------------------------------------//
	// detect
	//-----------------------------------------//
    virtual task detect(reset_tr tr);
        @(reset_vif.reset_n);
        assert(!$isunknown(reset_vif.reset_n));
        if(reset_vif.reset_n == 1'b0)
        begin
            tr.kind = reset_tr::ASSERT;
            reset_event.trigger();
        end
        else
        begin
            tr.kind = reset_tr::DEASSERT;
            reset_event.reset();
        end
    endtask



endclass

