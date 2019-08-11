
//------------------------------------------------------------------//
//
// add suffix
//
//------------------------------------------------------------------//
`uvm_analysis_imp_decl(_before)
`uvm_analysis_imp_decl(_after)

//------------------------------------------------------------------//
//
// scoreboard
//
//------------------------------------------------------------------//
class scoreboard extends uvm_scoreboard;
    uvm_analysis_imp_before #(packet, scoreboard) before_export;
    uvm_analysis_imp_after #(packet, scoreboard) after_export;
    uvm_in_order_class_comparator #(packet) comparator[16];
    
    `uvm_component_utils(scoreboard)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	//-----------------------------------------//
	// build phase
	//-----------------------------------------//
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
        
        before_export = new("before_export", this);
        after_export = new("after_export", this);

        for(int i=0; i<16; i++) begin
            comparator[i] = uvm_in_order_class_comparator #(packet)::type_id::create($sformatf("comparator_%0d", i), this);
        end
    endfunction

	//-----------------------------------------//
	// write_before
	//-----------------------------------------//
    virtual function void write_before(packet pkt);
        comparator[pkt.da].before_export.write(pkt);
    endfunction


	//-----------------------------------------//
	// write_before
	//-----------------------------------------//
    virtual function void write_after(packet pkt);
        comparator[pkt.da].after_export.write(pkt);
    endfunction

	//-----------------------------------------//
	// report
	//-----------------------------------------//
    virtual function void report();
        foreach(comparator[i]) begin
            `uvm_info("Scoreboard_Report", $sformatf("Comparator[%0d] Matches = %0d, Mismatched = %0d", i, comparator[i].m_matches, comparator[i].m_mismatches), UVM_MEDIUM);
        end
    endfunction


endclass

