module Cascade_tb1_master();
reg CS;  
reg WR ;
reg RD; 
wire [7:0] D; 
wire [2:0] CAS;
reg SP ;
wire INT;
reg [7:0] IR ;
reg INTA ;
reg A0;


reg [7:0] D_dummy;

integer write;

assign D = (write) ? D_dummy : 8'bz;

	PIC single_instance ( .CS(CS) , .WR(WR) ,.RD(RD) , .D(D) , .CAS(CAS) ,
	.SP(SP) , .INT(INT) , .IR(IR) , .INTA(INTA) , .A0(A0) );

initial begin 
$monitor("time is %t IR is %b  D is %b  INT is %b CAS is %b " , $time , IR , D , INT , CAS);
//ICW1 
$display("ICW1");
CS = 0;
WR = 0;
RD = 1;
A0=0;
INTA=1;
write = 1;
D_dummy = 8'b1011001;
SP=1;
IR=8'b00000000;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0=0;
write = 0;


#5
$display("ICW2");
//ICW2
CS = 0;
WR = 0;
RD = 1;
A0=1;
write = 1;
D_dummy = 8'b00110110;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0=0;
write = 0;

#5//ICW3
$display("ICW3");
CS = 0;
WR = 0;
RD = 1;
A0=1;
write = 1;
D_dummy = 8'b00010000;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0=0;
write = 0;


//ICW4
#5
$display("ICW4");
CS = 0;
WR = 0;
RD = 1;
A0=1;
write = 1;
D_dummy = 8'b00010111;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0=0;
write = 0;


#5
$display("2 interrupts arrive one from slave PIC and one from I/O device");
IR=8'b00010010;

#5
$display("first ack");
//first pulse
INTA=0;

#5
INTA=1;

#5
//second pulse 
INTA=0;

#5
INTA=1;
IR=8'b00010000;

#5
$display("second ack");
//first pulse
INTA=0;


#5

INTA=1;

#5
//second pulse 
$display("time is %t IR is %b  D is %b  INT is %b CAS is %b " , $time , IR , D , INT , CAS);
INTA=0;

#5
INTA=1;





end

endmodule


module Cascade_tb1_slave();
reg CS;  
reg WR ;
reg RD; 
wire [7:0] D; 
wire [2:0] CAS;
reg SP ;
wire INT;
reg [7:0] IR ;
reg INTA ;
reg A0;


reg [7:0] D_dummy;
reg [2:0] cas_o;

integer write;
integer cas_write;

assign D = (write) ? D_dummy : 8'bz;
assign CAS = (cas_write) ? cas_o : 3'bz;

	PIC single_instance ( .CS(CS) , .WR(WR) ,.RD(RD) , .D(D) , .CAS(CAS) ,
	.SP(SP) , .INT(INT) , .IR(IR) , .INTA(INTA) , .A0(A0) );

initial begin 
$monitor("time is %t IR is %b  D is %b  INT is %b CAS is %b " , $time , IR , D , INT , CAS);
//ICW1 
$display("ICW1");
CS = 0;
WR = 0;
RD = 1;
A0=0;
INTA=1;
write = 1;
cas_write=0;
D_dummy = 8'b10110001;
SP=0;
IR=8'b00000000;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0=0;
write = 0;


#5
$display("ICW2");
//ICW2
CS = 0;
WR = 0;
RD = 1;
A0=1;
write = 1;
D_dummy = 8'b00110110;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0=0;
write = 0;

#5//ICW3
$display("ICW3");
CS = 0;
WR = 0;
RD = 1;
A0=1;
write = 1;
D_dummy = 8'b00000100;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0=0;
write = 0;


//ICW4
#5
$display("ICW4");
CS = 0;
WR = 0;
RD = 1;
A0=1;
write = 1;
D_dummy = 8'b00010111;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0=0;
write = 0;


#5
$display("3 interrupts arrive ");
IR=8'b00010010;

#5
//first pulse
$display("first ack non matching cas signal");
INTA=0;

#5
INTA=1;
cas_o=001;
cas_write=1;

#5
//second pulse 
INTA=0;

#5
INTA=1;
IR=8'b00010010;
cas_write=0;

#5
$display("second ack");
//first pulse
INTA=0;


#5
INTA=1;
cas_o=100;
cas_write=1;

#5
//second pulse 
INTA=0;

#5
INTA=1;
cas_write=0;

#5
$display("third ack");
//first pulse
INTA=0;


#5
INTA=1;
cas_o=100;
cas_write=1;

#5
//second pulse 
INTA=0;

#5
INTA=1;
cas_write=0;


end


endmodule
