module program_decoder(
	input [1:0]opcode,
	output opcode_alu,
	output opcode_io,
	output opcode_imm,
	output opcode_cond
	);
	assign opcode_alu = (opcode == 2'b00);
	assign opcode_io = (opcode == 2'b01);
	assign opcode_imm = (opcode == 2'b10);
	assign opcode_cond = (opcode == 2'b11);
endmodule

