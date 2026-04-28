module alu_control(
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    input wire [6:0] opcode,
    output reg [3:0] alu_op,
    output reg s1_src,
    output reg s2_src
);

localparam S1_RS1 = 1'b0;
localparam S1_PC  = 1'b1;

localparam S2_RS2 = 1'b0;
localparam S2_IMM = 1'b1;

localparam ALU_ADD  = 4'd0;
localparam ALU_SUB  = 4'd1;
localparam ALU_AND  = 4'd2;
localparam ALU_OR   = 4'd3;
localparam ALU_XOR  = 4'd4;
localparam ALU_SLL  = 4'd5;
localparam ALU_SRL  = 4'd6;
localparam ALU_SRA  = 4'd7;
localparam ALU_SLT  = 4'd8;
localparam ALU_SLTU = 4'd9;
localparam ALU_PASS_B = 4'hF;

wire det = funct7[5];

always @(*) begin
    s1_src = S1_RS1;
    s2_src = S2_RS2;

    if (opcode == 7'b0110011) begin // R-type operations
        s2_src = S2_RS2;

        case (funct3)
            3'b000: alu_op = det ? ALU_SUB : ALU_ADD;
            3'b001: alu_op = ALU_SLL;
            3'b010: alu_op = ALU_SLT;
            3'b011: alu_op = ALU_SLTU;
            3'b100: alu_op = ALU_XOR;
            3'b101: alu_op = det ? ALU_SRA : ALU_SRL;
            3'b110: alu_op = ALU_OR;
            3'b111: alu_op = ALU_AND;
            default: alu_op = ALU_ADD;
        endcase
    end else if (opcode == 7'b0010011) begin // I-type operations
        s2_src = S2_IMM;

        case (funct3)
            3'b000: alu_op = ALU_ADD;
            3'b010: alu_op = ALU_SLT;
            3'b011: alu_op = ALU_SLTU;
            3'b100: alu_op = ALU_XOR;
            3'b110: alu_op = ALU_OR;
            3'b111: alu_op = ALU_AND;
            3'b001: alu_op = ALU_SLL;
            3'b101: alu_op = det ? ALU_SRA : ALU_SRL;
            default: alu_op = ALU_ADD;
        endcase
    end else if (opcode == 7'b0110111) begin // LUI requires value B to pass through the alu
        s2_src = S2_IMM;

        alu_op = ALU_PASS_B;
    end else if (opcode == 7'b0010111) begin // AUIPC adds the immediate to the PC
        s1_src = S1_PC;
        s2_src = S2_IMM;

        alu_op = ALU_ADD;
    end else if (opcode == 7'b1100111) begin // JALR calculates the jump target with rs1 + imm
        s1_src = S1_RS1;
        s2_src = S2_IMM;

        alu_op = ALU_ADD;
    end else begin
        s2_src = S2_IMM;

        alu_op = ALU_ADD;
    end
end

endmodule