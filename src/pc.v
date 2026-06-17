


module program_counter(
    input wire clk,
    input wire reset,
    input wire pc_src, //selector de fuente de próximo PC 
                                //00: PC+4 (secuencial)
                                //01: Jump
    input wire [31:0] jump_target,
    output reg [31:0] pc_out,
    output reg [31:0] pc4
    
    );
    wire [31:0] pc_plus_4;
    assign pc_plus_4 = pc_out + 4; // Incremento secuencial: PC + 4

    reg [31:0] pc_next; // Lógica combinacional para seleccionar próximo PC
    
    always @(*) begin
        case (pc_src)
            1'b0: pc_next = pc_plus_4;      // Secuencial
            1'b1: pc_next = jump_target;  // Jump
            default: pc_next = pc_plus_4;
        endcase
        pc4=pc_plus_4;
    end
    
    // Registro del PC (actualización síncrona)
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_out <= 32'h00000000;  // Dirección inicial: 0x00000000
        else
            pc_out <= pc_next;
    end
    
endmodule
