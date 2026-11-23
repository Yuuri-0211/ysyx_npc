module alu #(parameter W=4)(
	input  [W-1:0] a,
	input  [W-1:0] b,
	input  [2:0] mode,
	output [W-1:0] out,
	output         overflow,
	output				 zero,
	output         carry
	);
//add
	wire [W-1:0] add_sum;
	wire add_overflow,add_zero,add_carry;
	add #(.W(W)) u_add(
										.a(a),
										.b(b),
										.cin(1'b0),
										.sum(add_sum),
										.overflow(add_overflow),
										.zero(add_zero),
										.out_carry(add_carry)
										);
	wire [W+2:0] add_package = {add_sum,add_overflow,add_zero,add_carry};
//add
//sub
	wire [W-1:0] sub_sum;
	wire sub_overflow,sub_zero,sub_carry;
	add #(.W(W)) u_sub(
										.a(a),
										.b(~b),
										.cin(1'b1),
										.sum(sub_sum),
										.overflow(sub_overflow),
										.zero(sub_zero),
										.out_carry(sub_carry)
										);
	wire [W+2:0] sub_package = {sub_sum,sub_overflow,sub_zero,sub_carry};
//sub
//not
	wire [W-1:0] not_A = ~a;
	wire [W+2:0] not_package = {not_A,1'b0,not_A==0,1'b0}; 
//not
//and
	wire [W-1:0] and_a_b = a&b;
	wire [W+2:0] and_package = {and_a_b,1'b0,and_a_b==0,1'b0};
//and
//or
	wire [W-1:0] or_a_b = a|b;
	wire [W+2:0] or_package = {or_a_b,1'b0,or_a_b==0,1'b0};
//or
//xor
	wire [W-1:0] xor_a_b = a^b;
	wire [W+2:0] xor_package = {xor_a_b,1'b0,xor_a_b==0,1'b0};
//xor
//a less than b
	wire signed_less_than = (a[W-1] & ~b[W-1])|(~(a[W-1]^b[W-1]) & sub_sum[W-1]);//要么a为负，b为正，要么ab同号但减法结果为负
	wire [W+2:0]lt_package = {{(W-1){1'b0}},signed_less_than,1'b0,~signed_less_than,1'b0};
//a less than b
//a equal b
	wire [W+2:0]equal_package = {{(W-1){1'b0}},sub_zero,1'b0,~sub_zero,1'b0};
//a equal b
//mux
	wire [W+2:0] mux_out;
	MuxKey #(.NR_KEY(8),
		.KEY_LEN(3),
		.DATA_LEN(W+3)
		) u_mux(
						.out(mux_out),
						.key(mode),
						.lut({
									3'b000,add_package,
									3'b001,sub_package,
									3'b010,not_package,
									3'b011,and_package,
									3'b100,or_package,
									3'b101,xor_package,
									3'b110,lt_package,
									3'b111,equal_package
									})
						)	;
	assign out = mux_out[W+2:3];
	assign overflow = mux_out[2];
	assign zero = mux_out[1];
	assign carry = mux_out[0];
//mux

endmodule

module add #(parameter W=4)(
	input  [W-1:0]  a,
	input  [W-1:0]  b,
	input         cin,
	output [W-1:0]sum,
	output   overflow,
	output       zero,
	output  out_carry
);
	wire [W:0]result={1'b0,a}+{1'b0,b}+{{(W){1'b0}},cin};
	assign sum = result[W-1:0];
	assign out_carry=result[W];
	assign overflow = (a[W-1]==b[W-1])&&(sum[W-1]!=a[W-1]);
	assign zero = !(|sum);
endmodule
	
