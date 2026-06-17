`timescale 1ns/1ns

module riscv_tb;

    // ── DUT inputs ──────────────────────────────────────────────
    reg clk;
    reg rst;

    // ── DUT instantiation ────────────────────────────────────────
    riscv uut (
        .clk(clk),
        .rst(rst)
    );

    // ── Clock: 10 ns period (100 MHz) ────────────────────────────
    initial clk = 0;
    always #5 clk = ~clk;

    // ── VCD dump ─────────────────────────────────────────────────
    initial begin
        $dumpfile("signals.vcd");       
        $dumpvars(0, riscv_tb);        
    end

    // ── Reset + run ──────────────────────────────────────────────
    initial begin
        rst = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;

        // Run for cycles then stop
        repeat (2000) @(posedge clk);

        $finish;
    end

    // ── Optional: print PC+instruction each cycle ─────────────────
    always @(posedge clk) begin
        if (!rst)
            $display("t=%0t  pc4=%h  ins=%h  regWrite=%b  aluO=%h",
                     $time,
                     uut.pc4,
                     uut.ins,
                     uut.regWrite,
                     uut.aluO);
    end

endmodule