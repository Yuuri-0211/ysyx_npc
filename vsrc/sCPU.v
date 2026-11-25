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
	output cond_led,
	//io
	input [7:0] switch_i
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
	wire [7:0] w_data_in;
	assign w_data_in = reg_pc+{{5{reg_rom[5]}},reg_rom[4:2]};
	PC #(.W(8)) u_PC(
		.write_data(w_data_in),
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
	wire [1:0]raddr2_io;
	wire	[2:0] o_idx;
	wire [2:0] i_idx;
	wire [2:0] i_o_idx;
	wire i_o;
	reg [7:0]rdata1_out;
	reg [7:0]rdata2_out;
	wire [7:0]io_seg001;
	reg [63:0]io_temp;
	wire [7:0]i_bus;
	wire rf_wen;
	assign raddr2 = reg_rom[3:2];
	assign raddr1 = reg_rom[1:0];
	assign rdest = reg_rom[5:4];
	assign rf_wen = opcode_alu | opcode_imm | ((~i_o)&opcode_io);  
	assign i_o_idx = reg_rom[2:0];
	assign i_o = reg_rom[3];
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
		.raddr2(raddr2_io),
		.rdata2_out(rdata2_out)
		);

	seg u_seg3(
		.data(io_seg001),//其实监视已经可以不用了，因为要写io口了
		.high(seg3_high),
		.low(seg3_low)
		);
	DemuxKey #(
	.NR_KEY(8),
	.KEY_LEN(3),
	.DATA_LEN(8)
	) u_demux(
	.key(o_idx),
	.data_in(rdata2_out),
	.data_out(io_temp)
	);
	MuxKey #(
	.NR_KEY(8),
	.KEY_LEN(3),
	.DATA_LEN(8)
	) u_i_mux(
	.out(i_bus),
	.key(i_idx),
	.lut({
			3'b000,8'b0,
			3'b001,8'b0,
			3'b010,switch_i,
			3'b011,8'b0,
			3'b100,8'b0,
			3'b101,8'b0,
			3'b110,8'b0,
			3'b111,8'b0
		})
	);
	Reg #(//io口的o的001个输出，是两个七段数码管
	.WIDTH(8),
	.RESET_VAL(0)
	)u_io_temp001_reg(
	.clk(clk_count_1s),
	.rst(rst|hand_rst),//因为所有寄存器都是同步复位，所以这里还是或一个东西吧，其实是第一遍忘记hand_rst了哈哈哈
	.din(io_temp[15:8]),
	.wen(((~o_idx[2])&(~o_idx[1])&o_idx[0])&(opcode_io&i_o)),
	.dout(io_seg001)
	);
	MuxKey #(
	.NR_KEY(2),
	.KEY_LEN(1),
	.DATA_LEN(2)
	)u_io_alu_mux(
	.out(raddr2_io),
	.key(opcode_io&i_o),
	.lut({
			1'b0,raddr2,
			1'b1,rdest
		})
	);
	DemuxKey #(
	.NR_KEY(2),
	.KEY_LEN(1),
	.DATA_LEN(3)
	) u_i_o_demux(
	.key(i_o),
	.data_in(i_o_idx),
	.data_out({o_idx,i_idx})
	);
	//data_bus
	reg [7:0]data_bus_in;
	wire[7:0]imm_bus;
	wire [7:0] imm_data;//直接补齐全补0
	wire [2:0] shift_s;//直接补齐防止移位后益处，两位不够用的
	
	assign imm_data = {{6{1'b0}},reg_rom[1:0]};
	assign shift_s = {1'b0,reg_rom[3:2]};
	assign imm_bus = imm_data<<(shift_s<<1);
	MuxKey#(4,2,8) u_mux_data_bus(
		.out(data_bus_in),
		.key(opcode),
		.lut({
			2'b00,alu_out,
			2'b01,i_bus,
			2'b10,imm_bus,
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
		.opcode_io(opcode_io),
		.opcode_imm(opcode_imm),
		.opcode_cond(opcode_cond)
									);
	//program_decoder
	//cond
	reg cond_out;
	cond u_cond(
		.mode_cond(3'b011),
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

