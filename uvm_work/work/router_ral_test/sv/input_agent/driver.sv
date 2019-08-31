
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

		uvm_config_db#(virtual router_io)::get(this, "", "md_vif", router_vif);
		if(router_vif==null)
		begin
			`uvm_fatal("CFG_ERROR", "Interface for Driver not set");
		end
	endfunction

	//-----------------------------------------//
	// pre reset phase
	//-----------------------------------------//
    virtual task pre_reset_phase(uvm_phase phase);
        super.pre_reset_phase(phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        phase.raise_objection(this);
        if (port_id == -1) begin
            router_vif.drvClk.frame_n <= 'x;
            router_vif.drvClk.valid_n <= 'x;
            router_vif.drvClk.din <= 'x;
        end else begin
            router_vif.drvClk.frame_n[port_id] <= 'x;
            router_vif.drvClk.valid_n[port_id] <= 'x;
            router_vif.drvClk.din[port_id] <= 'x;
        end
        phase.drop_objection(this);
    endtask: pre_reset_phase

	//-----------------------------------------//
	// reset phase
	//-----------------------------------------//
    virtual task reset_phase(uvm_phase phase);
        super.reset_phase(phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
        phase.raise_objection(this);
        if (port_id == -1) begin
            router_vif.drvClk.frame_n <= '1;
            router_vif.drvClk.valid_n <= '1;
            router_vif.drvClk.din <= '0;
        end else begin
            router_vif.drvClk.frame_n[port_id] <= '1;
            router_vif.drvClk.valid_n[port_id] <= '1;
            router_vif.drvClk.din[port_id] <= '0;
        end
        phase.drop_objection(this);
    endtask: reset_phase

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
            `uvm_info("Put_Address",$sformatf("Din is:%0d", tr.da[i]) , UVM_MEDIUM);
			@(router_vif.drvClk);
		end
	endtask

	virtual task send_pad(packet tr);
		router_vif.drvClk.din[tr.sa] <= 1'b1;
		router_vif.drvClk.valid_n[tr.sa] <= 1'b1;
        `uvm_info("Put_pad","Din and valid_n is one", UVM_MEDIUM);
		repeat(5) @(router_vif.drvClk);
	endtask

	virtual task send_payload(packet tr);
        `uvm_info("Put_Payload",$sformatf("busy_n is %0d",router_vif.drvClk.busy_n[tr.sa]), UVM_MEDIUM);
		while(router_vif.drvClk.busy_n[tr.sa]==1'b0) 
        begin
            @(router_vif.drvClk);
        end
		foreach(tr.payload[index])
		begin
			datnum = tr.payload[index];

            `uvm_info("Put_Payload",$sformatf("payload size is %0d",$size(tr.payload,1)), UVM_MEDIUM);
            `uvm_info("Put_Payload",$sformatf("payload is %0d",datnum), UVM_MEDIUM);
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

