
//**************************************************************************
// Project     : 
// Module      : 
// Description :  
// Designer    :
// Version     : 
//***************************************************************************


//-----------------------------------------------
// 
// bus interface
//
//-----------------------------------------------

parameter aw = 8;

input       				      icb_wr,
input [aw-1:0]			      icb_wadr, 
input [31:0]              icb_wdat,
output                    icb_wack,

input 				            icb_rd,
input [aw-1:0]			      icb_radr, 
output[31:0]              icb_rdat,
output                    icb_rack,
