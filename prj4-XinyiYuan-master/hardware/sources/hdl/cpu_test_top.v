/* =========================================
* Top module of custom CPU with 
* 1). a fixed design that contains 
* a number of AXI ICs, and 
* 2). clock wizard that generates 
* CPU source clock. 
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 29/02/2020
* Version: v0.0.1
*===========================================
*/

`timescale 10 ns / 1 ns

module cpu_test_top (
  input sys_clk,
  input sys_reset_n
);

  wire cpu_clk;
  wire cpu_reset_n;

  wire [31:0]cpu_inst_araddr;
  wire [1:0]cpu_inst_arburst;
  wire [3:0]cpu_inst_arcache;
  wire [7:0]cpu_inst_arlen;
  wire [0:0]cpu_inst_arlock;
  wire [2:0]cpu_inst_arprot;
  wire [3:0]cpu_inst_arqos;
  wire cpu_inst_arready;
  wire [2:0]cpu_inst_arsize;
  wire cpu_inst_arvalid;
  wire [31:0]cpu_inst_rdata;
  wire cpu_inst_rlast;
  wire cpu_inst_rready;
  wire [1:0]cpu_inst_rresp;
  wire cpu_inst_rvalid;
  wire [31:0]cpu_mem_araddr;
  wire [1:0]cpu_mem_arburst;
  wire [3:0]cpu_mem_arcache;
  wire [7:0]cpu_mem_arlen;
  wire [0:0]cpu_mem_arlock;
  wire [2:0]cpu_mem_arprot;
  wire [3:0]cpu_mem_arqos;
  wire [0:0]cpu_mem_arready;
  wire [2:0]cpu_mem_arsize;
  wire [0:0]cpu_mem_arvalid;
  wire [31:0]cpu_mem_awaddr;
  wire [1:0]cpu_mem_awburst;
  wire [3:0]cpu_mem_awcache;
  wire [7:0]cpu_mem_awlen;
  wire [0:0]cpu_mem_awlock;
  wire [2:0]cpu_mem_awprot;
  wire [3:0]cpu_mem_awqos;
  wire [0:0]cpu_mem_awready;
  wire [2:0]cpu_mem_awsize;
  wire [0:0]cpu_mem_awvalid;
  wire [0:0]cpu_mem_bready;
  wire [1:0]cpu_mem_bresp;
  wire [0:0]cpu_mem_bvalid;
  wire [31:0]cpu_mem_rdata;
  wire [0:0]cpu_mem_rlast;
  wire [0:0]cpu_mem_rready;
  wire [1:0]cpu_mem_rresp;
  wire [0:0]cpu_mem_rvalid;
  wire [31:0]cpu_mem_wdata;
  wire [0:0]cpu_mem_wlast;
  wire [0:0]cpu_mem_wready;
  wire [3:0]cpu_mem_wstrb;
  wire [0:0]cpu_mem_wvalid;
  wire [31:0]cpu_perf_cnt_araddr;
  wire [2:0]cpu_perf_cnt_arprot;
  wire [0:0]cpu_perf_cnt_arready;
  wire [0:0]cpu_perf_cnt_arvalid;
  wire [31:0]cpu_perf_cnt_awaddr;
  wire [2:0]cpu_perf_cnt_awprot;
  wire [0:0]cpu_perf_cnt_awready;
  wire [0:0]cpu_perf_cnt_awvalid;
  wire [0:0]cpu_perf_cnt_bready;
  wire [1:0]cpu_perf_cnt_bresp;
  wire [0:0]cpu_perf_cnt_bvalid;
  wire [31:0]cpu_perf_cnt_rdata;
  wire [0:0]cpu_perf_cnt_rready;
  wire [1:0]cpu_perf_cnt_rresp;
  wire [0:0]cpu_perf_cnt_rvalid;
  wire [31:0]cpu_perf_cnt_wdata;
  wire [0:0]cpu_perf_cnt_wready;
  wire [3:0]cpu_perf_cnt_wstrb;
  wire [0:0]cpu_perf_cnt_wvalid;
  wire [31:0]	cpu_perf_cnt_0;
  wire [31:0]	cpu_perf_cnt_1;
  wire [31:0]	cpu_perf_cnt_2;
  wire [31:0]	cpu_perf_cnt_3;
  wire [31:0]	cpu_perf_cnt_4;
  wire [31:0]	cpu_perf_cnt_5;
  wire [31:0]	cpu_perf_cnt_6;
  wire [31:0]	cpu_perf_cnt_7;
  wire [31:0]	cpu_perf_cnt_8;
  wire [31:0]	cpu_perf_cnt_9;
  wire [31:0]	cpu_perf_cnt_10;
  wire [31:0]	cpu_perf_cnt_11;
  wire [31:0]	cpu_perf_cnt_12;
  wire [31:0]	cpu_perf_cnt_13;
  wire [31:0]	cpu_perf_cnt_14;
  wire [31:0]	cpu_perf_cnt_15;

  cpu_sim_wrapper		u_cpu_sim	(
    .sys_clk	(sys_clk),
	.system_clk	(cpu_clk),

    .sys_reset_n	(sys_reset_n),
    .cpu_reset_n	(cpu_reset_n),

    .cpu_inst_araddr	(cpu_inst_araddr + 32'h40000000),
    .cpu_inst_arburst	(cpu_inst_arburst	),
    .cpu_inst_arlen		(cpu_inst_arlen		),
    .cpu_inst_arready	(cpu_inst_arready	),
    .cpu_inst_arsize	(cpu_inst_arsize	),
    .cpu_inst_arvalid	(cpu_inst_arvalid	),
    .cpu_inst_rdata		(cpu_inst_rdata		),
    .cpu_inst_rlast		(cpu_inst_rlast		),
    .cpu_inst_rready	(cpu_inst_rready	),
    .cpu_inst_rresp		(cpu_inst_rresp		),
    .cpu_inst_rvalid	(cpu_inst_rvalid	),
    .cpu_mem_araddr		(cpu_mem_araddr + 32'h40000000),
    .cpu_mem_arburst	(cpu_mem_arburst	),
    .cpu_mem_arlen	(cpu_mem_arlen	),
    .cpu_mem_arready	(cpu_mem_arready),
    .cpu_mem_arsize		(cpu_mem_arsize	),
    .cpu_mem_arvalid	(cpu_mem_arvalid),
    .cpu_mem_awaddr		(cpu_mem_awaddr + 32'h40000000),
    .cpu_mem_awburst	(cpu_mem_awburst),
    .cpu_mem_awlen		(cpu_mem_awlen	),
    .cpu_mem_awready	(cpu_mem_awready),
    .cpu_mem_awsize		(cpu_mem_awsize	),
    .cpu_mem_awvalid	(cpu_mem_awvalid),
    .cpu_mem_bready	(cpu_mem_bready),
    .cpu_mem_bresp	(cpu_mem_bresp ),
    .cpu_mem_bvalid	(cpu_mem_bvalid),
    .cpu_mem_rdata	(cpu_mem_rdata ),
    .cpu_mem_rlast	(cpu_mem_rlast ),
    .cpu_mem_rready	(cpu_mem_rready),
    .cpu_mem_rresp	(cpu_mem_rresp ),
    .cpu_mem_rvalid	(cpu_mem_rvalid),
    .cpu_mem_wdata	(cpu_mem_wdata ),
    .cpu_mem_wlast	(cpu_mem_wlast ),
    .cpu_mem_wready	(cpu_mem_wready),
    .cpu_mem_wstrb	(cpu_mem_wstrb ),
    .cpu_mem_wvalid	(cpu_mem_wvalid)
  );

  cpu_wrapper	u_cpu_wrapper (
	.cpu_clk			(cpu_clk),
	.cpu_reset		(~cpu_reset_n),

	.cpu_perf_cnt_0 (cpu_perf_cnt_0),
	.cpu_perf_cnt_1 (cpu_perf_cnt_1),
	.cpu_perf_cnt_2 (cpu_perf_cnt_2),
	.cpu_perf_cnt_3 (cpu_perf_cnt_3),
	.cpu_perf_cnt_4 (cpu_perf_cnt_4),
	.cpu_perf_cnt_5 (cpu_perf_cnt_5),
	.cpu_perf_cnt_6 (cpu_perf_cnt_6),
	.cpu_perf_cnt_7 (cpu_perf_cnt_7),
	.cpu_perf_cnt_8 (cpu_perf_cnt_8),
	.cpu_perf_cnt_9 (cpu_perf_cnt_9),
	.cpu_perf_cnt_10 (cpu_perf_cnt_10),
	.cpu_perf_cnt_11 (cpu_perf_cnt_11),
	.cpu_perf_cnt_12 (cpu_perf_cnt_12),
	.cpu_perf_cnt_13 (cpu_perf_cnt_13),
	.cpu_perf_cnt_14 (cpu_perf_cnt_14),
	.cpu_perf_cnt_15 (cpu_perf_cnt_15),
	                      
	.cpu_inst_araddr  (cpu_inst_araddr ),
	.cpu_inst_arready (cpu_inst_arready),
	.cpu_inst_arvalid (cpu_inst_arvalid),
	.cpu_inst_arsize  (cpu_inst_arsize ),
	.cpu_inst_arburst (cpu_inst_arburst),
	.cpu_inst_arlen   (cpu_inst_arlen  ),
	                      
	.cpu_inst_rdata  (cpu_inst_rdata ),
	.cpu_inst_rready (cpu_inst_rready),
	.cpu_inst_rvalid (cpu_inst_rvalid),
	.cpu_inst_rlast  (cpu_inst_rlast ),
	                      
	.cpu_mem_araddr  (cpu_mem_araddr ),
	.cpu_mem_arready (cpu_mem_arready),
	.cpu_mem_arvalid (cpu_mem_arvalid),
	.cpu_mem_arsize  (cpu_mem_arsize ),
	.cpu_mem_arburst (cpu_mem_arburst),
	.cpu_mem_arlen   (cpu_mem_arlen  ),
	                      
	.cpu_mem_awaddr  (cpu_mem_awaddr ),
	.cpu_mem_awready (cpu_mem_awready),
	.cpu_mem_awvalid (cpu_mem_awvalid),
	.cpu_mem_awsize  (cpu_mem_awsize ),
	.cpu_mem_awburst (cpu_mem_awburst),
	.cpu_mem_awlen   (cpu_mem_awlen  ),
	                      
	.cpu_mem_bready (cpu_mem_bready),
	.cpu_mem_bvalid (cpu_mem_bvalid),
	                      
	.cpu_mem_rdata  (cpu_mem_rdata ),
	.cpu_mem_rready (cpu_mem_rready),
	.cpu_mem_rvalid (cpu_mem_rvalid),
	.cpu_mem_rlast  (cpu_mem_rlast ),
	                      
	.cpu_mem_wdata  (cpu_mem_wdata ),
	.cpu_mem_wready (cpu_mem_wready),
	.cpu_mem_wstrb  (cpu_mem_wstrb ),
	.cpu_mem_wvalid (cpu_mem_wvalid),
	.cpu_mem_wlast  (cpu_mem_wlast )
 );

 endmodule
