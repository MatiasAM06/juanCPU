module branch_unit(
// --- Señales de Control ---
    input wire jalr, //indica JALR
// --- Entradas del Camino de Datos ---
    input wire [31:0] pc_current, //PC actual
    input wire [31:0] imm, //extraido de la instrucción
    input wire [31:0] rs1_data,
// --- Salidas ---
    output reg [31:0] jump_target
    );
    
 // --- Lógica Combinacional para el Cálculo de la Dirección Destino ---
 // Este bloque modela el multiplexor 4 que elige la base de la suma (PC o Registro)
    always @(*) begin
        case(jalr)
        // Caso JAL / BRANCH: Salto relativo al PC actual (PC + inmediato)
            0:jump_target=(pc_current + imm);     
            // Caso JALR: Salto relativo a registro (RS1 + inmediato)
                // Se aplica un AND para poner en '0' el bit menos significativo (LSB),
                // cumpliendo con la especificación ISA de RISC-V para alineación de memoria.          //jal/b
            1:jump_target=((rs1_data + imm) & 32'hFFFFFFFE); //jalr
            default:jump_target=(pc_current + imm);
        endcase
    end

    
endmodule
