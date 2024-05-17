# Compile all the files in the project
project compileall

# Load the simulation
vsim -gui work.processor

# Load the memory
mem load -infile {mem_files/DoJZ.mem} instrCache1

add wave -position insertpoint  \
sim:/processor/clk  \
sim:/processor/NumberOfCycle \
sim:/processor/PC_PC \
sim:/processor/DE_Correction \
sim:/processor/CCR_flags \
sim:/processor/ctr_Predictor \
sim:/processor/ctr_JMP_DEC \
sim:/processor/ctr_Flush_FD \
sim:/processor/ctr_Flush_DE \
sim:/processor/RF_Rdata1 \
sim:/processor/FD_OpCode  \
sim:/processor/FD_Rdst1  \
sim:/processor/FD_Rdst2  \
sim:/processor/FD_Rsrc1  \
sim:/processor/FD_Rsrc2  \
sim:/processor/FD_Func  

# Force data
force -freeze sim:/processor/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/processor/we 1 0
force -freeze sim:/processor/PC_en 1 0
force -freeze sim:/processor/reset 1 0
run 50ps
force -freeze sim:/processor/reset 0 0
run 50ps

