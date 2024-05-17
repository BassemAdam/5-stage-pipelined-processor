#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/file.h>
#define MAX_BINARY_LENGTH 33 // 32 bits + 1 null terminator

char first_half[MAX_BINARY_LENGTH];
char second_half[MAX_BINARY_LENGTH];

typedef enum
{
    ALU,
    IMMEDIATE,
    NOP,
    DATA_OP,
    COND_JUMP,
    UNCOND_JUMP,
    MEM_SECURITY,
    INPUT_SIGNAL,
    ORG,
    UNKNOWN
} InstructionType;

InstructionType get_instruction_type(char *inst)
{
    char *copy = strdup(inst);
    char *operation = strtok(copy, " ");

    if (strcmp(operation, "NOT") == 0 || strcmp(operation, "NEG") == 0 || strcmp(operation, "INC") == 0 ||
        strcmp(operation, "DEC") == 0 || strcmp(operation, "MOV") == 0 || strcmp(operation, "SWAP") == 0 ||
        strcmp(operation, "ADD") == 0 || strcmp(operation, "SUB") == 0 || strcmp(operation, "AND") == 0 ||
        strcmp(operation, "OR") == 0 || strcmp(operation, "XOR") == 0 || strcmp(operation, "CMP") == 0)
    {
        return ALU;
    }
    if (strcmp(operation, "ADDI") == 0 || strcmp(operation, "SUBI") == 0 || strcmp(operation, "LDM") == 0 || strcmp(operation, "STD") == 0 || strcmp(operation, "LDD") == 0)
    {
        return IMMEDIATE;
    }

    if (strcmp(operation, "NOP") == 0)
    {

        return NOP;
    }
    if (strcmp(operation, "OUT") == 0 || strcmp(operation, "IN") == 0 || strcmp(operation, "PUSH") == 0 || strcmp(operation, "POP") == 0)
    {
        return DATA_OP;
    }
    if (strcmp(operation, "JZ") == 0 || strcmp(operation, "JNZ") == 0 || strcmp(operation, "JC") == 0 || strcmp(operation, "JNC") == 0 || strcmp(operation, "JN") == 0 || strcmp(operation, "JNN") == 0)
    {
        return COND_JUMP;
    }
    if (strcmp(operation, "JMP") == 0 || strcmp(operation, "CALL") == 0 || strcmp(operation, "RET") == 0 || strcmp(operation, "RTI") == 0)
    {
        return UNCOND_JUMP;
    }
    if (strcmp(operation, "FREE") == 0 || strcmp(operation, "PROTECT") == 0)
    {
        return MEM_SECURITY;
    }
    if (strcmp(operation, "RESET") == 0 || strcmp(operation, "INT") == 0)
    {
        return INPUT_SIGNAL;
    }
    if (strcmp(operation, ".ORG") == 0)
    {
        return ORG;
    }

    return UNKNOWN;
}

char *int_to_binary(unsigned int n, int num_bits)
{
    static char bin_str[17]; // 16 bits + 1 null terminator
    bin_str[0] = '\0';       // Start with an empty string

    // Iterate through each bit position
    for (int i = num_bits - 1; i >= 0; i--)
    {
        // Check if the current bit is set
        if (n & (1u << i))
        {
            // If set, append '1' to the string
            strcat(bin_str, "1");
        }
        else
        {
            // If not set, append '0' to the string
            strcat(bin_str, "0");
        }
    }

    return bin_str;
}

typedef struct
{
    unsigned int opcode : 3;
    unsigned int rdst;
    unsigned int rsrc1;
    unsigned int rsrc2;
    unsigned int fn_num : 4;

} ALU_Instruction;

typedef struct
{
    unsigned int opcode : 3;
    unsigned int rdst;
    unsigned int rsrc1;
    unsigned int rsrc2;
    unsigned int fn_num : 4;
    unsigned int imm;
} Immediate_Instruction;

typedef struct
{
    unsigned int opcode : 3;
    unsigned int rest : 13;

} NOP_Instruction;

typedef struct
{
    unsigned int opcode : 3;
    unsigned int rdst;
    unsigned int rsrc1;
    unsigned int rsrc2;
    unsigned int will_wb_reg : 1;
    unsigned int mem_op : 1;
    unsigned int stack_op : 1;
    unsigned int port_op : 1;

} Data_Op_Instruction;

typedef struct
{
    unsigned int opcode : 3;
    unsigned int rdst;
    unsigned int rsrc1 : 3;
    unsigned int rsrc2 : 3;
    unsigned int fn_num : 1;
    unsigned int rest : 3;

} cond_jump_Instruction;

typedef struct
{
    unsigned int opcode : 3;
    unsigned int rdst;
    unsigned int rsrc1 : 3;
    unsigned int rsrc2 : 3;
    unsigned int fn_num : 2;
    unsigned int rest : 2;
} uncond_jump_Instruction;

typedef struct
{
    unsigned int opcode : 3;
    unsigned int rdst;
    unsigned int rsrc1;
    unsigned int rsrc2 : 3;
    unsigned int fn_num : 1;
    unsigned int rest : 3;

} mem_security_Instruction;

typedef struct
{
    unsigned int opcode : 3;
    unsigned int rdst : 3;
    unsigned int rsrc1 : 3;
    unsigned int rsrc2 : 3;
    unsigned int fn_num : 1;
    unsigned int rest : 3;

} Input_Signal;

unsigned int parser_ALU_inst(char *inst)
{
    ALU_Instruction alu_inst;
    char *operation = strtok(inst, " ");
    if (strcmp(operation, "NOT") == 0)
    {
        alu_inst.opcode = 1;
        alu_inst.fn_num = 0;
        char *destination = strtok(NULL, " ");
        sscanf(destination, "R%u", &alu_inst.rdst);

        alu_inst.rsrc1 = alu_inst.rdst;
        alu_inst.rsrc2 = 0;
        alu_inst.fn_num = 0;
    }
    if (strcmp(operation, "NEG") == 0)
    {
        alu_inst.opcode = 1;
        alu_inst.fn_num = 1;

        alu_inst.rsrc2 = 0;
        char *destination = strtok(NULL, " ");
        sscanf(destination, "R%u", &alu_inst.rdst);
        alu_inst.rsrc1 = alu_inst.rdst;
    }
    if (strcmp(operation, "INC") == 0)
    {
        alu_inst.opcode = 1;
        alu_inst.fn_num = 2;

        alu_inst.rsrc2 = 0;
        char *destination = strtok(NULL, " ");
        sscanf(destination, "R%u", &alu_inst.rdst);
        alu_inst.rsrc1 = alu_inst.rdst;
    }

    if (strcmp(operation, "DEC") == 0)
    {
        alu_inst.opcode = 1;
        alu_inst.fn_num = 3;

        alu_inst.rsrc2 = 0;
        char *destination = strtok(NULL, " ");
        sscanf(destination, "R%u", &alu_inst.rdst);
        alu_inst.rsrc1 = alu_inst.rdst;
    }
    if (strcmp(operation, "MOV") == 0)
    {
        alu_inst.opcode = 1;
        alu_inst.fn_num = 4;
        alu_inst.rsrc2 = 0;
        char *instruction_copy = strdup(inst);
        char *destination = strtok(NULL, ", ");
        sscanf(destination, "R%u", &alu_inst.rdst);
        char *source = strtok(NULL, " ");
        sscanf(source, "R%u", &alu_inst.rsrc1);
        printf("rdst: %u rsrc1: %u\n", alu_inst.rdst, alu_inst.rsrc1);
    }
    if (strcmp(operation, "SWAP") == 0)
    {
        alu_inst.opcode = 1;
        alu_inst.fn_num = 5;
        char *destination = strtok(NULL, ", ");
        sscanf(destination, "R%u", &alu_inst.rdst);
        char *source1 = strtok(NULL, " ");
        sscanf(source1, "R%u", &alu_inst.rsrc2);
        alu_inst.rsrc1 = alu_inst.rdst;
    }
    if (strcmp(operation, "ADD") == 0)
    {
        alu_inst.opcode = 1;
        alu_inst.fn_num = 6;
        char *destination = strtok(NULL, ", ");
        sscanf(destination, "R%u", &alu_inst.rdst);
        char *source1 = strtok(NULL, ", ");
        printf("source1: %s\n", source1);
        sscanf(source1, "R%u", &alu_inst.rsrc1);

        char *source2 = strtok(NULL, " ");
        sscanf(source2, "R%u", &alu_inst.rsrc2);
        printf("rdst: %u rsrc1: %u rsrc2: %u\n", alu_inst.rdst, alu_inst.rsrc1, alu_inst.rsrc2);
    }
    if (strcmp(operation, "SUB") == 0)
    {
        alu_inst.opcode = 1;
        alu_inst.fn_num = 7;
        char *destination = strtok(NULL, ", ");
        sscanf(destination, "R%u", &alu_inst.rdst);
        char *source1 = strtok(NULL, ", ");
        sscanf(source1, "R%u", &alu_inst.rsrc1);
        char *source2 = strtok(NULL, " ");
        sscanf(source2, "R%u", &alu_inst.rsrc2);
    }
    if (strcmp(operation, "AND") == 0)
    {
        alu_inst.opcode = 1;
        alu_inst.fn_num = 8;
        char *destination = strtok(NULL, ", ");
        sscanf(destination, "R%u", &alu_inst.rdst);
        char *source1 = strtok(NULL, ", ");
        sscanf(source1, "R%u", &alu_inst.rsrc1);
        char *source2 = strtok(NULL, " ");
        sscanf(source2, "R%u", &alu_inst.rsrc2);
    }
    if (strcmp(operation, "OR") == 0)
    {
        alu_inst.opcode = 1;
        alu_inst.fn_num = 9;
        char *destination = strtok(NULL, ", ");
        sscanf(destination, "R%u", &alu_inst.rdst);
        char *source1 = strtok(NULL, ", ");
        sscanf(source1, "R%u", &alu_inst.rsrc1);
        char *source2 = strtok(NULL, " ");
        sscanf(source2, "R%u", &alu_inst.rsrc2);
        printf("rdst: %u rsrc1: %u rsrc2: %u\n", alu_inst.rdst, alu_inst.rsrc1, alu_inst.rsrc2);
    }
    if (strcmp(operation, "XOR") == 0)
    {
        alu_inst.opcode = 1;
        alu_inst.fn_num = 10;
        char *destination = strtok(NULL, ", ");
        sscanf(destination, "R%u", &alu_inst.rdst);
        char *source1 = strtok(NULL, ", ");
        sscanf(source1, "R%u", &alu_inst.rsrc1);
        char *source2 = strtok(NULL, " ");
        sscanf(source2, "R%u", &alu_inst.rsrc2);
    }
    if (strcmp(operation, "CMP") == 0)
    {
        alu_inst.opcode = 1;
        alu_inst.fn_num = 11;
        alu_inst.rdst = 0;
        char *source1 = strtok(NULL, ", ");
        sscanf(source1, "R%u", &alu_inst.rsrc1);
        char *source2 = strtok(NULL, " ");
        sscanf(source2, "R%u", &alu_inst.rsrc2);
    }

    unsigned int result = 0;
    result |= (alu_inst.opcode & 0x7) << 13; // Assuming opcode is 3 bits
    result |= (alu_inst.rdst & 0x7) << 10;   // Assuming rdst is 3 bits
    result |= (alu_inst.rsrc1 & 0x7) << 7;   // Assuming rsrc1 is 3 bits
    result |= (alu_inst.rsrc2 & 0x7) << 4;   // Assuming rsrc2 is 3 bits
    result |= (alu_inst.fn_num & 0xF);
    return result;
}

unsigned int parse_Immediate_instruction(char *instruction)
{

    Immediate_Instruction imm_inst;
    char *operation = strtok(instruction, " ");
    if (strcmp(operation, "ADDI") == 0)
    {
        imm_inst.opcode = 2;
        imm_inst.fn_num = 0;
        imm_inst.rsrc2 = 0;
        char *destination = strtok(NULL, ", ");
        sscanf(destination, "R%u", &imm_inst.rdst);
        char *source1 = strtok(NULL, ", ");
        sscanf(source1, "R%u", &imm_inst.rsrc1);
        char *immediate = strtok(NULL, " ");
        sscanf(immediate, "%x", &imm_inst.imm);
    }
    if (strcmp(operation, "SUBI") == 0)
    {
        imm_inst.opcode = 2;
        imm_inst.fn_num = 1;
        imm_inst.rsrc2 = 0;
        char *destination = strtok(NULL, ", ");
        sscanf(destination, "R%u", &imm_inst.rdst);
        char *source1 = strtok(NULL, ", ");
        sscanf(source1, "R%u", &imm_inst.rsrc1);
        char *immediate = strtok(NULL, " ");
        sscanf(immediate, "%x", &imm_inst.imm);
    }
    if (strcmp(operation, "LDM") == 0)
    {
        imm_inst.opcode = 2;
        imm_inst.fn_num = 2;
        imm_inst.rsrc2 = 0;
        imm_inst.rsrc1 = 0;
        char *destination = strtok(NULL, ", ");
        sscanf(destination, "R%u", &imm_inst.rdst);
        char *immediate = strtok(NULL, " ");
        sscanf(immediate, "%x", &imm_inst.imm);
    }
    if (strcmp(operation, "STD") == 0)
    {
        imm_inst.opcode = 2;
        imm_inst.fn_num = 3;
        imm_inst.rdst = 0;
        char *destination = strtok(NULL, ", ");
        sscanf(destination, "R%u", &imm_inst.rsrc1);

        char *immediate_and_source = strtok(NULL, " ");
        sscanf(immediate_and_source, "%d(R%u)", &imm_inst.imm, &imm_inst.rsrc2);
    }
    if (strcmp(operation, "LDD") == 0)
    {
        imm_inst.opcode = 2;
        imm_inst.fn_num = 12;
        imm_inst.rsrc2 = 0;
        char *destination = strtok(NULL, ", ");
        sscanf(destination, "R%u", &imm_inst.rdst);

        char *immediate_and_source = strtok(NULL, " ");
        sscanf(immediate_and_source, "%x(R%u)", &imm_inst.imm, &imm_inst.rsrc1);
    }
    unsigned int result = 0;
    result |= (imm_inst.opcode & 0x7) << 29; // Assuming opcode is 3 bits
    result |= (imm_inst.rdst & 0x7) << 26;   // Assuming rdst is 3 bits
    result |= (imm_inst.rsrc1 & 0x7) << 23;  // Assuming rsrc1 is 3 bits
    result |= (imm_inst.rsrc2 & 0x7) << 20;  // Assuming rsrc2 is 3 bits
    result |= (imm_inst.fn_num & 0xF) << 16; // Assuming fn_num is 4 bits
    result |= (imm_inst.imm & 0xFFFF);       // Assuming imm is 16 bits
    printf("result: %u %u %u %u %u %u\n", imm_inst.opcode, imm_inst.rdst, imm_inst.rsrc1, imm_inst.rsrc2, imm_inst.fn_num, imm_inst.imm);
    return result;
}

unsigned int parse_Data_Op_instruction(char *instruction)
{
    // Parse the Data Operation instruction and convert it into machine code
    Data_Op_Instruction data_op_inst;
    char *operation = strtok(instruction, " ");
    if (strcmp(operation, "OUT") == 0)
    {
        data_op_inst.opcode = 3;
        data_op_inst.will_wb_reg = 0;
        data_op_inst.mem_op = 0;
        data_op_inst.stack_op = 0;
        data_op_inst.port_op = 1;
        char *destination = strtok(NULL, " ");
        sscanf(destination, "R%u", &data_op_inst.rsrc1);
        data_op_inst.rdst = 0;
        data_op_inst.rsrc2 = 0;
    }
    if (strcmp(operation, "IN") == 0)
    {
        data_op_inst.opcode = 3;
        data_op_inst.will_wb_reg = 1;
        data_op_inst.mem_op = 0;
        data_op_inst.stack_op = 0;
        data_op_inst.port_op = 1;
        char *destination = strtok(NULL, " ");
        sscanf(destination, "R%u", &data_op_inst.rdst);
        data_op_inst.rsrc1 = 0;
        data_op_inst.rsrc2 = 0;
    }
    if (strcmp(operation, "PUSH") == 0)
    {
        data_op_inst.opcode = 3;
        data_op_inst.will_wb_reg = 0;
        data_op_inst.mem_op = 0;
        data_op_inst.stack_op = 1;
        data_op_inst.port_op = 0;
        char *destination = strtok(NULL, " ");
        sscanf(destination, "R%u", &data_op_inst.rsrc1);
        data_op_inst.rdst = 0;
        data_op_inst.rsrc2 = 0;
    }
    if (strcmp(operation, "POP") == 0)
    {
        data_op_inst.opcode = 3;
        data_op_inst.will_wb_reg = 1;
        data_op_inst.mem_op = 0;
        data_op_inst.stack_op = 1;
        data_op_inst.port_op = 0;
        char *destination = strtok(NULL, " ");
        sscanf(destination, "R%u", &data_op_inst.rdst);
        data_op_inst.rsrc1 = 0;
        data_op_inst.rsrc2 = 0;
    }

    unsigned int result = 0;
    result |= (data_op_inst.opcode & 0x7) << 13;
    result |= (data_op_inst.rdst & 0x7) << 10;
    result |= (data_op_inst.rsrc1 & 0x7) << 7;
    result |= (data_op_inst.rsrc2 & 0x7) << 4;
    result |= (data_op_inst.will_wb_reg & 0x1) << 3;
    result |= (data_op_inst.mem_op & 0x1) << 2;
    result |= (data_op_inst.stack_op & 0x1) << 1;
    result |= (data_op_inst.port_op & 0x1);

    return result;
}

unsigned int parse_cond_jump_instruction(char *instruction)
{
    // Parse the Conditional Jump instruction and convert it into machine code
    cond_jump_Instruction cond_jump_inst;
    char *operation = strtok(instruction, " ");
    if (strcmp(operation, "JZ") == 0)
    {
        cond_jump_inst.opcode = 4;
        cond_jump_inst.fn_num = 0;
        char *destination = strtok(NULL, " ");
        sscanf(destination, "R%u", &cond_jump_inst.rdst);
        cond_jump_inst.rsrc1 = 0;
        cond_jump_inst.rsrc2 = 0;
        cond_jump_inst.rest = 0;
    }
    unsigned int result = 0;
    result |= (cond_jump_inst.opcode & 0x7) << 13;
    result |= (cond_jump_inst.rdst & 0x7) << 10;
    result |= (cond_jump_inst.rsrc1 & 0x7) << 7;
    result |= (cond_jump_inst.rsrc2 & 0x7) << 4;
    result |= (cond_jump_inst.fn_num & 0x1) << 3;
    result |= (cond_jump_inst.rest & 0x7);
    return result;
}

unsigned int parse_uncond_jump_instruction(char *instruction)
{
    // Parse the Unconditional Jump instruction and convert it into machine code
    uncond_jump_Instruction uncond_jump_inst;
    char *operation = strtok(instruction, " ");
    if (strcmp(operation, "JMP") == 0)
    {
        uncond_jump_inst.opcode = 5;
        char *destination = strtok(NULL, " ");
        sscanf(destination, "R%u", &uncond_jump_inst.rdst);
        uncond_jump_inst.rsrc1 = 0;
        uncond_jump_inst.rsrc2 = 0;
        uncond_jump_inst.fn_num = 0;
        uncond_jump_inst.rest = 0;
    }
    if (strcmp(operation, "CALL") == 0)
    {
        uncond_jump_inst.opcode = 5;
        char *destination = strtok(NULL, " ");
        sscanf(destination, "R%u", &uncond_jump_inst.rdst);
        uncond_jump_inst.rsrc1 = 0;
        uncond_jump_inst.rsrc2 = 0;
        uncond_jump_inst.fn_num = 1;
        uncond_jump_inst.rest = 0;
    }
    if (strcmp(operation, "RET") == 0)
    {
        uncond_jump_inst.opcode = 5;
        uncond_jump_inst.rdst = 0;
        uncond_jump_inst.rsrc1 = 0;
        uncond_jump_inst.rsrc2 = 0;
        uncond_jump_inst.fn_num = 2;
        uncond_jump_inst.rest = 0;
    }
    if (strcmp(operation, "RTI") == 0)
    {
        uncond_jump_inst.opcode = 5;
        uncond_jump_inst.rdst = 0;
        uncond_jump_inst.rsrc1 = 0;
        uncond_jump_inst.rsrc2 = 0;
        uncond_jump_inst.fn_num = 3;
        uncond_jump_inst.rest = 0;
    }
    unsigned int result = 0;
    result |= (uncond_jump_inst.opcode & 0x7) << 13;
    result |= (uncond_jump_inst.rdst & 0x7) << 10;
    result |= (uncond_jump_inst.rsrc1 & 0x7) << 7;
    result |= (uncond_jump_inst.rsrc2 & 0x7) << 4;
    result |= (uncond_jump_inst.fn_num & 0x3) << 2;
    result |= (uncond_jump_inst.rest & 0x3);
    return result;
}

unsigned int parse_mem_security_instruction(char *instruction)
{
    // Parse the Memory Security instruction and convert it into machine code
    mem_security_Instruction mem_security_inst;
    char *operation = strtok(instruction, " ");
    if (strcmp(operation, "PROTECT") == 0)
    {
        mem_security_inst.opcode = 6;
        char *source = strtok(NULL, " ");
        sscanf(source, "R%u", &mem_security_inst.rsrc1);
        mem_security_inst.rdst = 0;
        mem_security_inst.rsrc2 = 0;
        mem_security_inst.fn_num = 0;
        mem_security_inst.rest = 0;
    }
    if (strcmp(operation, "FREE") == 0)
    {
        mem_security_inst.opcode = 6;
        char *source = strtok(NULL, " ");
        sscanf(source, "R%u", &mem_security_inst.rsrc1);
        mem_security_inst.rdst = 0;
        mem_security_inst.rsrc2 = 0;
        mem_security_inst.fn_num = 1;
        mem_security_inst.rest = 0;
    }
    unsigned int result = 0;
    result |= (mem_security_inst.opcode & 0x7) << 13;
    result |= (mem_security_inst.rdst & 0x7) << 10;
    result |= (mem_security_inst.rsrc1 & 0x7) << 7;
    result |= (mem_security_inst.rsrc2 & 0x7) << 4;
    result |= (mem_security_inst.fn_num & 0x1) << 3;
    result |= (mem_security_inst.rest & 0x7);
    return result;
}

unsigned int parse_Input_Signal(char *instruction)
{
    // Parse the Input Signal instruction and convert it into machine code
    Input_Signal input_signal_inst;
    char *operation = strtok(instruction, " ");
    if (strcmp(operation, "RESET") == 0)
    {
        input_signal_inst.opcode = 7;
        input_signal_inst.rdst = 0;
        input_signal_inst.rsrc1 = 0;
        input_signal_inst.rsrc2 = 0;
        input_signal_inst.fn_num = 0;
        input_signal_inst.rest = 0;
    }
    if (strcmp(operation, "INT") == 0)
    {
        input_signal_inst.opcode = 7;
        input_signal_inst.rdst = 0;
        input_signal_inst.rsrc1 = 0;
        input_signal_inst.rsrc2 = 0;
        input_signal_inst.fn_num = 1;
        input_signal_inst.rest = 0;
    }
    unsigned int result = 0;
    result |= (input_signal_inst.opcode & 0x7) << 13;
    result |= (input_signal_inst.rdst & 0x7) << 10;
    result |= (input_signal_inst.rsrc1 & 0x7) << 7;
    result |= (input_signal_inst.rsrc2 & 0x7) << 4;
    result |= (input_signal_inst.fn_num & 0x1) << 3;
    result |= (input_signal_inst.rest & 0x7);
    return result;
}

int main(int argc, char **argv)
{
	char* infile = "instructions.asm";
	if (argc > 1) {
        infile = argv[1];
    }
	char* outfile = "binary.mem";
	if (argc > 2) {
        outfile = argv[2];
    }
    FILE *fptr;
    FILE *binptr;
    fptr = fopen(infile, "r");
    binptr = fopen(outfile, "w");
    fprintf(binptr, "// memory data file (do not edit the following line - required for mem load use)\n// instance=/processor/instrCache1/ram\n// format=mti addressradix=d dataradix=b version=1.0 wordsperline=1\n");
    if (fptr == NULL)
    {
        printf("Error!");
        exit(1);
    }
    char inst[100];
    int i = 0;
    while (fgets(inst, 100, fptr) != NULL)
    {
        inst[strcspn(inst, "\n")] = 0;
        char *start = inst;
        while (*start == ' ' || *start == '\t')
        {
            start++;
        }

        // Convert to uppercase
        for (int i = 0; start[i]; i++)
        {
            start[i] = toupper((unsigned char)start[i]);
        }

        // If the line is a comment or empty, skip it
        if (*start == '#' || *start == '/' || *start == '\0')
        {
            continue;
        }

        char *machine_code;
        printf("instruction: %s", inst);
        switch (get_instruction_type(inst))
        {
        case ALU:
            printf("ALU instruction\n");
            machine_code = int_to_binary(parser_ALU_inst(inst), 16);
            printf("Machine code: %s\n", machine_code);
            // write to file
            fprintf(binptr, "%d: %s\n", i, machine_code);
            i++;
            break;
        case IMMEDIATE:
            printf("Immediate instruction\n");
            machine_code = int_to_binary(parse_Immediate_instruction(inst), 32);

            int length = strlen(machine_code);
            int half_length = length / 2;

            strncpy(first_half, machine_code, half_length);
            first_half[half_length] = '\0'; // Null-terminate the first half string

            strcpy(second_half, &machine_code[half_length]);

            printf("Machine code: %s\n", first_half);
            printf("Immediate value: %s\n", second_half);
            fprintf(binptr, "%d: %s\n", i, first_half);
            i++;
            fprintf(binptr, "%d: %s\n", i, second_half);
            i++;
            break;
        case NOP:
            printf("NOP instruction\n");
            printf("Machine code: %s\n", int_to_binary(0, 16));
            fprintf(binptr, "%d: %s\n", i, int_to_binary(0, 16));
            i++;
            break;
        case DATA_OP:
            printf("Data Operation instruction\n");
            // printf("Machine code: %s\n", int_to_binary(parse_Data_Op_instruction(inst), 32));
            machine_code = int_to_binary(parse_Data_Op_instruction(inst), 16);
            printf("Machine code: %s\n", machine_code);
            fprintf(binptr, "%d: %s\n", i, machine_code);
            i++;
            break;
        case COND_JUMP:
            printf("\nConditional Jump instruction\n");
            machine_code = int_to_binary(parse_cond_jump_instruction(inst), 16);
            printf("Machine code: %s\n", machine_code);
            fprintf(binptr, "%d: %s\n", i, machine_code);
            i++;
            break;
        case UNCOND_JUMP:
            printf("Unconditional Jump instruction\n");
            machine_code = int_to_binary(parse_uncond_jump_instruction(inst), 16);
            printf("Machine code: %s\n", machine_code);
            fprintf(binptr, "%d: %s\n", i, machine_code);
            i++;
            break;
        case MEM_SECURITY:
            printf("Memory Security instruction\n");
            machine_code = int_to_binary(parse_mem_security_instruction(inst), 16);
            printf("Machine code: %s\n", machine_code);
            fprintf(binptr, "%d: %s\n", i, machine_code);
            i++;
            break;
        case INPUT_SIGNAL:
            printf("Input Signal instruction\n");
            machine_code = int_to_binary(parse_Input_Signal(inst), 16);
            printf("Machine code: %s\n", machine_code);
            fprintf(binptr, "%d: %s\n", i, machine_code);
            i++;
            break;
        case ORG:
            printf("ORG instruction\n");
            // read the org number
            char *org = strtok(inst, " ");
            char *org_num = strtok(NULL, " ");
            int org_num_dec = strtol(org_num, NULL, 16);
            printf("ORG number: %s\n", org_num);
            if (org_num_dec != 0 && org_num_dec != 2)
            {
                // covert org num from hexa to decimal

                printf("ORG number in decimal: %d\n", org_num_dec);
                int start = i;
                for (int j = start; j < org_num_dec; j++)
                {
                    fprintf(binptr, "%d: %s\n", i, int_to_binary(0, 16));
                    i++;
                }
            }
            else if (org_num_dec == 2)
            {
                // check number in the next line and convert it from hex to binary

                fgets(inst, 100, fptr);
                inst[strcspn(inst, "\n")] = 0;
                int address;
                sscanf(inst, "%x", &address);
                printf("address: %d\n", address);
                unsigned int result = 0;
                result |= (address & 0xFFFFFFFF);
                printf("result: %u\n", result);
                unsigned int upper16Bits = (result >> 16) & 0xFFFF;
                unsigned int lower16Bits = result & 0xFFFF;
                printf("upper16Bits: %u\n", upper16Bits);
                printf("lower16Bits: %u\n", lower16Bits);
                fprintf(binptr, "%d: %s\n", 2, int_to_binary(upper16Bits, 16)); // print 1st 16 bits
                fprintf(binptr, "%d: %s\n", 3, int_to_binary(lower16Bits, 16));
                // print 1st 16 bits
                i = 4;
                continue;
            }
            else if (org_num_dec == 0)
            {
                fgets(inst, 100, fptr);
                inst[strcspn(inst, "\n")] = 0;
                int address;
                sscanf(inst, "%x", &address);
                printf("address: %d\n", address);
                unsigned int result = 0;
                result |= (address & 0xFFFFFFFF);
                printf("result: %u\n", result);
                unsigned int upper16Bits = (result >> 16) & 0xFFFF;
                unsigned int lower16Bits = result & 0xFFFF;
                printf("upper16Bits: %u\n", upper16Bits);
                printf("lower16Bits: %u\n", lower16Bits);
                fprintf(binptr, "%d: %s\n", 0, int_to_binary(upper16Bits, 16)); // print 1st 16 bits
                fprintf(binptr, "%d: %s\n", 1, int_to_binary(lower16Bits, 16));
                // print 1st 16 bits
                i = 2;
                continue;
            }

            i = strtol(org_num, NULL, 16);
            break;
        case UNKNOWN:
            printf("Unknown instruction\n");
            break;
        }

        printf("\n");
    }
    fclose(fptr);
    fclose(binptr);
}