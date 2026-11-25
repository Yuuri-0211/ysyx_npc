module reg_files#(parameter AD_W=2,
						parameter DA_W=8)(
						input wire clk,rst,
						//同步写入
						input wire						 rf_en,
						input wire  [DA_W-1:0] wdata_in,
						input wire  [AD_W-1:0] waddr,

						//异步读取
						input wire  [AD_W-1:0]raddr1,
						output  [DA_W-1:0]rdata1_out,
						input wire  [AD_W-1:0]raddr2,
						output  [DA_W-1:0]rdata2_out
						);
	reg [DA_W-1:0]reg_files_mem[0:(1<<AD_W)-1];
	
	integer i;
	always @(posedge clk)begin
		if(rst)begin
				for(i=0;i<(1<<AD_W);i=i+1)begin
						reg_files_mem[i] <= {DA_W{1'b0}};
					end
			end else if(rf_en) begin
						reg_files_mem[waddr] <= wdata_in;
			end
	end

	assign rdata1_out = reg_files_mem[raddr1];
	assign rdata2_out = reg_files_mem[raddr2];

endmodule

