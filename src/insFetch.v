 

module imStage(
    input wire clk,
    input wire rst,
    input wire jalr,
    input wire jmp,
    input wire [31:0] imm,
    input wire [31:0] rs1,

    output wire [31:0] instruction,
    output wire [31:0] pc4

    );

    wire [31:0] pcOut;
    wire [31:0] jmpTar;

    program_counter PC(
        .clk(clk),
        .reset(rst),
        .pc_src(jmp),
        .jump_target(jmpTar),
        .pc_out(pcOut),
        .pc4(pc4)
    );

    branch_unit BU(
        .jalr(jalr),
        .pc_current(pcOut),
        .imm(imm),
        .rs1_data(rs1),
        .jump_target(jmpTar)
    );

    instruction_memory IM(
        .addr(pcOut),
        .instruction(instruction)
    );

    
endmodule
