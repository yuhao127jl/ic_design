
class reg_adapter extends uvm_reg_adapter;
	`uvm_object_utils(reg_adapter)

	function new(string name = "reg_adapter");
		super.new(name);
	endfunction

	//-----------------------------------------//
	// reg2bus
	//-----------------------------------------//
	virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
		host_tr tr;

		tr = host_tr::type_id::create("tr");
		tr.kind = (rw.kind inside {UVM_READ, UVM_BURST_READ}) ? host_tr::READ : host_tr::WRITE;
		tr.addr = rw.addr;
		tr.data = rw.data;
		return tr;
	endfunction

	//-----------------------------------------//
	// bus2reg
	//-----------------------------------------//
	virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
		host_tr tr;

		if(!$cast(tr, bus_item)) `uvm_fatal("NOT_HOST_REG_TYPE", "bus_item is not correct type");
		rw.kind = (tr.kind == host_tr::READ) ? UVM_READ : UVM_WRITE;
		rw.addr = tr.addr;
		rw.data = tr.data;
		case(tr.status)
			host_tr::IS_OK	: rw_status = UVM_IS_OK;
			host_tr::NOT_OK	: rw_status = UVM_NOT_OK;
			host_tr::HAS_X	: rw_status = UVM_HAS_X;
			default: `uvm_fatal("RAL_STATUS", $sformatf("Unsupported status : %p", tr.status));
		endcase
	endfunction


endclass

