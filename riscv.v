

module riscv(
    input wire clk,
    input wire rst
    );

    wire jalr;
    wire jmp;
    wire [31:0] imm;
    wire [31:0] ins;
    wire [31:0] pc4;

    wire [3:0] aluFlags;
    wire pcSrc;
    wire memToReg;
    wire memWrite;
    wire memRead;
    wire aluSrc;
    wire [3:0] aluControl;
    wire regWrite;
    wire [1:0] regSrc;


    wire [3:0] rs1Addr;
    wire [3:0] rs2Addr;
    wire [3:0] rdAddr;
    reg [31:0] regWriteData;
    wire [31:0] rs1;
    wire [31:0] rs2;

    wire [31:0] aluA;
    wire [31:0] aluB;
    wire [31:0] aluO;

    wire [31:0] memData;


    assign aluA = rs1;
    assign aluB = aluSrc ? imm : rs2;

    //Register write source Mux
    always @(*) begin
        case (regSrc)
            0:regWriteData=aluO;
            1:regWriteData=memData;
            2:regWriteData=pc4;
            3:regWriteData=imm;
            default:regWriteData=0;

        endcase
    end


    //PC Assembly
    imStage s1(
        .clk(clk),
        .rst(rst),
        .jalr(jalr),
        .jmp(jmp),
        .imm(imm),
        .rs1(rs1),

        .instruction(ins),
        .pc4(pc4)

    );


    //Control Unit
    ControlUnit c1(
        .instruccion(ins),
        .flagsALU(aluFlags),

        .PCSrc(jmp),
        .MemtoReg(memToReg),
        .MemWrite(memWrite),
        .MemRead(memRead),
        .ALUSrc(aluSrc),
        .ALUControl(aluControl),
        .RegWrite(regWrite),
        .RegSrc(regSrc),
        .is_jalr(jalr)

    );

    //Register File
    register_file s2(
        .clk(clk),
        .reset(rst),
        .regWrite(regWrite),
        .instruction(ins),
        .write_data(regWriteData),

        .read_data1(rs1),
        .read_data2(rs2)

    );

    //Immediate Generator
    immediate_generator s3(
        .instruction(ins),

        .imm_out(imm)

    );




    //ALU
    ALU s4(
        .inA(aluA),
        .inB(aluB),
        .aluControl(aluControl),

        .result(aluO),
        .zero(aluFlags[0]),
        .carry(aluFlags[2]),
        .negative(aluFlags[1]),
        .overflow(aluFlags[3])

    );

    //Memory File
    memory_io s5(
        .clk(clk),
        .reset(rst),
        .memRead(memRead),
        .memWrite(memWrite),
        .address(aluO),
        .write_data(rs2),
        .ins(ins),

        .read_data(memData)


    );









endmodule