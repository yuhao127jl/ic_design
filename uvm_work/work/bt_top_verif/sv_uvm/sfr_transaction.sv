

//-----------------------------------------------------------------------------------//
//
// sfr bus transaction
//
//-----------------------------------------------------------------------------------//
class sfr_transaction extends uvm_sequence_item;
	rand bit			sfr_wr;
	rand bit[15:0]		sfr_wadr;
	rand bit[15:0]		sfr_wdat;
	rand bit			sfr_wack;

	rand bit			sfr_rd;
	rand bit[15:0]		sfr_radr;
	rand bit[15:0]		sfr_rdat;
	rand bit			sfr_rack;

	`uvm_object_utils_begin(sfr_transaction)
		`uvm_field_int(sfr_wr, UVM_ALL_ON)
		`uvm_field_int(sfr_wadr, UVM_ALL_ON)
		`uvm_field_int(sfr_wdat, UVM_ALL_ON)
		`uvm_field_int(sfr_wack, UVM_ALL_ON)

		`uvm_field_int(sfr_rd, UVM_ALL_ON)
		`uvm_field_int(sfr_radr, UVM_ALL_ON)
		`uvm_field_int(sfr_rdat, UVM_ALL_ON)
		`uvm_field_int(sfr_rack, UVM_ALL_ON)
	`uvm_object_utils_end

	constraint sfr_limit {

	}

	function new(string name = "sfr_transaction");
		super.new(name);
	endfunction

endclass


//-----------------------------------------------------------------------------------//
//
// qmem transaction
//
//-----------------------------------------------------------------------------------//
class qmem_transaction extends uvm_sequence_item;
	rand bit			qmem_bt_req;
	rand bit			qmem_bt_we;
	rand bit[15:0]		qmem_bt_adr;
	rand bit[15:0]		qmem_bt_wdat;
	rand bit[15:0]		qmem_bt_rdat;
	rand bit			qmem_bt_ack;

	`uvm_object_utils_begin(qmem_transaction)
		`uvm_field_int(qmem_bt_req, UVM_ALL_ON)
		`uvm_field_int(qmem_bt_we, UVM_ALL_ON)
		`uvm_field_int(qmem_bt_adr, UVM_ALL_ON)
		`uvm_field_int(qmem_bt_wdat, UVM_ALL_ON)
		`uvm_field_int(qmem_bt_rdat, UVM_ALL_ON)
		`uvm_field_int(qmem_bt_ack, UVM_ALL_ON)
	`uvm_object_utils_end

	constraint qmem_limit {

	}

	function new(string name = "qmem_transaction");
		super.new(name);
	endfunction



endclass


//-----------------------------------------------------------------------------------//
//
// exmem transaction
//
//-----------------------------------------------------------------------------------//
class exmem_transaction extends uvm_sequence_item;
	rand bit			exmem_bt_req;
	rand bit[3:0]		exmem_bt_we;
	rand bit[22:0]		exmem_bt_adr;
	rand bit[31:0]		exmem_bt_wdat;
	rand bit[31:0]		exmem_bt_rdat;
	rand bit			exmem_bt_ack;

	`uvm_object_utils_begin(exmem_transaction)
		`uvm_field_int(exmem_bt_req, UVM_ALL_ON)
		`uvm_field_int(exmem_bt_we, UVM_ALL_ON)
		`uvm_field_int(exmem_bt_adr, UVM_ALL_ON)
		`uvm_field_int(exmem_bt_wdat, UVM_ALL_ON)
		`uvm_field_int(exmem_bt_rdat, UVM_ALL_ON)
		`uvm_field_int(exmem_bt_ack, UVM_ALL_ON)
	`uvm_object_utils_end

	constraint exmem_limit {

	}

	function new(string name = "exmem_transaction");
		super.new(name);
	endfunction


endclass


