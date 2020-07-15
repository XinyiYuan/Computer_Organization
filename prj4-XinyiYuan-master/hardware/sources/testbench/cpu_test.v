`timescale 1ns / 1ns

module cpu_test
();

	reg				sys_clk;
    reg				sys_reset_n;

	initial begin
		sys_clk = 1'b0;
		sys_reset_n = 1'b0;
		# 30
		sys_reset_n = 1'b1;

	end

	always begin
		# 5 sys_clk = ~sys_clk;
	end

    cpu_test_top    u_cpu_test (
        .sys_clk		(sys_clk),
        .sys_reset_n	(sys_reset_n)
    );

endmodule
