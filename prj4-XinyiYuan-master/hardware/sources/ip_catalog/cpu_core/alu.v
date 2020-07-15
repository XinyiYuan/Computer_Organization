`timescale 10 ns / 1 ns

`define DATA_WIDTH 32

module alu(
	input [`DATA_WIDTH - 1:0] A,
	input [`DATA_WIDTH - 1:0] B,
	input [2:0] ALUop,
	output Overflow,
	output CarryOut,
	output Zero,
	output [`DATA_WIDTH - 1:0] Result
);

	wire [31:0]ResultAND;
	wire [31:0]ResultOR;
	wire [31:0]ResultXOR;
	wire [31:0]ResultRight;
	
	wire [32:0]SIGNED;
	wire [32:0]SIGNED1;
	wire [32:0]UNSIGNED;
	wire [32:0]UNSIGNED1;
	wire [32:0]calculate;
	wire [32:0]calculate1;
	wire [63:0]temp;

	assign ResultAND=A & B;

	assign ResultOR=A | B;

	assign ResultXOR=A ^ B;

	assign SIGNED=~{B[31],B}+33'd1;
	assign SIGNED1=(ALUop==3'b010)?{B[31],B}:SIGNED;
	assign UNSIGNED=~{1'b0,B}+33'd1;
	assign UNSIGNED1=(ALUop==3'b010)?{1'b0,B}:UNSIGNED;
	
	assign temp={32'hffffffff,A}>>B;
	assign ResultRight=(A[31]==1)?temp[31:0]:A>>B;
	
	assign calculate={A[31],A}+SIGNED1;
	assign calculate1={1'b0,A}+UNSIGNED1;
	
	assign Overflow=calculate[32]^calculate[31];
	assign CarryOut=calculate1[32];
	
	assign Result=(ALUop==3'b000)?ResultAND: // AND
				(ALUop==3'b001)?ResultOR: // OR
				(ALUop==3'b010)?calculate[31:0]: // ADD
				(ALUop==3'b011)?ResultXOR: // XOR
				(ALUop==3'b100)?ResultRight: // shift right
				(ALUop==3'b101)?CarryOut: // compare unsigned numbers
				(ALUop==3'b110)?calculate[31:0]: //Substract
				(ALUop==3'b111)?{31'b0,calculate[31]^Overflow}: // SLT
				0;
	
	assign Zero=(Result==0)?1:0;
	
endmodule
