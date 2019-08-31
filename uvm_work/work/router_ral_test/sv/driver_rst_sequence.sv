
//----------------------------------------------------------//
//
// driver_rst_sequence
//
//----------------------------------------------------------//
class driver_rst_sequence extends uvm_sequence #(packet);
	virtual router_io router_vif;
	int		port_id = -1;

	`uvm_object_utils_begin(driver_rst_sequence)
		`uvm_field_int(port_id, UVM_DEFAULT | UVM_DEC)
	`uvm_object_utils_end

	function new(string name = "driver_rst_sequence");
		super.new(name);
	endfunction

	//-----------------------------------------//
	// pre_start task
	//-----------------------------------------//
	virtual task pre_start();
		if((get_parent_sequence()==null) && (starting_phase!=null))
		begin
			starting_phase.raise_objection(this);
		end

		uvm_config_db#(int)::get(get_sequencer(), "", "port_id", port_id);
		if(!(port_id inside {-1, [0:15]}))
		begin
			`uvm_fatal("CFG_ERROR", $sformatf("port_id must be {-1, [0:15]}, not %0d!", port_id));
		end
		`uvm_info("DRV_RST_SEQ", $sformatf("Using port_id = %0d", port_id), UVM_MEDIUM);

		uvm_config_db#(virtual router_io)::get(get_sequencer(), "", "drv_rst_vif", router_vif);
		if(router_vif==null)
		begin
			`uvm_fatal("CFG_ERROR", "Interface for Driver Rst Sequence not set");
		end
	endtask

	//-----------------------------------------//
	// post_start task
	//-----------------------------------------//
	virtual task post_start();
		if((get_parent_sequence()==null) && (starting_phase!=null))
		begin
			starting_phase.drop_objection(this);
		end
	endtask

	//-----------------------------------------//
	// body task
	//-----------------------------------------//
	virtual task body();
		if(port_id == -1)
		begin
			router_vif.frame_n = '1;
			router_vif.valid_n = '1;
			router_vif.din 	= '0;
		end
		else
		begin
			router_vif.frame_n[port_id] = '1;
			router_vif.valid_n[port_id] = '1;
			router_vif.din[port_id] 	= '0;
		end
	endtask


endclass

