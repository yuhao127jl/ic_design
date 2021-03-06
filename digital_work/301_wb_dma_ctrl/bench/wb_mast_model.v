
 
module wb_mast(clk, rst, adr, din, dout, cyc, stb, sel, we, ack, err, rty);
 
input		clk, rst;
output	[31:0]	adr;
input	[31:0]	din;
output	[31:0]	dout;
output		cyc, stb;
output	[3:0]	sel;
output		we;
input		ack, err, rty;
 
////////////////////////////////////////////////////////////////////
//
// Local Wires
//
 
parameter mem_size = 4096;
 
reg	[31:0]	adr;
reg	[31:0]	dout;
reg		cyc, stb;
reg	[3:0]	sel;
reg		we;
 
reg	[31:0]	rd_mem[mem_size:0];
reg	[31:0]	wr_mem[mem_size:0];
integer		rd_cnt;
integer		wr_cnt;
 
////////////////////////////////////////////////////////////////////
//
// Memory Logic
//
 
initial
   begin
	//adr = 32'hxxxx_xxxx;
	//adr = 0;
	adr = 32'hffff_ffff;
	dout = 32'hxxxx_xxxx;
	cyc = 0;
	stb = 0;
	sel = 4'hx;
	we = 1'hx;
	rd_cnt = 0;
	wr_cnt = 0;
	#1;
	$display("\nINFO: WISHBONE MASTER MODEL INSTANTIATED (%m)\n");
   end
 
 
 
task mem_fill;
 
integer n;
begin
rd_cnt = 0;
wr_cnt = 0;
for(n=0;n<mem_size;n=n+1)
   begin
	rd_mem[n] = $random;
	wr_mem[n] = $random;
   end
end
endtask
 
////////////////////////////////////////////////////////////////////
//
// Write 1 Word Task
//
 
task wb_wr1;
input	[31:0]	a;
input	[3:0]	s;
input	[31:0]	d;
 
begin
 
@(posedge clk);
#1;
adr = a;
dout = d;
cyc = 1;
stb = 1;
we=1;
sel = s;
 
@(posedge clk);
while(~ack & ~err)	@(posedge clk);
#1;
cyc=0;
stb=0;
adr = 32'hxxxx_xxxx;
//adr = 32'hffff_ffff;
//adr = 0;
dout = 32'hxxxx_xxxx;
we = 1'hx;
sel = 4'hx;
 
end
endtask
 
////////////////////////////////////////////////////////////////////
//
// Write 4 Words Task
//
 
task wb_wr4;
input	[31:0]	a;
input	[3:0]	s;
input		delay;
input	[31:0]	d1;
input	[31:0]	d2;
input	[31:0]	d3;
input	[31:0]	d4;
 
integer		delay;
 
begin
 
@(posedge clk);
#1;
cyc = 1;
sel = s;
 
repeat(delay)
   begin
	@(posedge clk);
	#1;
   end
adr = a;
dout = d1;
stb = 1;
we=1;
while(~ack & ~err)	@(posedge clk);
#2;
stb=0;
we=1'bx;
dout = 32'hxxxx_xxxx;
 
 
repeat(delay)
   begin
	@(posedge clk);
	#1;
   end
stb=1;
adr = a+4;
dout = d2;
we=1;
@(posedge clk);
while(~ack & ~err)	@(posedge clk);
#2;
stb=0;
we=1'bx;
dout = 32'hxxxx_xxxx;
 
repeat(delay)
   begin
	@(posedge clk);
	#1;
   end
stb=1;
adr = a+8;
dout = d3;
we=1;
@(posedge clk);
while(~ack & ~err)	@(posedge clk);
#2;
stb=0;
we=1'bx;
dout = 32'hxxxx_xxxx;
 
repeat(delay)
   begin
	@(posedge clk);
	#1;
   end
stb=1;
adr = a+12;
dout = d4;
we=1;
@(posedge clk);
while(~ack & ~err)	@(posedge clk);
#1;
stb=0;
cyc=0;
 
adr = 32'hxxxx_xxxx;
//adr = 0;
//adr = 32'hffff_ffff;
dout = 32'hxxxx_xxxx;
we = 1'hx;
sel = 4'hx;
 
end
endtask
 
 
task wb_wr_mult;
input	[31:0]	a;
input	[3:0]	s;
input		delay;
input		count;
 
integer		delay;
integer		count;
integer		n;
 
begin
 
@(posedge clk);
#1;
cyc = 1;
 
for(n=0;n<count;n=n+1)
   begin
	repeat(delay)
	   begin
		@(posedge clk);
		#1;
	   end
	adr = a + (n*4);
	dout = wr_mem[n + wr_cnt];
	stb = 1;
	we=1;
	sel = s;
	if(n!=0)	@(posedge clk);
	while(~ack & ~err)	@(posedge clk);
	#2;
	stb=0;
	we=1'bx;
	sel = 4'hx;
	dout = 32'hxxxx_xxxx;
	adr = 32'hxxxx_xxxx;
   end
 
cyc=0;
 
adr = 32'hxxxx_xxxx;
//adr = 32'hffff_ffff;
 
wr_cnt = wr_cnt + count;
end
endtask
 
 
task wb_rmw;
input	[31:0]	a;
input	[3:0]	s;
input		delay;
input		rcount;
input		wcount;
 
integer		delay;
integer		rcount;
integer		wcount;
integer		n;
 
begin
 
@(posedge clk);
#1;
cyc = 1;
we = 0;
sel = s;
repeat(delay)	@(posedge clk);
 
for(n=0;n<rcount-1;n=n+1)
   begin
	adr = a + (n*4);
	stb = 1;
	while(~ack & ~err)	@(posedge clk);
	rd_mem[n + rd_cnt] = din;
	//$display("Rd Mem[%0d]: %h", (n + rd_cnt), rd_mem[n + rd_cnt] );
	#2;
	stb=0;
	we = 1'hx;
	sel = 4'hx;
	adr = 32'hxxxx_xxxx;
	repeat(delay)
	   begin
		@(posedge clk);
		#1;
	   end
	we = 0;
	sel = s;
   end
 
adr = a+(n*4);
stb = 1;
@(posedge clk);
while(~ack & ~err)	@(posedge clk);
rd_mem[n + rd_cnt] = din;
//$display("Rd Mem[%0d]: %h", (n + rd_cnt), rd_mem[n + rd_cnt] );
#1;
stb=0;
we = 1'hx;
sel = 4'hx;
adr = 32'hxxxx_xxxx;
 
rd_cnt = rd_cnt + rcount;
 
//@(posedge clk);
 
 
for(n=0;n<wcount;n=n+1)
   begin
	repeat(delay)
	   begin
		@(posedge clk);
		#1;
	   end
	adr = a + (n*4);
	dout = wr_mem[n + wr_cnt];
	stb = 1;
	we=1;
	sel = s;
//	if(n!=0)
		@(posedge clk);
	while(~ack & ~err)	@(posedge clk);
	#2;
	stb=0;
	we=1'bx;
	sel = 4'hx;
	dout = 32'hxxxx_xxxx;
	adr = 32'hxxxx_xxxx;
   end
 
cyc=0;
 
adr = 32'hxxxx_xxxx;
//adr = 32'hffff_ffff;
 
wr_cnt = wr_cnt + wcount;
end
endtask
 
 
 
 
task wb_wmr;
input	[31:0]	a;
input	[3:0]	s;
input		delay;
input		rcount;
input		wcount;
 
integer		delay;
integer		rcount;
integer		wcount;
integer		n;
 
begin
 
@(posedge clk);
#1;
cyc = 1;
we = 1'bx;
sel = 4'hx;
sel = s;
 
for(n=0;n<wcount;n=n+1)
   begin
	repeat(delay)
	   begin
		@(posedge clk);
		#1;
	   end
	adr = a + (n*4);
	dout = wr_mem[n + wr_cnt];
	stb = 1;
	we=1;
	sel = s;
	@(posedge clk);
	while(~ack & ~err)	@(posedge clk);
	#2;
	stb=0;
	we=1'bx;
	sel = 4'hx;
	dout = 32'hxxxx_xxxx;
	adr = 32'hxxxx_xxxx;
   end
 
wr_cnt = wr_cnt + wcount;
stb=0;
repeat(delay)	@(posedge clk);
#1;
 
sel = s;
we = 0;
for(n=0;n<rcount-1;n=n+1)
   begin
	adr = a + (n*4);
	stb = 1;
	while(~ack & ~err)	@(posedge clk);
	rd_mem[n + rd_cnt] = din;
	//$display("Rd Mem[%0d]: %h", (n + rd_cnt), rd_mem[n + rd_cnt] );
	#2;
	stb=0;
	we = 1'hx;
	sel = 4'hx;
	adr = 32'hxxxx_xxxx;
	repeat(delay)
	   begin
		@(posedge clk);
		#1;
	   end
	we = 0;
	sel = s;
   end
 
adr = a+(n*4);
stb = 1;
@(posedge clk);
while(~ack & ~err)	@(posedge clk);
rd_mem[n + rd_cnt] = din;
rd_cnt = rd_cnt + rcount;
//$display("Rd Mem[%0d]: %h", (n + rd_cnt), rd_mem[n + rd_cnt] );
#1;
 
cyc = 0;
stb = 0;
we  = 1'hx;
sel = 4'hx;
adr = 32'hxxxx_xxxx;
 
end
endtask
 
 
 
 
////////////////////////////////////////////////////////////////////
//
// Read 1 Word Task
//
 
task wb_rd1;
input	[31:0]	a;
input	[3:0]	s;
output	[31:0]	d;
 
begin
 
@(posedge clk);
#1;
adr = a;
cyc = 1;
stb = 1;
we  = 0;
sel = s;
 
//@(posedge clk);
while(~ack & ~err)	@(posedge clk);
d = din;
#1;
cyc=0;
stb=0;
//adr = 32'hxxxx_xxxx;
//adr = 0;
adr = 32'hffff_ffff;
dout = 32'hxxxx_xxxx;
we = 1'hx;
sel = 4'hx;
 
end
endtask
 
 
////////////////////////////////////////////////////////////////////
//
// Read 4 Words Task
//
 
 
task wb_rd4;
input	[31:0]	a;
input	[3:0]	s;
input		delay;
output	[31:0]	d1;
output	[31:0]	d2;
output	[31:0]	d3;
output	[31:0]	d4;
 
integer		delay;
begin
 
@(posedge clk);
#1;
cyc = 1;
we = 0;
sel = s;
repeat(delay)	@(posedge clk);
 
adr = a;
stb = 1;
while(~ack & ~err)	@(posedge clk);
d1 = din;
#2;
stb=0;
we = 1'hx;
sel = 4'hx;
repeat(delay)
   begin
	@(posedge clk);
	#1;
   end
we = 0;
sel = s;
 
adr = a+4;
stb = 1;
@(posedge clk);
while(~ack & ~err)	@(posedge clk);
d2 = din;
#2;
stb=0;
we = 1'hx;
sel = 4'hx;
repeat(delay)
   begin
	@(posedge clk);
	#1;
   end
we = 0;
sel = s;
 
 
adr = a+8;
stb = 1;
@(posedge clk);
while(~ack & ~err)	@(posedge clk);
d3 = din;
#2;
stb=0;
we = 1'hx;
sel = 4'hx;
repeat(delay)
   begin
	@(posedge clk);
	#1;
   end
we = 0;
sel = s;
 
adr = a+12;
stb = 1;
@(posedge clk);
while(~ack & ~err)	@(posedge clk);
d4 = din;
#1;
stb=0;
cyc=0;
we = 1'hx;
sel = 4'hx;
adr = 32'hffff_ffff;
end
endtask
 
 
 
task wb_rd_mult;
input	[31:0]	a;
input	[3:0]	s;
input		delay;
input		count;
 
integer		delay;
integer		count;
integer		n;
 
begin
 
@(posedge clk);
#1;
cyc = 1;
we = 0;
sel = s;
repeat(delay)	@(posedge clk);
 
for(n=0;n<count-1;n=n+1)
   begin
	adr = a + (n*4);
	stb = 1;
	while(~ack & ~err)	@(posedge clk);
	rd_mem[n + rd_cnt] = din;
	#2;
	stb=0;
	we = 1'hx;
	sel = 4'hx;
	adr = 32'hxxxx_xxxx;
	repeat(delay)
	   begin
		@(posedge clk);
		#1;
	   end
	we = 0;
	sel = s;
   end
 
adr = a+(n*4);
stb = 1;
@(posedge clk);
while(~ack & ~err)	@(posedge clk);
rd_mem[n + rd_cnt] = din;
#1;
stb=0;
cyc=0;
we = 1'hx;
sel = 4'hx;
adr = 32'hffff_ffff;
adr = 32'hxxxx_xxxx;
 
rd_cnt = rd_cnt + count;
end
endtask
 
endmodule
 
