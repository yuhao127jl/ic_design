
//----------------------------------------------------------//
//
// virtual_reset_sequencer
//
//----------------------------------------------------------//
class virtual_reset_sequencer extends uvm_sequencer;
    `uvm_component_utils(virtual_reset_sequencer)
    packet_sequencer pkt_seqr[$];
    reset_sequencer r_seqr;
    host_sequencer h_seqr;
    //virtual router_io router_vif;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

//    virtual function void build_phase(uvm_phase phase);
//        super.build_phase(phase);
//
//        uvm_config_db#(virtual router_io)::get(this, "", "v_rst_vif", router_vif);
//		if(router_vif==null)
//		begin
//			`uvm_fatal("V_RST_SEQ_ERROR", "Interface for Virtual Rst Sequence not set");
//		end
//
//        uvm_config_db#(virtual router_io)::set(this, "", "drv_rst_vif", router_vif);
//
//    endfunction
    
endclass


//----------------------------------------------------------//
//
// virtual_reset_sequence
//
//----------------------------------------------------------//
class virtual_reset_sequence extends uvm_sequence;
    `uvm_object_utils(virtual_reset_sequence)
    `uvm_declare_p_sequencer(virtual_reset_sequencer)

    reset_sequence r_seq;
    //driver_rst_sequence d_seq;
    host_reset_sequence h_seq;
    uvm_event reset_event = uvm_event_pool::get_global("reset");

	function new(string name = "virtual_reset_sequence");
		super.new(name);
	endfunction

	//-----------------------------------------//
	// post_start
	//-----------------------------------------//
    virtual task pre_start();
        if((get_parent_sequence() == null) && (starting_phase != null))
        begin
            starting_phase.raise_objection(this);
        end
    endtask

	//-----------------------------------------//
	// body task
	//-----------------------------------------//
	virtual task body();
        fork
            `uvm_do_on(r_seq, p_sequencer.r_seqr);
            //foreach(p_sequencer.pkt_seqr[i]) begin
            //    int j = i;
            //    fork 
            //        begin
            //            reset_event.wait_on();
            //            `uvm_do_on(d_seq, p_sequencer.pkt_seqr[j]);
            //        end
            //    join_none
            //end

            begin
                reset_event.wait_on();
                `uvm_do_on(h_seq, p_sequencer.h_seqr);
            end
        join
    endtask

	//-----------------------------------------//
	// post_start
	//-----------------------------------------//
    virtual task post_start();
        if((get_parent_sequence() == null) && (starting_phase != null))
        begin
            starting_phase.drop_objection(this);
        end
    endtask



endclass


