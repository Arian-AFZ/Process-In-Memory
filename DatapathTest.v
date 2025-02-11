module DatapathTest;
	reg reg_select;
	reg [31:0] load_data;
	reg load_enable;
	reg [1:0] opcode;
	wire [31:0] out;
	DataPath dp(reg_select, load_data, load_enable, opcode, out);
	initial begin
		reg_select = 1'b0;
		load_enable = 1'b0;
		opcode = 2'b00;
		load_data = 32'h44332211;
		#5 load_enable = 1'b1;
		#5 load_enable = 1'b0;
		#5 load_data = 32'h11223344; reg_select = 1'b1;
		#5 load_enable = 1'b1;
		#5 load_enable = 1'b0;
		#5 opcode = 2'b01;
		#5 opcode = 2'b10;
		#5 opcode = 2'b11;
		#5 $stop;
	end
endmodule
