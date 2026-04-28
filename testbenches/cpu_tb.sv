module cpu_tb;

reg clk;
reg rst;

top dut(
    .clk(clk),
    .button({1'b0, rst})
);

always #5 clk = ~clk;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, cpu_tb);

    clk = 1'b0;
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk); // hold for two cycles to be safe
    #1 rst = 1'b0;  // deasert just after the edge, not on it

    #200 $finish;
end

endmodule