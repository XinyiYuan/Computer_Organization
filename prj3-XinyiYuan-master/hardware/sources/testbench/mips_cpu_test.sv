`timescale 1ns / 1ps

module mips_cpu_test;

  // module instance
  mips_cpu_fpga u_mips_cpu();

  // the clock signal passed to the cpu.
  wire clock = u_mips_cpu.mips_cpu_clk;

  integer result;
  integer response;

  // the task to reset the board.
  task reset_board;
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.por_srstb_reset(1'b1);

    repeat(16) @(posedge clock);
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.por_srstb_reset(1'b0);
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.fpga_soft_reset(4'hF);

    // This delay depends on your clock frequency. It should be at least 16 clock cycles.
    repeat(32) @(posedge clock);
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.por_srstb_reset(1'b1);
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.fpga_soft_reset(4'h0);

    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.set_debug_level_info(1'b0);
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.M_AXI_HPM0_FPD.set_verbosity(32'd0);
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.S_AXI_HP0_FPD.set_verbosity(32'd0);

    // set latency as minimum to make simulation faster
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.set_slave_profile("M_AXI_HPM0_FPD", 2'b00);
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.set_slave_profile("S_AXI_HP0_FPD", 2'b00);
  endtask

  task run_simulation;

    repeat(100) @(posedge clock);

    // write 1 to 0x80020000 (release CPU reset)
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.write_data(32'h8002_0000, 1, 1024'b1, response);

    // wait for the cpu to write to 32'h4000000c to determine whether test have succeeded. 
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.wait_mem_update(32'h4000_000c, 32'h0, result);

    $display("Hit good trap");

  endtask

  task wait_clocks(input int cycles);
    repeat(cycles) @(posedge clock);
  endtask

  initial begin
    reset_board;
      
    // write 0 to 0x80020000 (CPU reset)
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.write_data(32'h8002_0000, 1, 1024'b0, response);

    // load content in test.txt into memory
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.pre_load_mem_from_file("inst.txt", 32'h4000_0000, 1024);

	run_simulation;
    
	// or wait random clocks to test. but could cause bug hard to reoccur. It's better to change it by hand.
    wait_clocks(50);

`ifdef DEADLOCK_SIM 
    // write 0 to 0x80020000 (CPU reset)
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.write_data(32'h8002_0000, 1, 1024'b0, response);

    // load content in test.txt into memory
    u_mips_cpu.u_zynq_soc_wrapper.mpsoc_i.zynq_mpsoc.inst.pre_load_mem_from_file("inst_deadlock.txt", 32'h4000_0000, 1024);

	run_simulation;

    $display("Deadlock sim finished");
`endif

    $finish;
  end
endmodule
