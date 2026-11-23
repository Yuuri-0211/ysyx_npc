module sCPU(
	input  [7:0] data_load,
	input  wen,clk,rst,
	output [7:0] seg1_high,
	output [7:0] seg1_low,
	output [7:0] seg2_high,
	output [7:0] seg2_low
);						
	reg [7:0] reg_pc;
	reg [7:0] reg_rom;
	PC #(.W(8)) u_PC(
		.write_data(data_load),
		.wen(wen),
		.clk(clk),
		.rst(rst),
		.out(reg_pc)
		);
	seg u_seg1(
		.data(reg_pc),
		.high(seg1_high),
		.low(seg1_low)
	);
	rom #(.AD_W(8),
				.DA_W(8)) u_rom(
				.addr_in(reg_pc),
				.clk(clk),
				.data_out(reg_rom)
				);
	seg u_seg2(
		.data(reg_rom),
		.high(seg2_high),
		.low(seg2_low)
	);
endmodule

