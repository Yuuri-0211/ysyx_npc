module cond(
	input [2:0]mode_cond,
	input [7:0]data_in,
	output cond
	);
	wire cond_never = 1'b0;
	wire cond_always = 1'b1;
	wire cond_zero = ~(|data_in);
	wire cond_not_zero = (|data_in);
	wire cond_less_than_zero = data_in[7];
	wire cond_more_equal_zero = ~(data_in[7]);
	wire cond_less_equal_zero = cond_less_than_zero|cond_zero;
	wire cond_more_than_zero = ~cond_less_equal_zero;
	MuxKey #(
	.NR_KEY(8),
	.KEY_LEN(3),
	.DATA_LEN(1)) u_mux(
	.out(cond),
	.key(mode_cond),
	.lut({
		3'b000,cond_never,
		3'b001,cond_always,
		3'b010,cond_zero,
		3'b011,cond_not_zero,
		3'b100,cond_less_than_zero,
		3'b101,cond_more_equal_zero,
		3'b110,cond_less_equal_zero,
		3'b111,cond_more_than_zero		
			})
	);
endmodule

