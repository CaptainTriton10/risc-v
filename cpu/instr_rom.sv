module instr_rom #(
    parameter SIZE = 255
) (
    input wire [31:0] addr,
    output wire [31:0] instr
);

reg [31:0] rom [SIZE-1:0];

initial begin
    $readmemh("program.hex", rom);
end

assign instr = rom[addr[$clog2(SIZE)-1:0]];

endmodule
