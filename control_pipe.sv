module control (input logic [5:0] Op,
				output logic MemRead, MemWrite, MemToReg, ALUSrc,
				output logic RegWrite, RegDst, Branch, Jump,
				output logic [1:0] ALUOp);

	always_comb
	begin 
				  MemRead = 1'b0;  
				  MemWrite = 1'b0;  
                  MemToReg = 1'b0;  
                  ALUSrc = 1'b0;  
                  RegWrite = 1'b0;  
                  RegDst = 1'b0;  
                  Branch = 1'b0;  
                  Jump = 1'b0;  
                  ALUOp = 2'b00;		
      case(Op)   
      6'b000000: begin // R-type  
                  RegWrite = 1'b1;  
                  RegDst = 1'b1;  
                  ALUOp = 2'b10;   
                  end  
      6'b100011: begin // lw  
						MemRead = 1'b1;   
                  MemToReg = 1'b1;  
                  ALUSrc = 1'b1;  
                  RegWrite = 1'b1;    
                  end  
      6'b101011: begin // sw  
				  MemWrite = 1'b1;     
                  ALUSrc = 1'b1;     
                  end 
      6'b000100: begin // beq 
				  Branch = 1'b1;     
                  ALUOp = 2'b01; 				  
                  end 
      6'b000010: begin // jump
				  Jump = 1'b1;     				  
                 end 
      endcase
    end
endmodule
