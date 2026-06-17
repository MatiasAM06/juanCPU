

module instruction_memory(
    input wire [31:0] addr, //Dirección de memoria [31:0] (del PC)
    output reg [31:0] instruction //Instrucción de 32 bits leída [31:0]
    );
    // --- Matriz de Almacenamiento (RAM/ROM de Instrucciones) ---
    // Declara una memoria de 1024 posiciones (palabras), donde cada posición almacena 32 bits (4 bytes).
    // Capacidad total: 4 KB de memoria de instrucciones.
    reg [31:0] insMem [0:1023];

    // --- Inicialización de la Memoria ---
    // Carga el código máquina en formato hexadecimal desde un archivo externo antes de iniciar la simulación.
    initial begin
    $readmemh("./build/program.hex", insMem);
    end
    
    // La lectura es asíncrona (combinacional). Reacciona inmediatamente si el PC cambia.
    always @(*) begin 
         //Se usa 'addr[31:2]' para dividir la dirección de bytes entre 4.
        // Como cada instrucción ocupa 4 bytes (32 bits), el arreglo 'insMem' se indexa por "palabras".
        instruction=insMem[addr[31:2]];        
    end



    
endmodule
