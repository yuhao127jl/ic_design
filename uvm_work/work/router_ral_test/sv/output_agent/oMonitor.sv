
class oMonitor extends uvm_monitor;
	int					port_id = -1;
	virtual router_io 	router_vif;

	uvm_analysis_port #(packet) analysis_port;

	`uvm_component_utils_begin(oMonitor)
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
	
		uvm_config_db#(virtual router_io)::get(this, "", "m_vif", router_vif);
		if(router_vif==null)
		begin
			`uvm_fatal("CFG_ERROR", "oMonitor DUT Interface not set");
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
			tr.da = this.port_id;
			this.get_packet(tr);
			`uvm_info("Got_Output_Packet", {"\n", tr.sprint()}, UVM_MEDIUM);
			analysis_port.write(tr);
		end
	endtask

	//-----------------------------------------//
	// get_packet
	//-----------------------------------------//
	virtual task get_packet(packet tr);
		logic [7:0] datnum;
		@(negedge router_vif.oMonClk.frameo_n[port_id]);

		//------ Payload ------//
		forever begin
			for(int i=0; i<8; i=i) begin
				if(!router_vif.oMonClk.valido_n[port_id]) 
				begin
                    datnum[i++] = router_vif.oMonClk.dout[port_id];
                    if(i==8) tr.payload.push_back(datnum);
				end

				if(router_vif.oMonClk.frameo_n[port_id]) 
				begin
					if(i==8) return;
					else `uvm_fatal("Payload_Error", "Not byte aligned");
				end
				@(router_vif.oMonClk);
			end // end for
		end // end forever
    endtask


endclass
