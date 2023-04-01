module datapath(input logic clk, reset, MemRead, MemWrite, MemToReg, 
                input logic ALUSrc, RegWrite, RegDst, Branch, Jump,
				input logic [1:0] ALUOp,
				output logic [5:0] Op);

	parameter PCSTART = 0; //starting address of instruction memory
	
	// Instruction memory internal storage, input address and output data bus signals
	logic [7:0] instmem [127:0];
	logic [6:0] instmem_address;
   logic [31:0] instmem_data;
	
	// Data memory internal storage, input address and output data bus signals
	logic [7:0] datamem [127:0];
	logic [6:0] datamem_address;
	logic [31:0] datamem_data;	
	
	// ... may have other logic signal declarations here
	
	logic [31:0] PC = PCSTART;
	logic PCenable;
	bit PCSel;
	logic [31:0]PC_plus_4;
	logic [31:0] WriteDataBack;
	logic JumpFlag;
	logic [25:0] JumpAddress;
	logic IF_Flush;
	logic IF_hold;
	bit zeroflag=0;
	logic [31:0]branchaddress;
	// IF/ID Pipeline staging register fields can be represented using structure format of System Verilog
	// You may refer to the first field in the structure as IfId.instruction for example
	struct {
		logic [31:0] instruction;
		logic [31:0] PCincremented;
		logic [4:0] RegisterRs;
		logic [4:0] RegisterRt;
		logic [4:0] RegisterRd;
	} IfId;
	
	
	
	// ID/EX Pipeline staging register
	struct {
		logic [31:0] R_data1;
		logic [31:0] R_data2;
		logic [31:0] PC_plus_4;
		logic [31:0] sign_ext_branch_offset;
		logic [4:0] RegisterRd;
		logic [4:0] RegisterRt;
		logic [4:0] RegisterRs;
		logic [31:0] BranchAddress;
		bit zeroflag;
		logic [1:0]ALUOp;
		logic RegWrite;
		logic RegDst;
		logic ALUSrc;
		logic MemWrite;
		logic MemRead;
		logic Branch;
	
		logic MemToReg; 		// MemtoReg

	}IdEx;
	//assign IdEx.RegisterRs = IfId.RegisterRs;
	
	// EX/MEM Pipeline staging register
	struct {
		//logic [31:0] BranchAddress;
		//bit zeroflag;
		logic [31:0] AluOut;
		logic [31:0] ForwardB; // ReadData2
		logic [4:0] Reg_dest_addr_result;
		logic [4:0] RegisterRd;
		
		logic MemToReg; 		// MemtoReg
		logic MemWrite;
		logic MemRead;
		logic Branch;
		logic RegWrite;
	} ExMem;
	
	
	// MEM/WB Pipeline staging register
	struct {
	
	logic [31:0] AluOut;
	logic [31:0] Mem_data;
	logic [4:0] Reg_dest_addr_result;
	logic MemToReg; 
	logic RegWrite;	
	} memWB;
	
	// Register File description
	logic [31:0] RF[31:0];
	logic [31:0] da; //read data 1
	logic [31:0] db; //read data 2
	logic [31:0] RF_WriteData; // write data
	
	logic [4:0] RF_WriteAddr;
	logic [4:0] Read_addr1;
	logic [4:0] Read_addr2;
	// ... may have other declarations
	
	// initialize instruction and data memory arrays
	// this will read the .dat file in the same directory
	// and initialize the memory accordingly.
	initial
		$readmemh("instruction_memory.dat", instmem);
	initial
		$readmemh("data_memory.dat", datamem);

	// Instruction Memory Address
	assign instmem_address = PC;

	// Instruction Memory Read Logic
	assign instmem_data[31:24] = instmem[instmem_address];
	assign instmem_data[23:16] = instmem[instmem_address+1];
	assign instmem_data[15:8] = instmem[instmem_address+2];
	assign instmem_data[7:0] = instmem[instmem_address+3];
	

	// Data	Memory Address
	assign datamem_address = ExMem.AluOut;
	
	// Data Memory Write Logic
	always @(posedge clk) begin
		if (ExMem.MemWrite) begin
			datamem[datamem_address] <= ExMem.ForwardB[31:24];
			datamem[datamem_address+1] <= ExMem.ForwardB[23:16];
			datamem[datamem_address+2] <= ExMem.ForwardB[15:8];
			datamem[datamem_address+3] <= ExMem.ForwardB[7:0];
		end
	end

	// Data Memory Read Logic
	assign datamem_data[31:24] = (ExMem.MemRead)? datamem[datamem_address]:8'bx;
	assign datamem_data[23:16] = (ExMem.MemRead)? datamem[datamem_address+1]:8'bx;
	assign datamem_data[15:8] = (ExMem.MemRead)? datamem[datamem_address+2]:8'bx;
	assign datamem_data[7:0] = (ExMem.MemRead)? datamem[datamem_address+3]:8'bx;
	
	// Show content of $s0 $s1 $s2
	logic [31:0]s0_content;
	logic [31:0]s1_content;
	logic [31:0]s2_content;
	assign s0_content = RF[16];
	assign s1_content = RF[17];
	assign s2_content = RF[18];
	
	
	logic [31:0]mem_content1; //8
	logic [31:0]mem_content2; //12
	logic [31:0]mem_content3; //16
	logic [31:0]mem_content4; //20
	logic [31:0]mem_content5; //24
	logic [31:0]mem_content6;  // 100
	logic [31:0]mem_content7;  // 96
	logic [31:0]mem_content8;  // 92
	logic [31:0]mem_content9;  // 88
	logic [31:0]mem_content10; // 84
	
	assign mem_content1[31:24] =   datamem[8];
	assign mem_content1[23:16] =   datamem[8+1];
	assign mem_content1[15:8]  =   datamem[8+2];
	assign mem_content1[7:0]   =   datamem[8+3];
	
	assign mem_content2[31:24] =   datamem[12];
	assign mem_content2[23:16] =   datamem[12+1];
	assign mem_content2[15:8]  =   datamem[12+2];
	assign mem_content2[7:0]   =   datamem[12+3];
	
	assign mem_content3[31:24] =   datamem[16];
	assign mem_content3[23:16] =   datamem[16+1];
	assign mem_content3[15:8]  =   datamem[16+2];
	assign mem_content3[7:0]   =   datamem[16+3];
	
	assign mem_content4[31:24] =   datamem[20];
	assign mem_content4[23:16] =   datamem[20+1];
	assign mem_content4[15:8]  =   datamem[20+2];
	assign mem_content4[7:0]   =   datamem[20+3];
	
	assign mem_content5[31:24] =   datamem[24];
	assign mem_content5[23:16] =   datamem[24+1];
	assign mem_content5[15:8]  =   datamem[24+2];
	assign mem_content5[7:0]   =   datamem[24+3];
	
	
	assign mem_content6[31:24] =   datamem[100];
	assign mem_content6[23:16] =   datamem[100+1];
	assign mem_content6[15:8]  =   datamem[100+2];
	assign mem_content6[7:0]   =   datamem[100+3];
	
	assign mem_content7[31:24] =   datamem[96];
	assign mem_content7[23:16] =   datamem[96+1];
	assign mem_content7[15:8]  =   datamem[96+2];
	assign mem_content7[7:0]   =   datamem[96+3];
	
	assign mem_content8[31:24] =   datamem[92];
	assign mem_content8[23:16] =   datamem[92+1];
	assign mem_content8[15:8]  =   datamem[92+2];
	assign mem_content8[7:0]   =   datamem[92+3];
	
	assign mem_content9[31:24] =   datamem[88];
	assign mem_content9[23:16] =   datamem[88+1];
	assign mem_content9[15:8]  =   datamem[88+2];
	assign mem_content9[7:0]   =   datamem[88+3];
	
	assign mem_content10[31:24] =   datamem[84];
	assign mem_content10[23:16] =   datamem[84+1];
	assign mem_content10[15:8]  =   datamem[84+2];
	assign mem_content10[7:0]   =   datamem[84+3];
	

	
	
	//PC logic
	//assign PCSel = IdEx.Branch & zeroflag ; değişti
	always@(posedge clk)begin
		if(zeroflag && Branch)begin
		PCSel <=1'b1;
		end
		else PCSel <=1'b0;
	end
	always_comb
	begin
		PC_plus_4 = PC + 4 ;
	end
	
	always@ (negedge clk)begin


		if(reset)begin
			PC <= PCSTART;
			end
		else begin
		if (PCenable || PCSel) begin
				case (PCSel)
				
					1'b0: 	begin
							if(IdEx.Branch) begin
								// Wait
							end
							else if(instmem_data[31:26]==6'b000010) begin
							PC <= instmem_data[25:0];
							end
							else begin
							PC <= PC_plus_4;
							end
						end  
						
					1'b1: 	begin // branch
							PC <= branchaddress;
							end	
					endcase
				
		end
	end
end
	
	
	// Hazard Detection Unit
	always_comb
	begin
		IF_Flush = 1'b0;
		PCenable = 1'b1;
		//JumpAddress = 0;
		//JumpFlag =1'b0;
		IF_hold = 1'b0;
	
	//////////////////// Branch Detection
	if(Branch)begin
		PCenable = 1'b0; // değişti
		IF_Flush = 1'b1;
	end
	
	else if (IdEx.Branch) begin
		//PCenable = 1'b1;
		IF_Flush = 1'b1;
	end
	
	/////////////////// Jump detection
		else if(JumpFlag)begin		
		//JumpAddress  = IfId.instruction[25:0];
		//IF_Flush =1'b1;
		//JumpFlag =1'b1;
		end
		// 
	/////////////////// Load-use Detection
		else if (IdEx.MemRead && ((IdEx.RegisterRt == IfId.RegisterRs) || (IdEx.RegisterRt == IfId.RegisterRt)))begin
			PCenable  =1'b0;
			//IF_Flush  =1'b1;
			IF_hold   =1'b1;
			
		end
		
		/*
		else begin
	   IF_Flush  =1'b0;
		JumpFlag	 =1'b0;
		JumpAddress = 0;
		IF_hold = 1'b0;
		PCenable  =1'b1;
		end
		*/
		
	end
	//
	
	
	
	assign Op = (IfId.instruction[31:26]);
	 //Filling IF/ID
always@(negedge clk)begin //posedge reset , posedge IF_Flush, posedge IF_hold

		
	if	(IF_Flush || reset)begin
			IfId.instruction 	 <= 32'b0;
			IfId.PCincremented <= 32'b0;
			IfId.RegisterRs <= 5'b0;
			IfId.RegisterRt <= 5'b0;
			JumpFlag <=1'b0;
			end
	else if(IF_hold)begin
		// Do nothing, hold the previous value
		
			end
	
	
	else	if(instmem_data[31:26]==6'b000010) begin
			//JumpAddress  <= instmem_data[25:0];
			JumpFlag <=1'b1;
			IfId.instruction 	 <= 32'b0;
			IfId.PCincremented <= 32'b0;
			IfId.RegisterRs <= 5'b0;
			IfId.RegisterRt <= 5'b0;
			IfId.RegisterRd <= 0;
			end
	else begin
			IfId.instruction <= instmem_data;
			IfId.PCincremented <= PC_plus_4;
			IfId.RegisterRs <= instmem_data[25:21];
			IfId.RegisterRt <= instmem_data[20:16];
			IfId.RegisterRd <= instmem_data[15:11];
			JumpFlag <=1'b0;
	end
		
	
		
	end

	

	//
	
	// Read Register file
	assign Read_addr1 = IfId.instruction[25:21];
	assign Read_addr2 = IfId.instruction[20:16];
	assign RF_WriteData = WriteDataBack;
	assign RF_WriteAddr = memWB.Reg_dest_addr_result;
	
	//Read Register file $r0 is always 0

	 assign da = (IfId.instruction[25:21]!=0)? RF[Read_addr1]: 0;
	 assign db = (IfId.instruction[20:16]!=0)? RF[Read_addr2]: 0;
	
	
	
	
	
	// Write to Register file
	
	always @(posedge clk) begin
		if (memWB.RegWrite) begin
			RF[RF_WriteAddr] <= RF_WriteData;
		end
	end
	
	//


	//Filling ID/EX 	
	always@ (negedge clk)begin  // or posedge ExMem.Branch or posedge reset
		
		if(reset || IF_hold)begin // || ExMem.Branch 
			IdEx.MemToReg <= 0;
			IdEx.RegDst <= 0;
			IdEx.ALUSrc <= 0;
			IdEx.MemWrite <= 0;
			IdEx.MemRead <= 0;
			IdEx.Branch <= 0;
			IdEx.ALUOp <= 0;
			IdEx.RegisterRd <= 0;
			IdEx.RegisterRt <= 0;
			IdEx.RegisterRs <= 0;
			IdEx.sign_ext_branch_offset <= 0;
			IdEx.PC_plus_4 <= 0;
			IdEx.R_data1 <= 0;
			IdEx.R_data2 <= 0;	
			IdEx.RegWrite <= 0;
		end
		else begin
		IdEx.MemToReg <= MemToReg;
		IdEx.RegDst <= RegDst;
		IdEx.ALUSrc <= ALUSrc;
		IdEx.MemWrite <= MemWrite;
		IdEx.MemRead <= MemRead;
		IdEx.Branch <= Branch;
		IdEx.ALUOp <= ALUOp;
		IdEx.RegWrite <=RegWrite;
		IdEx.RegisterRd <= IfId.instruction[15:11]; // Rd
		IdEx.RegisterRt <= IfId.instruction[20:16]; // Rt
		IdEx.RegisterRs <= IfId.instruction[25:21]; // Rs
		IdEx.sign_ext_branch_offset <= 32'(signed'(IfId.instruction[15:0]));
		IdEx.PC_plus_4 <= IfId.PCincremented;
		
		IdEx.R_data1 <= da ;
		IdEx.R_data2 <= db ;
		end
		
	end
	//
	
	
	
	/////////////// Forward Unit EXECUTION STAGE
	logic [1:0]ForwardA ;
	logic [1:0]ForwardB ;
	always_comb//(ExMem.MemToReg or ExMem.RegisterRd or IdEx.RegisterRs or IdEx.RegisterRt)
	begin
	ForwardA = 2'b00;
	ForwardB = 2'b00;
	// EX/MEM Hazard
	if (ExMem.MemToReg && (ExMem.RegisterRd != 0) && (ExMem.RegisterRd == IdEx.RegisterRs))begin
	ForwardA <= 2'b10; // wb
	end
	if (ExMem.MemToReg && (ExMem.RegisterRd != 0) && (ExMem.RegisterRd == IdEx.RegisterRt))begin
	ForwardB <= 2'b10; // wb
	end
	//
	
	// MEM/WB Hazard
	if (memWB.MemToReg && (ExMem.RegisterRd != 0) && (ExMem.RegisterRd != IdEx.RegisterRs) && (ExMem.RegisterRd == IdEx.RegisterRs))
		begin
		ForwardA <= 2'b01; // ALUOut
		end
	if (ExMem.MemToReg && (ExMem.RegisterRd != 0) && (ExMem.RegisterRd != IdEx.RegisterRt) && (ExMem.RegisterRd == IdEx.RegisterRt)) 
	   begin
		ForwardB <= 2'b01; // ALUOut
		end
	end
		///////////////////
		
		///////////// Branch Evaluation
	always_comb begin
	zeroflag = 0;
	branchaddress = 0;
	if(IfId.instruction[31:26]==6'b000100)begin
	branchaddress = IfId.PCincremented + ((32'(signed'(IfId.instruction[15:0])))<<2);
	zeroflag = ((da-db)==0)? 1'b1:1'b0;
	end
end
	////////////

	/////////////////// ALU Stage
logic [31:0]ALU_in1; 	
logic [31:0]ALU_in2;
logic [31:0] ALUResult;

		always_comb
begin 
				ALU_in1 = 0;
				ALU_in2 = 0;
				ALUResult =	0;		
      case(ForwardA)   
      2'b00: begin //   
                  ALU_in1 = IdEx.R_data1;
                  end  
      2'b01: begin //   
						ALU_in1 = ExMem.AluOut;   
                  end  
      2'b10: begin //  
						ALU_in1 = WriteDataBack ;    
                  end 
      endcase
		case(ForwardB)   
      2'b00: begin //   
                  ALU_in2 = (IdEx.ALUSrc)? IdEx.sign_ext_branch_offset : IdEx.R_data2;
                  end  
      2'b01: begin //   
						ALU_in2 = (IdEx.ALUSrc)? IdEx.sign_ext_branch_offset : ExMem.AluOut;   
                  end  
      2'b10: begin //  
						ALU_in2 = (IdEx.ALUSrc)? IdEx.sign_ext_branch_offset : WriteDataBack ;    
                  end 
      endcase
		
	// ALU UNIT
		case(IdEx.ALUOp)   
      2'b00: begin //   
                  ALUResult = ALU_in1 + ALU_in2 ;
                  end  
      2'b01: begin //   
						ALUResult = ALU_in1 - ALU_in2 ; 
                  end  
      2'b10: begin //  
						ALUResult = ALU_in1 + ALU_in2 ;  
                  end 
			default: ALUResult = ALU_in1 + ALU_in2 ;
      endcase
	
 end
	
	
	////////////////////

	
	//////////////////Filling EX/MEM 	
	
	always@ (negedge clk)begin // or posedge reset
	
		if(reset)begin
			//ExMem.zeroflag <= 0;
			//ExMem.BranchAddress <= 0;
			ExMem.AluOut <= 0;
			ExMem.ForwardB <= 0;
			ExMem.Reg_dest_addr_result <= 0;
			ExMem.RegisterRd <= 0;
			ExMem.MemToReg <= 0;
			ExMem.MemWrite <= 0;
			ExMem.MemRead <= 0;
			ExMem.Branch <= 0;
			ExMem.RegWrite <=0;
			
		end
		else begin
		
		ExMem.AluOut <= ALUResult;
		ExMem.ForwardB <= IdEx.R_data2; // ReadData2
		ExMem.Reg_dest_addr_result <= (IdEx.RegDst)? IdEx.RegisterRd:IdEx.RegisterRt; 
		ExMem.RegisterRd <= IdEx.RegisterRd;
		
		ExMem.MemToReg <= IdEx.MemToReg;		
		ExMem.MemWrite <= IdEx.MemWrite;
		ExMem.MemRead 	<=	IdEx.MemRead;
		ExMem.Branch   <= IdEx.Branch;
		ExMem.RegWrite <= IdEx.RegWrite;
		
		end
		
	end
	////////////////////
	
	
	///////// Filling MEM/WEB
	always@ (negedge clk)begin // 
	
	if(reset)begin
			memWB.AluOut <= 0;
			memWB.Mem_data <= 0;
			memWB.Reg_dest_addr_result <= 0;
			memWB.MemToReg <= 0;
			memWB.RegWrite <=0;
		end
		else begin
	
	memWB.AluOut <= ExMem.AluOut;
	memWB.Mem_data <= datamem_data ;
	memWB.Reg_dest_addr_result <= ExMem.Reg_dest_addr_result ;
	memWB.MemToReg <= ExMem.MemToReg;
	memWB.RegWrite <=ExMem.RegWrite;	
		end
	end
   ////////
	
	assign WriteDataBack = (memWB.MemToReg)? memWB.Mem_data:memWB.AluOut;
	
	
	
endmodule
