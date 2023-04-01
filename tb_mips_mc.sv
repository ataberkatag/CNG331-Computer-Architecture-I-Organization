module tb_mips_mc;

	logic clk;
    logic reset;
	logic [5:0] Opcode_Out;
	mips_mc uut(clk, reset, Opcode_Out);
	
	// Clock Generator
  always		// infinite loop for clock
  begin
	#10000         	// creating delay for clock
	clk = 1'b1;	    // after 10000 time unit delay, clock goes high.
	#10000			// creating delay for clock
	clk = 1'b0;		// after 10000 time unit delay, clock goes low.
  end		
initial
 begin
 #0 reset = 1; 
 #50000 reset = 0; 
 end
endmodule
