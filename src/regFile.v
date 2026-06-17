module register_file (
    input clk,
    input reset,
    input regWrite, // De la CU

    input [31:0] instruction, // Instrucción completa
    input [31:0] write_data, // Lo que se escribe en rd

    output reg [31:0] read_data1, // Contenido registro rs1
    output reg [31:0] read_data2 // Contenido registro rs2
);

    reg [31:0] registers [0:31]; // Array de 32 registros, cada uno de 32 bits
    integer i;

    // Extraer campos de la instrucción
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd  = instruction[11:7];

    // Lectura
    always @(*) begin

        if (rs1 == 5'd0)
            read_data1 = 32'b0;
        else
            read_data1 = registers[rs1];

        if (rs2 == 5'd0)
            read_data2 = 32'b0;
        else
            read_data2 = registers[rs2];

    end

    // Escritura y reset
    always @(posedge clk) begin

        if (reset) begin

            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
                registers[2]<=1024;

        end
        else if (regWrite && rd != 5'd0) begin

            registers[rd] <= write_data;

        end

    end

endmodule