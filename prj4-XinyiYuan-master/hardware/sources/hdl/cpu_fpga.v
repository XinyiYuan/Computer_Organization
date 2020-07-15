/* =========================================
* Custom CPU coupled with Zynq MPSoC PS part 
* for full-system evaluation
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 29/02/2020
* Version: v0.0.1
*===========================================
*/

`timescale 10 ns / 1 ns

module cpu_fpga ();

  wire [31:0]	cpu_axi_data_araddr;
  wire [1:0]	cpu_axi_data_arburst;
  wire [3:0]	cpu_axi_data_arcache;
  wire [7:0]	cpu_axi_data_arlen;
  wire [0:0]	cpu_axi_data_arlock;
  wire [2:0]	cpu_axi_data_arprot;
  wire [3:0]	cpu_axi_data_arqos;
  wire			cpu_axi_data_arready;
  wire [3:0]	cpu_axi_data_arregion;
  wire [2:0]	cpu_axi_data_arsize;
  wire		cpu_axi_data_arvalid;
  wire [31:0]	cpu_axi_data_awaddr;
  wire [1:0]	cpu_axi_data_awburst;
  wire [3:0]	cpu_axi_data_awcache;
  wire [7:0]	cpu_axi_data_awlen;
  wire [0:0]	cpu_axi_data_awlock;
  wire [2:0]	cpu_axi_data_awprot;
  wire [3:0]	cpu_axi_data_awqos;
  wire			cpu_axi_data_awready;
  wire [3:0]	cpu_axi_data_awregion;
  wire [2:0]	cpu_axi_data_awsize;
  wire		cpu_axi_data_awvalid;
  wire cpu_axi_data_bready;
  wire [1:0]cpu_axi_data_bresp;
  wire cpu_axi_data_bvalid;
  wire [31:0]cpu_axi_data_rdata;
  wire cpu_axi_data_rlast;
  wire cpu_axi_data_rready;
  wire [1:0]cpu_axi_data_rresp;
  wire cpu_axi_data_rvalid;
  wire [31:0]cpu_axi_data_wdata;
  wire cpu_axi_data_wlast;
  wire cpu_axi_data_wready;
  wire [3:0]cpu_axi_data_wstrb;
  wire cpu_axi_data_wvalid;

  wire [31:0]cpu_axi_inst_araddr;
  wire [1:0]cpu_axi_inst_arburst;
  wire [3:0]cpu_axi_inst_arcache;
  wire [7:0]cpu_axi_inst_arlen;
  wire [0:0]cpu_axi_inst_arlock;
  wire [2:0]cpu_axi_inst_arprot;
  wire [3:0]cpu_axi_inst_arqos;
  wire cpu_axi_inst_arready;
  wire [3:0]cpu_axi_inst_arregion;
  wire [2:0]cpu_axi_inst_arsize;
  wire cpu_axi_inst_arvalid;
  wire [31:0]cpu_axi_inst_rdata;
  wire cpu_axi_inst_rlast;
  wire cpu_axi_inst_rready;
  wire [1:0]cpu_axi_inst_rresp;
  wire cpu_axi_inst_rvalid;

  wire [31:0]cpu_axi_mmio_araddr;
  wire [2:0]cpu_axi_mmio_arprot;
  wire cpu_axi_mmio_arready;
  wire cpu_axi_mmio_arvalid;
  wire [31:0]cpu_axi_mmio_awaddr;
  wire [2:0]cpu_axi_mmio_awprot;
  wire cpu_axi_mmio_awready;
  wire cpu_axi_mmio_awvalid;
  wire cpu_axi_mmio_bready;
  wire [1:0]cpu_axi_mmio_bresp;
  wire cpu_axi_mmio_bvalid;
  wire [31:0]cpu_axi_mmio_rdata;
  wire cpu_axi_mmio_rready;
  wire [1:0]cpu_axi_mmio_rresp;
  wire cpu_axi_mmio_rvalid;
  wire [31:0]cpu_axi_mmio_wdata;
  wire cpu_axi_mmio_wready;
  wire [3:0]cpu_axi_mmio_wstrb;
  wire cpu_axi_mmio_wvalid;

  wire [31:0]cpu_axi_uart_araddr;
  wire [2:0]cpu_axi_uart_arprot;
  wire cpu_axi_uart_arready;
  wire cpu_axi_uart_arvalid;
  wire [31:0]cpu_axi_uart_awaddr;
  wire [2:0]cpu_axi_uart_awprot;
  wire cpu_axi_uart_awready;
  wire cpu_axi_uart_awvalid;
  wire cpu_axi_uart_bready;
  wire [1:0]cpu_axi_uart_bresp;
  wire cpu_axi_uart_bvalid;
  wire [31:0]cpu_axi_uart_rdata;
  wire cpu_axi_uart_rready;
  wire [1:0]cpu_axi_uart_rresp;
  wire cpu_axi_uart_rvalid;
  wire [31:0]cpu_axi_uart_wdata;
  wire cpu_axi_uart_wready;
  wire [3:0]cpu_axi_uart_wstrb;
  wire cpu_axi_uart_wvalid;
  
  wire system_reset_n;
  wire sys_port_reset_n;
  wire system_clk;

mpsoc_wrapper	u_mpsoc_wrapper (
  .cpu_axi_data_araddr   (cpu_axi_data_araddr  ),
  .cpu_axi_data_arburst  (cpu_axi_data_arburst ),
  .cpu_axi_data_arcache  (cpu_axi_data_arcache ),
  .cpu_axi_data_arlen    (cpu_axi_data_arlen   ),
  .cpu_axi_data_arlock   (cpu_axi_data_arlock  ),
  .cpu_axi_data_arprot   (cpu_axi_data_arprot  ),
  .cpu_axi_data_arqos    (cpu_axi_data_arqos   ),
  .cpu_axi_data_arready  (cpu_axi_data_arready ),
  .cpu_axi_data_arsize   (cpu_axi_data_arsize  ),
  .cpu_axi_data_arvalid  (cpu_axi_data_arvalid ),
  .cpu_axi_data_awaddr   (cpu_axi_data_awaddr  ),
  .cpu_axi_data_awburst  (cpu_axi_data_awburst ),
  .cpu_axi_data_awcache  (cpu_axi_data_awcache ),
  .cpu_axi_data_awlen   (cpu_axi_data_awlen   ),
  .cpu_axi_data_awlock  (cpu_axi_data_awlock  ),
  .cpu_axi_data_awprot  (cpu_axi_data_awprot  ),
  .cpu_axi_data_awqos   (cpu_axi_data_awqos   ),
  .cpu_axi_data_awready (cpu_axi_data_awready ),
  .cpu_axi_data_awsize  (cpu_axi_data_awsize  ),
  .cpu_axi_data_awvalid (cpu_axi_data_awvalid ),
   .cpu_axi_data_bready (cpu_axi_data_bready ),
   .cpu_axi_data_bresp  (cpu_axi_data_bresp  ),
   .cpu_axi_data_bvalid (cpu_axi_data_bvalid ),
   .cpu_axi_data_rdata  (cpu_axi_data_rdata  ),
   .cpu_axi_data_rlast  (cpu_axi_data_rlast  ),
   .cpu_axi_data_rready (cpu_axi_data_rready ),
   .cpu_axi_data_rresp  (cpu_axi_data_rresp  ),
   .cpu_axi_data_rvalid (cpu_axi_data_rvalid ),
   .cpu_axi_data_wdata  (cpu_axi_data_wdata  ),
   .cpu_axi_data_wlast  (cpu_axi_data_wlast  ),
   .cpu_axi_data_wready (cpu_axi_data_wready ),
   .cpu_axi_data_wstrb  (cpu_axi_data_wstrb  ),
   .cpu_axi_data_wvalid (cpu_axi_data_wvalid ),
   .cpu_axi_inst_araddr (cpu_axi_inst_araddr ),
   .cpu_axi_inst_arburst(cpu_axi_inst_arburst),
   .cpu_axi_inst_arcache(cpu_axi_inst_arcache),
   .cpu_axi_inst_arlen  (cpu_axi_inst_arlen  ),
   .cpu_axi_inst_arlock  (cpu_axi_inst_arlock  ),
   .cpu_axi_inst_arprot  (cpu_axi_inst_arprot  ),
   .cpu_axi_inst_arqos   (cpu_axi_inst_arqos   ),
   .cpu_axi_inst_arready (cpu_axi_inst_arready ),
   .cpu_axi_inst_arsize  (cpu_axi_inst_arsize  ),
   .cpu_axi_inst_arvalid (cpu_axi_inst_arvalid ),
   .cpu_axi_inst_rdata   (cpu_axi_inst_rdata   ),
   .cpu_axi_inst_rlast   (cpu_axi_inst_rlast   ),
   .cpu_axi_inst_rready  (cpu_axi_inst_rready  ),
   .cpu_axi_inst_rresp   (cpu_axi_inst_rresp   ),
   .cpu_axi_inst_rvalid  (cpu_axi_inst_rvalid  ),
   .cpu_axi_mmio_araddr  (cpu_axi_mmio_araddr  ),
   .cpu_axi_mmio_arprot  (cpu_axi_mmio_arprot  ),
   .cpu_axi_mmio_arready (cpu_axi_mmio_arready ),
   .cpu_axi_mmio_arvalid (cpu_axi_mmio_arvalid ),
   .cpu_axi_mmio_awaddr  (cpu_axi_mmio_awaddr  ),
   .cpu_axi_mmio_awprot  (cpu_axi_mmio_awprot  ),
   .cpu_axi_mmio_awready (cpu_axi_mmio_awready ),
   .cpu_axi_mmio_awvalid (cpu_axi_mmio_awvalid ),
   .cpu_axi_mmio_bready  (cpu_axi_mmio_bready  ),
   .cpu_axi_mmio_bresp   (cpu_axi_mmio_bresp   ),
   .cpu_axi_mmio_bvalid  (cpu_axi_mmio_bvalid  ),
   .cpu_axi_mmio_rdata   (cpu_axi_mmio_rdata   ),
   .cpu_axi_mmio_rready  (cpu_axi_mmio_rready  ),
   .cpu_axi_mmio_rresp   (cpu_axi_mmio_rresp   ),
   .cpu_axi_mmio_rvalid  (cpu_axi_mmio_rvalid  ),
   .cpu_axi_mmio_wdata   (cpu_axi_mmio_wdata   ),
   .cpu_axi_mmio_wready  (cpu_axi_mmio_wready  ),
   .cpu_axi_mmio_wstrb   (cpu_axi_mmio_wstrb   ),
   .cpu_axi_mmio_wvalid  (cpu_axi_mmio_wvalid  ),
   .cpu_axi_uart_araddr  (cpu_axi_uart_araddr  ),
   .cpu_axi_uart_arready (cpu_axi_uart_arready ),
   .cpu_axi_uart_arvalid (cpu_axi_uart_arvalid ),
   .cpu_axi_uart_awaddr  (cpu_axi_uart_awaddr  ),
   .cpu_axi_uart_awready (cpu_axi_uart_awready ),
   .cpu_axi_uart_awvalid (cpu_axi_uart_awvalid ),
   .cpu_axi_uart_bready  (cpu_axi_uart_bready  ),
   .cpu_axi_uart_bresp   (cpu_axi_uart_bresp   ),
   .cpu_axi_uart_bvalid  (cpu_axi_uart_bvalid  ),
   .cpu_axi_uart_rdata   (cpu_axi_uart_rdata   ),
   .cpu_axi_uart_rready  (cpu_axi_uart_rready  ),
   .cpu_axi_uart_rresp   (cpu_axi_uart_rresp   ),
   .cpu_axi_uart_rvalid  (cpu_axi_uart_rvalid  ),
   .cpu_axi_uart_wdata   (cpu_axi_uart_wdata   ),
   .cpu_axi_uart_wready  (cpu_axi_uart_wready  ),
   .cpu_axi_uart_wstrb   (cpu_axi_uart_wstrb   ),
   .cpu_axi_uart_wvalid  (cpu_axi_uart_wvalid  ),
   .system_reset_n  (system_reset_n),
   .sys_port_reset_n  (sys_port_reset_n),
   .system_clk (system_clk)
);

cpu_top	u_cpu_top (
  .cpu_axi_data_araddr   (cpu_axi_data_araddr  ),
  .cpu_axi_data_arburst  (cpu_axi_data_arburst ),
  .cpu_axi_data_arcache  (cpu_axi_data_arcache ),
  .cpu_axi_data_arlen    (cpu_axi_data_arlen   ),
  .cpu_axi_data_arlock   (cpu_axi_data_arlock  ),
  .cpu_axi_data_arprot   (cpu_axi_data_arprot  ),
  .cpu_axi_data_arqos    (cpu_axi_data_arqos   ),
  .cpu_axi_data_arready  (cpu_axi_data_arready ),
  .cpu_axi_data_arregion (cpu_axi_data_arregion),
  .cpu_axi_data_arsize   (cpu_axi_data_arsize  ),
  .cpu_axi_data_arvalid  (cpu_axi_data_arvalid ),
  .cpu_axi_data_awaddr   (cpu_axi_data_awaddr  ),
  .cpu_axi_data_awburst  (cpu_axi_data_awburst ),
  .cpu_axi_data_awcache  (cpu_axi_data_awcache ),
  .cpu_axi_data_awlen   (cpu_axi_data_awlen   ),
  .cpu_axi_data_awlock  (cpu_axi_data_awlock  ),
  .cpu_axi_data_awprot  (cpu_axi_data_awprot  ),
  .cpu_axi_data_awqos   (cpu_axi_data_awqos   ),
  .cpu_axi_data_awready (cpu_axi_data_awready ),
  .cpu_axi_data_awregion(cpu_axi_data_awregion),
  .cpu_axi_data_awsize  (cpu_axi_data_awsize  ),
  .cpu_axi_data_awvalid (cpu_axi_data_awvalid ),
   .cpu_axi_data_bready (cpu_axi_data_bready ),
   .cpu_axi_data_bresp  (cpu_axi_data_bresp  ),
   .cpu_axi_data_bvalid (cpu_axi_data_bvalid ),
   .cpu_axi_data_rdata  (cpu_axi_data_rdata  ),
   .cpu_axi_data_rlast  (cpu_axi_data_rlast  ),
   .cpu_axi_data_rready (cpu_axi_data_rready ),
   .cpu_axi_data_rresp  (cpu_axi_data_rresp  ),
   .cpu_axi_data_rvalid (cpu_axi_data_rvalid ),
   .cpu_axi_data_wdata  (cpu_axi_data_wdata  ),
   .cpu_axi_data_wlast  (cpu_axi_data_wlast  ),
   .cpu_axi_data_wready (cpu_axi_data_wready ),
   .cpu_axi_data_wstrb  (cpu_axi_data_wstrb  ),
   .cpu_axi_data_wvalid (cpu_axi_data_wvalid ),
   .cpu_axi_inst_araddr (cpu_axi_inst_araddr ),
   .cpu_axi_inst_arburst(cpu_axi_inst_arburst),
   .cpu_axi_inst_arcache(cpu_axi_inst_arcache),
   .cpu_axi_inst_arlen  (cpu_axi_inst_arlen  ),
   .cpu_axi_inst_arlock  (cpu_axi_inst_arlock  ),
   .cpu_axi_inst_arprot  (cpu_axi_inst_arprot  ),
   .cpu_axi_inst_arqos   (cpu_axi_inst_arqos   ),
   .cpu_axi_inst_arready (cpu_axi_inst_arready ),
   .cpu_axi_inst_arregion(cpu_axi_inst_arregion),
   .cpu_axi_inst_arsize  (cpu_axi_inst_arsize  ),
   .cpu_axi_inst_arvalid (cpu_axi_inst_arvalid ),
   .cpu_axi_inst_rdata   (cpu_axi_inst_rdata   ),
   .cpu_axi_inst_rlast   (cpu_axi_inst_rlast   ),
   .cpu_axi_inst_rready  (cpu_axi_inst_rready  ),
   .cpu_axi_inst_rresp   (cpu_axi_inst_rresp   ),
   .cpu_axi_inst_rvalid  (cpu_axi_inst_rvalid  ),
   .cpu_axi_mmio_araddr  (cpu_axi_mmio_araddr  ),
   .cpu_axi_mmio_arprot  (cpu_axi_mmio_arprot  ),
   .cpu_axi_mmio_arready (cpu_axi_mmio_arready ),
   .cpu_axi_mmio_arvalid (cpu_axi_mmio_arvalid ),
   .cpu_axi_mmio_awaddr  (cpu_axi_mmio_awaddr  ),
   .cpu_axi_mmio_awprot  (cpu_axi_mmio_awprot  ),
   .cpu_axi_mmio_awready (cpu_axi_mmio_awready ),
   .cpu_axi_mmio_awvalid (cpu_axi_mmio_awvalid ),
   .cpu_axi_mmio_bready  (cpu_axi_mmio_bready  ),
   .cpu_axi_mmio_bresp   (cpu_axi_mmio_bresp   ),
   .cpu_axi_mmio_bvalid  (cpu_axi_mmio_bvalid  ),
   .cpu_axi_mmio_rdata   (cpu_axi_mmio_rdata   ),
   .cpu_axi_mmio_rready  (cpu_axi_mmio_rready  ),
   .cpu_axi_mmio_rresp   (cpu_axi_mmio_rresp   ),
   .cpu_axi_mmio_rvalid  (cpu_axi_mmio_rvalid  ),
   .cpu_axi_mmio_wdata   (cpu_axi_mmio_wdata   ),
   .cpu_axi_mmio_wready  (cpu_axi_mmio_wready  ),
   .cpu_axi_mmio_wstrb   (cpu_axi_mmio_wstrb   ),
   .cpu_axi_mmio_wvalid  (cpu_axi_mmio_wvalid  ),
   .cpu_axi_uart_araddr  (cpu_axi_uart_araddr  ),
   .cpu_axi_uart_arprot  (cpu_axi_uart_arprot  ),
   .cpu_axi_uart_arready (cpu_axi_uart_arready ),
   .cpu_axi_uart_arvalid (cpu_axi_uart_arvalid ),
   .cpu_axi_uart_awaddr  (cpu_axi_uart_awaddr  ),
   .cpu_axi_uart_awprot  (cpu_axi_uart_awprot  ),
   .cpu_axi_uart_awready (cpu_axi_uart_awready ),
   .cpu_axi_uart_awvalid (cpu_axi_uart_awvalid ),
   .cpu_axi_uart_bready  (cpu_axi_uart_bready  ),
   .cpu_axi_uart_bresp   (cpu_axi_uart_bresp   ),
   .cpu_axi_uart_bvalid  (cpu_axi_uart_bvalid  ),
   .cpu_axi_uart_rdata   (cpu_axi_uart_rdata   ),
   .cpu_axi_uart_rready  (cpu_axi_uart_rready  ),
   .cpu_axi_uart_rresp   (cpu_axi_uart_rresp   ),
   .cpu_axi_uart_rvalid  (cpu_axi_uart_rvalid  ),
   .cpu_axi_uart_wdata   (cpu_axi_uart_wdata   ),
   .cpu_axi_uart_wready  (cpu_axi_uart_wready  ),
   .cpu_axi_uart_wstrb   (cpu_axi_uart_wstrb   ),
   .cpu_axi_uart_wvalid  (cpu_axi_uart_wvalid  ),
   .system_reset_n  (system_reset_n),
   .sys_port_reset_n  (sys_port_reset_n),
   .system_clk (system_clk)
);

 endmodule
