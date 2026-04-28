module branch_logic(
    input wire [2:0] funct3,
    input wire [31:0] rs1,
    input wire [31:0] rs2,
    output reg taken
);

always @(*) begin
    case (funct3)
        3'b000: taken = (rs1 == rs2);
        3'b001: taken = (rs1 != rs2);
        3'b100: taken = (rs1 < rs2);
        3'b101: taken = (rs1 >= rs2);
        3'b110: taken = ($signed(rs1) < $signed(rs2));
        3'b111: taken = ($signed(rs1) >= $signed(rs2));
    endcase
end

endmodule