`define TESTBENCH

module top(
    input wire clk,
    input wire [1:0] button,
    output wire [3:0] gpdi_dp,
    output wire [4:0] led
);

wire rst = button[0];

localparam WB_ALU = 2'b00;
localparam WB_RAM = 2'b01;
localparam WB_PC4 = 2'b10;

localparam PC_LOAD_IMM = 2'b00;
localparam PC_LOAD_RS1IMM = 2'b01;
localparam PC_LOAD_BRANCH = 2'b10;

localparam S1_RS1 = 1'b0;
localparam S1_PC  = 1'b1;

localparam S2_RS2 = 1'b0;
localparam S2_IMM = 1'b1;

wire [31:0] program_counter;
wire clk2;

wire [31:0] instr;
wire [6:0] opcode = instr[6:0];
wire [2:0] funct3 = instr[14:12];
wire [6:0] funct7 = instr[31:25];
wire [31:0] imm32;

// DISPLAY OUTPUT //

wire vsync, hsync, de;
wire [7:0] vga_r, vga_g, vga_b;

wire [11:0] fb_addr;
wire [7:0] fb_data;

`ifndef TESTBENCH
    // Generate pixel and tmds clock (25MHz and 250MHz)
    wire clkp, clkt;
    dvi_pll pll(.clk_in(clk), .clkp(clkp), .clkt(clkt), .locked());

    dvi_out dvi(
        .clkp(clkp),
        .fb_addr(fb_addr),
        .fb_data (fb_data),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .vsync(vsync),
        .hsync(hsync),
        .de(de)
    );

    // Convert the signal to DVI and send over HDMI
    vga2tmds tmds_generator(
    	.clkp(clkp), .clkt(clkt),
    	.vsync(vsync), .hsync(hsync), .de(de),
    	.r(vga_r), .g(vga_g), .b(vga_b), .tmds(gpdi_dp)
    );
`endif

// CPU MODULES //

imm_decoder imm_decoder_inst(
    .instr(instr),
    .opcode(opcode),
    .imm32(imm32)
);

wire reg_we;
wire [4:0] rd_index  = instr[11:7];
wire [4:0] rs1_index = instr[19:15];
wire [4:0] rs2_index = instr[24:20];
wire [31:0] rs1_data;
wire [31:0] rs2_data;
wire [1:0] wb_sel;

wire pc_load, branch_taken;
wire [1:0] pc_load_sel;

wire [31:0] alu_result;
wire [3:0] alu_op;
wire s1_src, s2_src;

wire ram_we;
wire [31:0] ram_rd_data;

wire [31:0] rs1_mux = s1_src == S1_RS1 ? rs1_data : program_counter;
wire [31:0] rs2_mux = s2_src == S2_RS2 ? rs2_data : imm32;

alu alu_inst(
    .a(rs1_mux),
    .b(rs2_mux),
    .alu_op(alu_op),
    .result(alu_result)
);

wire [31:0] reg_wr_data = (wb_sel == WB_ALU) ? alu_result :
                          (wb_sel == WB_RAM) ? ram_rd_data :
                          program_counter + 32'h00000004;

registers registers_inst(
    .clk(clk2),
    .we(reg_we),
    .wr_index(rd_index),
    .wr_data(reg_wr_data),
    .index_r1(rs1_index),
    .index_r2(rs2_index),
    .rd_data_r1(rs1_data),
    .rd_data_r2(rs2_data)
);

branch_logic branch_logic_inst(
    .funct3(funct3),
    .rs1(rs1_data),
    .rs2(rs2_data),
    .taken(branch_taken)
);

reg [31:0] pc_in;
always @(*) begin
    case (pc_load_sel)
        PC_LOAD_IMM: pc_in = program_counter + imm32;
        PC_LOAD_RS1IMM: pc_in = rs1_data + imm32; // TODO: make lsb 0 (as per spec)
        PC_LOAD_BRANCH: pc_in = branch_taken ?
            program_counter + imm32 : program_counter + 32'd1;
        default: pc_in = program_counter + 32'd1;
    endcase
end

program_counter program_counter_inst(
    .clk(clk),
    .rst(rst),
    .pc_load(pc_load),
    .pc_in(pc_in),
    .pc_out(program_counter),
    .clk2(clk2)
);

reg [3:0] byte_mask;
always @(*) begin
    case (funct3)
        3'b000: byte_mask = 4'b0001;
        3'b001: byte_mask = 4'b0011;
        3'b010: byte_mask = 4'b1111;
        default: byte_mask = 4'b1111;
    endcase
end

ram ram_inst(
    .clk(clk),
    .data_addr(rs1_data + imm32),
    .fb_addr(fb_addr),
    .we(ram_we),
    .byte_mask(byte_mask),
    .wr_data(rs2_data),
    .rd_data(ram_rd_data),
    .fb_data(fb_data)
);

instr_rom instr_rom_inst(
    .addr(program_counter),
    .instr(instr)
);

alu_control alu_control_inst(
    .funct3(funct3),
    .funct7(funct7),
    .opcode(opcode),
    .alu_op(alu_op),
    .s1_src(s1_src),
    .s2_src(s2_src)
);

control_unit control_unit_inst(
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .reg_we(reg_we),
    .ram_we(ram_we),
    .wb_sel(wb_sel),
    .pc_load(pc_load),
    .pc_load_sel(pc_load_sel)
);

endmodule
