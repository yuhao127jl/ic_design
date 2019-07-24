//***************************************************************
// 工程：三级CIC抽取滤波器设计
// 描述：
// 时间：2017-12-05
//***************************************************************

module cic3_dsf(
	input clki,       // 12MHz
	input rst_n,
	input clko,       // 可选择
	input [1:0]srat,  // 采样率选择
	input [1:0]din,
	output reg [31:0]dout
);
reg [25:0]dreg00,dreg01,dreg02,dhold;

//-------------------------------------
// 
//-------------------------------------
reg [1:0]sdat;
always @(*)
begin 
	case(din)
		2'b11: sdat = 2'b01;  //  +1
		2'b00: sdat = 2'b11;  //  -1
		default: sdat = 2'b00;//   0
	endcase 
end

always @(*)
begin 
	case(srat)
		2'b00: dout = {{12{dhold[19]}},dhold[19:0]};  //  48KHz/44.1KHz/32KHz
		2'b01: dout = {{12{dhold[22]}},dhold[22:3]};  //  24KHz/22.05KHz/16KHz
		default: dout = {{12{dhold[25]}},dhold[25:6]};// 12KHz/11.025KHz/8KHz
	endcase 
end

// Integrators-积分器		
wire [25:0]dreg00_in = dreg00 + {{24{sdat[1]}},sdat[1:0]};
wire [25:0]dreg01_in = dreg01 + dreg00;
wire [25:0]dreg02_in = dreg02 + dreg01;
// 取积分器后的数据
wire [25:0]dhold_in = dreg02;

reg [17:0]cic_out;
reg [25:0]dreg10,dreg11,dreg12;
// Comb-梳状器		
wire [25:0]dreg10_in = dreg02 - dhold;
wire [25:0]dreg11_in = dreg10_in - dreg10;
wire [25:0]dreg12_in = dreg11_in - dreg11;
always @(*)
begin 
	case(srat)
		2'b00: cic_out = dreg12[19:2];//  48KHz/44.1KHz/32KHz
		2'b01: cic_out = dreg12[22:5];//  24KHz/22.05KHz/16KHz
		default: cic_out = dreg12[25:8];// 12KHz/11.025KHz/8KHz
	endcase 
end

//-------------------------------------
// register assingment
//-------------------------------------
always @(posedge clki or negedge rst_n)
if(!rst_n)
begin
	dreg00 <= 'd0;
	dreg01 <= 'd0;
	dreg02 <= 'd0;
end
else	
begin
	dreg00 <= dreg00_in;
	dreg01 <= dreg01_in;
	dreg02 <= dreg02_in;
end

always @(posedge clko or negedge rst_n)
if(!rst_n)
begin
	dhold <= 'd0;
	dreg10 <= 'd0;
	dreg11 <= 'd0;
	dreg12 <= 'd0;
end
else	
begin
	dhold <= dhold_in;
	dreg10 <= dreg00_in;
	dreg11 <= dreg01_in;
	dreg12 <= dreg02_in;
end



endmodule
