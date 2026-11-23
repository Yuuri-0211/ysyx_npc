module decoder38(
	input [2:0]code_in,
	input       en ,
	output[7:0] out
	);
	assign out = en?(8'b0000_0001<<code_in) : 8'b0000_0000;
endmodule

