module DemuxKey #(
    parameter NR_KEY   = 8,  // 输出通道数 (2^KEY_LEN)
    parameter KEY_LEN  = 3,  // 地址位宽 (3位地址可以选8个通道)
    parameter DATA_LEN = 8   // 数据位宽
)(
    input  wire                      [KEY_LEN-1:0] key,      // 地址选择
    input  wire                      [DATA_LEN-1:0] data_in,  // 输入数据
    output reg  [NR_KEY*DATA_LEN-1:0] data_out               // 扁平化的输出总线
);

    integer i;

    always @(*) begin
        // 1. 默认所有通道全部输出 0
        data_out = {NR_KEY*DATA_LEN{1'b0}};
        
        // 2. 将输入数据放到对应通道的位置
        data_out[key*DATA_LEN +: DATA_LEN] = data_in;//[起始位 +:位宽]等价于[起始位+位宽-1:起始位]
    end

endmodule

