
module branch_unit(
    input wire jalr, //indica JALR
    input wire [31:0] pc_current, //PC actual
    input wire [31:0] imm, //extraido de la instrucción
    input wire [31:0] rs1_data,
    output reg [31:0] jump_target
    
    );
    
//Cálculo de direcciones destino  

        
    always @(*) begin
        case(jalr)
            0:jump_target=(pc_current + imm);               //jal/b
            1:jump_target=((rs1_data + imm) & 32'hFFFFFFFE); //jalr
            default:jump_target=(pc_current + imm);
        endcase
    end

    
endmodule
