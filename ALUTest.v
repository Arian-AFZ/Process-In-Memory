module ALUTest;
	reg [31:0] a, b;
	reg [1:0] opcode;
	wire [31:0] result;
	ALU alu(.A(a), .B(b), .opcode(opcode), .out(result));
	
	initial begin
		a <= 32'h12345678;
		b <= 32'h87654321;
		# 5 opcode = 2'b00;
		# 5 opcode = 2'b01;
		# 5 opcode = 2'b10;
		# 5 opcode = 2'b11;
		# 5 $stop;
	end
endmodule