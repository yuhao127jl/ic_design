

//----------------------------------------------------------//
//
// router env
//
//----------------------------------------------------------//
class router_env extends uvm_env;
    reset_agent r_agent;
    input_agent i_agent[16];
    output_agent o_agent[16];
    scoreboard sb;
    virtual_reset_sequencer v_rst_seqr;
    host_agent h_agent;

    ral_block_host_regmodel regmodel;
    reg_adapter adapter;

	//-----------------------------------------//
	// reg predictor
	//-----------------------------------------//
    typedef uvm_reg_predictor #(host_tr) hreg_predictor;
    hreg_predictor hreg_predt;

    `uvm_component_utils(router_env)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
    
	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
    virtual	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
        
        r_agent = reset_agent::type_id::create("r_agent", this);
        uvm_config_db#(uvm_object_wrapper)::set(this, "r_agent.seqr.reset_phase", "default_sequence", null);

        foreach(i_agent[i]) begin
            i_agent[i] = input_agent::type_id::create($sformatf("i_agent[%0d]", i), this);
            uvm_config_db#(int)::set(this, i_agent[i].get_name(), "port_id", i);
            uvm_config_db#(uvm_object_wrapper)::set(this, {i_agent[i].get_name(),".", "seqr.reset_phase"}, "default_sequence", null);
            uvm_config_db#(uvm_object_wrapper)::set(this, {i_agent[i].get_name(),".", "seqr.main_phase"}, "default_sequence", packet_sequence::get_type());
        end

        uvm_config_db#(uvm_object_wrapper)::set(this, "v_rst_seqr.reset_phase", "default_sequence", virtual_reset_sequence::get_type());

        sb = scoreboard::type_id::create("sb", this);

        foreach(o_agent[i]) begin
            o_agent[i] = output_agent::type_id::create($sformatf("o_agent[%0d]", i), this);
            uvm_config_db#(int)::set(this, o_agent[i].get_name(), "port_id", i);
        end

        v_rst_seqr = virtual_reset_sequencer::type_id::create("v_rst_seqr", this);
        h_agent = host_agent::type_id::create("h_agent", this);
        adapter = reg_adapter::type_id::create("adapter", this);

        uvm_config_db#(ral_block_host_regmodel)::get(this, "", "regmodel", regmodel);

        if(regmodel == null) begin
            string hdl_path;
            `uvm_info("HOST_CFG", "Self constructing regmodel", UVM_MEDIUM);
            if(!uvm_config_db#(string)::get(this, "", "hdl_path", hdl_path))
            begin
                `uvm_warning("HOST_CFG", "HDL path for DPI backdoor not set!");
            end
            regmodel = ral_block_host_regmodel::type_id::create("regmodel", this);
            regmodel.build();
            regmodel.lock_model();
            regmodel.set_hdl_path_root(hdl_path);
        end

        uvm_config_db#(ral_block_host_regmodel)::set(this, h_agent.get_name(), "regmodel", regmodel);
        
        uvm_config_db#(uvm_object_wrapper)::set(this, {h_agent.get_name(), ".", "seqr.configure_phase"}, "default_sequence", ral_port_unlock_sequence::get_type());

        hreg_predt = hreg_predictor::type_id::create("hreg_predt", this);

    endfunction

	//-----------------------------------------//
	// connect phase
	//-----------------------------------------//
    virtual	function void connect_phase(uvm_phase phase);
        foreach(i_agent[i]) begin
            i_agent[i].analysis_port.connect(sb.before_export);
            v_rst_seqr.pkt_seqr.push_back(i_agent[i].seqr);
        end

        foreach(o_agent[i]) begin
            o_agent[i].analysis_port.connect(sb.after_export);
        end

        v_rst_seqr.r_seqr = this.r_agent.seqr;
        v_rst_seqr.h_seqr = this.h_agent.seqr;

        // setup the regmodel's address map to apply the proper adapter to
        // the corresponding sequencer.
        regmodel.default_map.set_sequencer(h_agent.seqr, adapter);

        // set the predictor's map to the regmodel's map
        hreg_predt.map = regmodel.get_default_map();

        // set the predictor's adapter to the adapter being used by the sequencer
        hreg_predt.adapter = adapter;

        // connect the host_agent's analysis_port to the predictor's bus_in analysis_port
        h_agent.analysis_port.connect(hreg_predt.bus_in);

    endfunction


endclass






