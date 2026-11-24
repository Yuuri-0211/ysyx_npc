module sCPU(
	//PC out
	input  clk,rst,hand_rst,
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
//慢点
reg [31:0]count;
reg clk_count_1s;
	always@(posedge clk) begin
		if(rst) begin
			count <= 0;
			clk_count_1s <= 0;
		end else begin
			if(count>=5000000) begin
				count <= 0;
				clk_count_1s <= 1;
			end else begin
				count <= count + 1;
				clk_count_1s <= 0;
			end
		end
	end
//慢点
	//pc	
	reg [7:0] reg_pc;
	PC #(.W(8)) u_PC(
		.write_data({4'b0000,reg_rom[5:2]}),
		.pc_load(cond_out&opcode_cond),
		.clk(clk_count_1s),
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
				//.clk(clk_count_1s),
				.data_out(reg_rom)
				);
	seg u_seg2(
		.data(reg_rom),
		.high(seg2_high),
		.low(seg2_low)
	);
	//rom
	//reg_files
	wire [1:0]raddr1;
	wire [1:0]raddr2;
	wire [1:0]rdest;
	reg [7:0]rdata1_out;
	reg [7:0]rdata2_out;
	reg [7:0]dbg_reg0;
	wire rf_wen;
	assign raddr2 = reg_rom[3:2];
	assign raddr1 = reg_rom[1:0];
	assign rdest = reg_rom[5:4];
	assign rf_wen = opcode_alu | opcode_imm; 
	reg_files #(
		.AD_W(2),
		.DA_W(8)) u_reg_files(
		.clk(clk_count_1s),
		.rst(rst|hand_rst),
		.rf_en(rf_wen),
		.wdata_in(data_bus_in),
		.waddr(rdest),
		.raddr1(raddr1),
		.rdata1_out(rdata1_out),
		.raddr2(raddr2),
		.rdata2_out(rdata2_out),
		.dbg_reg0(dbg_reg0)
		);
	seg u_seg3(
		.data(dbg_reg0),//这里专门监控reg0吧
		.high(seg3_high),
		.low(seg3_low)
		);
	//data_bus
	reg [7:0]data_bus_in;
	MuxKey#(4,2,8) u_mux_data_bus(
		.out(data_bus_in),
		.key(opcode),
		.lut({
			2'b00,alu_out,
			2'b01,8'b0000_0000,
			2'b10,{{4'b0000},reg_rom[3:0]},
			2'b11,8'b0000_0000
			})
		);
	seg u_seg4(
		.data(data_bus_in),
		.high(seg4_high),
		.low(seg4_low)
		);
	//data_bus
	//reg_files
	//program_decoder
	reg opcode_alu,opcode_io,opcode_imm,opcode_cond;
	wire [1:0]opcode;
	assign opcode = reg_rom[7:6];
	program_decoder u_program_decoder(
		.opcode(opcode),
		.opcode_alu(opcode_alu),
		.opcode_io(),
		.opcode_imm(opcode_imm),
		.opcode_cond(opcode_cond)
									);
	//program_decoder
	//cond
	reg cond_out;
	cond u_cond(
		.mode_cond(3'b010),
		.data_in(rdata1_out),
		.cond(cond_out)
	);
	assign cond_led = cond_out&opcode_cond;
	//cond
	//alu
	reg [7:0]alu_out;
	alu #(.W(8)) u_alu(
		.a(rdata1_out),
		.b(rdata2_out),
		.mode(3'b000),
		.out(alu_out),
		.overflow(),
		.zero(),
		.carry()
		);
	//alu
endmodule

