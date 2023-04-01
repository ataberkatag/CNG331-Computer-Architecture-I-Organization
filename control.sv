module control (input logic clk, reset, Zero,
                input logic [5:0] Op, 
                output logic IorD, MemRead, MemWrite, MemToReg, IRWrite,
                output logic ALUSrcA, RegWrite, RegDst, PCSel,
                output logic [1:0] PCSource,
                output logic [1:0] ALUSrcB,
                output logic [1:0] ALUOp);


reg [3:0]state;
reg [3:0]next_state;

parameter S0=4'b0000; 
parameter S1=4'b0001; 
parameter S2=4'b0010; 
parameter S3=4'b0011; 
parameter S4=4'b0100; 
parameter S5=4'b0101; 
parameter S6=4'b0110; 
parameter S7=4'b0111; 
parameter S8=4'b1000;
parameter S9=4'b1001;

always@(posedge clk or posedge reset)begin
if(reset) state<=S0;
else  state<=next_state;

end

always_comb // next state assignment
begin
     next_state=S0;
	  
     ALUOp = 0;
     ALUSrcB = 0;
     PCSource = 0;
     ALUSrcA = 0;
     PCSel = 0;
     IRWrite = 0;
     MemWrite = 0;
	  MemRead = 0;
     RegWrite = 0;
     RegDst = 0;
     MemToReg = 0;
     IorD = 0;
	  
 case(state)
 S0: begin 
            next_state=S1;
            IorD = 0;
            MemRead = 1;
            IRWrite = 1;
            ALUSrcA = 0;
            ALUSrcB = 2'b01;
            PCSource = 2'b00;
            ALUOp = 2'b00;
            PCSel = 1;
            
        
 end
 S1: begin
           ALUSrcA = 0;
            ALUSrcB = 2'b11;
            ALUOp = 2'b00;
            PCSel = 0;
            if(Op == 6'b100011 || Op == 6'b101011)begin//lw or sw
                next_state = S2;
            end
            else if (Op == 6'b000000)begin
                next_state = S6;
            end
            else if(Op == 6'b000100)begin
                next_state = S8;
            end
            else if (Op == 6'b000010)begin
                next_state = S9;
            end
 end
 
 S2: begin
           ALUSrcA = 1;
            ALUSrcB = 2'b10;
            ALUOp = 2'b00;
            PCSel = 0;
            if(Op == 6'b100011) begin
                next_state = S3;
            end
            else if(Op == 6'b101011) begin
                next_state = S5;
            end
            
 end
 
 S3: begin
         next_state=S4;
           MemRead = 1;
            IorD = 1;
            PCSel = 0;
    
 end
 
 S4:begin
         next_state=S0;
           RegDst = 0;
            RegWrite = 1;
            MemToReg = 1;
            PCSel = 0;
 end
 
 S5:begin
         next_state=S0;
           MemWrite = 1;
            IorD = 1;
            PCSel = 0;
 end
 
 S6:begin
         next_state=S7;
           ALUSrcA = 1;
            ALUSrcB = 2'b00;
            ALUOp = 2'b10;
            PCSel = 0;
 end
 S7:begin
            next_state=S0;
            RegDst = 1;
            RegWrite = 1;
            MemToReg = 0;
            PCSel = 0;
 end
 S8:begin
            next_state=S0;
            ALUSrcA = 1;
            ALUSrcB = 2'b00;
            ALUOp = 2'b01;
            PCSource = 2'b01;
				if(Zero) begin
            PCSel <= 1;
				end
				else PCSel <=0;
				
				
 
 end 
 S9:begin
             next_state=S0;
            PCSource = 2'b10;
            PCSel = 1;
 end
endcase
end

endmodule