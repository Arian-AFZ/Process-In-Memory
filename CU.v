module CU (
    input [44:0] instruction,
    input clk,
    input rst,
    input mem_ready,
    input operation_enable,
    output reg [31:0] immediate_memory_data,
    output reg memory_write,
    output reg memory_read,
    output reg mux_select,
    output reg [9:0] memory_address,
    output reg reg_select,
    output reg reg_load_enable,
    output [1:0] alu_opcode,
    output reg ready
);

    reg [44:0] inst_reg;
    reg [2:0] inner_counter;

    assign alu_opcode = inst_reg[43:42];

    always @(posedge rst) begin
        inner_counter <= 3'b000;
        memory_write <= 1'b0;
        memory_read <= 1'b0;
        reg_load_enable <= 1'b0;
        mux_select <= 1'b1;
	    ready <= 1'b1;
    end

    always @(posedge clk) begin
        if (rst == 1'b0) begin
            if ((ready == 1'b1) && (operation_enable == 1'b1)) begin
                ready = 1'b0;
                inst_reg = instruction;
                inner_counter = 3'b001;
                if ((~inst_reg[44]) & (inst_reg[43] | inst_reg[42])) begin // Write
                    memory_address <= inst_reg[41:32];
                    immediate_memory_data <= inst_reg[31:0];
                    mux_select <= 1'b1;
                    #2  memory_write = 1'b1;
                    #12 memory_write = 1'b0;
                end
                else if (~(inst_reg[44] | inst_reg[43] | inst_reg[42])) begin // Read
                    memory_address = inst_reg[41:32];    
                    #2  memory_read = 1'b1;
                    #12 memory_read = 1'b0;
                end
                else if (inst_reg[44]) begin // Fetch the first ALU operand
                    reg_select <= 1'b0;
                    memory_address <= inst_reg[41:32];
                    #2  memory_read = 1'b1;
                    #12 memory_read = 1'b0;
                end
            end
        end
    end

    always @(posedge mem_ready) begin
        if (rst == 1'b0) begin
            if (!inst_reg[44]) begin // If the operation was a simple read or write, we are done
                if (inner_counter == 3'b001) begin
                    inner_counter <= 3'b000;
                    ready <= 1'b1;
                end
            end
            else begin
                if (inner_counter == 3'b001) begin
                    reg_load_enable <= 1'b1; //  Load the result of memory fetch to the first register
                    memory_address <= inst_reg[31:22]; // The next task of memory is to read from src2, indicated in field B
                    #10 reg_load_enable = 1'b0; // Wait for the load to complete
                    reg_select <= 1'b1; // Select the second register to load next fetched data in
                    memory_read <= 1'b1;
                    #12 memory_read <= 1'b0;
                    inner_counter <= inner_counter + 1;  // The control unit is done in this block
                end
                else if (inner_counter == 3'b010) begin
                    reg_load_enable = 1'b1; // Load the result of second memory fetch to the second register
                    mux_select <= 1'b0; // Data will be written into memory from ALU's output
                    memory_address <= inst_reg[21:12]; // Field C determines operation destination
                    #10 reg_load_enable <= 1'b0; // Wait for register to load data and ALU to calculate the final result of operating on the two numbers
                    memory_write <= 1'b1; // Initiate the write command to memory
                    #12 memory_write <= 1'b0;
                    inner_counter <= inner_counter + 1;  // The control unit is done in this block.
                end
                else if (inner_counter == 3'b011) begin // All three operations (read, read, write) are done now.
                    ready <= 1'b1;
                    inner_counter <= 3'b0;
                end
            end
        end
    end
endmodule

/*
Write Scenario
    instruction first three bits: 011, 010, 001
    memory_write = 1
    memory_read = 0
    memory_address = A
    memory_data_in = D
    ready = 0
    mux_select = 1
    ----- memory ready posedge ---
    ready = 1
    memory_write = 0

Read Scenario
    instruction first three bits: 000
    memory_write = 0
    memory_read = 1
    memory_address = A
    ready = 0
    --- memory ready posedge ---
    ready = 1
    memory_read = 0
    

ALU Scenario
    instruction first bit: 1
    memory_wirte = 0
    memory_read = 1
    memory_address = A
    reg_select = 0
    load_enable = 0
    #10 memory_read = 0
    --- memory ready posedge ---
    load_enable <= 1
    memory_address <= B
    #5 load_enable = 0 (wait for load to complete, then swith to the other register)
    reg_select = 1 
    memory_read = 1
    #10 memory_read = 0
    --- memory ready posedge ---
    load_enable = 1
    #10 load_enable = 0 (wait for register to load data and ALU to calculate the final result of operating on the two numbers)
    memory input MUX = get input from ALU's output
    memory_address = C
    #2 (wait for output of MUX to be updated)
    memory_read = 0
    memory_write = 1
    --- memory ready posedge ---
    ready = 1
*/