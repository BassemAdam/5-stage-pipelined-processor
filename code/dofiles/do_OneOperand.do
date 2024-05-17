# Compile all the files in the project
project compileall

# Load the simulation
vsim -gui work.processor

# Load the memory
mem load -infile {mem_files/OneOperand.mem} instrCache1

# Add signals to the waveform viewer
add wave -position insertpoint  \
sim:/processor/NumberOfCycle  \
sim:/processor/PC_PC  \
sim:/processor/DM_SP_signal  \
sim:/processor/CCR_flags  \
sim:/processor/clk  \
sim:/processor/reset  \
sim:/processor/INT_In  \
sim:/processor/IN_PORT  \
sim:/processor/OUT_PORT  \
sim:/processor/exception  



# InstrCache

# Fetch/Decode Buffer
add wave -position insertpoint  \
sim:/processor/FD_OpCode  \
sim:/processor/FD_Rdst1  \
sim:/processor/FD_Rdst2  \
sim:/processor/FD_Rsrc1  \
sim:/processor/FD_Rsrc2  \
sim:/processor/FD_Func  \
sim:/processor/FD_InputPort  

# Register File
add wave -position insertpoint  \
sim:/processor/RF_Rdata1  \
sim:/processor/RF_Rdata2  

# Decode/Execute Buffer
add wave -position insertpoint  \
sim:/processor/DE_ALUopd1 \
sim:/processor/DE_ALUopd2  \
sim:/processor/DE_InPort_out  \
sim:/processor/DE_we1_reg_out  \
sim:/processor/DE_we2_reg_out  \
sim:/processor/DE_ALUorMem_out  \
sim:/processor/DE_OUTport_en_out  \
sim:/processor/DE_flags_en_out  \
sim:/processor/DE_Rdst1_out  \
sim:/processor/DE_Rdst2_out  \
sim:/processor/DE_ALUsel_out  \
sim:/processor/DE_MemW_out  \
sim:/processor/DE_MemR_out  \
sim:/processor/DE_Push_out  \
sim:/processor/DE_Pop_out  \
sim:/processor/DE_Protect_out  \
sim:/processor/DE_Free_out \
sim:/processor/DE_STD_VALUE  \
sim:/processor/DE_STD_address_signal  \
sim:/processor/DE_ALUopd1_address_signal  \
sim:/processor/DE_ALUopd2_address_signal  \
sim:/processor/DE_src1_use_in_signal  \
sim:/processor/DE_src1_use_out_signal  \
sim:/processor/DE_src2_use_in_signal  \
sim:/processor/DE_src2_use_out_signal  \
sim:/processor/DE_STD_use_in_signal  \
sim:/processor/DE_STD_use_out_signal  \

# POP USE
add wave -position insertpoint  \
sim:/processor/stall_PopUse  \
sim:/processor/flush_EM  

# Forward Unit
add wave -position insertpoint  \
sim:/processor/FWD_ALU_OPD_1_signal \
sim:/processor/FWD_ALU_OPD_2_signal  


# ALU
add wave -position insertpoint  \
sim:/processor/ALU_Result1  \
sim:/processor/ALU_Result2  \
sim:/processor/ALU_flags  


# EM
add wave -position insertpoint  \
sim:/processor/EM_ALUorMem_out  \
sim:/processor/EM_we1_reg_out  \
sim:/processor/EM_we2_reg_out  \
sim:/processor/EM_OUTport_en_out  \
sim:/processor/EM_Rdst1_out  \
sim:/processor/EM_Rdst2_out  \
sim:/processor/EM_ALUResult1_out  \
sim:/processor/EM_ALUResult2_out  \
sim:/processor/EM_MemW_out  \
sim:/processor/EM_MemR_out  \
sim:/processor/EM_Push_out  \
sim:/processor/EM_Pop_out  \
sim:/processor/EM_Protect_out  \
sim:/processor/EM_Free_out  

# DataMemory
add wave -position insertpoint  \
sim:/processor/DM_RData  \

# MW
add wave -position insertpoint  \
sim:/processor/MW_value1  \
sim:/processor/MW_value2  \
sim:/processor/MW_we1_reg_out  \
sim:/processor/MW_we2_reg_out  \
sim:/processor/MW_OUTport_en_out  \
sim:/processor/MW_Rdst1_out  \
sim:/processor/MW_Rdst2_out  

# Controller 
add wave -position insertpoint  \
sim:/processor/ctr_hasImm  \
sim:/processor/ctr_ALUsel  \
sim:/processor/ctr_flags_en  \
sim:/processor/ctr_we1_reg  \
sim:/processor/ctr_we2_reg  \
sim:/processor/ctr_ALUorMem  \
sim:/processor/ctr_isInput  \
sim:/processor/ctr_OUTport_en  \
sim:/processor/ctr_MemW  \
sim:/processor/ctr_MemR  \
sim:/processor/ctr_Push  \
sim:/processor/ctr_Pop  \
sim:/processor/ctr_Free  \
sim:/processor/ctr_Protect


# Force data

# cycle 1
force -freeze sim:/processor/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/processor/we 1 0
force -freeze sim:/processor/PC_en 1 0
force -freeze sim:/processor/reset 1 0
run 50ps
force -freeze sim:/processor/reset 0 0
run 50ps

# cycle 2
run
run


run
# cycle 5
force -freeze sim:/processor/IN_PORT 32'h0005 0
run
force -freeze sim:/processor/IN_PORT 32'h0010 0
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


