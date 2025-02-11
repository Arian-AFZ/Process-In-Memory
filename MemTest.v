module MemTest;
	reg [9:0] address;
	reg [31:0] data_in;
	reg write, read, clock;
   	wire [31:0] data_out;
	wire ready;
	Memory m(address, data_in, write, read, clock, data_out, ready);
	initial clock = 1'b0;
	always #5 clock = ~clock;
	initial begin
		address <= 10'b0;
		data_in <= 32'hfa350123;
		write = 1'b1;
		read = 1'b0;
		wait(ready);
		write = 1'b0;
		read = 1'b1;
		#30
		read = 1'b0;
		#20 $stop;		
	end
endmodule