

module instruction_memory(
    input wire [31:0] addr, //Dirección de memoria [31:0] (del PC)
    output reg [31:0] instruction //Instrucción de 32 bits leída [31:0]
    );
    
    reg [31:0] insMem [0:1023];
    initial begin
    $readmemh("./build/program.hex", insMem);
    end
    always @(*) begin 
        instruction=insMem[addr[31:2]];        
    end



    
endmodule
