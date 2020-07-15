`timescale 1ns / 1ns

`define DATA_WIDTH 32
`define ADDR_WIDTH 5

module reg_file_test
();

	reg clk;
	reg rst;
	reg [`ADDR_WIDTH - 1:0] waddr;
	reg wen;
	reg [`DATA_WIDTH - 1:0] wdata;

	reg [`ADDR_WIDTH - 1:0] raddr1;
	reg [`ADDR_WIDTH - 1:0] raddr2;
	wire [`DATA_WIDTH - 1:0] rdata1;
	wire [`DATA_WIDTH - 1:0] rdata2;

	initial begin
		clk=1'b1;
		rst=1'b1;
		wen=1'b1;
		forever begin
			repeat(5) begin
				#10 rst={$random} % 2;
			end
			wen={$random} % 2;
			waddr={$random} % 32;
			raddr1={$random} % 32;
			raddr2={$random} % 32;
			wdata={$random} % 32;
		end
		// TODO: Please add your testbench here
	end

	always begin
		#5 clk = ~clk;
	end

	reg_file u_reg_file(
		.clk(clk),
		.rst(rst),
		.waddr(waddr),
		.raddr1(raddr1),
		.raddr2(raddr2),
		.wen(wen),
		.wdata(wdata),
		.rdata1(rdata1),
		.rdata2(rdata2)
	);

endmodule
