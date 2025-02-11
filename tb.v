module tb;
        reg clk;
        reg [44:0] instruction;
        reg rst;
	reg operation_enable;
        wire [31:0] result;
        wire ready;

        PIM pim (
                .clk(clk),
                .instruction(instruction),
                .data_out(result),
		.rst(rst),
		.ready(ready),
		.operation_enable(operation_enable)
        );

        // Clock generation
        always #5 clk = ~clk;

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

        task perform_alu_op(input [2:0] alu_opcode, input [9:0] src1, input [9:0] src2, input [9:0] dst); begin
		operation_enable = 1'b1;
                instruction = {alu_opcode, src1, src2, dst, 12'hABC}; // Perform ALU operation. The last 12 bits should be ignored.
		#15 operation_enable = 1'b0;
                #200;
        end endtask

        initial begin
                clk = 0;
		operation_enable = 1'b0;
                $display("Starting Testbench...");
		rst = 1'b0;
		#1 rst = 1'b1;
		#17 rst = 1'b0;

                // Initialize memory with edge case values
                write_to_memory(10'h000, 32'h7FFFFFFF); // Largest positive 32-bit integer
                write_to_memory(10'h001, 32'h80000000); // Smallest negative 32-bit integer
                write_to_memory(10'h002, 32'h00000000); // Zero
                write_to_memory(10'h003, 32'hFFFFFFFF); // All bits set (unsigned -1)
                write_to_memory(10'h004, 32'h00000001); // One
                write_to_memory(10'h3FF, 32'h12345678); // Random value at the last address

                // Verify writes by reading back
                $display("Verifying initial memory writes...");
                read_from_memory(10'h000);
                $display("Address 0x000: %h", result);
                read_from_memory(10'h001);
                $display("Address 0x001: %h", result);
                read_from_memory(10'h002);
                $display("Address 0x002: %h", result);
                read_from_memory(10'h003);
                $display("Address 0x003: %h", result);
		read_from_memory(10'h004);
                $display("Address 0x004: %h", result);
                read_from_memory(10'h3FF);
                $display("Address 0x3FF: %h", result);
                
                // Perform ALU operations
                $display("\nPerforming ALU operations...");

                // ADD: 0x7FFFFFFF + 0x00000001 -> Overflow expected
                perform_alu_op(3'b100, 10'h000, 10'h004, 10'h010); // ADD, write result to 0x010
                read_from_memory(10'h010);
                $display("ADD (0x7FFFFFFF + 0x00000001): %h", result);

                // SUB: 0x80000000 - 0x00000001 -> Underflow expected
                perform_alu_op(3'b101, 10'h001, 10'h004, 10'h011); // SUB, write result to 0x011
                read_from_memory(10'h011);
                $display("SUB (0x80000000 - 0x00000001): %h", result);

                // AND: 0xFFFFFFFF & 0x12345678
                perform_alu_op(3'b110, 10'h003, 10'h3FF, 10'h012); // AND, write result to 0x012
                read_from_memory(10'h012);
                $display("AND (0xFFFFFFFF & 0x12345678): %h", result);

                // OR: 0x00000000 | 0x12345678
                perform_alu_op(3'b111, 10'h002, 10'h3FF, 10'h013); // OR, write result to 0x013
                read_from_memory(10'h013);
                $display("OR ( 0x00000000 | 0x12345678): %h", result);

                $stop;
        end
        initial begin
        $dumpfile("results.vcd");
        $dumpvars(0, tb);
    end
endmodule