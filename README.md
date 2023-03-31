# CNG331-Computer-Architecture-I-Organization
Assignments: CAD-2 and Term Project

These two assigments made by team which is consist of 2 person.

//////////////////////////////////CAD-2/////////////////////////////////

In this CAD assignment you will work as a team of two to implement two different organizations of simple MIPS processor, and compare energy spent by each, after running a simple benchmark to store numbers in multiples of 4 to different data memory locations.
2. Organizations
  a. Multi-Cycle MIPS
  b. Pipelined MIPS
3. Benchmark
Both implementations will be simple enough to only accommodate the instructions available in the benchmark:
## This is a simple test benchmark consisting of only fundamental MIPS instructions lw $s0, 0($zero) # load final count from memory address 0
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
