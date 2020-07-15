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

module cpu_top (
  output [31:0]	cpu_axi_data_araddr,
  output [1:0]	cpu_axi_data_arburst,
  output [3:0]	cpu_axi_data_arcache,
  output [7:0]	cpu_axi_data_arlen,
  output [0:0]	cpu_axi_data_arlock,
  output [2:0]	cpu_axi_data_arprot,
  output [3:0]	cpu_axi_data_arqos,
  input			cpu_axi_data_arready,
  output [3:0]	cpu_axi_data_arregion,
  output [2:0]	cpu_axi_data_arsize,
  output		cpu_axi_data_arvalid,
  output [31:0]	cpu_axi_data_awaddr,
  output [1:0]	cpu_axi_data_awburst,
  output [3:0]	cpu_axi_data_awcache,
  output [7:0]	cpu_axi_data_awlen,
  output [0:0]	cpu_axi_data_awlock,
  output [2:0]	cpu_axi_data_awprot,
  output [3:0]	cpu_axi_data_awqos,
  input			cpu_axi_data_awready,
  output [3:0]	cpu_axi_data_awregion,
  output [2:0]	cpu_axi_data_awsize,
  output		cpu_axi_data_awvalid,
  output cpu_axi_data_bready,
  input [1:0]cpu_axi_data_bresp,
  input cpu_axi_data_bvalid,
  input [31:0]cpu_axi_data_rdata,
  input cpu_axi_data_rlast,
  output cpu_axi_data_rready,
  input [1:0]cpu_axi_data_rresp,
  input cpu_axi_data_rvalid,
  output [31:0]cpu_axi_data_wdata,
  output cpu_axi_data_wlast,
  input cpu_axi_data_wready,
  output [3:0]cpu_axi_data_wstrb,
  output cpu_axi_data_wvalid,
  output [31:0]cpu_axi_inst_araddr,
  output [1:0]cpu_axi_inst_arburst,
  output [3:0]cpu_axi_inst_arcache,
  output [7:0]cpu_axi_inst_arlen,
  output [0:0]cpu_axi_inst_arlock,
  output [2:0]cpu_axi_inst_arprot,
  output [3:0]cpu_axi_inst_arqos,
  input cpu_axi_inst_arready,
  output [3:0]cpu_axi_inst_arregion,
  output [2:0]cpu_axi_inst_arsize,
  output cpu_axi_inst_arvalid,
  input [31:0]cpu_axi_inst_rdata,
  input cpu_axi_inst_rlast,
  output cpu_axi_inst_rready,
  input [1:0]cpu_axi_inst_rresp,
  input cpu_axi_inst_rvalid,
  input [31:0]cpu_axi_mmio_araddr,
  input [2:0]cpu_axi_mmio_arprot,
  output cpu_axi_mmio_arready,
  input cpu_axi_mmio_arvalid,
  input [31:0]cpu_axi_mmio_awaddr,
  input [2:0]cpu_axi_mmio_awprot,
  output cpu_axi_mmio_awready,
  input cpu_axi_mmio_awvalid,
  input cpu_axi_mmio_bready,
  output [1:0]cpu_axi_mmio_bresp,
  output cpu_axi_mmio_bvalid,
  output [31:0]cpu_axi_mmio_rdata,
  input cpu_axi_mmio_rready,
  output [1:0]cpu_axi_mmio_rresp,
  output cpu_axi_mmio_rvalid,
  input [31:0]cpu_axi_mmio_wdata,
  output cpu_axi_mmio_wready,
  input [3:0]cpu_axi_mmio_wstrb,
  input cpu_axi_mmio_wvalid,
  output [31:0]cpu_axi_uart_araddr,
  output [2:0]cpu_axi_uart_arprot,
  input cpu_axi_uart_arready,
  output cpu_axi_uart_arvalid,
  output [31:0]cpu_axi_uart_awaddr,
  output [2:0]cpu_axi_uart_awprot,
  input cpu_axi_uart_awready,
  output cpu_axi_uart_awvalid,
  output cpu_axi_uart_bready,
  input [1:0]cpu_axi_uart_bresp,
  input cpu_axi_uart_bvalid,
  input [31:0]cpu_axi_uart_rdata,
  output cpu_axi_uart_rready,
  input [1:0]cpu_axi_uart_rresp,
  input cpu_axi_uart_rvalid,
  output [31:0]cpu_axi_uart_wdata,
  input cpu_axi_uart_wready,
  output [3:0]cpu_axi_uart_wstrb,
  output cpu_axi_uart_wvalid,
  input system_reset_n,
  input sys_port_reset_n,
  input system_clk
);

  wire cpu_clk;
  wire cpu_clk_locked;
  wire [0:0]cpu_ic_reset_n;
  wire [0:0]cpu_reset_n;
  wire cpu_reset;

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

  cpu_fixed		u_cpu_fixed	(
    .cpu_axi_data_araddr	(cpu_axi_data_araddr ),
    .cpu_axi_data_arburst	(cpu_axi_data_arburst),
    .cpu_axi_data_arcache	(cpu_axi_data_arcache),
    .cpu_axi_data_arlen	(cpu_axi_data_arlen),
    .cpu_axi_data_arlock	(cpu_axi_data_arlock),
    .cpu_axi_data_arprot	(cpu_axi_data_arprot),
    .cpu_axi_data_arqos	(cpu_axi_data_arqos),
    .cpu_axi_data_arready	(cpu_axi_data_arready	),
    .cpu_axi_data_arregion	(cpu_axi_data_arregion	),
    .cpu_axi_data_arsize	(cpu_axi_data_arsize	),
    .cpu_axi_data_arvalid	(cpu_axi_data_arvalid	),
    .cpu_axi_data_awaddr	(cpu_axi_data_awaddr	),
    .cpu_axi_data_awburst	(cpu_axi_data_awburst	),
    .cpu_axi_data_awcache	(cpu_axi_data_awcache),
    .cpu_axi_data_awlen	(cpu_axi_data_awlen),
    .cpu_axi_data_awlock	(cpu_axi_data_awlock),
    .cpu_axi_data_awprot	(cpu_axi_data_awprot),
    .cpu_axi_data_awqos	(cpu_axi_data_awqos),
    .cpu_axi_data_awready	(cpu_axi_data_awready	),
    .cpu_axi_data_awregion	(cpu_axi_data_awregion	),
    .cpu_axi_data_awsize	(cpu_axi_data_awsize	),
    .cpu_axi_data_awvalid	(cpu_axi_data_awvalid	),
    .cpu_axi_data_bready	(cpu_axi_data_bready	),
    .cpu_axi_data_bresp	(cpu_axi_data_bresp),
    .cpu_axi_data_bvalid	(cpu_axi_data_bvalid),
    .cpu_axi_data_rdata	(cpu_axi_data_rdata),
    .cpu_axi_data_rlast	(cpu_axi_data_rlast),
    .cpu_axi_data_rready	(cpu_axi_data_rready),
    .cpu_axi_data_rresp	(cpu_axi_data_rresp),
    .cpu_axi_data_rvalid	(cpu_axi_data_rvalid),
    .cpu_axi_data_wdata	(cpu_axi_data_wdata),
    .cpu_axi_data_wlast	(cpu_axi_data_wlast),
    .cpu_axi_data_wready	(cpu_axi_data_wready),
    .cpu_axi_data_wstrb	(cpu_axi_data_wstrb),
    .cpu_axi_data_wvalid	(cpu_axi_data_wvalid ),
    .cpu_axi_inst_araddr	(cpu_axi_inst_araddr ),
    .cpu_axi_inst_arburst	(cpu_axi_inst_arburst),
    .cpu_axi_inst_arcache	(cpu_axi_inst_arcache),
    .cpu_axi_inst_arlen	(cpu_axi_inst_arlen),
    .cpu_axi_inst_arlock	(cpu_axi_inst_arlock),
    .cpu_axi_inst_arprot	(cpu_axi_inst_arprot),
    .cpu_axi_inst_arqos	(cpu_axi_inst_arqos),
    .cpu_axi_inst_arready	(cpu_axi_inst_arready	),
    .cpu_axi_inst_arregion	(cpu_axi_inst_arregion	),
    .cpu_axi_inst_arsize	(cpu_axi_inst_arsize	),
    .cpu_axi_inst_arvalid	(cpu_axi_inst_arvalid	),
    .cpu_axi_inst_rdata	(cpu_axi_inst_rdata),
    .cpu_axi_inst_rlast	(cpu_axi_inst_rlast),
    .cpu_axi_inst_rready	(cpu_axi_inst_rready),
    .cpu_axi_inst_rresp	(cpu_axi_inst_rresp),
    .cpu_axi_inst_rvalid	(cpu_axi_inst_rvalid	),
    .cpu_axi_mmio_araddr	(cpu_axi_mmio_araddr	),
    .cpu_axi_mmio_arprot	(cpu_axi_mmio_arprot	),
    .cpu_axi_mmio_arready	(cpu_axi_mmio_arready	),
    .cpu_axi_mmio_arvalid	(cpu_axi_mmio_arvalid	),
    .cpu_axi_mmio_awaddr	(cpu_axi_mmio_awaddr	),
    .cpu_axi_mmio_awprot	(cpu_axi_mmio_awprot	),
    .cpu_axi_mmio_awready	(cpu_axi_mmio_awready	),
    .cpu_axi_mmio_awvalid	(cpu_axi_mmio_awvalid	),
    .cpu_axi_mmio_bready	(cpu_axi_mmio_bready	),
    .cpu_axi_mmio_bresp		(cpu_axi_mmio_bresp		),
    .cpu_axi_mmio_bvalid	(cpu_axi_mmio_bvalid	),
    .cpu_axi_mmio_rdata		(cpu_axi_mmio_rdata		),
    .cpu_axi_mmio_rready	(cpu_axi_mmio_rready	),
    .cpu_axi_mmio_rresp		(cpu_axi_mmio_rresp		),
    .cpu_axi_mmio_rvalid	(cpu_axi_mmio_rvalid	),
    .cpu_axi_mmio_wdata		(cpu_axi_mmio_wdata		),
    .cpu_axi_mmio_wready	(cpu_axi_mmio_wready	),
    .cpu_axi_mmio_wstrb		(cpu_axi_mmio_wstrb		),
    .cpu_axi_mmio_wvalid	(cpu_axi_mmio_wvalid	),
    .cpu_axi_uart_araddr	(cpu_axi_uart_araddr	),
    .cpu_axi_uart_arprot	(cpu_axi_uart_arprot	),
    .cpu_axi_uart_arready	(cpu_axi_uart_arready	),
    .cpu_axi_uart_arvalid	(cpu_axi_uart_arvalid	),
    .cpu_axi_uart_awaddr	(cpu_axi_uart_awaddr	),
    .cpu_axi_uart_awprot	(cpu_axi_uart_awprot	),
    .cpu_axi_uart_awready	(cpu_axi_uart_awready	),
    .cpu_axi_uart_awvalid	(cpu_axi_uart_awvalid	),
    .cpu_axi_uart_bready	(cpu_axi_uart_bready	),
    .cpu_axi_uart_bresp		(cpu_axi_uart_bresp		),
    .cpu_axi_uart_bvalid	(cpu_axi_uart_bvalid	),
    .cpu_axi_uart_rdata		(cpu_axi_uart_rdata		),
    .cpu_axi_uart_rready	(cpu_axi_uart_rready	),
    .cpu_axi_uart_rresp		(cpu_axi_uart_rresp		),
    .cpu_axi_uart_rvalid	(cpu_axi_uart_rvalid	),
    .cpu_axi_uart_wdata		(cpu_axi_uart_wdata		),
    .cpu_axi_uart_wready	(cpu_axi_uart_wready	),
    .cpu_axi_uart_wstrb		(cpu_axi_uart_wstrb		),
    .cpu_axi_uart_wvalid	(cpu_axi_uart_wvalid	),
    .cpu_clk	(cpu_clk),
    .cpu_clk_locked	(cpu_clk_locked),
    .cpu_ic_reset_n	(cpu_ic_reset_n),
    .cpu_inst_araddr	(cpu_inst_araddr + 32'h40000000),
    .cpu_inst_arburst	(cpu_inst_arburst	),
    .cpu_inst_arcache	('d0),
    .cpu_inst_arlen		(cpu_inst_arlen		),
    .cpu_inst_arlock	('d0),
    .cpu_inst_arprot	('d0),
    .cpu_inst_arqos		('d0),
    .cpu_inst_arready	(cpu_inst_arready	),
    .cpu_inst_arregion	(),
    .cpu_inst_arsize	(cpu_inst_arsize	),
    .cpu_inst_arvalid	(cpu_inst_arvalid	),
    .cpu_inst_rdata		(cpu_inst_rdata		),
    .cpu_inst_rlast		(cpu_inst_rlast		),
    .cpu_inst_rready	(cpu_inst_rready	),
    .cpu_inst_rresp		(cpu_inst_rresp		),
    .cpu_inst_rvalid	(cpu_inst_rvalid	),
    .cpu_mem_araddr		(cpu_mem_araddr + 32'h40000000),
    .cpu_mem_arburst	(cpu_mem_arburst	),
    .cpu_mem_arcache	('d0),
    .cpu_mem_arlen	(cpu_mem_arlen	),
    .cpu_mem_arlock	('d0),
    .cpu_mem_arprot	('d0),
    .cpu_mem_arqos	('d0),
    .cpu_mem_arready	(cpu_mem_arready),
    .cpu_mem_arsize		(cpu_mem_arsize	),
    .cpu_mem_arvalid	(cpu_mem_arvalid),
    .cpu_mem_awaddr		(cpu_mem_awaddr + 32'h40000000),
    .cpu_mem_awburst	(cpu_mem_awburst),
    .cpu_mem_awcache	('d0),
    .cpu_mem_awlen		(cpu_mem_awlen	),
    .cpu_mem_awlock		('d0),
    .cpu_mem_awprot		('d0),
    .cpu_mem_awqos		('d0),
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
    .cpu_mem_wvalid	(cpu_mem_wvalid),
    .cpu_perf_cnt_araddr	(cpu_perf_cnt_araddr	),
    .cpu_perf_cnt_arprot	(cpu_perf_cnt_arprot	),
    .cpu_perf_cnt_arready	(cpu_perf_cnt_arready	),
    .cpu_perf_cnt_arvalid	(cpu_perf_cnt_arvalid	),
    .cpu_perf_cnt_awaddr	(cpu_perf_cnt_awaddr	),
    .cpu_perf_cnt_awprot	(cpu_perf_cnt_awprot	),
    .cpu_perf_cnt_awready	(cpu_perf_cnt_awready	),
    .cpu_perf_cnt_awvalid	(cpu_perf_cnt_awvalid	),
    .cpu_perf_cnt_bready	(cpu_perf_cnt_bready	),
    .cpu_perf_cnt_bresp		(cpu_perf_cnt_bresp		),
    .cpu_perf_cnt_bvalid	(cpu_perf_cnt_bvalid	),
    .cpu_perf_cnt_rdata		(cpu_perf_cnt_rdata		),
    .cpu_perf_cnt_rready	(cpu_perf_cnt_rready	),
    .cpu_perf_cnt_rresp		(cpu_perf_cnt_rresp		),
    .cpu_perf_cnt_rvalid	(cpu_perf_cnt_rvalid	),
    .cpu_perf_cnt_wdata		(cpu_perf_cnt_wdata		),
    .cpu_perf_cnt_wready	(cpu_perf_cnt_wready	),
    .cpu_perf_cnt_wstrb		(cpu_perf_cnt_wstrb		),
    .cpu_perf_cnt_wvalid	(cpu_perf_cnt_wvalid	),
    .cpu_reset_n	(cpu_reset_n),
	.cpu_reset		(cpu_reset),
    .sys_port_reset_n	(sys_port_reset_n),
    .system_clk	(system_clk),
    .system_reset_n	(system_reset_n)
  );

  cpu_clk		u_cpu_clk (
    .cpu_clk		(cpu_clk	   ),
    .cpu_clk_locked	(cpu_clk_locked),
    .cpu_ic_reset_n	(cpu_ic_reset_n),
    .cpu_perf_cnt_0	(cpu_perf_cnt_0),
    .cpu_perf_cnt_1	(cpu_perf_cnt_1),
    .cpu_perf_cnt_2	(cpu_perf_cnt_2),
    .cpu_perf_cnt_3	(cpu_perf_cnt_3),
    .cpu_perf_cnt_4	(cpu_perf_cnt_4),
    .cpu_perf_cnt_5	(cpu_perf_cnt_5),
    .cpu_perf_cnt_6	(cpu_perf_cnt_6),
    .cpu_perf_cnt_7	(cpu_perf_cnt_7),
    .cpu_perf_cnt_8	(cpu_perf_cnt_8),
    .cpu_perf_cnt_9	(cpu_perf_cnt_9),
    .cpu_perf_cnt_10	(cpu_perf_cnt_10),
    .cpu_perf_cnt_11	(cpu_perf_cnt_11),
    .cpu_perf_cnt_12	(cpu_perf_cnt_12),
    .cpu_perf_cnt_13	(cpu_perf_cnt_13),
    .cpu_perf_cnt_14	(cpu_perf_cnt_14),
    .cpu_perf_cnt_15	(cpu_perf_cnt_15),
    .cpu_perf_cnt_araddr	(cpu_perf_cnt_araddr ),
    .cpu_perf_cnt_arprot	(cpu_perf_cnt_arprot ),
    .cpu_perf_cnt_arready	(cpu_perf_cnt_arready),
    .cpu_perf_cnt_arvalid	(cpu_perf_cnt_arvalid),
    .cpu_perf_cnt_awaddr	(cpu_perf_cnt_awaddr ),
    .cpu_perf_cnt_awprot	(cpu_perf_cnt_awprot ),
    .cpu_perf_cnt_awready	(cpu_perf_cnt_awready),
    .cpu_perf_cnt_awvalid	(cpu_perf_cnt_awvalid),
    .cpu_perf_cnt_bready	(cpu_perf_cnt_bready),
    .cpu_perf_cnt_bresp		(cpu_perf_cnt_bresp	),
    .cpu_perf_cnt_bvalid	(cpu_perf_cnt_bvalid),
    .cpu_perf_cnt_rdata		(cpu_perf_cnt_rdata	),
    .cpu_perf_cnt_rready	(cpu_perf_cnt_rready),
    .cpu_perf_cnt_rresp		(cpu_perf_cnt_rresp	),
    .cpu_perf_cnt_rvalid	(cpu_perf_cnt_rvalid),
    .cpu_perf_cnt_wdata		(cpu_perf_cnt_wdata	),
    .cpu_perf_cnt_wready	(cpu_perf_cnt_wready),
    .cpu_perf_cnt_wstrb		(cpu_perf_cnt_wstrb	),
    .cpu_perf_cnt_wvalid	(cpu_perf_cnt_wvalid),
    .cpu_reset_n			(cpu_reset_n		),
    .system_clk				(system_clk),
    .system_reset_n			(system_reset_n)
  );

  cpu_wrapper	u_cpu_wrapper (
	.cpu_clk			(cpu_clk),
	.cpu_reset		(~cpu_reset),

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
