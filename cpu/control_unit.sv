module control_unit(
    input wire [6:0] opcode,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    output reg reg_we,
    output reg ram_we,
    output reg [1:0] wb_sel,
    output reg pc_load,
    output reg [1:0] pc_load_sel
);

localparam TRUE = 1'b1;
localparam FALSE = 1'b0;

localparam WB_ALU = 2'b00;
localparam WB_RAM = 2'b01;
localparam WB_PC4 = 2'b10;

localparam PC_LOAD_IMM = 2'b00;
localparam PC_LOAD_RS1IMM = 2'b01;
localparam PC_LOAD_BRANCH = 2'b10;

always @(*) begin
    reg_we = FALSE;
    ram_we = FALSE;
    wb_sel = WB_ALU;
    pc_load = FALSE;

    case (opcode)
        7'b0110011, 7'b0010011: begin // R-type; I-type ALU
            reg_we = TRUE;
            wb_sel = WB_ALU;
        end
        7'b0000011: begin // I-type LOAD
            reg_we = TRUE;
            wb_sel = WB_RAM;
        end
        7'b1100111: begin // I-type JALR;
            reg_we = TRUE;
            wb_sel = WB_PC4;
            pc_load = TRUE;
            pc_load_sel = PC_LOAD_RS1IMM;
        end
        7'b1101111: begin // J-type JAL
            reg_we = TRUE;
            wb_sel = WB_PC4;
            pc_load = TRUE;
            pc_load_sel = PC_LOAD_IMM;
        end
        7'b0100011: begin // S-type
            ram_we = TRUE;
        end
        7'b1100011: begin // B-type
            pc_load = TRUE;
            pc_load_sel = PC_LOAD_BRANCH;
        end
        7'b0110111, 7'b0010111: begin // U-type
            reg_we = TRUE;
        end
        default: ;
    endcase
end

endmodule