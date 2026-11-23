module decoder24(
	input [1:0]code_in,
	input       en ,
	output[3:0] out
	);
	assign out = en?(4'b0001<<code_in) : 4'b0000;
endmodule
