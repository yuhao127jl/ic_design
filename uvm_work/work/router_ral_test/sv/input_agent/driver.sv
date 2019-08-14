
class driver extends uvm_driver #(packet);
	virtual router_io router_vif;
	int		port_id = -1;
	logic [7:0] datnum;
	
	`uvm_component_utils_begin(driver)
		`uvm_field_int(port_id, UVM_DEFAULT | UVM_DEC)
	`uvm_component_utils_end

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
    virtual	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		uvm_config_db#(int)::get(this, "", "port_id", port_id);
		if(!(port_id inside {-1, [0:15]}))
		begin
			`uvm_fatal("CFG_ERROR", $sformatf("port_id must be {-1, [0:15]}, not %0d!", port_id));
		end
		uvm_config_db#(virtual router_io)::get(this, "", "m_vif", router_vif);
		if(router_vif==null)
		begin
			`uvm_fatal("CFG_ERROR", "Interface for Driver not set");
		end
	endfunction

	//-----------------------------------------//
	// start_of_simulation_phase
	//-----------------------------------------//
	function void start_of_simulation_phase(uvm_phase phase);
		super.start_of_simulation_phase(phase);
		`uvm_info("DRV_CFG", $sformatf("port_id is : %0d", port_id), UVM_MEDIUM);
	endfunction
	
	//-----------------------------------------//
	// run_phase
	//-----------------------------------------//
	virtual task run_phase(uvm_phase phase);
		forever 
		begin
			seq_item_port.get_next_item(req);
			
			if(port_id inside {-1, req.sa})
			begin
				send(req);
				`uvm_info("DRV_RUN", {"\n", req.sprint()}, UVM_MEDIUM);
			end

			seq_item_port.item_done();
		end
	endtask

	//-----------------------------------------//
	// task send()
	//-----------------------------------------//
	virtual task send(packet tr);
		send_address(tr);
		send_pad(tr);
		send_payload(tr);
	endtask
	
	virtual task send_address(packet tr);
		router_vif.drvClk.frame_n[tr.sa] <= 1'b0;
		for(int i=0; i<4; i++)
		begin
			router_vif.drvClk.din[tr.sa] <= tr.da[i];
			@(router_vif.drvClk);
		end
	endtask

	virtual task send_pad(packet tr);
		router_vif.drvClk.din[tr.sa] <= 1'b1;
		router_vif.drvClk.valid_n[tr.sa] <= 1'b1;
		repeat(5) @(router_vif.drvClk);
	endtask

	virtual task send_payload(packet tr);
		while(!router_vif.drvClk.busy_n[tr.sa]) @(router_vif.drvClk);
		foreach(tr.payload[index])
		begin
			datnum = tr.payload[index];
			for(int i=0; i<$size(tr.payload,2); i++)
			begin
				router_vif.drvClk.din[tr.sa] <= datnum[i];
				router_vif.drvClk.valid_n[tr.sa] <= 1'b0;
				router_vif.drvClk.frame_n[tr.sa] <= ((tr.payload.size()-1) == index) && (i==7);
				@(router_vif.drvClk);
			end
		end
		router_vif.valid_n[tr.sa] <= 1'b1;
	endtask

endclass

