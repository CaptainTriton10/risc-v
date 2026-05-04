module ram #(
    parameter SIZE = 4096,
    parameter FB_ADDR = 12'h6A0
) (
    input wire clk,
    input wire [31:0] data_addr,
    input wire we,
    input wire [3:0] byte_mask,
    input wire [31:0] wr_data,
    input wire [11:0] fb_addr,
    output wire [31:0] rd_data,
    output wire [7:0] fb_data
);

localparam WORDS = SIZE / 4;

wire [$clog2(WORDS)-1:0] word_data_addr  = data_addr[2 +: $clog2(WORDS)];

reg [31:0] mem [(WORDS)-1:0];

always @(posedge clk) begin
    if (we) begin
        if (byte_mask[3]) mem[word_data_addr][24 +: 8] <= wr_data[24 +: 8];
        if (byte_mask[2]) mem[word_data_addr][16 +: 8] <= wr_data[16 +: 8];
        if (byte_mask[1]) mem[word_data_addr][8  +: 8] <= wr_data[8  +: 8];
        if (byte_mask[0]) mem[word_data_addr][0  +: 8] <= wr_data[0  +: 8];
    end
end

assign rd_data  = mem[word_data_addr];
assign fb_data  = mem[FB_ADDR + fb_addr][7:0];

endmodule
