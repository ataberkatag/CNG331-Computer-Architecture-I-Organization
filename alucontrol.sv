module alucontrol (input logic [1:0]ALUOp,input logic [5:0]Function,output logic [3:0]ALUCtrl);


always_comb begin
		ALUCtrl=0;
		case(ALUOp)
		
		2'b00: ALUCtrl = 4'b0010;
		
		2'b01: ALUCtrl = 4'b0110;
		
		2'b10: begin
		
			if(Function==6'b100000)begin
					ALUCtrl = 4'b0010;
			end
			else if(Function==6'b100010)begin
					ALUCtrl = 4'b0110;
			end
			else if(Function==6'b100100)begin
					ALUCtrl = 4'b0000;
			end
			else if(Function==6'b100101)begin
					ALUCtrl = 4'b0001;
			end
			else if(Function==6'b101010)begin
					ALUCtrl = 4'b1111;
			end
		
		end
		
		endcase

    end    
endmodule