
class packet_da_25 extends packet;
    `uvm_object_utils(packet_da_25)
    
    constraint da_25
    {
        da inside {[2:5}};
    }

	function new(string name = "packet_da_25")
		super.new(name);
	endfunction

endclass

