

module memory_io(

    input clk,
    input reset,

    // Señales de control
    input memRead,
    input memWrite,

    // Dirección desde la ALU
    input [31:0] address,

    // Dato desde el Register File
    input [31:0] write_data,
    input [31:0] ins,               //To detect ret and memDump.

    // Dato leído hacia Write Back
    output reg [31:0] read_data
    
);

    // Memoria de datos
    reg [31:0] data_memory [0:255];

    integer i;

    // ============================================
    // RESET + ESCRITURA
    // ============================================

    always @(posedge clk) begin

        if (reset) begin

            

            for(i = 0; i < 256; i = i + 1)
                data_memory[i] <= 32'b0;
            data_memory[10] <= 32'hDEADBEEF;

        end

        else if(memWrite) begin

            case(address)

                

                // Memoria normal
                default:
                    data_memory[address[9:2]] <= write_data;

            endcase
        end
    end

    // ============================================
    // LECTURA COMBINACIONAL
    // ============================================

    always @(*) begin

        if(memRead) begin

            case(address)

                

                // Memoria normal
                default:
                    read_data = data_memory[address[9:2]];

            endcase
        end

        else begin
            read_data = 32'b0;
        end
    end



    //Finish sim and memDump Logic
    integer fd;
    always @(posedge clk) begin
        if (ins == 32'h00008067) begin
            $display("=== Memory Dump ===");
            fd = $fopen("./memDump.hex", "w");
            for (i = 0; i < 256; i = i + 1) begin
                $fdisplay(fd, "%08h:%08h", i*4, data_memory[i]);
            end
            $fclose(fd);
            $finish;
        end
    end

endmodule
/*

module memory_io(

    input clk,
    input reset,

    // Señales de control
    input memRead,
    input memWrite,

    // DirecciÃ³n desde la ALU
    input [31:0] address,

    // Dato desde el Register File
    input [31:0] write_data,
    input [31:0] ins,               //To detect ret and memDump.

    // Dato leÃ­do hacia Write Back
    output reg [31:0] read_data
    
);

  // --- Matriz de Almacenamiento (RAM de datos) ---
    // Declara 256 posiciones, donde cada palabra mide 32 bits (4 bytes). Capacidad: 1 KB.
    reg [31:0] data_memory [0:255];

    integer i;

    // ============================================
    // RESET + ESCRITURA
    // ============================================

    always @(posedge clk) begin

        if (reset) begin
// Inicialización de toda la memoria de datos a cero absoluto
            for(i = 0; i < 256; i = i + 1)
                data_memory[i] <= 32'b0;
        end

        else if(memWrite) begin
// TRUCO DE DISEÑO: 'address[9:2]' extrae 8 bits descartando los bits [1:0].
            // Esto transforma la dirección por bytes de la ALU en un índice de palabra válido.
            // (Estructura preparada para añadir periféricos/IO mapeados en memoria mediante 'case')
            case(address)

                

                // Memoria normal
                default:
                    data_memory[address[9:2]] <= write_data;

            endcase
        end
    end

    // ============================================
    // LECTURA COMBINACIONAL
    // ============================================

    always @(*) begin

        if(memRead) begin

            case(address)

                

                // Memoria normal
                default:
                    read_data = data_memory[address[9:2]];

            endcase
        end

        else begin
            read_data = 32'b0;// Mantener bus en cero si no se está leyendo
        end
    end



    //Finish sim and memDump Logic
    always @(posedge clk) begin
        if (ins==32'h00008067) begin
            $display("=== Memory Dump ===");
            $writememh("./memdump.hex", data_memory);
            $finish;
        end
    end

endmodule
*/
