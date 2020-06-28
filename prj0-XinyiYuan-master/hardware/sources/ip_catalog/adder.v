`timescale 1ns / 1ps

module adder(
    input [7:0] operand0,
    input [7:0] operand1,
    output [7:0] result,
    output cout
    );

    assign {cout,result}=operand0+operand1;
	/*TODO: Add your logic code here*/

endmodule
