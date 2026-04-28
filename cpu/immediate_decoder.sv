module imm_decoder(
    input wire [31:0] instr,
    input wire [6:0] opcode,
    output reg [31:0] imm32
);

always @(*) begin
    case (opcode)
        // R-type
        7'b0110011:
            imm32 = 32'b0;
        // I-type
        7'b0010011, 7'b0000011, 7'b1100111:
            imm32 = {{20{instr[31]}}, instr[31:20]};
        // S-type
        7'b0100011:
            imm32 = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        // B-type
        7'b1100011:
            imm32 = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        // U-type
        7'b0110111, 7'b0010111:
            imm32 = {instr[31:12], 12'b0};
        // J-type
        7'b1101111:
            imm32 = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        default:
            imm32 = 32'b0;
    endcase
end

endmodule