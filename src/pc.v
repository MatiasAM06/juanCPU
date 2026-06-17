module program_counter(

// --- Señales de Control Global ---
    input wire clk,
    input wire reset,
// --- Señales de Control del Camino de Datos ---
    input wire pc_src, //selector de fuente de próximo PC 
                                //00: PC+4 (secuencial)
                                //01: JumpTarget
                                
   // --- Entradas de Dirección ---                             
    input wire [31:0] jump_target,
    
    // --- Salidas ---
    output reg [31:0] pc_out,
    output reg [31:0] pc4
    
    );
    // --- Señales Internas ---
    wire [31:0] pc_plus_4;// Resultado de la suma secuencial
    reg [31:0] pc_next; // Dirección que se cargará en el PC en el próximo ciclo 


// Sumador para el incremento secuencial del PC
    assign pc_plus_4 = pc_out + 4; 

    
  // MUX 1: Selección del próximo valor del PC y asignación de salidas 
        always @(*) begin
        case (pc_src)
            1'b0: pc_next = pc_plus_4;    // Selección: Camino secuencial
            1'b1: pc_next = jump_target;  // Selección: Camino de salto
            default: pc_next = pc_plus_4; // En caso de fallas 
        endcase
        // Asignación de la salida PC+4 dentro del bloque combinacional
        pc4=pc_plus_4;
    end
    
   // --- Lógica Secuencial (Registro del PC) ---
    
    // Actualización del registro del PC con Reset Asíncrono
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 32'h00000000;  // Dirección inicial: 0x00000000
        else
            pc_out <= pc_next; // Carga del nuevo valor del PC en el flanco de subida
    end
    
endmodule
