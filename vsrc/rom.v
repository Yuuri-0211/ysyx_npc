module rom #(parameter AD_W=8
						,parameter DA_W=8)(
						input clk,
						input [DA_W-1:0]addr_in,
						output reg [DA_W-1:0]data_out
	);
	reg [DA_W-1:0]rom_mem[0:(1<<AD_W)-1];
	
	initial begin
		//从外部读取文件
		$readmemh("vsrc/rom_data.hex",rom_mem);
	end

	always@(posedge clk)begin
		data_out <= rom_mem[addr_in];
	end
endmodule

