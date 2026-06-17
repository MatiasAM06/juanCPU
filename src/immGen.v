

module immediate_generator (
    input  [31:0] instruction,
    output reg [31:0] imm_out
);

    wire [6:0] opcode;
    assign opcode = instruction[6:0];

    always @(*) begin
        case (opcode)

            // =========================
            // I-TYPE (addi, lw, etc.)
            // imm[11:0] = instruction[31:20]
            // =========================
            7'b0010011, // addi
            7'b0000011: // lw
                imm_out = {{20{instruction[31]}}, instruction[31:20]};

            // =========================
            // S-TYPE (sw)
            // imm[11:5] = instruction[31:25]
            // imm[4:0]  = instruction[11:7]
            // =========================
            7'b0100011: // sw
                imm_out = {{20{instruction[31]}},
                           instruction[31:25],
                           instruction[11:7]};

            // =========================
            // B-TYPE (beq, bne)
            // imm = {instruction[31], instruction[7],
            //        instruction[30:25], instruction[11:8], 0}
            // =========================
            7'b1100011: // branch
                imm_out = {{19{instruction[31]}},
                           instruction[31],
                           instruction[7],
                           instruction[30:25],
                           instruction[11:8],
                           1'b0};

            // =========================
            // U-TYPE (lui, auipc)
            // imm[31:12] = instruction[31:12]
            // =========================
            7'b0110111, // lui
            7'b0010111: // auipc
                imm_out = {instruction[31:12], 12'b0};

            // =========================
            // J-TYPE (jal)
            // imm = {instruction[31], instruction[19:12],
            //        instruction[20], instruction[30:21], 0}
            // =========================
            7'b1101111: // jal
                imm_out = {{11{instruction[31]}},
                           instruction[31],
                           instruction[19:12],
                           instruction[20],
                           instruction[30:21],
                           1'b0};

            // =========================
            // DEFAULT
            // =========================
            default:
                imm_out = 32'b0;
        endcase
    end

endmodule
