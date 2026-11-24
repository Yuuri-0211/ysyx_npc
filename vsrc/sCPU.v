module sCPU(
	//PC out
	//input  [7:0] data_load,
	input  pc_load,clk,rst,hand_rst,
	output [7:0] seg1_high,
	output [7:0] seg1_low,

	//rom out
	output [7:0] seg2_high,
	output [7:0] seg2_low,

	//reg_file out
	output [7:0] seg3_high,
	output [7:0] seg3_low,
	output [7:0] seg4_high,
	output [7:0] seg4_low,
	//cond
	output cond_led
);						

	//pc	
	reg [7:0] reg_pc;
	PC #(.W(8)) u_PC(
		.write_data({4'b0000,reg_rom[5:2]}),
		.pc_load(pc_load|(cond_out&opcode_cond)),
		.clk(clk),
		.rst(rst|hand_rst),
		.out(reg_pc)
		);
	seg u_seg1(
		.data(reg_pc),
		.high(seg1_high),
		.low(seg1_low)
	);
	//pc
	//rom	
	reg [7:0] reg_rom;
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
	//rom
	//reg_files
	wire [1:0]raddr1=2'b00;
	wire [1:0]raddr2=2'b01;
	wire [7:0]rdata1_out;
	wire [7:0]rdata2_out;
	reg_files #(
		.AD_W(2),
		.DA_W(8)) u_reg_files(
		.clk(clk),
		.rst(rst|hand_rst),
		.rf_en(opcode_imm),
		.wdata_in({{4'b0000},reg_rom[3:0]}),
		.waddr(reg_rom[5:4]),
		.raddr1(raddr1),
		.rdata1_out(rdata1_out),
		.raddr2(raddr2),
		.rdata2_out(rdata2_out)
												);
	seg u_seg3(
		.data(rdata1_out),
		.high(seg3_high),
		.low(seg3_low)
	);
	seg u_seg4(
		.data(rdata2_out),
		.high(seg4_high),
		.low(seg4_low)
	);
	//reg_files
	//program_decoder
	wire opcode_alu,opcode_io,opcode_imm,opcode_cond;
	program_decoder u_program_decoder(
		.opcode(reg_rom[7:6]),
		.opcode_alu(),
		.opcode_io(),
		.opcode_imm(opcode_imm),
		.opcode_cond(opcode_cond)
									);
	//program_decoder
	//cond
	wire cond_out;
	cond u_cond(
		.mode_cond(3'b010),
		.data_in(rdata1_out),
		.cond(cond_out)
	);
	assign cond_led = pc_load|(cond_out&opcode_cond);
	//cond

endmodule

