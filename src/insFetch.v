 module imStage(
// --- Señales de Control Global ---
    input wire clk,
    input wire rst,
// --- Señales de Control desde la Etapa de Decodificación/Ejecución ---
    input wire jalr,
    input wire jmp,
    
// --- Datos de Entrada (Inmediatos y Registros) ---    
    input wire [31:0] imm,
    input wire [31:0] rs1,
// --- Salidas de la Etapa de Fetch  ---
    output wire [31:0] instruction,
    output wire [31:0] pc4

    );
//Este archivo es el top de pc.v, bUnit.v y insMem.v
// --- Interconexiones Internas (Buses de datos) ---
    wire [31:0] pcOut;
    wire [31:0] jmpTar;
    
// =========================================================================
// INSTANCIACIÓN DE SUBMÓDULOS
// =========================================================================

 // 1. Program Counter
 // Se encarga de almacenar y actualizar la dirección de la instrucción actual.
    program_counter PC(
        .clk(clk),
        .reset(rst),
        .pc_src(jmp),
        .jump_target(jmpTar),
        .pc_out(pcOut),
        .pc4(pc4)
    );
// 2. Unidad de Saltos (Branch Unit)
 // Calcula la dirección del objetivo del salto (jump_target) basándose en el tipo de instrucción.
    branch_unit BU(
        .jalr(jalr),
        .pc_current(pcOut),
        .imm(imm),
        .rs1_data(rs1),
        .jump_target(jmpTar)
    );
// 3. Memoria de Instrucciones (Instruction Memory)
 // Memoria que entrega la instrucción apuntada por el PC.
    instruction_memory IM(
        .addr(pcOut),
        .instruction(instruction)
    );
 
endmodule
