
class host_monitor extends uvm_monitor;
	uvm_analysis_port #(host_tr) analysis_port;
    virtual host_io host_vif;
    host_tr tr;

    `uvm_component_utils(host_monitor)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		uvm_config_db#(virtual host_io)::get(this.get_parent(), "", "md_vif", host_vif);
		if(host_vif==null)
		begin
			`uvm_fatal("CFG_ERROR", "Interface for DUT host  not set");
        end
		analysis_port = new("analysis_port", this);
    endfunction

	//-----------------------------------------//
	// run phase
	//-----------------------------------------//
	virtual task run_phase(uvm_phase phase);
		forever begin
			tr = host_tr::type_id::create("tr", this);
			data_detect(tr);
			`uvm_info("HOST_MON", {"\n", tr.sprint()}, UVM_HIGH);
			analysis_port.write(tr);
		end
	endtask

	//-----------------------------------------//
	// data_detect
	//-----------------------------------------//
    virtual task data_detect(host_tr tr);
        fork begin
            fork 
                wr_detect();
                rd_detect();
            join_any
            disable fork;
        end
        join
    endtask

	//-----------------------------------------//
	// wr_detect
	//-----------------------------------------//
    virtual task wr_detect();
        @(host_vif.mon);
        wait(host_vif.mon.wr_n ==0);
        tr.addr = host_vif.mon.address;
        tr.data = host_vif.mon.data;
        tr.kind = host_tr::WRITE;
        `uvm_info("GOT_WRITE", {"\n", tr.sprint()}, UVM_FULL);
    endtask

	//-----------------------------------------//
	// rd_detect
	//-----------------------------------------//
    virtual task rd_detect();
        @(host_vif.mon);
        wait(host_vif.mon.rd_n ==0);
        tr.addr = host_vif.mon.address;
        tr.data = host_vif.mon.data;
        tr.kind = host_tr::READ;
        `uvm_info("GOT_READ", {"\n", tr.sprint()}, UVM_FULL);
    endtask


endclass



