import sys

# Reads MArch assembly instruction file and outputs
#   machine code for MArch to output.txt. See spec 
#   for available functions
# 
# Format assembly instructions as follows:
#   <instr> <operand1>, <operand2>  <comment if desired>
#
# Usage: python3 assembler.py <assembly_source_file>
#
# Michael Tam



# check args
if (len(sys.argv) != 2):
    print("Usage: python3 assembler.py <assembly file>\n")
    print("Generates a machine-code file for MArch at output.txt")

#open necessary files
dest_file = open("output.txt", "w")
src_file = open(sys.argv[1], "r")

bits_map = {
    "add": "0000", "sub": "0001",
    "and": "0010", "xor": "0011",
    "slt": "0100", "rev": "0101",
    "lb" : "0110", "sb" : "0111",
    "mov": "100" , "biz": "101",
    "addi": "110" , "ls": "111"
} #map each instruction to its corresponding machine-code bit prelude

format_map = {
    "add": "R", "sub": "R",
    "and": "R", "xor": "R",
    "slt": "R", "rev": "R",
    "lb" : "R", "sb" : "R",
    "mov": "F" , "biz": "F",
    "addi": "I" , "ls": "I"
} #map each instruction to its corresponding format for easy error checking

#get each instruction in a line
lines = src_file.readlines()
line_num = 1    #for debugging compile errors in assembly
for line in lines:
    words = line.split()    #get each word in assembly file
    instr = words[0]        
    
    if (bits_map[instr] == None):
        #unexpected instruction error
        print("Unexpected instruction in " + sys.argv[1] + ", line: " + line_num)
        exit(1)

    arg1 = None
    arg2 = None

    #get instruction operands based on format type
    if (format_map[instr] == "R"):
        #out of bounds check
        if int(words[1][1:-1]) > 7 or int(words[2][1:]) > 3:
            print(instr + " calls reg out of bounds, line: " + line_num)
            exit(1)

        #get args
        arg1 = str('{0:03b}'.format(int(words[1][1:-1]))) #converts 'R1,' to '001'
        arg2 = str('{0:02b}'.format(int(words[2][1:])))   #converts 'R1' to '01'
    
    elif (format_map[instr] == "F"):
        #out of bounds check
        if int(words[1][1:-1]) > 7 or int(words[2][1:]) > 7:
            print(instr + "calls reg out of bounds, line: " + line_num)
            exit(1)       
        
        #get args
        arg1 = str('{0:03b}'.format(int(words[1][1:-1]))) #converts 'R1,' to '001'
        arg2 = str('{0:03b}'.format(int(words[2][1:])))   #converts 'R1' to '001'
    
    elif (format_map[instr] == "I"):
        #out of bounds check
        if int(words[1][1:-1]) > 3 or int(words[2][1:]) > 15:
            print(instr + " calls reg out of bounds, line: " + line_num)
            exit(1)

        #get args
        arg1 = str('{0:02b}'.format(int(words[1][1:-1]))) #converts 'R1,' to '01'
        arg2 = str('{0:04b}'.format(int(words[2])))       #converts '14' to '1110'

    #write to output file
    dest_file.write(bits_map[instr] + arg1 + arg2 + "\n")
    line_num += 1
    
 