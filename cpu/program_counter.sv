module program_counter(
    input wire clk,
    input wire rst,
    input wire pc_load,
    input wire [31:0] pc_in,
    output reg [31:0] pc_out
);

always @(posedge clk) begin
    if (rst) begin
        pc_out <= 32'h0;
    end else if (pc_load) begin
        pc_out <= pc_in;
    end else if (pc_out >= 32'h00007FFC) begin  // Instruction memory limit
        pc_out <= 32'h0;
    end else begin
        pc_out <= pc_out + 32'h4;
    end
end

endmodule