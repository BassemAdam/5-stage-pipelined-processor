#Compile all the files in the project
project compileall

#Load the simulation
vsim -gui work.DataMemory

#Add signals to the waveform viewer
add wave -position insertpoint  \
sim:/DataMemory/clk  \
sim:/DataMemory/RES  \
sim:/datamemory/DM_Protect \
sim:/datamemory/DM_Free  \
sim:/DataMemory/sp  \
sim:/DataMemory/DM_WData  \
sim:/DataMemory/DM_MemR  \
sim:/DataMemory/DM_MemW  \
sim:/DataMemory/DM_Push  \
sim:/DataMemory/DM_Pop  \
sim:/DataMemory/DM_RAddr  \
sim:/DataMemory/DM_WAddr  \
sim:/DataMemory/DM_Exception  \
sim:/DataMemory/DM_RData


#Run the simulation for a specified amount of time
force -freeze sim:/DataMemory/RES 1 0

force -freeze sim:/DataMemory/clk 1 0, 0 {50 ps} -r 100
run 50ps
force -freeze sim:/DataMemory/RES 0 0

run 50ps
force -freeze sim:/DataMemory/DM_Push 1 0
force -freeze sim:/DataMemory/DM_WData 32'h40000005 0

run
force -freeze sim:/DataMemory/DM_WData 32'h22000002 0
run
force -freeze sim:/datamemory/DM_Pop 1 0
force -freeze sim:/datamemory/DM_Push 0 0