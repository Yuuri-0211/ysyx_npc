module PC #(parameter W)(
	input [W-1:0] write_data,
	input wen,clk,rst,
	output reg [W-1:0] out
	);
wire [W-1:0]reg_in;
wire [W-1:0]add_out;
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
MuxKey #(2,1,W) u_mux(
	.out(reg_in),
	.key(wen),
	.lut({1'b0,add_out,
				1'b1,write_data
			 })
	);
add #(.W(W)) u_add(
	.a(out),
	.b({(W){1'b0}}),
	.cin(1'b1),
	.sum(add_out),
	.overflow(),
	.zero(),
	.out_carry()
	);
Reg #(.WIDTH(W),.RESET_VAL(0)) u_reg(
	.clk(clk),
	.rst(rst),
	.wen(clk_count_1s),//1秒使能放这里还挺有说法的，不然也是默认1
	.din(reg_in),
	.dout(out)
	);
endmodule

