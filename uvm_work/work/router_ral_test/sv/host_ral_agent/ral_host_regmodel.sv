
//------------------------------------------------------------------//
//
// ral_reg_HOST_ID
//
//------------------------------------------------------------------//
class ral_reg_HOST_ID extends uvm_reg;
    uvm_reg_field REV_ID;
    uvm_reg_field CHIP_ID;

	function new(string name = "HOST_ID");
		super.new(name, 16, build_coverage(UVM_NO_COVERAGE));
	endfunction

	//-----------------------------------------//
	// build
	//-----------------------------------------//
	virtual function void build();
        this.REV_ID = uvm_reg_field::type_id::create("REV_ID", ,get_full_name());
        this.REV_ID.configure(this, 8, 0, "RO", 0, 8'h03, 1, 0, 1);
        this.CHIP_ID = uvm_reg_field::type_id::create("CHIP_ID", ,get_full_name());
        this.CHIP_ID.configure(this, 8, 8, "RO", 0, 8'h5A, 1, 0, 1);
    endfunction

    `uvm_object_utils(ral_reg_HOST_ID)

endclass



//------------------------------------------------------------------//
//
// ral_reg_LOCK
//
//------------------------------------------------------------------//
class ral_reg_LOCK extends uvm_reg;
    rand uvm_reg_field LOCK;

	function new(string name = "LOCK");
		super.new(name, 16, build_coverage(UVM_NO_COVERAGE));
	endfunction

	//-----------------------------------------//
	// build
	//-----------------------------------------//
	virtual function void build();
        this.LOCK = uvm_reg_field::type_id::create("LOCK", ,get_full_name());
        this.LOCK.configure(this, 16, 0, "W1C", 0, 16'hffff, 1, 0, 1);

    endfunction

    `uvm_object_utils(ral_reg_LOCK)

endclass


//------------------------------------------------------------------//
//
// ral_reg_R_ARRAY
//
//------------------------------------------------------------------//
class ral_reg_R_ARRAY extends uvm_reg;
    rand uvm_reg_field H_REG;

	function new(string name = "R_ARRAY");
		super.new(name, 16, build_coverage(UVM_NO_COVERAGE));
	endfunction

	//-----------------------------------------//
	// build
	//-----------------------------------------//
	virtual function void build();
        this.H_REG = uvm_reg_field::type_id::create("H_REG", ,get_full_name());
        this.H_REG.configure(this, 16, 0, "RW", 0, 16'h0, 1, 0, 1);
    endfunction

endclass


//------------------------------------------------------------------//
//
// ral_mem_RAM
//
//------------------------------------------------------------------//
class ral_mem_RAM extends uvm_mem;



endclass



