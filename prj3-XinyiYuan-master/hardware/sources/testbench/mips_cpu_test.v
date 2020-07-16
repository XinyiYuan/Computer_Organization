`timescale 1ns / 1ns

module mips_cpu_test
();

	reg				mips_cpu_clk;
    reg				mips_cpu_reset_n;

    wire            mips_cpu_pc_sig;

	initial begin
		mips_cpu_clk = 1'b0;
		mips_cpu_reset_n = 1'b0;
		# 30
		mips_cpu_reset_n = 1'b1;

	end

	always begin
		# 5 mips_cpu_clk = ~mips_cpu_clk;
	end

    mips_cpu_fpga    u_mips_cpu (
        .sys_clk		(mips_cpu_clk),
        .sys_reset_n	(mips_cpu_reset_n),

        .mips_cpu_pc_sig    (mips_cpu_pc_sig)
    );

endmodule
