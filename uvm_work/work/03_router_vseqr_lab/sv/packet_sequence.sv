
class packet_sequence extends uvm_sequence #(packet_transaction);
  `uvm_object_utils(packet_sequence)

  int item_num = 10;

  function new(string name = "packet_sequence");
    super.new(name); 
  endfunction
  
  //function void pre_randomize();
  //  uvm_config_db#(int)::get(m_sequencer, "", "item_num", item_num);
  //endfunction

  virtual task body();

    packet_transaction tr;

    if(starting_phase != null) 
      starting_phase.raise_objection(this);

    repeat(item_num) begin
        //`uvm_do(req)
        tr = packet_transaction::type_id::create("tr");
        start_item(tr);
        tr.randomize();
        finish_item(tr);
        get_response(rsp);
        `uvm_info("SEQ", {"\n", "PKT_Sequence get the response: \n", rsp.sprint()}, UVM_MEDIUM)
    end

    #100;
    if(starting_phase != null)
      starting_phase.drop_objection(this);
  endtask

endclass

