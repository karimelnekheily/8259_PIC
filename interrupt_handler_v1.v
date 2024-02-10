module interrupt_handler(input [7:0]IRQs ,inout [7:0] internal_bus ,input [7:0] OCW1
,input RD,input A0,input EOI_mode,
output reg INT ,input INTA,input[4:0] VEC_ADD,
input read_mode , input [2:0] int_level , input [2:0] EOI_command);

reg [7:0]IRR;
reg [7:0]ISR;
reg [7:0]IMR;
reg [4:0]VEC_ADD_REG;
reg [7:0]write_buffer;
reg [7:0]interrupt_add;
reg int_flag;

//bits from 0 to 24 are used to store priority for each IRQ 
//the rest are reserved
integer default_priority = 32'b1111_1010_1100_0110_1000_1000; 


reg [32:0] priority_reg = 32'b1111_1010_1100_0110_1000_1000;
reg [3:0] current_priority = 4'b1000;

integer i; 
integer count=0;
integer j;
integer k;


assign internal_bus = (!RD && A0) ? IMR : (!RD && !A0)? write_buffer : (int_flag) ? interrupt_add : 8'bz ;

always@(read_mode)begin
if(read_mode == 0)
write_buffer = IRR;
else
write_buffer = ISR;
end

always@(OCW1)begin
IMR=OCW1;
end

always@(IRQs)begin
IRR = IRQs;
end

always@(VEC_ADD)begin
VEC_ADD_REG = VEC_ADD;
end

always@(negedge INTA)begin
count = count + 1;
if(count == 1)begin 

	if(IRR[j] == 0)begin//if interrupt request was too short 
	j=7;
	end

	if(current_priority[3] == 1 || (current_priority[3] == 0 && ((priority_reg & 7<<(j*3) ) >>(j*3))> current_priority[2:0]))begin
						ISR[j]=1;
						IRR[j]=0;
						current_priority =  (priority_reg & 7<<(j*3) ) >>(j*3);
						interrupt_add = (VEC_ADD_REG<<3)+j;
	end

end
if(count == 2)begin
int_flag=1;
count = 0;

end
end

always@(posedge INTA)begin
int_flag=0;
if(count == 0)
INT = 0;
end

endmodule

