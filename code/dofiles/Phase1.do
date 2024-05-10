# project open M5-stage-pipelined-processor.mpf
project compileall

vsim -gui work.processor
mem load -infile {mem_files/Phase1.mem} instrCache1

# Add signals to the waveform viewer
add wave -position insertpoint  \
sim:/processor/clk  \
sim:/processor/reset  \
sim:/processor/IN_PORT  \
sim:/processor/ctr_we1_reg  \
sim:/processor/PC_PC  \
sim:/processor/IC_ResetPC  \
sim:/processor/IC_Inst  \
sim:/processor/FD_Rsrc1  \
sim:/processor/FD_Rsrc2  \
sim:/processor/FD_Rdst1  \
sim:/processor/FD_Rdst2  \
sim:/processor/FD_OpCode  \
sim:/processor/FD_InputPort  \
sim:/processor/DE_ALUopd1 \
sim:/processor/DE_ALUopd2  \
sim:/processor/ctr_isInput  \
sim:/processor/EM_ALUResult1_out  \
sim:/processor/EM_Rdst1_out  \
sim:/processor/MW_value1  \
sim:/processor/MW_value2  


force -freeze sim:/processor/IN_PORT 32'h00000005 0
force -freeze sim:/processor/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/processor/we 1 0
force -freeze sim:/processor/PC_en 1 0
force -freeze sim:/processor/reset 1 0
run 50ps
force -freeze sim:/processor/reset 0 0
run 50ps
