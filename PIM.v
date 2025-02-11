module PIM (
    input [44:0] instruction,
    input clk,
    input rst,
    input operation_enable,
    output ready,
    output [31:0] data_out
);
    // Control Unit outputs
    wire memory_write, memory_read, mux_select;
    wire [9:0] memory_address;
    wire reg_select, reg_load_enable;
    wire [1:0] alu_opcode;
    wire [31:0] immediate_memory_data;

    // Memory outputs
    wire mem_ready;

    // Mux outputs
    wire [31:0] mem_data_in;

    // Datapath outputs
    wire [31:0] datapath_out;

    // Instansitations
    DataPath data_path(
        .reg_select(reg_select),
        .load_data(data_out),
        .load_enable(reg_load_enable),
        .opcode(alu_opcode),
	.out(datapath_out)
    );
    MUX mux(
        .A(datapath_out),
        .B(immediate_memory_data),
        .select(mux_select),
        .out(mem_data_in)
    );
    Memory ram(
        .address(memory_address),
        .data_in(mem_data_in),
        .write(memory_write),
        .read(memory_read),
        .ready(mem_ready),
        .data_out(data_out),
	.clock(clk),
	.rst(rst)
    );
    CU control_unit(
        .mem_ready(mem_ready),
        .instruction(instruction),
        .rst(rst),
        .clk(clk),
        .memory_write(memory_write),
        .memory_read(memory_read),
        .mux_select(mux_select),
        .memory_address(memory_address),
        .reg_select(reg_select),
        .reg_load_enable(reg_load_enable),
        .alu_opcode(alu_opcode),
        .ready(ready),
	.immediate_memory_data(immediate_memory_data),
	.operation_enable(operation_enable)
    );
endmodule