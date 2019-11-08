
class host_driver extends uvm_driver #(host_tr);
    `uvm_component_utils(host_driver)

    virtual host_io host_vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
    virtual	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
        
		uvm_config_db#(virtual host_io)::get(this.get_parent(), "", "h_vif", host_vif);
		if(host_vif==null)
		begin
			`uvm_fatal("CFG_ERROR", "Interface for DUT host not set");
		end
    endfunction

	//-----------------------------------------//
	// run_phase
	//-----------------------------------------//
	virtual task run_phase(uvm_phase phase);
		forever 
		begin
			seq_item_port.get_next_item(req);
            `uvm_info("RUN", {"Before process\n", req.sprint() }, UVM_FULL);

            data_rw(req);
            rsp = host_tr::type_id::create("rsp", this);
            rsp.set_id_info(req);

            `uvm_info("RUN", {"After process\n", req.sprint() }, UVM_FULL);
			seq_item_port.item_done();
        end
    endtask

	//-----------------------------------------//
	// data_rw  task
	//-----------------------------------------//
    virtual task data_rw(host_tr req);
        if(req.addr inside {['h4000:'h4fff]}) // emulating RAM access
        begin
            case(req.kind)
                host_tr::READ: begin
                    host_vif.rd_n       = '0;
                    host_vif.address    = req.addr;
                    @(host_vif.mst);
                    req.data            = host_vif.mst.data;
                    host_vif.rd_n       = '1;
                    host_vif.address    = 'z;
                end
                host_tr::WRITE: begin
                    host_vif.wr_n       = '0;
                    host_vif.data       = req.data;
                    host_vif.address    = req.addr;
                    @(host_vif.mst);
                    host_vif.wr_n       = '1;
                    host_vif.data       = 'z;
                    host_vif.address    = 'z;
                end
                default: begin `uvm_fatal("REG_ERR", "Not a valid Register Command"); end
            endcase
        end
        else // emulating register access
        begin
            case(req.kind)
                host_tr::READ: begin
                    host_vif.mst.rd_n       <= '0;
                    host_vif.mst.address    <= req.addr;
                    @(host_vif.mst);
                    req.data                <= host_vif.mst.data;
                    host_vif.mst.rd_n       <= '1;
                    host_vif.mst.address    <= 'z;
                end
                host_tr::WRITE: begin
                    host_vif.mst.wr_n       <= '0;
                    host_vif.mst.data       <= req.data;
                    host_vif.mst.address    <= req.addr;
                    @(host_vif.mst);
                    host_vif.mst.wr_n       <= '1;
                    host_vif.mst.data       <= 'z;
                    host_vif.mst.address    <= 'z;
                end
                default: begin `uvm_fatal("REG_ERR", "Not a valid Register Command");end
            endcase
        end
    endtask


endclass

