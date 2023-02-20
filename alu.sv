// combinational -- no clock
// sample -- change as desired
module alu(
  input[2:0] alu_cmd,    // ALU instructions
  input[7:0] inA, inB,	 // 8-bit wide data path
  input      sc_i,       // shift_carry in
  output logic[7:0] rslt,
  output logic sc_o,     // shift_carry out
               pari,     // reduction XOR (output)
	       zero      // NOR (output)
);

always_comb begin 
  rslt = 'b0;            
  sc_o = 'b0;    
  zero = !rslt;
  pari = ^rslt;
  case(alu_cmd)
    3'b000: // add 2 8-bit unsigned; automatically makes carry-out
      	{sc_o,rslt} = inA + inB + sc_i;
    3'b001: //subtract 2 8-bit unsigned 
	{sc_o,rslt} = inA - inB + sc_i;
    3'b010: //AND
	rslt = inA & inB;
    3'b011: //XOR
	rslt = inA ^ inB;
    3'b100: //slt
	if (inA < inB) begin
	    rslt = 'b0;
	end
	else begin
	    rslt = 'b1;
	end
    3'b101: //move 
	rslt = inB;
    3'b110: //left shift
	if (inB == 0) begin
	    //shift in parity bit
	    rslt[7:1] = inA[6:0];
	    rslt[0]   = sc_i;
	    sc_o      = inA[7];
	end
	else if (inB < 8) begin
	    //left cycle
	    rslt = inA;
	    for (int i = 0; (i < inB && i < 8); i++) begin
		rslt = {rslt[6:0], rslt[7]};
	    end
	end
	else if (inB < 16) begin
	    //shift in 0
		 rslt = inA;
		 for (int i = 0; (i < inB && i < 16); i++) begin
		{sc_o,rslt} = {rslt, sc_i};
		 end
	end
    3'b111: //endian swap
	    for (int i = 0; i < 8; i++) begin
		rslt[7-i] = inA[i];
	    end
  endcase
end
   
endmodule
