module seg(
	input  wire[7:0]data,
	output reg [7:0]high,
	output reg [7:0]low
	);
	wire [3:0]high_seg = data[7:4];
	wire [3:0]low_seg = data[3:0];
	always@(*)begin
		case(high_seg)
			4'h0: high = 8'b1100_0000;
			4'h1: high = 8'b1111_1001;
			4'h2: high = 8'b1010_0100;
			4'h3: high = 8'b1011_0000;
			4'h4: high = 8'b1001_1001;
			4'h5: high = 8'b1001_0010;
			4'h6: high = 8'b1000_0010;
			4'h7: high = 8'b1111_1000;
			4'h8: high = 8'b1000_0000;
			4'h9: high = 8'b1001_0000;
			4'hA: high = 8'b1000_1000;
			4'hB: high = 8'b1000_0011;
			4'hC: high = 8'b1100_0110;
			4'hD: high = 8'b1010_0001;
			4'hE: high = 8'b1000_0110;
			4'hF: high = 8'b1000_1110;
		endcase
	end 
	always@(*)begin
		case(low_seg)
			4'h0: low = 8'b1100_0000;
			4'h1: low = 8'b1111_1001;
			4'h2: low = 8'b1010_0100;
			4'h3: low = 8'b1011_0000;
			4'h4: low = 8'b1001_1001;
			4'h5: low = 8'b1001_0010;
			4'h6: low = 8'b1000_0010;
			4'h7: low = 8'b1111_1000;
			4'h8: low = 8'b1000_0000;
			4'h9: low = 8'b1001_0000;
			4'hA: low = 8'b1000_1000;
			4'hB: low = 8'b1000_0011;
			4'hC: low = 8'b1100_0110;
			4'hD: low = 8'b1010_0001;
			4'hE: low = 8'b1000_0110;
			4'hF: low = 8'b1000_1110;
		endcase
	end 
endmodule
