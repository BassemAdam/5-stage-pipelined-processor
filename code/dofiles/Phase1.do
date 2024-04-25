# project open M5-stage-pipelined-processor.mpf
project compileall

vsim -gui work.processor
mem load -infile {mem_files/instrCache1.mem} instrCache1

add wave -position insertpoint  \
sim:/processor/clk  \
sim:/processor/PC_PC  \
sim:/processor/CCR_flags  \
sim:/processor/ALU_flags  \
sim:/processor/DE_flags_en_out  \
sim:/processor/MW_value1  \
sim:/processor/MW_value2  \
sim:/processor/EM_ALUResult1_out


force -freeze sim:/processor/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/processor/we 1 0
force -freeze sim:/processor/PC_en 1 0
force -freeze sim:/processor/reset 1 0
run
force -freeze sim:/processor/reset 0 0
run
