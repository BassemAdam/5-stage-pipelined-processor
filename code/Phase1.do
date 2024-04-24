# project open M5-stage-pipelined-processor.mpf
project compileall

vsim -gui work.processor
mem load -infile {instrCache1.mem} instrCache1

add wave -position insertpoint  \
sim:/processor/clk  \
sim:/processor/Ipc_out  \
sim:/processor/CCR_flags  \
sim:/processor/ALU_flags  \
sim:/processor/DE_flags_en_out  \
sim:/processor/WB_ALUResult_Out  \
sim:/processor/WB_ALUResult_Out_2  \
sim:/processor/EM_ALUResult


force -freeze sim:/processor/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/processor/we 1 0
force -freeze sim:/processor/PC_Enable 1 0
force -freeze sim:/processor/reset 1 0
run
force -freeze sim:/processor/reset 0 0
run
