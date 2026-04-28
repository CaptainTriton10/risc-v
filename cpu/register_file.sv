module registers #(
    parameter N = 32
) (
    input wire clk,
    input wire we,
    input wire [$clog2(N)-1:0] wr_index,
    input wire [31:0] wr_data,
    input wire [$clog2(N)-1:0] index_r1,
    input wire [$clog2(N)-1:0] index_r2,
    output wire [31:0] rd_data_r1,
    output wire [31:0] rd_data_r2
);

reg [31:0] registers [N-1:0];

integer i;
initial begin
    for (i = 0; i < N; i++) begin
        registers[i] = 32'h0;
    end
end

always @(posedge clk) begin
    if (we && wr_index != 0) begin
        registers[wr_index] <= wr_data;
    end
end

assign rd_data_r1 = index_r1 == 0 ? 32'h0 : registers[index_r1];
assign rd_data_r2 = index_r2 == 0 ? 32'h0 : registers[index_r2];

endmodule