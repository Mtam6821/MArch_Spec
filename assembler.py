import sys

# check args
if (len(sys.argv) != 2):
    print("Usage: python3 assembler.py <assembly file>\n")
    print("Generates a machine-code file for MArch at output.txt")


#open necessary files
dest_file = open("output.txt", "w")
src_file = open(sys.argv[1], "r")

#get each instruction in a line
lines = src_file.readlines()
line_num = 0
for line in lines:
    words = line.split()    #get each word in assembly file
    instr = words[0]
    
    
    #write opcode + func bits, then convert operand regs to binary and write, then newline for each line
    if (instr == "add"):
        if int(words[1][1:]) > 7 or int(words[2][1:]) > 4:
            print("Reg out of bounds, line: " + line_num)
            exit(1)
        arg1 = str('{0:03b}'.format(int(words[1][1:]))) #converts 'R1' to '001'
        arg2 = str('{0:02b}'.format(int(words[2][1:]))) #converts 'R1' to '01'
        dest_file.write("0000" +  + "\n")
    elif (instr == "sub"):
        if int(words[1][1:]) > 7 or int(words[2][1:]) > 4:
            print("Reg out of bounds, line: " + line_num)
            exit(1)
        arg1 = str('{0:03b}'.format(int(words[1][1:]))) #converts 'R1' to '001'
        arg2 = str('{0:02b}'.format(int(words[2][1:]))) #converts 'R1' to '01'
        dest_file.write("0001" +  + "\n")
    else:
        #unexpected instruction error
        print("Unexpected instruction in " + sys.argv[1] + ", line: " + line_num)
        exit(1)
    line_num += 1
    
 