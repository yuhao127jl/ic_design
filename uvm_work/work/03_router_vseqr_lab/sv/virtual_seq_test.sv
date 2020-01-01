

//------------------------------------------------------------------//
//
// virtual sequencer
//
//------------------------------------------------------------------//
class virtual_sequencer_test extends uvm_sequencer;
    `uvm_component_utils(virtual_sequencer_test)

    my_sequencer        m_seqr;
    packet_sequencer    pkt_seqr;

    function new(string name = "", uvm_component parent);
        super.new(name, parent);
    endfunction


endclass


//------------------------------------------------------------------//
//
// virtual sequence
//
//------------------------------------------------------------------//
class virtual_sequence_test extends uvm_sequence;
    `uvm_object_utils(virtual_sequence_test)

    `uvm_declare_p_sequencer(virtual_sequencer_test)

    my_sequence         m_seq;
    packet_sequence     pkt_seq;

    uvm_event reset_event = uvm_event_pool::get_global("para_vseq");

    //-----------------------------------------//
    // 
    //-----------------------------------------//
    function new(string name = "virtual_sequence_test");
        super.new(name); 
    endfunction

  
    //-----------------------------------------//
    // body
    //-----------------------------------------//
    virtual task body();
        if(starting_phase != null) 
          starting_phase.raise_objection(this);

        `uvm_do_on(m_seq, p_sequencer.m_seqr);
        `uvm_do_on(pkt_seq, p_sequencer.pkt_seqr);

        if(starting_phase != null)
          starting_phase.drop_objection(this);
    endtask


endclass

