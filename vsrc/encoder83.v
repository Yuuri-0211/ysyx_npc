module encoder83 (
    input  wire [7:0] in,
    output wire [2:0] code_out
    //output wire       valid
);

    // 1. 三目运算符实现优先级（相当于 if-else 的嵌套）
    // 语法：条件 ? 成立时的值 : 不成立时的值
    assign code_out = in[7] ? 3'd7 :
                 in[6] ? 3'd6 :
                 in[5] ? 3'd5 :
                 in[4] ? 3'd4 :
                 in[3] ? 3'd3 :
                 in[2] ? 3'd2 :
                 in[1] ? 3'd1 :
                 in[0] ? 3'd0 : 3'd0; // 最后一个 3'd0 是兜底的默认值

    // 2. 归约运算符 | (Reduction OR) 判断是否全为 0
    // |in 的意思是把 8 位输入按位或起来，只要有任何一个 1，结果就是 1
    //assign valid = |in; 

endmodule

