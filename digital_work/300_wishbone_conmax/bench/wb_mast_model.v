
 
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
 
reg	[31:0]	mem[mem_size:0];
integer		cnt;
 
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
	cnt = 0;
	#1;
	$display("\nINFO: WISHBONE MASTER MODEL INSTANTIATED (%m)\n");
   end
 
 
 
task mem_fill;
 
integer n;
begin
cnt = 0;
cnt = 0;
for(n=0;n<mem_size;n=n+1)
   begin
	mem[n] = $random;
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
 
//@(posedge clk);
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
adr = $random;
 
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
 
adr = $random;
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
adr = $random;
 
 
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
adr = $random;
 
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
adr = $random;
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
 
//@(posedge clk);
#1;
cyc = 1;
adr = $random;
for(n=0;n<count;n=n+1)
   begin
	repeat(delay)
	   begin
		@(posedge clk);
		#1;
	   end
	adr = a + (n*4);
	dout = mem[n + cnt];
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
	//adr = 32'hxxxx_xxxx;
	adr = $random;
   end
 
cyc=0;
 
adr = 32'hxxxx_xxxx;
//adr = 32'hffff_ffff;
 
cnt = cnt + count;
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
	mem[n + cnt] = din;
	//$display("Rd Mem[%0d]: %h", (n + cnt), mem[n + cnt] );
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
mem[n + cnt] = din;
//$display("Rd Mem[%0d]: %h", (n + cnt), mem[n + cnt] );
#1;
stb=0;
we = 1'hx;
sel = 4'hx;
adr = 32'hxxxx_xxxx;
 
cnt = cnt + rcount;
 
//@(posedge clk);
 
 
for(n=0;n<wcount;n=n+1)
   begin
	repeat(delay)
	   begin
		@(posedge clk);
		#1;
	   end
	adr = a + (n*4);
	dout = mem[n + cnt];
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
 
cnt = cnt + wcount;
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
	dout = mem[n + cnt];
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
 
cnt = cnt + wcount;
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
	mem[n + cnt] = din;
	//$display("Rd Mem[%0d]: %h", (n + cnt), mem[n + cnt] );
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
mem[n + cnt] = din;
cnt = cnt + rcount;
//$display("Rd Mem[%0d]: %h", (n + cnt), mem[n + cnt] );
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
 
//@(posedge clk);
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
adr = $random;
 
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
adr = $random;
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
adr = $random;
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
adr = $random;
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
adr = $random;
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
adr = $random;
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
 
//@(posedge clk);
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
	mem[n + cnt] = din;
	#2;
	stb=0;
	we = 1'hx;
	sel = 4'hx;
	//adr = 32'hxxxx_xxxx;
	adr = $random;
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
mem[n + cnt] = din;
#1;
stb=0;
cyc=0;
we = 1'hx;
sel = 4'hx;
//adr = 32'hffff_ffff;
//adr = 32'hxxxx_xxxx;
adr = $random;
 
cnt = cnt + count;
end
endtask
 
endmodule
 
