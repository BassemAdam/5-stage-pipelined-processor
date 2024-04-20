# the "vcom -refresh" comand should compile all files (Nouh)
vcom -work work -2002 -refresh
# vcom -work work -2002 -explicit -stats=none processor.vhd
vsim -gui work.processor
# with the "mem load -infile <path in work dir> <memory instance>" comand we don't need the path from the C: dir (Nouh)
mem load -infile {instrCache.mem} instrCache1
add wave -position insertpoint  \
sim:/processor/clk
force -freeze sim:/processor/clk 0 0, 1 {50 ps} -r 100
add wave -position insertpoint  \
sim:/processor/reset
add wave -position insertpoint  \
sim:/processor/we
add wave -position insertpoint  \
sim:/processor/Ipc_out
add wave -position insertpoint  \
sim:/processor/instruction_Out_Cache
add wave -position insertpoint  \
sim:/processor/opCode_Out
add wave -position insertpoint  \
sim:/processor/Rsrc1_Out \
sim:/processor/Rsrc2_Out \
sim:/processor/Rdest_Out \
sim:/processor/FnNum_Out \
sim:/processor/PC_Enable
add wave -position insertpoint  \
sim:/processor/Rsrc1_data_Out \
sim:/processor/Rsrc2_data_Out \
#-sim:/processor/ALU_Selectors \
sim:/processor/ctr_ALU_sel \
sim:/processor/DE_Rsrc1_data_out \
sim:/processor/DE_Rsrc2_data_out \
sim:/processor/DE_dest_out \
sim:/processor/DE_AluSelectors_out
force -freeze sim:/processor/we 1 0
force -freeze sim:/processor/PC_Enable 1 0
force -freeze sim:/processor/reset 1 0
run
force -freeze sim:/processor/reset 0 0
run
mem load -infile {registers.mem} /processor/registerFile1/q_registers
add wave -position insertpoint  \
sim:/processor/ALUResult \
sim:/processor/zeroFlag \
sim:/processor/NegativeFlag \
sim:/processor/CarryFlag \
sim:/processor/OverflowFlag \
sim:/processor/EM_ALUResult \
sim:/processor/EM_dest_out
add wave -position insertpoint  \
sim:/processor/WB_Rdest_Out \
sim:/processor/WB_ALUResult_Out
run
run
