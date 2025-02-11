module CUTest;
	reg [44:0] instruction;
	reg clk;
	reg rst;
	wire mem_ready;
	reg operation_enable;
	wire [31:0] immediate_memory_data;
	wire memory_write;
	wire memory_read;
	wire mux_select;
	wire [9:0] memory_address;
	wire reg_select;
	wire reg_load_enable;
	wire [1:0] alu_opcode;
	wire ready;

	CU cu(instruction, clk, rst, mem_ready, 
	operation_enable, immediate_memory_data, memory_write, memory_read,
	mux_select, memory_address, reg_select, reg_load_enable, alu_opcode, ready);	

	Memory ram(.address(memory_address), .data_in(immediate_memory_data),
	.write(memory_write), .read(memory_read), .clock(clk), .rst(rst), .ready(mem_ready));

	 task write_to_memory(input [9:0] address, input [31:0] data); begin
		operation_enable = 1'b1;
                instruction = {3'b001, address, data[31:0]}; // Write to memory
                #15 operation_enable = 1'b0;
		#45;
        end endtask

        task read_from_memory(input [9:0] address); begin
		operation_enable = 1'b1;
                instruction = {3'b000, address, 32'b0}; // Read from memory
                #15 operation_enable = 1'b0;
		#45;
        end endtask

        task perform_alu_op(input [1:0] alu_opcode, input [9:0] src1, input [9:0] src2, input [9:0] dst); begin
		operation_enable = 1'b1;
                instruction = {1'b1, alu_opcode, src1, src2, dst, 12'b0}; // Perform ALU operation
		#15 operation_enable = 1'b0;
                #200;
        end endtask

	always #5 clk = ~clk;

	initial begin
		clk = 1'b0;
		rst = 1'b0;
		operation_enable = 1'b0;
		#3 rst = 1'b1;
		#5 rst = 1'b0;
		write_to_memory(10'b1110001010, 32'h12345678);
		read_from_memory(10'b1110001010);
		perform_alu_op(2'b01, 10'b0, 10'b1110001010, 10'h45);
		#5 $stop;
	end
	
endmodule