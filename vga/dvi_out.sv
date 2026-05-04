module dvi_out #(
    parameter COLS = 80,
    parameter ROWS = 30,
    parameter CHAR_WIDTH = 8,
    parameter BIT_DEPTH = 8
) (
    input  wire       clkp,
    input [$clog2(COLS*ROWS)-1:0] fb_addr,
    input [CHAR_WIDTH-1:0] fb_data,
    output wire [BIT_DEPTH-1:0] vga_r,
    output wire [BIT_DEPTH-1:0] vga_g,
    output wire [BIT_DEPTH-1:0] vga_b,
    output wire       vsync,
    output wire       hsync,
    output wire       de
);

reg [7:0] r, g, b;
wire [9:0] px, py;

vga vga_driver(
    .clk(clkp),
    .r(r), .g(g), .b(b),
    .px(px), .py(py),
    .vsync(vsync), .hsync(hsync), .de(de),
    .vga_r(vga_r), .vga_g(vga_g), .vga_b(vga_b)
);

vga_text text (
    .clk   (clkp),
    .fb_addr (fb_addr),
    .fb_data (fb_data),
    .px(px), .py(py),
    .r(r), .g(g), .b(b)
);

endmodule
