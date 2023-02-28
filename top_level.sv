// sample top level design
module top_level(
  input        clk, reset, req, 
  output logic done);
  parameter D = 10,          // program counter width
    A = 3;             		  // ALU command bit width
  wire[D-1:0] target, 		  // jump target 
              prog_ctr;
  wire[7:0]   datA,datB,	  // from RegFile
              muxB, 			  // see ALUSrc
				  muxC,			  // writeback alu rslt or memory
			     ALU_rslt,      // alu output
              immed;
  logic sc_in,   				  // shift/carry out from/to ALU
   	  pariQ,               // registered parity flag from ALU
		  zeroQ;               // registered zero flag from ALU 
  wire  jump,                // from ALU to PC; take branch
		  biz,					  // from Control to ALU, indicates if branch possible
		  pari,
        zero,
		  RegWrite,	  
		  sc_clr,
		  sc_en,
        MemWrite,
		  MemtoReg,
        ALUSrc;		             // immediate switch
  wire[A-1:0] alu_cmd;				 // alu op bits
  wire[8:0]   mach_code;          // machine code
  wire[2:0]   rd_addrA, rd_adrB;  // address pointers to reg_file
// fetch subassembly
  PC #(.D(D)) 					     // D sets program counter width
     pc1 (.reset            ,
          .clk              ,
		    .absjump_en (jump),	  //jump iff datA = 0 and branch = 1
		    .target(datB)     ,   //Upper bits taken from second op reg when jumping
		    .prog_ctr          ); //current PC

		 
		 /* removed, not needed
// lookup table to facilitate jumps/branches
  PC_LUT #(.D(D))
    pl1 (.addr  (how_high),
         .target          ); 
	*/		


// contains machine code
  instr_ROM ir1(.prog_ctr,		  //input: PC
                .mach_code);	  //output: instruction at PC

// control decoder
  Control ctl1(.instr(mach_code[8:5]),
  .Branch(biz),			//indicates if biz instruction
  .MemWrite, 				//only for stores
  .ALUSrc,        		//for I-type instructions (never 1 with MemWrite)
  .RegWrite,      		//for writeback to reg file
  .MemtoReg(MemtoReg),	//write ALU or memory data
  .ALUOp());				//ALUOp 

  assign rd_addrA = 	(mach_code[8] == 0) ? mach_code[4:2] :
							(mach_code[7] == 0) ? mach_code[5:3] :
														 mach_code[5:4];
  assign rd_addrB = 	(mach_code[8] == 0) ? mach_code[1:0] :
							(mach_code[7] == 0) ? mach_code[2:0] :
														 mach_code[5:4];	//doesn't matter, will be ignored by muxB
  assign immed    = mach_code[3:0]; 
  
  reg_file #(.pw(3)) rf1(.dat_in(muxC),	//write back either ALU op or memory
				 .clk,
             .wr_en   (RegWrite),			//enable write to reg
             .rd_addrA(rd_addrA),			//address of first reg (and destination in all ALU OPs)
             .rd_addrB(rd_addrB),			//second operand reg
             .wr_addr (rd_addrA),      	// in place operation
             .datA_out(datA),
             .datB_out(datB)); 

  assign muxB = ALUSrc? immed : datB;

  alu alu1(.alu_cmd(ALUOp),
			  .branch(biz),	
           .inA(datA),
		     .inB(muxB),
		     .sc_i(sc),   // output from sc register
		     .rslt(ALU_rslt), // ALU rslt
		     .sc_o(sc_o), // input to sc register
		     .pari);  
			 
  assign jump = ALU_rslt & !biz;
			  
  dat_mem dm1(.dat_in(datA)  ,  	 //data from Reg file
              .clk           ,
			     .wr_en  (MemWrite), //for store instructions
			     .addr   (datB),		 //direct memory addr stored in reg
              .dat_out(mem_out)); //data out for writeback
				  
  assign muxC = MemtoReg ? ALU_rslt : mem_out;	//ALU or memory for writeback stage 

// registered flags from ALU
  always_ff @(posedge clk) begin
    pariQ <= pari;
	zeroQ <= zero;
    if(sc_clr)
	  sc_in <= 'b0;
    else if(sc_en)
      sc_in <= sc_o;
  end

  assign done = prog_ctr == 1020;
 
endmodule
