# Compile all the files in the project
project compileall

# Load the simulation
vsim -gui work.processor

# Load the memory
mem load -infile {mem_files/Memory2.mem} instrCache1
add wave -position insertpoint sim:/processor/NumberOfCycle
add wave -position insertpoint sim:/processor/clk
add wave -position insertpoint sim:/processor/PC_PC
# Add signals to the waveform viewer
add wave -position insertpoint -radix hexadecimal /processor/Regfile/q_registers(0)
add wave -position insertpoint -radix hexadecimal /processor/Regfile/q_registers(1)
add wave -position insertpoint -radix hexadecimal /processor/Regfile/q_registers(2)
add wave -position insertpoint -radix hexadecimal /processor/Regfile/q_registers(3)
add wave -position insertpoint -radix hexadecimal /processor/Regfile/q_registers(4)
add wave -position insertpoint -radix hexadecimal /processor/Regfile/q_registers(5)
add wave -position insertpoint -radix hexadecimal /processor/Regfile/q_registers(6)
add wave -position insertpoint -radix hexadecimal /processor/Regfile/q_registers(7)


add wave -position insertpoint sim:/processor/DM_SP_signal
add wave -position insertpoint sim:/processor/CCR_flags
add wave -position insertpoint sim:/processor/reset
add wave -position insertpoint sim:/processor/INT_In
add wave -position insertpoint sim:/processor/IN_PORT
add wave -position insertpoint sim:/processor/OUT_PORT
add wave -position insertpoint sim:/processor/exception



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
sim:/processor/DE_Pop_out  \
sim:/processor/FD_Rsrc1  \
sim:/processor/FD_Rsrc2  \
sim:/processor/DE_Rdst1_out  \
sim:/processor/stall_PopUse  \
sim:/processor/flush_DM  \
sim:/processor/DE_src1_use_in_signal  \
sim:/processor/DE_src2_use_in_signal  \
sim:/processor/DE_we1_reg_out


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


force -freeze sim:/processor/IN_PORT 32'h0019 0
run
force -freeze sim:/processor/IN_PORT 32'hFFFFFFFF 0
run
force -freeze sim:/processor/IN_PORT 32'hFFFFF320  0
run
run
run
run
run
run
force -freeze sim:/processor/IN_PORT 32'h00000010  0
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
force -freeze sim:/processor/IN_PORT 32'h00000010  0
run
force -freeze sim:/processor/IN_PORT 32'h00000019  0
run
run
run
run
run
run
run
run
force -freeze sim:/processor/IN_PORT 32'h00000211  0
run
force -freeze sim:/processor/IN_PORT 32'h00000211  0
run

run
run
run
force -freeze sim:/processor/IN_PORT 32'h00000100  0
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