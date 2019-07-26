
class packet_sequence_base extends uvm_sequence #(packet);
    `uvm_objects_utils(packet_sequence_base)

	function new(string name = "packet_sequence_base");
		super.new(name);
	endfunction

	virtual task pre_start();
		if((get_parent_sequence()==null) && (starting_phase!=null))
		begin
			starting_phase.drop_objection(this);
		end
	endtask

endclass


class packet_sequence extends packet_sequence_base;
	int			item_cnt = 10;
	bit[15:0]	da_enable = '1;
	int			valid_da[$];
	int			port_id = -1;
	
	`uvm_object_utils_begin(packet_sequence)
		`uvm_field_int(item_cnt, UVM_ALL_ON)
		`uvm_field_int(da_enable, UVM_ALL_ON)
		`uvm_field_queue_int(valid_da, UVM_ALL_ON)
		`uvm_field_int(port_id, UVM_ALL_ON)
	`uvm_object_utils_end

	task pre_start();
		super.pre_start();
		begin
			uvm_sequencer_base my_seqr = get_sequencer();

			uvm_config_db#(int)::get(null, get_full_name(), "item_cnt", item_cnt);
			uvm_config_db#(bit[15:0])::get(null, get_full_name(), "da_enable", da_enable);
			uvm_config_db#(int)::get(my_seqr.get_parent(), "", "port_id", port_id);
			if(!(port_id inside {-1, [0:15]}))
			begin
				`uvm_fatal("CFG_ERR", $sformatf("Illegal port_id value of %0d", port_id));
			end

			valid_da.delete();
			for(int i=0; i<16; i++)
			begin
				if(da_enable[i]) valid_da.push_back(i);
			end
		end
	endtask

	function new(string name = "packet_sequence");
		super.new(name);
	endfunction

	task body();
		repeat(item_cnt) 
		begin
			`uvm_do_with(req, {if(port_id==-1) sa inside {[0:15]};
						 else sa = port_id;});
		end
	endtask

endclass
