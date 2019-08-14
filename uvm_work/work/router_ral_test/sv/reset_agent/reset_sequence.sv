
//------------------------------------------------------------------//
//
// transaction - reset
//
//------------------------------------------------------------------//
class reset_tr extends uvm_sequence_item;
    typedef enum {ASSERT, DEASSERT} kind_e;
    rand kind_e kind;
    rand int unsiged cycles = 1;

    `uvm_object_utils_begin(reset_tr)
        `uvm_field_enum(kind_e, kind, UVM_ALL_ON)
        `uvm_field_int(cycles, UVM_ALL_ON)
    `uvm_object_utils_end

	function new(string name = "reset_tr");
		super.new(name);
	endfunction

endclass


//------------------------------------------------------------------//
//
// reset sequence
//
//------------------------------------------------------------------//
class reset_sequence extends uvm_sequence #(reset_tr);
    `uvm_object_utils(reset_sequence)

	function new(string name = "reset_sequence");
		super.new(name);
	endfunction

	//-----------------------------------------//
	// pre_start 
	//-----------------------------------------//
	virtual task pre_start();
		if((get_parent_sequence()==null) && (starting_phase!=null))
		begin
			starting_phase.drop_objection(this);
		end
	endtask

	//-----------------------------------------//
	// body task
	//-----------------------------------------//
    virtual task body();
        `uvm_do_with(req, {kind == DEASSERT; cycles == 2;});
        `uvm_do_with(req, {kind == ASSERT; cycles == 1;});
        `uvm_do_with(req, {kind == DEASSERT; cycles == 15;});
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
