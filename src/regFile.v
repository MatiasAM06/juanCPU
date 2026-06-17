module register_file (
// --- Señales de Control Global ---
    input clk,
    input reset,
    input regWrite, // De la CU
    
// --- Entradas de Datos ---
    input [31:0] instruction, // Instrucción completa
    input [31:0] write_data, // Lo que se escribe en rd
    
// --- Salidas de Datos ---
    output reg [31:0] read_data1, // Contenido registro rs1
    output reg [31:0] read_data2 // Contenido registro rs2
);
// --- Matriz de Almacenamiento (32 registros de 32 bits cada uno) ---
    reg [31:0] registers [0:31]; 
    integer i;

    // Extraer campos de la instrucción
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
// Extracción de índices según el estándar de codificación de RISC-V
    assign rs1 = instruction[19:15];// Registro Fuente 1
    assign rs2 = instruction[24:20];// Registro Fuente 2
    assign rd  = instruction[11:7];// Registro Destino

    // --- Lógica Combinacional: Lectura Asíncrona ---
    // En RISC-V la lectura del banco de registros es inmediata
    always @(*) begin
// Hardwired Zero: Si se solicita el registro x0, se retorna un cero absoluto.
        if (rs1 == 5'd0)
            read_data1 = 32'b0;
        else
            read_data1 = registers[rs1];

        if (rs2 == 5'd0)
            read_data2 = 32'b0;
        else
            read_data2 = registers[rs2];

    end

   // --- Lógica Secuencial: Escritura y Reset Síncronos ---
    // La actualización de los registros ocurre únicamente en el flanco de subida de clk.
  
    always @(posedge clk) begin

        if (reset) begin
// Inicialización de todos los registros a 0
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
// Inicialización especial del Stack Pointer (x2 = sp) a la dirección 256 (0x00000100)
                registers[2]<=256;

        end
        else if (regWrite && rd != 5'd0) begin
        // Escritura permitida solo si regWrite está activo y el destino NO es x0
            registers[rd] <= write_data;

        end

    end

endmodule
