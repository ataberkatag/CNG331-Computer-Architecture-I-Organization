# CNG331-Computer-Architecture-I-Organization
Assignments: CAD-2 and Term Project

These two assigments made by team which is consist of 2 person.

//////////////////////////////////////////////////////////////////////CAD-2//////////////////////////////////////////////////////////////////////

  In this CAD assignment you will work as a team of two to implement two different organizations of simple MIPS processor, and compare energy spent by each, 
	after running a simple benchmark to store numbers in multiples of 4 to different data memory locations.
1. Organizations
  a. Multi-Cycle MIPS
  b. Pipelined MIPS
2. Benchmark
  Both implementations will be simple enough to only accommodate the instructions available in the benchmark:
This is a simple test benchmark consisting of only fundamental MIPS instructions lw $s0, 0($zero) # load final count from memory address 0

lw $s1, 4($zero) # initialize counter $s1 from address 4

lw $s2, 4($zero) # initialize $s2 from address 4

repeat:

exit:

beq $s0,

add $s1,

sw  $s1,

j repeat

j exit

$s1, exit # check if final count reached

$s1, $s2 # increment the counter by the amount read from address 4 0($s1) # store to the address with the same value

//////////////////////////////////////////////////////////////////////Term Project//////////////////////////////////////////////////////////////////////

Form a team of two to write a simple assembler using a high-level programming language such as C or C++, Python, Java, or a scripting language 
such as Perl or JavaScript to convert any MIPS assembly program containing some of the main MIPS instructions and pseudo-instructions to hexadecimal 
machine language or object code. The list of assembler directives, instructions and pseudo-instructions that are required to work with your assembler 
can be found in the provided test code in APPENDIX I. You may find the definition of assembler directives and pseudo-instructions in APPENDIX II. 
Your mini-assembler solution should support an interactive mode and a batch mode. The interactive mode reads an instruction from command line, 
assembles it to hexadecimal (converting from pseudo-instruction as necessary), and outputs the result to the screen. The interactive mode does not 
support assembler directives or instruction labels. Appendix documents are inside the repository.
