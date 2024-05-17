; //.org 0  #this means the the following line would be  at address  0 , and this is the reset address
; //FF
; //
; //.org FF
; //PUSH R0
; //STD R0,3(R2)
; //PROTECT R1
; //FREE R1
; //LDD R1,5(R1)

.org 0  #this means the the following line would be  at address  0 , and this is the reset address
0

.org 4
PUSH R0
STD R0,3(R2)
PROTECT R1
FREE R1
LDD R1,5(R1)