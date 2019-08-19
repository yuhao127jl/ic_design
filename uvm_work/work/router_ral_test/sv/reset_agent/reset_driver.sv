
class reset_driver extends uvm_driver #(reset_tr);
	virtual reset_io	reset_vif;  // virtual interface

	`uvm_component_utils(reset_driver)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		uvm_config_db#(virtual reset_io)::get(this, "", "rmd_vif", reset_vif);
		if(reset_vif==null)
		begin
			`uvm_fatal("CFG_ERROR", "Interface for reset driver not set");
		end
	endfunction

	//-----------------------------------------//
	// run_phase
	//-----------------------------------------//
	virtual task run_phase(uvm_phase phase);
		forever 
		begin
			seq_item_port.get_next_item(req);
			drive(req);
			seq_item_port.item_done();
		end
	endtask

	//-----------------------------------------//
	// task drive()
	//-----------------------------------------//
	virtual task drive(reset_tr tr);
		if(tr.kind == reset_tr::ASSERT) 
		begin
			reset_vif.reset_n = 1'b0;
			repeat(tr.cycles) @(reset_vif.mst);
		end
		else
		begin
			reset_vif.reset_n = '1;
			repeat(tr.cycles) @(reset_vif.mst);
		end
	endtask



endclass


