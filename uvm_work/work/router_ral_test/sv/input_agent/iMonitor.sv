
class iMonitor extends uvm_monitor;
	virtual router_io 	router_vif;
	int					port_id = -1;
	
	uvm_analysis_port #(packet) analysis_port;

	`uvm_component_utils_begin(iMonitor)
		`uvm_field_int(port_id, UVM_DEFAULT | UVM_DEC)
	`uvm_component_utils_end
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
	virtual function void build_phase(uvm_phase phase);
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

		analysis_port = new("analysis_port", this);
	endfunction

	//-----------------------------------------//
	// run phase
	//-----------------------------------------//
	virtual task run_phase(uvm_phase phase);
		packet tr;
		
		forever begin
			tr = packet::type_id::create("tr", this);
			tr.sa = this.port_id;
			`uvm_info("Start_get_Packet", {"\n", tr.sprint()}, UVM_MEDIUM);
			get_packet(tr);
			`uvm_info("Got_Input_Packet", {"\n", tr.sprint()}, UVM_MEDIUM);
			analysis_port.write(tr);
		end
	endtask

	//-----------------------------------------//
	// get_packet
	//-----------------------------------------//
	virtual task get_packet(packet tr);
		logic [7:0] datnum;
		@(negedge router_vif.iMonClk.frame_n[port_id]);

		//------ Address ------//
		for(int i=0; i<4; i++) begin
			if(!router_vif.iMonClk.frame_n[port_id]) 
			begin
				tr.da[i] = router_vif.iMonClk.din[port_id];
                `uvm_info("Got_Address",$sformatf("Din is : %0d", tr.da[i]) , UVM_MEDIUM);
			end
			else
			begin
				`uvm_fatal("Address_Error", $sformatf("@ Header cycle %0d, Frame not zero", i));
			end
			@(router_vif.iMonClk);
		end

		//------ Header ------//
		for(int i=0; i<5; i++) begin
			if(!router_vif.iMonClk.frame_n[port_id]) 
			begin
				if(router_vif.iMonClk.valid_n[port_id] && router_vif.iMonClk.din[port_id])
				begin
					@(router_vif.iMonClk);
                    `uvm_info("Got_Header","Din has done", UVM_MEDIUM);
					continue;
				end
				else
				begin
					`uvm_fatal("Header_Error", $sformatf("@ %0d valid or Din not zero", i));
				end
			end
			else
			begin
				`uvm_fatal("Header_Error", $sformatf("Frame %0d not zero", i));
			end
		end

		//------ Payload ------//
		forever begin
			for(int i=0; i<8; i=i) begin
				if(!router_vif.iMonClk.valid_n[port_id]) 
				begin
                    `uvm_info("Got_Payload","busy_n check", UVM_MEDIUM);
					if(router_vif.iMonClk.busy_n[port_id]) 
					begin
						datnum[i++] = router_vif.iMonClk.din[port_id];
						if(i==8) tr.payload.push_back(datnum);
                        `uvm_info("Got_Payload","Payload has done", UVM_MEDIUM);
					end
					else 	
						`uvm_fatal("Payload_Error", "Busy & Valid conflict");
				end

				if(router_vif.iMonClk.frame_n[port_id]) 
				begin
					if(i==8) return;
					else `uvm_fatal("Payload_Error", "Not byte aligned");
				end
				@(router_vif.iMonClk);
			end // end for
		end // end forever

	endtask

endclass

