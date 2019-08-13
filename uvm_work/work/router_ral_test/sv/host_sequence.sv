
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
		addr inside {'h0, 'h100, {'h1000:'h10ff}, {'h4000:'h4ffff};}
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
			starting_phase.drop_objection(this);
		end

		if(uvm_config_db#(virtual host_io)::get(p_seqr.get_parent(), "", "mvif", host_vif))
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
    `uvm_objects_utils(host_reset_sequence)

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

