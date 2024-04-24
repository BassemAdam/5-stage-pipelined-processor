# vcom -work work -2002 -refresh
vsim -gui work.processor
mem load -infile {binary2.mem} instrCache1
add wave -position insertpoint  \
sim:/processor/clk \
sim:/processor/reset \
sim:/processor/we \
sim:/processor/Ipc_out \
sim:/processor/instruction_Out_Cache \
sim:/processor/InsCache_immediate_out \
sim:/processor/InsCache_IsImmediate_out \
sim:/processor/InsCache_correctedPc_out \
sim:/processor/opCode_Out \
sim:/processor/Rsrc1_Out \
sim:/processor/Rsrc2_Out \
sim:/processor/Rdest_Out \
sim:/processor/FnNum_Out \
sim:/processor/I_FD_immediate_out \
sim:/processor/I_FD_IsImm_out \
sim:/processor/Rsrc1_data_Out \
sim:/processor/Rsrc2_data_Out \
sim:/processor/Cont_instruction_In \
sim:/processor/Rsrc1 \
sim:/processor/Rsrc2 \
sim:/processor/Rdest \
sim:/processor/DE_we_reg_out \
sim:/processor/DE_Rsrc1_data_out \
sim:/processor/DE_Rsrc2_data_out \
sim:/processor/DE_dest_out \
sim:/processor/DE_AluSelectors_out
add wave -position insertpoint  \
sim:/processor/DE_isImm_OUT
add wave -position insertpoint  \
sim:/processor/PC_Enable
force -freeze sim:/processor/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/processor/PC_Enable 1 0
force -freeze sim:/processor/we 1 0
force -freeze sim:/processor/reset 1 0
run

force -freeze sim:/processor/reset 0 0

run
#mem load -infile {registers.mem} /processor/registerFile1/q_registers