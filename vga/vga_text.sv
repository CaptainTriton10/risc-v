module vga_text #(
    parameter COLS = 80,
    parameter ROWS = 30,
    parameter CHAR_WIDTH = 8,
    parameter BIT_DEPTH = 8
) (
    input clk,
    input [9:0] px,
    input [9:0] py,
    input [CHAR_WIDTH-1:0] fb_data,
    output [$clog2(COLS*ROWS)-1:0] fb_addr,
    output [BIT_DEPTH-1:0] r,
    output [BIT_DEPTH-1:0] g,
    output [BIT_DEPTH-1:0] b
);

reg [CHAR_WIDTH-1:0] framebuf [0:(COLS*ROWS)-1];
reg [127:0] font [0:255];

initial begin
    $readmemh("empty.hex", framebuf);
    $readmemh("font.hex", font);
end

wire [11:0] base_x = {{7{1'b0}}, px[9:3]};
wire [11:0] base_y = {{6{1'b0}}, py[9:4]};

wire [2:0] gpx = px[2:0];
wire [3:0] gpy = py[3:0];

wire [6:0] pixel;

always @(posedge clk) begin
    pixel = 127 - ((gpy << 3) + gpx);
end

wire active = (px < (COLS << 3)) && (py < (ROWS << 4));

assign fb_addr = active ? ((base_y << 4) + (base_y << 6)) + base_x : 8'h00;
wire [CHAR_WIDTH-1:0] ch = active ? fb_data : 8'h00;

assign r = (active && font[ch][pixel]) ? 8'hFF : 8'h00;
assign g = (active && font[ch][pixel]) ? 8'hFF : 8'h00;
assign b = (active && font[ch][pixel]) ? 8'hFF : 8'h00;

endmodule