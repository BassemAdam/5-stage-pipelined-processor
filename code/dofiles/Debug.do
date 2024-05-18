# Compile all the files in the project
project compileall

# Load the simulation
vsim -gui work.processor

# Load the memory
mem load -infile {mem_files/DoRTI.mem} instrCache1

add wave -position insertpoint  \
sim:/processor/NumberOfCycle \
sim:/processor/clk \
sim:/processor/reset \
sim:/processor/we \
sim:/processor/INT_In \
sim:/processor/IN_PORT \
sim:/processor/exception \
sim:/processor/OUT_PORT 

# PC signals 
add wave -position insertpoint  \
sim:/processor/PC_en \
sim:/processor/PC_PC 
# PC signals end 
 
# Instruction Cache signals 
add wave -position insertpoint  \
sim:/processor/IC_Inst \
sim:/processor/IC_InterruptPC \
sim:/processor/IC_ResetPC 
# Instruction Cache signals end 
 
# FD Buffer signals 
add wave -position insertpoint  \
sim:/processor/FD_OpCode \
sim:/processor/FD_Rsrc1 \
sim:/processor/FD_Rsrc2 \
sim:/processor/FD_Rdst1 \
sim:/processor/FD_Rdst2 \
sim:/processor/FD_Func  \
sim:/processor/FD_InputPort \
sim:/processor/FD_current_PC_out 
# FD Buffer signals end 
 
# Register File signals 
add wave -position insertpoint  \
sim:/processor/RF_Rdata1 \
sim:/processor/RF_Rdata2 
# Register File signals end
 
# DE Buffer signals 
add wave -position insertpoint  \
sim:/processor/DE_ALUopd1 \
sim:/processor/DE_ALUopd2 \
sim:/processor/DE_InPort_out \
sim:/processor/DE_we1_reg_out \
sim:/processor/DE_we2_reg_out \
sim:/processor/DE_ALUorMem_out \
sim:/processor/DE_OUTport_en_out \
sim:/processor/DE_flags_en_out \
sim:/processor/DE_Rdst1_out  \
sim:/processor/DE_Rdst2_out  \
sim:/processor/DE_ALUsel_out \
sim:/processor/DE_MemW_out \
sim:/processor/DE_MemR_out \
sim:/processor/DE_Push_out \
sim:/processor/DE_Pop_out  \
sim:/processor/DE_Protect_out \
sim:/processor/DE_Free_out \
sim:/processor/DE_STD_VALUE \
sim:/processor/DE_Correction \
sim:/processor/DE_POP_PC_out \
sim:/processor/DE_PC_out \
sim:/processor/DE_Push_CCR_out \
sim:/processor/DE_Push_PC_out  
# DE Buffer signals end 
 
# ALU signals 
add wave -position insertpoint  \
sim:/processor/ALU_Result1 \
sim:/processor/ALU_Result2 \
sim:/processor/ALU_flags 
# ALU signals end 
 
# EM Buffer signals  
add wave -position insertpoint  \
sim:/processor/EM_POP_PC_out \
sim:/processor/EM_ALUorMem_out \
sim:/processor/EM_we1_reg_out \
sim:/processor/EM_we2_reg_out \
sim:/processor/EM_OUTport_en_out \
sim:/processor/EM_Rdst1_out \
sim:/processor/EM_Rdst2_out \
sim:/processor/EM_ALUResult1_out \
sim:/processor/EM_ALUResult2_out 

# MEMORY OPERATIONS SIGNALS 
add wave -position insertpoint  \
sim:/processor/EM_MemW_out \
sim:/processor/EM_MemR_out \
sim:/processor/EM_Push_out \
sim:/processor/EM_Pop_out  \
sim:/processor/EM_Protect_out \
sim:/processor/EM_Free_out  \
sim:/processor/EM_STD_VALUE 
# EM Buffer signals end 

# Data Memory signals 
add wave -position insertpoint  \
sim:/processor/DM_RData 
# Data Memory signals end 

# MW Buffer signals 
add wave -position insertpoint  \
sim:/processor/MW_value1 \
sim:/processor/MW_value2 \
sim:/processor/MW_POP_PC_out  \
sim:/processor/MW_we1_reg_out \
sim:/processor/MW_we2_reg_out \
sim:/processor/MW_OUTport_en_out \
sim:/processor/MW_Rdst1_out \
sim:/processor/MW_Rdst2_out 
# MW Buffer signals end 

# CCR signals 
add wave -position insertpoint  \
sim:/processor/CCR_flags 
# CCR signals end 

# Controller Signals (most of the are not connected) 
add wave -position insertpoint  \
sim:/processor/ctr_hasImm \
sim:/processor/ctr_ALUsel \
sim:/processor/ctr_flags_en \
sim:/processor/ctr_we1_reg  \
sim:/processor/ctr_we2_reg  \
sim:/processor/ctr_ALUorMem \
sim:/processor/ctr_isInput  \
sim:/processor/ctr_OUTport_en \
sim:/processor/ctr_Predictor  \
sim:/processor/ctr_POP_PC_out 

# Controller for memoryData 
add wave -position insertpoint  \
sim:/processor/ctr_MemW \
sim:/processor/ctr_MemR \
sim:/processor/ctr_Push \
sim:/processor/ctr_Pop  \
sim:/processor/ctr_Free \
sim:/processor/ctr_JMP_DEC  \
sim:/processor/ctr_JMP_EXE  \
sim:/processor/ctr_Flush_FD \
sim:/processor/ctr_Flush_DE \
sim:/processor/ctr_Protect  \
sim:/processor/ctr_Push_PC_out  \
sim:/processor/ctr_Push_CCR_out \
sim:/processor/ctr_INT 
# Controller signals end 


# Force data
force -freeze sim:/processor/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/processor/we 1 0
force -freeze sim:/processor/PC_en 1 0
force -freeze sim:/processor/reset 1 0
run 50ps
force -freeze sim:/processor/reset 0 0
run 50ps
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run  
force -freeze sim:/processor/INT_In 1 0
run
run
force -freeze sim:/processor/INT_In 0 0
run
run
run