
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.05.2026 18:25:04
// Design Name: 
// Module Name: ControlUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ControlUnit(
    input [31:0] instruccion,
   input [3:0] flagsALU, //NZCV

    output reg PCSrc, //jump
   // output reg PCJAL, //Indica que se usa PC+Imm
    output reg MemtoReg, //para Loads
    output reg MemWrite, // para Stores 
    output reg MemRead, //para Loads
    output reg  ALUSrc, // 0 reg, 1 extended imm, upper imm y  PC (tipo J)
    output reg [3:0] ALUControl, //definida en ALU
    output reg RegWrite, // 1 en tipo I, R y Loads
    output reg [1:0] RegSrc, // Es 0 para tipo R, I, S y B, 1 para tipo U  y J (rd bits 11-7) 
    /*aqui los que ocupa el if_stage, si se usan, no se ocupa PCSrc*/
    output reg is_branch, //NU
    output reg is_jal,  //NU
    output reg is_jalr,
    output reg [2:0] branch_op
);


//obtiene las partes de opcode y funct3 y funct7 que se usan en tipo R,I, S y B
//también separa las flags de la ALU
// cond representa si la condición se cumplió o no, para branches
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire Z;
    wire N;
    wire C;
    wire V;
    reg cond;
   
    assign opcode = instruccion[6:0];
    assign funct3 = instruccion[14:12];
    assign funct7 = instruccion[31:25];
  assign N= flagsALU [1];
   assign Z= flagsALU [0];
    assign C= flagsALU [2];
    assign V= flagsALU [3];

    always @(*) begin
        //Valores por defecto
        MemtoReg = 0; MemWrite = 0; ALUSrc = 0; 
        ALUControl = 4'b0000;  RegWrite = 0; RegSrc=2'd0; 
        MemRead=0; 
        is_branch=0; is_jal =0; is_jalr=0; branch_op=3'b000; PCSrc=0;
        
        
        case (opcode)
        
            7'b0110011: begin // TIPO R
                RegWrite = 1;
                case ({funct7, funct3}) //logica de la ALU
                    {7'b0000000, 3'b000}: ALUControl = 4'b0000; // ADD
                    {7'b0100000, 3'b000}: ALUControl = 4'b0001; // SUB
                    {7'b0000000, 3'b111}: ALUControl = 4'b0111; // AND
                    {7'b0000000, 3'b110}: ALUControl = 4'b1000; // OR
                    {7'b0000000, 3'b100}: ALUControl = 4'b1001; // XOR
                    {7'b0000000, 3'b001}: ALUControl = 4'b0010; // LLS
                    {7'b0000000, 3'b101}: ALUControl = 4'b0011; // LLR
                    {7'b0100000, 3'b101}: ALUControl = 4'b0100; // ARS
                    {7'b0000000, 3'b010}: ALUControl = 4'b0101; // SLT
                    {7'b0000000, 3'b011}: ALUControl = 4'b0110; // SLTU                 
                    default: ALUControl = 3'b000;
                endcase
            end

            7'b0010011: begin // TIPO I 
              RegWrite = 1;ALUSrc = 1;
              case (funct3) //logica de la ALU
                    3'b000: ALUControl = 4'b0000; // ADDI
                    3'b010: ALUControl = 4'b0101; // SLTI
                    3'b011: ALUControl = 4'b0110; // SLTUI
                    3'b100: ALUControl = 4'b1001; // XORI
                    3'b110: ALUControl = 4'b1000; // ORI
                    3'b111: ALUControl = 4'b0111; // ANDI
                    default: ALUControl = 4'b0000;
                endcase
            end

            7'b0000011: begin // LOAD (LW)
                RegWrite = 1;MemRead=1;ALUSrc = 1;MemtoReg = 1; RegSrc=1;
                ALUControl = 4'b0000; // Suma para calcular dirección
            end

            7'b0100011: begin // STORE (SW)
                MemWrite = 1;ALUSrc = 1;
                ALUControl = 4'b0000; // Suma para dirección
            end

            7'b1100011: begin // BRANCH 
                    ALUControl=4'b0001; //resta para comparación
                    is_branch=1;
                    branch_op =funct3;
                    case (funct3) //según condicion
                    3'b101:  // GE
                    cond = ~N|Z;
                    3'b000: //EQ    
                    cond = Z;  
                    3'b001: //NE    
                    cond = ~Z;
                    3'b100: // LT  
                    cond = N^V;                              
                    default: cond = 0;
                    endcase
                PCSrc=cond;
               end
               
            7'b0110111: begin //Lui o tipoU 
            RegWrite=1;RegSrc=2'd3;
            end

            7'b1101111: begin  //tipo J (JAL)
            RegSrc =2'd2;RegWrite=1; is_jal=1;PCSrc=1;
            end
            
            7'b1100111: begin  //tipo J (JALR)                     
            RegSrc =2'd2;RegWrite=1; is_jalr=1;PCSrc=1;
            end
             
            
            default: begin
                // Mantener valores por defecto
            end
        endcase
    end

    



endmodule