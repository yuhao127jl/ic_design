
//------------------------------------------------------------------//
//
// transaction - host
//
//------------------------------------------------------------------//
class host_tr extends uvm_sequence_item;
    typedef enum {READ, WRITE} kind_e;
    typedef enum {IS_OK, NOT_OK, HAS_X} status_e;
    rand kind_e kind;
    rand status_e status;
	rand bit[15:0] addr;
	rand bit[15:0] data;

    `uvm_object_utils_begin(host_tr)
        `uvm_field_enum(kind_e, kind, UVM_ALL_ON)
        `uvm_field_enum(status_e, status, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

	constraint valid{
		addr inside {'h0, 'h100, ['h1000:'h10ff], ['h4000:'h4ffff]};
	}

	function new(string name = "host_tr");
		super.new(name);
		status.rand_mode(0);
	endfunction

endclass


//------------------------------------------------------------------//
//
// host sequence base
//
//------------------------------------------------------------------//
class host_sequence_base extends uvm_sequence #(host_tr);
    `uvm_object_utils(host_sequence_base)

	virtual host_io host_vif;
	uvm_sequencer_base p_seqr;

	function new(string name = "host_sequence_base");
		super.new(name);
	endfunction

	//-----------------------------------------//
	// pre_start 
	//-----------------------------------------//
	virtual task pre_start();
		p_seqr = get_sequencer();
		if((get_parent_sequence()==null) && (starting_phase!=null))
		begin
			starting_phase.raise_objection(this);
		end

		if(uvm_config_db#(virtual host_io)::get(p_seqr.get_parent(), "", "h_vif", host_vif))
		begin
			`uvm_info("HOST_SEQ_CFG", "Has access to host interface", UVM_HIGH);
		end
	endtask

	//-----------------------------------------//
	// post_start 
	//-----------------------------------------//
	virtual task post_start();
		if((get_parent_sequence()==null) && (starting_phase!=null))
		begin
			starting_phase.drop_objection(this);
		end
	endtask

endclass

//------------------------------------------------------------------//
//
// host reset sequence 
//
//------------------------------------------------------------------//
class host_reset_sequence extends host_sequence_base;
    `uvm_object_utils(host_reset_sequence)

	function new(string name = "host_reset_sequence");
		super.new(name);
	endfunction

	//-----------------------------------------//
	// body
	//-----------------------------------------//
	virtual task body();
		host_vif.wr_n = 1'b1;
		host_vif.rd_n = 1'b1;
		host_vif.address = 'z;
		host_vif.data = 'z;
	endtask

endclass

//------------------------------------------------------------------//
//
// host bfm sequence 
// The host_bfm_sequence class is designed to test the DUT registers
// adn memory using the host_driver without using RAL.
//
//------------------------------------------------------------------//
class host_bfm_sequence extends host_sequence_base;
    `uvm_object_utils(host_bfm_sequence)

	function new(string name = "host_bfm_sequence");
		super.new(name);
	endfunction

	//-----------------------------------------//
	// body
	// read and write the DUT configuartion fields
	//-----------------------------------------//
	virtual task body();
		`uvm_do_with(req, {addr == 'h0; kind == host_tr::READ;});
		
		//--------------------------------------------//
		//
		//--------------------------------------------//
		if(req.data != 'h5A03)
        begin
			`uvm_fatal("BFM_ERR", $sformatf("HOST_ID is %4h instead of 'h5A03", req.data));
        end
		else
        begin
			`uvm_info("BFM_TEST", $sformatf("HOST_ID is %4h the expected value is 'h5A03", req.data), UVM_MEDIUM);
        end

		//--------------------------------------------//
		//
		//--------------------------------------------//
		`uvm_do_with(req, {addr == 'h100; kind == host_tr::READ;});
		if(req.data != '1)
			`uvm_fatal("BFM_ERR", $sformatf("LOCK is %4h instead of 'hffff", req.data));

		//--------------------------------------------//
		//
		//--------------------------------------------//
		`uvm_do_with(req, {addr == 'h100; data == '1; kind == host_tr::WRITE;});
		`uvm_do_with(req, {addr == 'h100; kind == host_tr::READ;});
		if(req.data != '0)
        begin
			`uvm_fatal("BFM_ERR", $sformatf("LOCK is %4h instead of 'h0000", req.data));
        end
		else
        begin
			`uvm_info("BFM_TEST", $sformatf("LOCK is %4h the expected value is 'h0000", req.data), UVM_MEDIUM);
        end
		
		//--------------------------------------------//
		//
		//--------------------------------------------//
		for(int i=0; i<256; i++) begin
			`uvm_do_with(req, {addr == 'h1000+i; kind == host_tr::WRITE;});
        end

		for(int i=0; i<256; i++) begin
			`uvm_do_with(req, {addr == 'h1000+i; kind == host_tr::READ;});
			if(req.data != (i^(i>>1)))
				`uvm_fatal("BFM_ERR", $sformatf("R_ARRAY is %4h instead of %4h", req.data, i^(i>>1)));
		end
		`uvm_info("BFM_ERR", "R_ARRAY contains the expected values", UVM_MEDIUM);

		//--------------------------------------------//
		//
		//--------------------------------------------//
		for(int i=0; i<4096; i++) begin
			`uvm_do_with(req, {addr == 'h4000+i; data ==16'b1 << 1%16; kind == host_tr::WRITE;});
		end
	
		//--------------------------------------------//
		//
		//--------------------------------------------//
		for(int i=0; i<4096; i++) begin
			`uvm_do_with(req, {addr == 'h4000+i; kind == host_tr::READ;});
			if(req.data != (16'b1 << 1%16))
				`uvm_fatal("BFM_ERR", $sformatf("R_ARRAY is %4h instead of %4h", req.data, 16'b1 << 1%16));
		end
		`uvm_info("BFM_ERR", "RAM contains the expected values", UVM_MEDIUM);

	endtask

endclass


//------------------------------------------------------------------//
//
// host ral sequence base
// The following is the RAL configuartion sequence base. It contains 
// the reg model that the RAL sequences will need.
//
//------------------------------------------------------------------//
class host_ral_sequence_base extends uvm_reg_sequence #(host_sequence_base);
    `uvm_object_utils(host_ral_sequence_base)

	// creat instance of regmodel
	ral_block_host_regmodel regmodel;

	function new(string name = "host_ral_sequence_base");
		super.new(name);
	endfunction

	//-----------------------------------------//
	// pre_start 
	//-----------------------------------------//
	virtual task pre_start();
		super.pre_start();
	
		if(!uvm_config_db#(ral_block_host_regmodel)::get(p_seqr.get_parent(), "", "regmodel", regmodel))
		begin
			`uvm_info("RAL_CFG", "regmodel not set . Make sure it is set by other mechanisms", UVM_MEDIUM);
		end

		if(regmodel == null)
		begin
			`uvm_fatal("RAL_CFG", "regmodel not set");
		end
	endtask


endclass


//------------------------------------------------------------------//
//
// host ral test sequence 
//
//------------------------------------------------------------------//
class host_ral_test_sequence extends host_ral_sequence_base;
    `uvm_object_utils(host_ral_test_sequence)

	function new(string name = "host_ral_test_sequence");
		super.new(name);
	endfunction

	//-----------------------------------------//
	// task body()
	//-----------------------------------------//
	virtual task body();
		uvm_status_e status;
		uvm_reg_data_t data;
		// 	
		regmodel.HOST_ID.read(.status(status), .value(data), .path(UVM_BACKDOOR), .parent(this));
		if(data != 'h5A03)
        begin
			`uvm_fatal("RAL_ERR", $sformatf("HOST_ID is %4h instead of 'h5A03", data));
        end
		else
        begin
			`uvm_info("RAL_TEST", $sformatf("HOST_ID is %4h the expected value is 'h5A03", data), UVM_MEDIUM);
        end

		// 	
		regmodel.LOCK.read(.status(status), .value(data), .path(UVM_BACKDOOR), .parent(this));
		if(data != 'hffff)
			`uvm_fatal("RAL_ERR", $sformatf("LOCK is %4h instead of 'hffff", data));

		// 	
		regmodel.LOCK.write(.status(status), .value('1), .path(UVM_FRONTDOOR), .parent(this));
		regmodel.LOCK.read(.status(status), .value(data), .path(UVM_BACKDOOR), .parent(this));
		if(data != 'h0)
        begin
			`uvm_fatal("RAL_ERR", $sformatf("LOCK is %4h instead of 'h0000", data));
        end
		else
        begin
			`uvm_info("RAL_TEST", $sformatf("LOCK is %4h the expected value is 'h0000", data), UVM_MEDIUM);
        end


		//--------------------------------------------//
		//
		//--------------------------------------------//
		for(int i=0; i<256; i++) begin
			regmodel.R_ARRAY[i].write(.status(status), .value(i^(i>>1)), .path(UVM_FRONTDOOR), .parent(this));
		end

		//
		for(int i=0; i<256; i++) begin
			regmodel.R_ARRAY[i].read(.status(status), .value(data), .path(UVM_BACKDOOR), .parent(this));
			if(data != (i^(i>>1)))
				`uvm_fatal("RAL_ERR", $sformatf("R_ARRAY is %4h instead of %4h", data, i^(i>>1)));
		end
		`uvm_info("RAL_TEST", "R_ARRAY contains the expected values", UVM_MEDIUM);
	
		//--------------------------------------------//
		//
		//--------------------------------------------//
		for(int i=0; i<4096; i++) begin
			regmodel.RAM.write(.status(status), .offset(i), .value(16'b1<<1%16), .path(UVM_FRONTDOOR), .parent(this));
		end

		//
		for(int i=0; i<4096; i++) begin
			regmodel.RAM.read(.status(status), .offset(i), .value(data), .path(UVM_BACKDOOR), .parent(this));
			if(data != (16'b1 << 1%16))
				`uvm_fatal("RAL_ERR", $sformatf("RAM is %4h instead of %4h", data, 16'b1 << 1%16));
			`uvm_info("RAL_TEST", "RAM contains the expected values", UVM_MEDIUM);
		end
	endtask


endclass

//------------------------------------------------------------------//
//
// host ral port unlock sequence 
//
//------------------------------------------------------------------//
class ral_port_unlock_sequence extends host_ral_sequence_base;
    `uvm_object_utils(ral_port_unlock_sequence)

	function new(string name = "ral_port_unlock_sequence");
		super.new(name);
	endfunction

	//-----------------------------------------//
	// task body()
	//-----------------------------------------//
	virtual task body();
		uvm_status_e status;
		uvm_reg_data_t data;
		// 	
		regmodel.LOCK.write(.status(status), .value('1), .path(UVM_FRONTDOOR), .parent(this));
	endtask

endclass

