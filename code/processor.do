vsim -gui work.processor
mem load -i {C:/cApps/1.Work_Study/University/CompArch/Project/Phase1/Project Files/-5-stage-pipelined-processor/code/instrCache.mem} /processor/instrCache1/ram
mem load -i {C:/cApps/1.Work_Study/University/CompArch/Project/Phase1/Project Files/-5-stage-pipelined-processor/code/registers.mem} /processor/registerFile1/q_registers
add wave -position insertpoint  \
sim:/processor/clk
force -freeze sim:/processor/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/processor/we 1 0
force -freeze sim:/processor/reset 0 0
add wave -position insertpoint  \
sim:/processor/instruction_Out_Cache
add wave -position insertpoint  \
sim:/processor/opCode_Out \
sim:/processor/Rsrc1_Out \
sim:/processor/Rsrc2_Out \
sim:/processor/Rdest_Out \
sim:/processor/FnNum_Out \
sim:/processor/Rsrc1_data_Out \
sim:/processor/Rsrc2_data_Out
run
run
