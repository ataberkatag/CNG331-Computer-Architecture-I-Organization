module mips_pipe(input logic clk,
               input logic reset,
			   output logic [5:0] Opcode_Out);

	logic [5:0] Op;
	logic MemRead;
	logic MemWrite;
	logic MemToReg;
	logic ALUSrc;
	logic RegWrite;
	logic RegDst;
	logic Branch;
	logic Jump;
	logic [1:0] ALUOp;

	

	control u0(.Op(Op), .MemRead(MemRead), .MemWrite(MemWrite), .MemToReg(MemToReg), .ALUSrc(ALUSrc), 
				.RegWrite(RegWrite), .RegDst(RegDst), .Branch(Branch), .Jump(Jump), .ALUOp(ALUOp));

	datapath u1(.clk(clk), .reset(reset), .Op(Op), .MemRead(MemRead), .MemWrite(MemWrite), .MemToReg(MemToReg), 
				.ALUSrc(ALUSrc), .RegWrite(RegWrite), .RegDst(RegDst), .Branch(Branch), .Jump(Jump),  
				.ALUOp(ALUOp));
assign Opcode_Out = Op;
endmodule

