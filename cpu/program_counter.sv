module program_counter(
    input wire clk,
    input wire rst,
    input wire pc_load,
    input wire [31:0] pc_in,
    output reg [31:0] pc_out,
    output wire clk2
);

reg clk_div = 0;

always @(posedge clk) begin
    if (clk_div) begin
        if (rst) begin
            pc_out <= 32'h0;
        end else if (pc_load) begin
            pc_out <= pc_in;
        end else begin
            pc_out <= pc_out + 32'd1;
        end
    end
    clk_div <= ~clk_div;
end

assign clk2 = clk_div;

endmodule
