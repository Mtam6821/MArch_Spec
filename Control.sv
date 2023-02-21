// control decoder
module Control #(parameter opwidth = 3, mcodebits = 4)(
  input [mcodebits-1:0] instr,    	   // subset of machine code (any width you need)
  output logic Branch, 
     MemtoReg, MemWrite, ALUSrc, RegWrite,
  output logic[opwidth-1:0] ALUOp);	   // for up to 8 ALU operations

always_comb begin
// defaults to add
  Branch 	=   'b0;    // 1: branch (jump)
  MemWrite  =   'b0;    // 1: store to memory
  ALUSrc 	=   'b0;    // 1: immediate  0: second reg file output
  RegWrite  =   'b1;    // 0: for store or no op  1: most other operations 
  MemtoReg  =   'b0;    // 1: load -- route memory instead of ALU to reg_file data in
  ALUOp	   =   'b000;  // add;

// override defaults 
case(instr)   
  'b0001:  ALUOp = 'b001;	//sub
  'b0010:  ALUOp = 'b010;	//AND
  'b0011:  ALUOp = 'b011;	//XOR
  'b0100:  ALUOp = 'b100;	//slt

  'b0110:  begin		//load
	  	MemtoReg = 'b1;
		ALUOp = 'b111;	//ALU op doesn't matter	
  	   end
  'b0111:  begin		//store
		MemWrite = 'b1;
		RegWrite = 'b0;
		ALUOp = 'b111; //ALU op doesn't matter
	   end
  'b100X:  ALUOp = 'b101; 	//mov
  'b101X:  begin		//biz
	   Branch   = 'b1;
		RegWrite = 'b0;
		ALUOp = 'b011;	  //check if zero: datA ^ 0
  	   end
  'b110X:  ALUSrc = 'b1;	//addi
  'b111X:  begin
	  	ALUSrc = 'b1;	
	  	ALUOp = 'b110;  //shift in 0 vs parity bit is handled by ALU
	   end
endcase

end
	
endmodule
