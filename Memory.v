module Memory (
        input [9:0] address,
        input [31:0] data_in,
        input write,
        input read,
        input clock,
        input rst,
        output reg [31:0] data_out,
        output reg ready
);
        reg [31:0] mem [0:1023]; // Memory is an array of 32-bit vectors
	always @(posedge rst) ready = 1'b1;
        always @(posedge clock) begin
	        if (rst == 1'b0) begin
                        if (write) begin
                                ready = 1'b0;
                                #23 mem[address] = data_in;
                                ready = 1'b1;
                        end
                        else if (read) begin
                                ready = 1'b0;
                                #23 data_out = mem[address];
                                ready = 1'b1;
                        end 
	        end
        end  
endmodule