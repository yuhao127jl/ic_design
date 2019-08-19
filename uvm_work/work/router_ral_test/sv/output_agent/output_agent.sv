
class output_agent extends uvm_agent;
    virtual router_io               router_vif;
    int                             port_id = -1;
    oMonitor                        omon;
    uvm_analysis_port #(packet)     analysis_port;

    `uvm_component_utils_begin(output_agent)
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

        omon = oMonitor::type_id::create("omon", this);

        uvm_config_db#(int)::get(this, "", "port_id", port_id);
		uvm_config_db#(virtual router_io)::get(this, "", "rt_oagt_vif", router_vif);

        uvm_config_db#(int)::set(this, "*", "port_id", port_id);
		uvm_config_db#(virtual router_io)::set(this, "*", "om_vif", router_vif);
    endfunction

	//-----------------------------------------//
	// connect phase
	//-----------------------------------------//
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        this.analysis_port = omon.analysis_port;
        //omon.analysis_port.connect(this.analysis_port);
    endfunction

	//-----------------------------------------//
	// start_of_simulation_phase
	//-----------------------------------------//
    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);

        `uvm_info("O_AGENT_CFG", $sformatf("Using port_id of %0d", port_id), UVM_MEDIUM);
    endfunction



endclass
