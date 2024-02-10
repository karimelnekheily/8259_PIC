
module interrupt_handler(	input [7:0]IRQs ,inout [7:0] internal_bus ,input [7:0] OCW1,
							input RD,input A0,input EOI_mode,//if 1 AEOI else EOI
							output reg INT = 0  ,input INTA,input[4:0] VEC_ADD,
							input read_mode , input [2:0] int_level , //from ocw2 
/*what type of eoi command*/input [2:0] EOI_command , input LTIM , //level or edge
	/*from ocw2*/			output reg int_flag = 0 , input EOI_command_updated );//used to enter always block if EOI got updated 
							//used to output on internal bus
reg [7:0]IRR;
reg [7:0]ISR=0;
reg [7:0]IMR;
reg [4:0]VEC_ADD_REG;
reg [7:0]write_buffer;
reg [7:0]interrupt_add;

reg rotate_in_AEOI_flag;
reg rotate_mode_flag; 

//bits from 0 to 24 are used to store priority for each IRQ 
//the rest are reserved
integer default_priority = 32'b1111_1010_1100_0110_1000_1000; //each 3 bits from right to left determine priority of 1 bit 
															  //of IR (24bits) (8*3)


reg [31:0] priority_reg = 32'b1111_1010_1100_0110_1000_1000;
reg [3:0] current_priority = 4'b1000; //the current operating priority , the default when none is working is 1000 (out of 3 bits index)
reg nested_higher_prio_finish=0; //signal that a nested interrupt finished to enter always block
integer i; 
integer count=1;//count of negative edges of INTA
integer j; //variable that detects IR high bits 
integer k; 
integer c=7; //variable tracks the higher priority IRQs that came through IR
integer base_index; //variable used to be able to use rotation mode 


assign internal_bus = (!RD && A0) ? IMR : (!RD && !A0)? write_buffer : (int_flag) ? interrupt_add : 8'bz ;

always@(priority_reg)begin
	if(priority_reg != default_priority) //if i changed default priority then im in rotate mode
		rotate_mode_flag = 1;
	else
		rotate_mode_flag = 0;

end



always@(read_mode , IRR , ISR)begin
	if(read_mode == 0) //this determines which to read IRR or ISR
		write_buffer = IRR;
	else
		write_buffer = ISR;
end

always@(OCW1)begin //take value from OCW1 and add it to IMR
	IMR=OCW1;
end

always@(IRQs)begin //IRQs is input interrupt and IRR is internal reg containing the interrupt
	IRR = IRQs;
end

always@(VEC_ADD)begin //the ICW2 address part (5 bits)
	VEC_ADD_REG = VEC_ADD;
end

always@(negedge INTA)begin //what happens when INTA comes 
count = count + 1;
if(count == 2)begin 

	if(IRR[j] == 0)begin//if interrupt request was too short set prio to lowest
	j=7;
	end
				//if none was working or a lowest prio was working .. take its place
	if(current_priority[3] == 1 || (current_priority[3] == 0 && ((priority_reg & 7<<(j*3) ) >>(j*3))< current_priority[2:0]))begin
						ISR[j]=1;
						IRR[j]=0;
						current_priority =  (priority_reg & 7<<(j*3) ) >>(j*3); 
						interrupt_add = (VEC_ADD_REG<<3)+j;
	end

end
if(count == 3)begin //when at second negative edge of INTA check on EOI mode if AEOI reset , set base index to be able to rotate
	int_flag=1;
	count = 1;
	if(EOI_mode == 1)begin
		ISR[j] = 0;
		current_priority = 4'b1000; //return to default prio (i finished)
		if(rotate_in_AEOI_flag)begin
		
			priority_reg =(default_priority << 3*(j+1)) | (default_priority >> (24 - 3*(j+1)));
			if(j==7)
				base_index=0; //rotate to bit 0 (case bit 7 was currently being serviced)
			else
				base_index=j+1; //rotate to bit j+1 (normal case)
		end
	end

end
end

always@(posedge INTA)begin

	int_flag=0;
	if(count == 1)begin
		INT = 0; //set to zero at the second positive edge 
		if(c<7)begin //set the interrupting prio to lowest priority
			c=7;
		end

		if(LTIM == 1)begin //if level mode if Interrupt is still one Set its IRR to 1 if if it was reset to zero
			if(IRQs[j] == 1)
			IRR[j] = 1;
		end

		nested_higher_prio_finish=nested_higher_prio_finish ^ 1 ; //keep rechecking if there are unserviced interrupts in IRR

	end

end


always@(IRR , IMR ,nested_higher_prio_finish)begin //check on masking and IRR bits
  
  if(INT==1)begin   //if INT =1 then some interrupt interrupted me
                    //j now carries the int that is being done
	if(rotate_mode_flag == 0)begin //non rotate mode
	 for(i=0;i<=7;i=i+1)begin
		if(IRR[i] == 1 && IMR[i] !=1)begin
		c=i;
		if(c<j)begin//higher prio interrupted me
		  count=0;
		  IRR[j]=1; //set the lower prio IRR to 1 (it is still unserviced)  
		  j=c; //set the interrupt being serviced now to the higher priority interrupt
		  int_flag=0; //dont output on address bus yet (wait)
		  i=8; //break out of for loop
		 end
		 else begin
		    c=7; //if non higher prio set c to lowest priority 
			if(LTIM == 0)
			IRR[j]=0; //if edge mode set IRR to zero
		end
		end
	 end
	end

	else begin //rotate mode
		 for(i=base_index;i<8;i=i+1)begin
			if(IRR[i] == 1 && IMR[i] !=1)begin
				count=0;
				IRR[j]=1; //set its IRR to 1 (meaning : it isn't dont yet )  
				j=i;
				int_flag=0;
				i=8;
			end
			else begin
				if(LTIM == 0)
					IRR[j]=0; //if edge mode set IRR to 0
			end
		end
	 end


	


  end
	
	
	else begin //not interrupted
		if(rotate_mode_flag == 0)begin //if fully nested mode
			for(i=0;i<=7;i=i+1)begin //just check on bits from LSB to MSB
				if(IRR[i] == 1 && IMR[i] !=1)begin
				INT = 1;
				j=i;
				i=8; //break if found any interrupts
				end
			end
		end

		else begin //if rotation mode
			for(i=j+1;i<8;i=i+1)begin //start from rotation index 
				if(IRR[i] == 1 && IMR[i] !=1)begin
					INT = 1;
					j=i;
					i=8;
				end
				if(i == 7) //transition from bit 7 to bit 0
					i=-1;

				if(i == j)	
					i=8;   //break condition 

			end

		end
	end

end

always@(EOI_command_updated)begin
	if(EOI_command == 3'b001)begin	//non specific EOI
		for(k=0;k<=7;k=k+1)begin
			if(ISR[k] == 1)begin
				ISR[k] = 0; //set the ISR of the current to 0
				k=8;  		//break
			end
		
		end
	end
	if(EOI_command == 3'b011)begin	//specific EOI
		ISR[int_level] = 0;			//set ISR of specified bit to 0
	end

	if(EOI_command == 3'b101)begin	//rotate on non specific EOI
		for(k=0;k<=7;k=k+1)begin
			if(ISR[k] == 1)begin //if being serviced set its ISR to 0 and rotate the priority reg
				ISR[k] = 0;
				priority_reg =(default_priority << 3*(k+1)) | (default_priority >> (24 - 3*(k+1)));
			if(k==7)
				base_index=0; //set the rotation index
			else
				base_index=k+1; 
				k=8; //break
			end
		end
	end
	
	if(EOI_command == 3'b111)begin //rotate on specific EOI
		ISR[int_level] = 0; //reset isr of specified bit
		priority_reg =(default_priority << 3*(int_level+1)) | (default_priority >> (24 - 3*(int_level +1) )); //rotate specified bit
	if(int_level==7)
		base_index=0;
	else
		base_index=int_level+1;
	end
	
	if(EOI_command == 3'b110)begin//set priority level (rotate without reseting isr)
		priority_reg =(default_priority << 3*(int_level+1)) | (default_priority >> (24 - 3*(int_level +1) ));
	if(int_level==7)
		base_index=0;
	else
		base_index=int_level+1;
	end

	if(EOI_command == 3'b100)begin//set rotate on AEOI //set rotate mode
		rotate_in_AEOI_flag = 1;
	end
	
	if(EOI_command == 3'b000)begin//reset rotate on AEOI
		rotate_in_AEOI_flag = 0;
	end

end

endmodule


