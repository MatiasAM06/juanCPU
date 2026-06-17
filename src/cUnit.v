
module ControlUnit(
// --- Entradas desde la Etapa de Fetch/Decode ---
    input [31:0] instruccion,
   input [3:0] flagsALU, //ZNCV
// --- Señales de Control para el Flujo---

    output reg PCSrc, // Selector del próximo PC (1: Salto/Branch tomado, 0: Secuencial)
    output reg MemtoReg, // No se usa
    output reg MemWrite, // Habilita la escritura en la Memoria de Datos (instrucciones Store)
    output reg MemRead, // Habilita la lectura en la Memoria de Datos (instrucciones Load)
    output reg  ALUSrc, // Selector del segundo operando de la ALU (0: Registro rs2, 1: Inmediato)
    output reg [3:0] ALUControl, //definida en ALU// Código de operación enviado a la ALU para seleccionar la función
    output reg RegWrite, // Habilita la escritura en el Banco de Registros en el registro destino (rd)
    output reg is_branch,
    output reg is_jal,    
    output reg [1:0] RegSrc, // Selección del datos para el destino rd 
                             //   2'd0: ResultadoAlu 2d'1: Memoria (LDR) , 2'd2: PC+4 , 2'd3: Inmediato
    output reg is_jalr,// Indica que la instrucción es un JALR (Salto incondicional por registro)
    output reg [2:0] branch_op // Operación específica de Branch (mapea directamente a funct3)
);


//obtiene las partes de opcode y funct3 y funct7 que se usan en tipo R,I, S y B
// --- Cables de Decodificación Interna ---
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    
 // --- Desglose de Banderas de Condición (Flags) ---
    wire V; // Overflow (Desbordamiento)
    wire C; // Carry Out (Acarreo)
    wire N; // Negative (Resultado negativo)
    wire Z; // Zero (Resultado igual a cero)
    
    
    reg cond; // Señal interna que determina si la condición del Branch se cumple
    
 // --- Asignaciones (Decodificación de Campos del ISA RISC-V) ---  
    assign opcode = instruccion[6:0];
    assign funct3 = instruccion[14:12];
    assign funct7 = instruccion[31:25];
 // Asignación de flags según pasados desde la ALU
  assign N= flagsALU [1];
  assign Z= flagsALU [0];
  assign C= flagsALU [2];
  assign V= flagsALU [3];

    always @(*) begin
        // 1. Valores por Defecto
        MemtoReg = 0; MemWrite = 0; ALUSrc = 0; 
        ALUControl = 4'b0000;  RegWrite = 0; RegSrc=2'd0; 
        MemRead=0; 
        is_branch=0; is_jal =0; is_jalr=0; branch_op=3'b000; PCSrc=0;
        
        // 2. Matriz de Decodificación basada en el OPCODE
        case (opcode)
        
            7'b0110011: begin // === TIPO R (Operaciones Registro-Registro) ===// TIPO R
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
                    default: ALUControl = 4'b0000;
                endcase
            end

            7'b0010011: begin // === TIPO I (Operaciones Registro-Inmediato) ===
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

            7'b0000011: begin // === LOAD (Ej: LW) ===
                RegWrite = 1;MemRead=1;ALUSrc = 1;MemtoReg = 1; RegSrc=1;
                ALUControl = 4'b0000; // Suma para calcular dirección
            end

            7'b0100011: begin // === STORE (Ej: SW) ===
                MemWrite = 1;ALUSrc = 1;
                ALUControl = 4'b0000; // Suma para dirección
            end

            7'b1100011: begin // === BRANCH (Saltos Condicionales) ===
                    ALUControl=4'b0001; //resta para comparación
                    is_branch=1;
                    branch_op =funct3;
                    // Evaluación de la condición del salto según banderas de la ALU
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
                PCSrc=cond;// El PC saltará si la condición lógica fue verdadera
               end
               
            7'b0110111: begin // === LUI (Load Upper Immediate - Tipo U) ===
            RegWrite=1;RegSrc=2'd3;
            end

            7'b1101111: begin  // === JAL (Jump and Link - Tipo J) ===
            RegSrc =2'd2;RegWrite=1; is_jal=1;PCSrc=1;
            end
            
            7'b1100111: begin  // === JALR (Jump and Link Register - Tipo I/J) ===                   
            RegSrc =2'd2;RegWrite=1; is_jalr=1;PCSrc=1;
            end
