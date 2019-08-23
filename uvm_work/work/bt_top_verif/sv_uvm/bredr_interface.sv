
//-----------------------------------------------------------------------------------//
//
// bredr_top interface
//
//-----------------------------------------------------------------------------------//
interface bredr_interface(input bit bsb_clk);
	
	//*********************sfr_bus*********************//
	logic				bt_con_wr;   			//i
	logic				bt_optcon_wr;  			//i
	logic				bt_edrcon_wr;  			//i
	logic				ble_exmem_baseadr_wr,	//i
	logic				bt_pcm_con_wr;  		//i
	logic				bt_pcm_wadr_wr;  		//i
	logic				bt_pcm_radr_wr;  		//i
	logic				bt_fine_con_wr;  		//i
	logic   [7:0]		bt_fine_prd_wr;  		//i
	logic				bt_clkn_con_wr;  		//i
	logic   [7:0]		bt_clkn_prd_wr;  		//i
	logic	[31:0]		sfr_wdat32;   			//i
	logic	[31:0]		bt_con; 	  			//o
	logic	[31:0]		bt_optcon;	  			//o
	logic	[31:0]		bt_inf; 	  			//o
	logic	[7:0]		edr_con; 	  			//o
	logic	[22:0]		bt_exmem_baseadr; 		//o
	logic	[15:0]		bt_pcm_con;	  			//o
	logic	[31:0]		bt_fine_con;	  		//o
	logic	[9:0]		bt_fine0_prd;  			//o
	logic	[9:0]		bt_fine1_prd;  			//o
	logic	[9:0]		bt_fine2_prd;  			//o
	logic	[9:0]		bt_fine3_prd;  			//o
	logic	[9:0]		bt_fine4_prd;  			//o
	logic	[9:0]		bt_fine5_prd;  			//o
	logic	[9:0]		bt_fine6_prd;  			//o
	logic	[9:0]		bt_fine7_prd;  			//o

	logic	[31:0]		bt_clkn_con;	  		//o
	logic	[15:0]		bt_clkn0_prd;  			//o
	logic	[15:0]		bt_clkn1_prd;  			//o
	logic	[15:0]		bt_clkn2_prd;  			//o
	logic	[15:0]		bt_clkn3_prd;  			//o
	logic	[15:0]		bt_clkn4_prd;  			//o
	logic	[15:0]		bt_clkn5_prd;  			//o
	logic	[15:0]		bt_clkn6_prd;  			//o
	logic	[15:0]		bt_clkn7_prd;  			//o

	logic				clk_sel;	  			//i

	//*********************qmem*********************//
	logic				qmem_bt_req; 			//i
	logic				qmem_bt_we;  			//i
	logic	[15:0]		qmem_bt_adr; 			//i
	logic	[15:0]		qmem_bt_wdat;			//i
	logic	[15:0]		qmem_bt_rdat;			//o
	logic				qmem_bt_ack; 			//o

	//*********************exmem*********************//
	logic				bredr_em_req; 			//o
	logic	[3:0]		bredr_em_we;  			//o
	logic	[22:0]		bredr_em_adr; 			//o
	logic	[31:0]		bredr_em_wdat;			//o
	logic	[31:0]		bredr_em_rdat;			//i
	logic				bredr_em_ack; 			//i

	//*********************pcm dma*********************//
	logic				pcm_dma_req; 			//o
	logic	[3:0]		pcm_dma_we;  			//o
	logic	[22:0]		pcm_dma_adr; 			//o
	logic	[31:0]		pcm_dma_wdat;			//o
	logic	[31:0]		pcm_dma_rdat;			//i
	logic				pcm_dma_ack; 			//i

	//*********************bredr interrupt*********************//
	logic				bt_int;	    			//o
	logic				bt_dbg_int;				//o
	logic				bt_pcm_dma_int;			//o
	logic				bt_clkn_int;			//o

	//*********************bredr tx & rx*********************//
	logic				bredr_txen;				//o
	logic				bredr_txvalid;			//o
	logic	[2:0]		bredr_txdat;			//o
	logic				bredr_rxen;				//i
	logic				bredr_rxmch;			//i
	logic				bredr_rxvalid;			//i
	logic	[2:0]		bredr_rxdat;			//i
	logic	[63:0]		bredr_sw;   			//o
	logic	[1:0]		bredr_mode;				//o
	logic				bredr_ver;				//o
	
	//*********************ble prio*********************//
	logic				bredr_abort;			//i
	logic	[4:0]		bredr_currentprio;		//o			

	logic	[7:0]		bredr_hop_index;		//o			
	logic	[15:0]		bredr_anl_base; 		//o			
	logic	[15:0]		bredr_freq_base;		//o			

	//*********************bredr deepsl*********************//
	logic				lp_pu;			        //i
	logic				lp_kst;			    	//o
	logic				lp_allowed;		    	//o
	logic				lp_ref;			    	//i

	//*********************bredr pcm*********************//
	logic				pcmfsync_in;			//i
	logic				pcmclk_in;				//i
	logic				pcmdin; 				//i
	logic				pcmfsync_en;			//o
	logic				pcmfsync_out;			//o
	logic				pcmclk_en;	    		//o
	logic				pcmclk_out;	    		//o
	logic				pcmdout_en;	    		//o
	logic				pcmdout_out;			//o

	//*********************ble dbg io*********************//
	logic	[7:0]		debug_port;             //o


	//*********************ble rst*********************//
	logic				sfr_clk;				//i
	logic				bsb_rst_;				//i
	logic				sys_rst_;				//i


	//---------------------------------------------------------------------//
	//
	// modport
	//
	//---------------------------------------------------------------------//
	modport driver(clocking drvclk, output	ble_rst_);
	modport imom(clocking imonclk);
	modport omom(clocking omonclk);
	modport bredr_top(
                    //*********************sfr_bus*********************//
                    input				bt_con_wr,   			//i
                    input				bt_optcon_wr,  			//i
                    input				bt_edrcon_wr,  			//i
                    input				ble_exmem_baseadr_wr,	//i
                    input				bt_pcm_con_wr,  		//i
                    input				bt_pcm_wadr_wr,  		//i
                    input				bt_pcm_radr_wr,  		//i
                    input				bt_fine_con_wr,  		//i
                    input   [7:0]		bt_fine_prd_wr,  		//i
                    input				bt_clkn_con_wr,  		//i
                    input   [7:0]		bt_clkn_prd_wr,  		//i
                    input	[31:0]		sfr_wdat32,   			//i
                    output	[31:0]		bt_con, 	  			//o
                    output	[31:0]		bt_optcon,	  			//o
                    output	[31:0]		bt_inf, 	  			//o
                    output	[7:0]		edr_con, 	  			//o
                    output	[22:0]		bt_exmem_baseadr, 		//o
                    output	[15:0]		bt_pcm_con,	  			//o
                    output	[31:0]		bt_fine_con,	  		//o
                    output	[9:0]		bt_fine0_prd,  			//o
                    output	[9:0]		bt_fine1_prd,  			//o
                    output	[9:0]		bt_fine2_prd,  			//o
                    output	[9:0]		bt_fine3_prd,  			//o
                    output	[9:0]		bt_fine4_prd,  			//o
                    output	[9:0]		bt_fine5_prd,  			//o
                    output	[9:0]		bt_fine6_prd,  			//o
                    output	[9:0]		bt_fine7_prd,  			//o

                    output	[31:0]		bt_clkn_con,	  		//o
                    output	[15:0]		bt_clkn0_prd,  			//o
                    output	[15:0]		bt_clkn1_prd,  			//o
                    output	[15:0]		bt_clkn2_prd,  			//o
                    output	[15:0]		bt_clkn3_prd,  			//o
                    output	[15:0]		bt_clkn4_prd,  			//o
                    output	[15:0]		bt_clkn5_prd,  			//o
                    output	[15:0]		bt_clkn6_prd,  			//o
                    output	[15:0]		bt_clkn7_prd,  			//o

                    input				clk_sel,	  			//i

                    //*********************qmem*********************//
                    input				qmem_bt_req, 			//i
                    input				qmem_bt_we,  			//i
                    input	[15:0]		qmem_bt_adr, 			//i
                    input	[15:0]		qmem_bt_wdat,			//i
                    output	[15:0]		qmem_bt_rdat,			//o
                    output				qmem_bt_ack, 			//o

                    //*********************exmem*********************//
                    output				bredr_em_req, 			//o
                    output	[3:0]		bredr_em_we,  			//o
                    output	[22:0]		bredr_em_adr, 			//o
                    output	[31:0]		bredr_em_wdat,			//o
                    input	[31:0]		bredr_em_rdat,			//i
                    input				bredr_em_ack, 			//i

                    //*********************pcm dma*********************//
                    output				pcm_dma_req, 			//o
                    output	[3:0]		pcm_dma_we,  			//o
                    output	[22:0]		pcm_dma_adr, 			//o
                    output	[31:0]		pcm_dma_wdat,			//o
                    input	[31:0]		pcm_dma_rdat,			//i
                    input				pcm_dma_ack, 			//i

                    //*********************bredr interrupt*********************//
                    output				bt_int,	    			//o
                    output				bt_dbg_int,				//o
                    output				bt_pcm_dma_int,			//o
                    output				bt_clkn_int,			//o

                    //*********************bredr tx & rx*********************//
                    output				bredr_txen,				//o
                    output				bredr_txvalid,			//o
                    output	[2:0]		bredr_txdat,			//o
                    input				bredr_rxen,				//i
                    input				bredr_rxmch,			//i
                    input				bredr_rxvalid,			//i
                    input	[2:0]		bredr_rxdat,			//i
                    output	[63:0]		bredr_sw,   			//o
                    output	[1:0]		bredr_mode,				//o
                    output				bredr_ver,				//o
                    
                    //*********************ble prio*********************//
                    input				bredr_abort,			//i
                    output	[4:0]		bredr_currentprio,		//o			

                    output	[7:0]		bredr_hop_index,		//o			
                    output	[15:0]		bredr_anl_base, 		//o			
                    output	[15:0]		bredr_freq_base,		//o			

                    //*********************bredr deepsl*********************//
                    input				lp_pu,			        //i
                    output				lp_kst,			    	//o
                    output				lp_allowed,		    	//o
                    input				lp_ref,			    	//i

                    //*********************bredr pcm*********************//
                    input				pcmfsync_in,			//i
                    input				pcmclk_in,				//i
                    input				pcmdin, 				//i
                    output				pcmfsync_en,			//o
                    output				pcmfsync_out,			//o
                    output				pcmclk_en,	    		//o
                    output				pcmclk_out,	    		//o
                    output				pcmdout_en,	    		//o
                    output				pcmdout_out,			//o

                    //*********************ble dbg io*********************//
                    output	[7:0]		debug_port,             //o


                    //*********************ble rst*********************//
                    input				sfr_clk,				//i
                    input				bsb_clk,				//i
                    input				bsb_rst_,				//i
                    input				sys_rst_				//i
					),
	


endinterface
//-----------------------------------------------------------------------------------//
//
// END
//
//-----------------------------------------------------------------------------------//

