module Single_TB1(); //edge mode
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

initial 
begin
$monitor("time is %t IR is %b  D is %b  INT is %b " , $time , IR , D , INT);
//ICW1 
$display("ICW1");
CS = 0;
WR = 0;
RD = 1;
A0=0;
INTA=1;
write = 1;
D_dummy = 8'b10110011;
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


//ICW4
#5
$display("ICW4");
CS = 0;
WR = 0;
RD = 1;
A0=1;
write = 1;
D_dummy = 8'b00010111;

//2 interrupts arrive

#5
$display("2 interrupts arrive");
IR=8'b00101000;


//read IRR
#5
$display("read IRR");
CS = 0;
WR = 1;
RD = 0;
A0=0;
write = 0;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0=0;
write = 0;


#5
$display("first ack");
//first pulse
INTA=0;

#5
INTA=1;

//second pulse
#5
INTA=0;

#5
INTA=1;



#5
$display("second ack");
//first pulse
INTA=0;

#5
INTA=1;

#5
//second pulse
INTA=0;

#5
INTA=1;
IR=8'b00000000; //interuput request goes down

#5
$display("1 interrupt arrive");
IR=8'b00010000;

#5
$display("ack");
//first pulse
INTA=0;

#5
INTA=1;

#5
$display("a lower priority interrupt arrives mid ack");
IR=8'b01010000;

#5
//second pulse
INTA=0;

#5
INTA=1;


#5
$display("ack");
//first pulse
INTA=0;

#5
INTA=1;

#5
//second pulse
INTA=0;

#5
INTA=1;
IR=8'b00000000;

#5
$display("1 interrupt arrive");
IR=8'b00010000;

#5
$display("ack");
//first pulse
INTA=0;

#5
INTA=1;

#5
$display("a higher priority interrupt arrives mid ack");
IR=8'b00010010;

#5
//second pulse
INTA=0;

#5
INTA=1;

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

#5
$display("second ack");
//first pulse
INTA=0;

#5
INTA=1;

#5
//second pulse
INTA=0;

#5
INTA=1;
IR=8'b00000000;

#5
$display("turn on automatic rotate on AEOI");
CS = 0;
WR = 0;
RD = 1;
A0=0;
write = 1;
D_dummy = 8'b10000101;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0=0;
write = 0;

#5
$display("1 interrupt arrives");
IR = 8'b00001000;

#5
$display("ack");
//first pulse
INTA=0;

#5
INTA=1;

#5
//second pulse
INTA=0;

#5
INTA=1;
IR=8'b00000000;

#5
$display("2 interrupts arrive");
IR=8'b01000010;


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



#5
$display("second ack");
//first pulse
INTA=0;

#5
INTA=1;

#5
//second pulse
INTA=0;

#5
INTA=1;
IR=8'b00000000;


end


endmodule

module Single_tb2(); //level mode
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

initial 
begin
$monitor("time is %t IR is %b  D is %b  INT is %b " , $time , IR , D , INT);
//ICW1 
$display("ICW1");
CS = 0;
WR = 0;
RD = 1;
A0=0;
INTA=1;
write = 1;
D_dummy = 8'b10111010;
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

#5
$display("setting read to ISR");
CS = 0;
WR = 0;
RD = 1;
A0=0;
write = 1;
D_dummy = 8'b00101111;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0=0;
write = 0;


#5
$display("masking interrupt 4");
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
A0 = 0;
write = 0;

#5
$display("reading IMR");
RD = 0;
CS = 0;
A0 = 1;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0 = 0;
write = 0;

#5
$display("interrupt 4 arrives");
IR=8'b00010000;
$display("INT line doesn't go high");


#5
$display("unmasking interrupt 4");
$display("INT line goes high");
CS = 0;
WR = 0;
RD = 1;
A0=1;
write = 1;
D_dummy = 8'b00000000;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0 = 0;
write = 0;


#5
$display("ack");
//first pulse
INTA=0;

#5
INTA=1;

#5
//second pulse
INTA=0;

#5
INTA=1;

#5
$display("reading ISR");
RD = 0;
CS = 0;
A0 = 0;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0 = 0;
write = 0;


#5
$display("non specific EOI");
$display("interrupt line goes high");
CS = 0;
WR = 0;
RD = 1;
A0=0;
write = 1;
D_dummy = 8'b00100111;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0=0;
write = 0;

#5
$display("reading ISR");
RD = 0;
CS = 0;
A0 = 0;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0 = 0;
write = 0;

#5
$display("ack");
//first pulse
INTA=0;

#5
INTA=1;

#5
//second pulse
INTA=0;


#5
INTA=1;

#5
$display("interrupt goes down");
IR=8'b00000000;

$display("non specific EOI");
CS = 0;
WR = 0;
RD = 1;
A0=0;
write = 1;
D_dummy = 8'b00100111;

#5
//Stops driving the bus signal
CS = 1;
WR = 1;
RD = 1;
A0=0;
write = 0;


end
endmodule

