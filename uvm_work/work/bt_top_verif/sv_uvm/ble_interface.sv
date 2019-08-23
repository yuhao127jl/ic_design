
//-----------------------------------------------------------------------------------//
//
// ble_top interface
//
//-----------------------------------------------------------------------------------//
interface ble_interface(input bit bsb_clk);
	
	//*********************sfr_bus*********************//
	logic				ble_con_wr;   			//i
	logic				ble_exmem_wr, 			//i
	logic	[31:0]		sfr_wdat32;   			//i
	logic	[15:0]		ble_con;	  			//o

	logic				clk_sel;	  			//i

	//*********************qmem*********************//
	logic				qmem_ble_req; 			//i
	logic				qmem_ble_we;  			//i
	logic	[15:0]		qmem_ble_adr; 			//i
	logic	[15:0]		qmem_ble_wdat;			//i
	logic	[15:0]		qmem_ble_rdat;			//o
	logic				qmem_ble_ack; 			//o

	//*********************exmem*********************//
	logic				ex_mem_req; 			//o
	logic	[3:0]		ex_mem_we;  			//o
	logic	[22:0]		ex_mem_adr; 			//o
	logic	[31:0]		ex_mem_wdat;			//o
	logic	[31:0]		ex_mem_rdat;			//i
	logic				ex_mem_ack; 			//i

	//*********************bit phase*********************//
	logic				ext_bit_phase0;			//i
	logic				ext_bit_phase1;			//i
	logic				ext_bit_phase2;			//i
	logic	[9:0]		ext-bit_counter;		//i
	logic				ext_clkn_edge;			//i

	//*********************ble tx & rx*********************//
	logic				ble_txen;				//o
	logic				ble_txvalid;			//o
	logic	[1:0]		ble_txdat;				//o
	logic				ble_rxen;				//i
	logic				ble_rxmch;				//i
	logic				ble_rxvalid;			//i
	logic	[1:0]		ble_rxdat;				//i
	logic	[31:0]		syncword_init;			//o
	logic	[1:0]		ble_phy;				//o
	logic				ble_ci;					//i
	logic				ble_eop;				//o
	
	//*********************ble prio*********************//
	logic	[4:0]		ble_currentprio;		//o			
	logic				ble_abort;				//i

	logic	[5:0]		hop_frq_pointer;		//o			
	logic	[15:0]		anl_base_offset;		//o			
	logic	[15:0]		freq_base_offset;		//o			
	logic	[22:0]		ble_base_adr;			//o			

	//*********************ble deepsl*********************//
	logic				deepsl_kst;				//o
	logic				deepsl_wkup;			//i
	logic				deepsl_allowed;			//o
	logic				deepsl_ref;				//i

	//*********************ble dbg io*********************//
	logic	[7:0]		ble_dbg_port;

	//*********************ble interrupt*********************//
	logic				event_int;				//o
	logic				blerx_int;				//o

	//*********************ble rst*********************//
	logic				ble_rst_;				//i
	logic				sfr_clk;				//i


	//---------------------------------------------------------------------//
	//
	// modport
	//
	//---------------------------------------------------------------------//
	modport driver(clocking drvclk, output	ble_rst_);
	modport imom(clocking imonclk);
	modport omom(clocking omonclk);
	modport ble_top(
					//*********************sfr_bus*********************//
					input				ble_con_wr,   			//i
					input				ble_exmem_wr, 			//i
					input	[31:0]		sfr_wdat32,   			//i
					output	[15:0]		ble_con,	  			//o

					input				clk_sel,	  			//i

					//*********************qmem*********************//
					input				qmem_ble_req, 			//i
					input				qmem_ble_we,  			//i
					input	[15:0]		qmem_ble_adr, 			//i
					input	[15:0]		qmem_ble_wdat,			//i
					output	[15:0]		qmem_ble_rdat,			//o
					output				qmem_ble_ack, 			//o

					//*********************exmem*********************//
					output				ex_mem_req, 			//o
					output	[3:0]		ex_mem_we,  			//o
					output	[22:0]		ex_mem_adr, 			//o
					output	[31:0]		ex_mem_wdat,			//o
					input	[31:0]		ex_mem_rdat,			//i
					input				ex_mem_ack, 			//i

					//*********************bit phase*********************//
					input				ext_bit_phase0,			//i
					input				ext_bit_phase1,			//i
					input				ext_bit_phase2,			//i
					input	[9:0]		ext-bit_counter,		//i
					input				ext_clkn_edge,			//i

					//*********************ble tx & rx*********************//
					output				ble_txen,				//o
					output				ble_txvalid,			//o
					output	[1:0]		ble_txdat,				//o
					input				ble_rxen,				//i
					input				ble_rxmch,				//i
					input				ble_rxvalid,			//i
					input	[1:0]		ble_rxdat,				//i
					output	[31:0]		syncword_init,			//o
					output	[1:0]		ble_phy,				//o
					input				ble_ci,					//i
					output				ble_eop,				//o
					
					//*********************ble prio*********************//
					output	[4:0]		ble_currentprio,		//o			
					input				ble_abort,				//i

					output	[5:0]		hop_frq_pointer,		//o			
					output	[15:0]		anl_base_offset,		//o			
					output	[15:0]		freq_base_offset,		//o			
					output	[22:0]		ble_base_adr,			//o			

					//*********************ble deepsl*********************//
					output				deepsl_kst,				//o
					input				deepsl_wkup,			//i
					output				deepsl_allowed,			//o
					input				deepsl_ref,				//i

					//*********************ble dbg io*********************//
					output	[7:0]		ble_dbg_port,

					//*********************ble interrupt*********************//
					output				event_int,				//o
					output				blerx_int,				//o

					//*********************ble rst*********************//
					input				ble_rst_,				//i
					input				sfr_clk,				//i
					input				bsb_clk					//i
					);
	


endinterface
//-----------------------------------------------------------------------------------//
//
// END
//
//-----------------------------------------------------------------------------------//

