module datapath(input logic clk, reset, IorD, MemRead, MemWrite, MemToReg, 
                input logic IRWrite, ALUSrcA, RegWrite, RegDst, PCSel,
				input logic [1:0] PCSource,
                input logic [1:0] ALUSrcB,  
				input logic [3:0] ALUCtrl,
				output logic Zero,
				output logic [5:0] Op,
				output logic [5:0] Function);

	parameter PCSTART = 128; //starting address of instruction memory
	logic [7:0] PC;
	logic [31:0] ALUOut;
	logic [31:0] ALUResult;
	logic [31:0] OpA;
	logic [31:0] OpB;
	logic [7:0] PC_in;

	// Instruction memory and Data memory 
	logic [7:0]  memory [255:0];
	logic [7:0]  mem_address;
   logic [31:0] mem_data;
	
	initial
		$readmemh("mips_memory.dat", memory);
	
	//MULTI-CYCLE Stage Registers
	logic [31:0]Instruction; //IR  register
	logic [31:0]mdr;			 //mdr register
	logic [31:0]A;
	logic [31:0]B;
	// ALUOut is defined already
	
	//register file
	logic [31:0] registers[31:0];
	logic [31:0] da; //read data 1
	logic [31:0] db; //read data 2
	logic [31:0] RF_WriteData; // write data
	
	logic [4:0] RF_WriteAddr;

	
	
	
	assign mem_address = (IorD)? ALUOut:PC;  // DATA or Instruction
	assign Op = Instruction[31:26];
	assign Function = Instruction[5:0];
	////////////// MEMORY READ LOGIC //////////////

					
				assign	mem_data[31:24] = (MemRead)?memory[mem_address]   :8'bx ;
				assign	mem_data[23:16] = (MemRead)?memory[mem_address +1]:8'bx ;
				assign	mem_data[15:8]  = (MemRead)?memory[mem_address +2]:8'bx ;
				assign	mem_data[7:0]   = (MemRead)?memory[mem_address +3]:8'bx;
				

	////////////// MEMORY READ LOGIC //////////////

	
	
	
	////////////// MEMORY WRITE LOGIC //////////////
	always@(posedge clk) begin
		if (MemWrite) begin
			memory[mem_address ] <=  B[31:24];
			memory[mem_address+1] <= B[23:16];
			memory[mem_address+2] <= B[15:8];
			memory[mem_address+3] <= B[7:0];
		end
	end
	////////////// MEMORY WRITE LOGIC //////////////
	
	/////// IR MDR  //////
	always@(posedge clk)begin
		if(reset)begin
					Instruction <=0;
					mdr <=0;
					end
				
		else if(IRWrite)begin
				Instruction <= mem_data;
		end
		else begin
				mdr <= mem_data;
		end
		
	end
	
	//////// IR MDR //////
	
	
	
	////////////////////// REGISTER LOGIC //////////////////
	//$r0 is always 0
	assign da = (Instruction[25:21]!=0)? registers[Instruction[25:21]] : 0;
	assign db = (Instruction[20:16]!=0)? registers[Instruction[20:16]] : 0;
	assign RF_WriteData = (MemToReg) ? mdr : ALUOut;
	assign RF_WriteAddr = (RegDst) ? Instruction[15:11] : Instruction[20:16];

	// Register Write
	always @(posedge clk) begin
		if (RegWrite) begin
			registers[RF_WriteAddr] <= RF_WriteData;
		end
	end
	
	//A and B registers

	always @(posedge clk) begin
		if (reset)
			A <= 0;
		else
			A<=da;
	end

	always @(posedge clk) begin
		if (reset)
			B <= 0;
		else
			B<=db;
	end
////////////////////// REGISTER LOGIC //////////////////


//////////////////   ALU START  //////////////////
	
	//Mux1
	assign OpA = (ALUSrcA) ? A : PC;
	
	//Mux2
	always_comb
	begin
		case(ALUSrcB)
		2'b00:OpB=B;
		2'b01:OpB=4;
		2'b10:OpB={{(16){Instruction[15]}},Instruction[15:0]};
		2'b11:OpB={{(14){Instruction[15]}},Instruction[15:0],2'b00};
		endcase
	end
	/////
	
	///// Zero Flag
	assign Zero = (ALUResult==0); //Zero == 1 when ALUResult is 0 (for branch)
///// ALU Unit
	always_comb
	begin
		case(ALUCtrl)
		4'b0000: ALUResult = OpA & OpB;
		4'b0001: ALUResult = OpA | OpB;
		4'b0010: ALUResult = OpA + OpB;  //OpA ^ OpB; //XOR
		4'b0011: ALUResult = ~(OpA | OpB);   //NOR
		4'b0110: ALUResult = OpA - OpB;     //OpA + OpB;
		//4'b1110: // ALUResult = OpA - OpB;
		//4'b1111: // ALUResult = OpA < OpB?1:0;
		default: ALUResult = OpA + OpB;
		endcase
	end
/////
	always@(posedge clk)begin
		if (reset) ALUOut<= 0;
		else ALUOut<=ALUResult;
		
	end
//////////////////////   ALU OVER      ///////////////////




/////////// PC LOGIC //////////

always_comb
	begin
	PC_in = 0;
		case(PCSource)
		2'b00:PC_in = ALUResult;
		2'b01:PC_in = ALUOut;
		2'b10:PC_in = Instruction[25:0];
		endcase
	end
always@(posedge clk)begin

		if (reset) begin
		PC <= 128;
		end
		else if (PCSel)begin
		PC <= PC_in;
		end
	
end
	
	
// Show content of $s0 $s1 $s2
	logic [31:0]s0_content;
	logic [31:0]s1_content;
	logic [31:0]s2_content;
	assign s0_content = registers[16];
	assign s1_content = registers[17];
	assign s2_content = registers[18];
	
	
	logic [31:0]mem_content1; // 8
	logic [31:0]mem_content2; // 12
	logic [31:0]mem_content3;
	logic [31:0]mem_content4;
	logic [31:0]mem_content5;
	logic [31:0]mem_content6; //100
	logic [31:0]mem_content7; // 96
	logic [31:0]mem_content8;
	logic [31:0]mem_content9;
	logic [31:0]mem_content10;
	
	assign mem_content1[31:24] =   memory[8];
	assign mem_content1[23:16] =   memory[8+1];
	assign mem_content1[15:8]  =   memory[8+2];
	assign mem_content1[7:0]   =   memory[8+3];
	
	assign mem_content2[31:24] =   memory[12];
	assign mem_content2[23:16] =   memory[12+1];
	assign mem_content2[15:8]  =   memory[12+2];
	assign mem_content2[7:0]   =   memory[12+3];
	
	assign mem_content3[31:24] =   memory[16];
	assign mem_content3[23:16] =   memory[16+1];
	assign mem_content3[15:8]  =   memory[16+2];
	assign mem_content3[7:0]   =   memory[16+3];
	
	assign mem_content4[31:24] =   memory[20];
	assign mem_content4[23:16] =   memory[20+1];
	assign mem_content4[15:8]  =   memory[20+2];
	assign mem_content4[7:0]   =   memory[20+3];
	
	assign mem_content5[31:24] =   memory[24];
	assign mem_content5[23:16] =   memory[24+1];
	assign mem_content5[15:8]  =   memory[24+2];
	assign mem_content5[7:0]   =   memory[24+3];
	
	
	assign mem_content6[31:24] =   memory[100];
	assign mem_content6[23:16] =   memory[100+1];
	assign mem_content6[15:8]  =   memory[100+2];
	assign mem_content6[7:0]   =   memory[100+3];
	
	assign mem_content7[31:24] =   memory[96];
	assign mem_content7[23:16] =   memory[96+1];
	assign mem_content7[15:8]  =   memory[96+2];
	assign mem_content7[7:0]   =   memory[96+3];
	
	assign mem_content8[31:24] =   memory[92];
	assign mem_content8[23:16] =   memory[92+1];
	assign mem_content8[15:8]  =   memory[92+2];
	assign mem_content8[7:0]   =   memory[92+3];
	
	assign mem_content9[31:24] =   memory[88];
	assign mem_content9[23:16] =   memory[88+1];
	assign mem_content9[15:8]  =   memory[88+2];
	assign mem_content9[7:0]   =   memory[88+3];
	
	assign mem_content10[31:24] =   memory[84];
	assign mem_content10[23:16] =   memory[84+1];
	assign mem_content10[15:8]  =   memory[84+2];
	assign mem_content10[7:0]   =   memory[84+3];
	
	
endmodule
