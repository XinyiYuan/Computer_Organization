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

	wire carryin;
	wire overflow;
	wire carryout1;
	wire carryout2;
	wire carryout3;
	wire carryout;
	wire [31:0]B1;
	wire [31:0]B2;
	wire [31:0]Result1; //the result of AND
	wire [31:0]Result2; //the result of OR
	wire [31:0]Result3; //the result of ADD and SUB
	wire [31:0]Result4; //the result of ADD, SUB and SLT

	assign Result1=A & B;

	assign Result2=A | B;

	assign carryout1=(B==32'b0)?1:0; //the carryout when turning B into B2
	assign B2=~B+32'b1;
	assign B1=(ALUop==3'b110 || ALUop==3'b111)? B2:B;
	assign {carryin,Result3[30:0]}=A[30:0]+B1[30:0];
	assign {carryout2,Result3[31]}=A[31]+B1[31]+carryin;
	assign carryout3=((ALUop==3'b110 || ALUop==3'b111) && B==32'h80000000)?~carryout2:carryout2; //when B=32'h80000000, carryout3 is the negation of carryout2
	assign carryout=carryout1 | carryout2;
	assign overflow=carryin^carryout3;

	assign Result4[0]=(ALUop==3'b010 || ALUop==3'b110)?Result3[0]:((ALUop==3'b111)?overflow^Result3[31]:0);
	assign Result4[31:1]=(ALUop==3'b010 || ALUop==3'b110)?Result3[31:1]:31'b0;

	assign Result=(ALUop==3'b000)?Result1:((ALUop==3'b001)?Result2:((ALUop==3'b010 || ALUop==3'b110 || ALUop==3'b111)?Result4:32'b0));
	assign Zero=(Result==0)?1:0;
	assign Overflow=(ALUop==3'b010 || ALUop==3'b110 || ALUop==3'b111)?overflow:1'b0;
	assign CarryOut=(ALUop==3'b010)?carryout2:((ALUop==3'b110 || ALUop==3'b111)? ~carryout:1'b0);


	

endmodule
