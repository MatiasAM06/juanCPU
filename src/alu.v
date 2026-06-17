

module ALU(
	input wire [31:0] inA,
	input wire [31:0] inB,
	input wire [3:0]  aluControl,

	output wire [31:0] result,
	output wire [0:0] zero,
	output wire [0:0] carry,	
	output wire [0:0] negative,
	output wire [0:0] overflow
	);

	
	wire [31:0] sumW;
	wire [31:0] subW;
	wire [31:0] llsW;
	wire [31:0] lrsW;
	wire [31:0] arsW;
	wire [31:0] sltW;
	wire [31:0] sluW;
	wire [31:0] andW;
	wire [31:0] _orW;
	wire [31:0] xorW;


	reg [31:0] tOut;
	assign result = overflow ? 32'b0:tOut;

	assign sumW = inA+inB;
	assign subW = inA-inB;
	assign llsW = inA<<inB[4:0];
	assign lrsW = inA>>inB[4:0];
	assign arsW = $signed(inA)>>>inB[4:0];
	assign sltW = ($signed(inA)<$signed(inB)) ? 32'b1 : 32'b0;
	assign sluW = (inA<inB) ? 32'b1 : 32'b0;
	assign andW = inA & inB;
	assign _orW = inA | inB;
	assign xorW = inA ^ inB;
	
	assign zero = ~(|tOut);
	assign carry = 0;
	assign negative = tOut[31];
	assign overflow = aluControl==ADD?(inA[31]^tOut[31]&(inB[31]^tOut[31])):0;
	//--------------
	//   Literals
	//--------------

	//ALU control mux literals
	localparam ADD  = 4'b0000;
	localparam SUB  = 4'b0001;
	localparam AND  = 4'b0111;
	localparam _OR  = 4'b1000;
	localparam XOR  = 4'b1001;
	localparam LLS  = 4'b0010;
	localparam LRS  = 4'b0011;
	localparam ARS  = 4'b0100;
	localparam SLT  = 4'b0101;
	localparam SLU  = 4'b0110;


	always @(*) begin
		case(aluControl)
			ADD: tOut=sumW;
			SUB: tOut=subW;
			LLS: tOut=llsW;
			LRS: tOut=lrsW;
			ARS: tOut=arsW;
			SLT: tOut=sltW;
			SLU: tOut=sluW;
			AND: tOut=andW;
			_OR: tOut=_orW;
			XOR: tOut=xorW;

			default: tOut=32'b0;

		endcase
	end




endmodule
