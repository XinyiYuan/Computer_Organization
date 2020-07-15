`timescale 10ns / 1ns

`define DATA_WIDTH 32

module alu_test
();

	reg [`DATA_WIDTH - 1:0] A;
	reg [`DATA_WIDTH - 1:0] B;
	reg [2:0] ALUop;
	wire Overflow;
	wire CarryOut;
	wire Zero;
	wire [`DATA_WIDTH - 1:0] Result;

	initial
	begin

		ALUop=3'b000; //and
		A={$random}%32'b1111_1111_1111_1111_1111_1111_1111_1111;
		B={$random}%32'b1111_1111_1111_1111_1111_1111_1111_1111;
	#30	ALUop=3'b001; //or
		A={$random}%32'b1111_1111_1111_1111_1111_1111_1111_1111;
		B={$random}%32'b1111_1111_1111_1111_1111_1111_1111_1111;
	#30	ALUop=3'b010; //add
		A={$random}%32'b1111_1111_1111_1111_1111_1111_1111_1111;
		B={$random}%32'b1111_1111_1111_1111_1111_1111_1111_1111;
	#30	ALUop=3'b110; //sub
		A={$random}%32'b1111_1111_1111_1111_1111_1111_1111_1111;
		B={$random}%32'b1111_1111_1111_1111_1111_1111_1111_1111;
	#30	ALUop=3'b111; //slt
		A={$random}%32'b1111_1111_1111_1111_1111_1111_1111_1111;
		B={$random}%32'b1111_1111_1111_1111_1111_1111_1111_1111;
	#30	ALUop=3'b101; //wrong

		// TODO: Please add your testbench here
	end

	alu u_alu(
		.A(A),
		.B(B),
		.ALUop(ALUop),
		.Overflow(Overflow),
		.CarryOut(CarryOut),
		.Zero(Zero),
		.Result(Result)
	);

endmodule

