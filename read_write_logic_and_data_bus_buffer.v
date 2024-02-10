module Read_Write_Logic(   
			inout wire [7:0] internal_bus,
			input wire RD,
			input wire WR,
			input wire A0,
			input wire CS,
			input wire SP,
			output reg read_mode,//if mode = 0 read IRR else read ISR
			output [7:0] IMR,
      				
			output wire EOI_mode,//if 1 AEOI else EOI
			output[4:0] VEC_ADD,
			output[2:0] int_level,
			output[2:0] EOI_command,
			output LTIM,
			output reg EOI_command_updated,
			output SNGL,
			output reg[7:0] ICW3
);
reg[7:0] ICW1;
reg [7:0]ICW2;
reg[7:0] ICW4;
reg[7:0] OCW1;
reg[7:0] OCW2;
reg[7:0] OCW3;
reg ICW_done=0;
reg ICW2_done=0;
reg ICW3_done=0;


assign SNGL = ICW1[1];
assign EOI_mode = ICW4[1];
assign VEC_ADD[4:0] = ICW2[7:3];
assign IMR = OCW1;
assign int_level = OCW2[2:0];
assign EOI_command = OCW2[7:5];
assign LTIM = ICW1 [3];


 
always@(CS,WR,A0,RD,internal_bus)begin
if(!CS && !WR && RD && ~A0 && internal_bus[4])begin	//ICW1
ICW1[7:0] = {internal_bus[7:5], 1'b0 ,internal_bus[3:0]};
ICW_done = 0;
read_mode=0;
OCW1 = 0;
EOI_command_updated=0;
if(ICW1[0] == 1'b0)
ICW4 [7:0] = 0;
end
else if(!CS && !WR && RD && A0 && !ICW_done && !ICW2_done )begin	//ICW2
ICW2[7:0] = {internal_bus[7:3],3'b000}; 
if(ICW1[1:0] == 2'b10 )
ICW_done = 1;
ICW2_done=1;
end
else if(!CS && !WR && RD && A0 && !ICW1[1] && !ICW_done && ICW2_done && !ICW3_done )begin //ICW3
if(SP)begin
ICW3[7:0] = internal_bus[7:0];
end
if(!SP)begin
ICW3[7:0] = {5'b00000 , internal_bus[2:0]};
end
if(ICW1[0] == 1'b0)
ICW_done = 1;
ICW3_done = 1;
end
else if(!CS && !WR && RD && A0 && ICW1[0] && !ICW_done && ICW2_done  )begin //ICW4
ICW4[7:0] = {3'b000 , internal_bus[4:0]};
ICW_done = 1;
end
else if(!CS && !WR && RD && A0 && ICW_done) //OCW1
OCW1[7:0] = internal_bus[7:0];

else if(!CS && !WR && RD && !A0 && ICW_done && !internal_bus[3])begin //OCW2
OCW2[7:0] = {internal_bus[7:5],2'b00,internal_bus[2:0] };
EOI_command_updated = EOI_command_updated ^ 1;
end

else if(!CS && !WR && RD && !A0 && ICW_done && internal_bus[3]) //OCW3
OCW3[7:0] = {1'b0, internal_bus[6:5] ,2'b00,internal_bus[2:0] };

if(OCW3[1:0] == 2'b11)begin//read ISR
read_mode = 1;
end
if(OCW3[1:0] == 2'b10)begin //read IRR
read_mode = 0;
end
end
endmodule






module Bi_directional_Tri_state_buffer(inout [7:0]CPU_io , inout [7:0]internal_bus , input WR ,input RD , input E,
input int_flag); 
assign internal_bus = (!WR && !E) ? CPU_io : 8'bz;  
assign CPU_io = ((!RD && !E) || int_flag)  ? internal_bus : 8'bz;
endmodule
