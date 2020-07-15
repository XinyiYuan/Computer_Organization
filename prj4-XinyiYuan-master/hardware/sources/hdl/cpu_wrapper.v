/* =========================================
* AXI wrapper for custom CPU in the FPGA
* evaluation platform
*
* Author: Yisong Chang (changyisong@ict.ac.cn)
* Date: 29/02/2020
* Version: v0.0.1
*===========================================
*/

`timescale 10 ns / 1 ns

module cpu_wrapper (
	input			cpu_clk,
	input			cpu_reset,
`ifdef POST_SIMU
	output			cpu_pc_sig,
`endif

    output [31:0]	cpu_perf_cnt_0,
    output [31:0]	cpu_perf_cnt_1,
    output [31:0]	cpu_perf_cnt_2,
    output [31:0]	cpu_perf_cnt_3,
    output [31:0]	cpu_perf_cnt_4,
    output [31:0]	cpu_perf_cnt_5,
    output [31:0]	cpu_perf_cnt_6,
    output [31:0]	cpu_perf_cnt_7,
    output [31:0]	cpu_perf_cnt_8,
    output [31:0]	cpu_perf_cnt_9,
    output [31:0]	cpu_perf_cnt_10,
    output [31:0]	cpu_perf_cnt_11,
    output [31:0]	cpu_perf_cnt_12,
    output [31:0]	cpu_perf_cnt_13,
    output [31:0]	cpu_perf_cnt_14,
    output [31:0]	cpu_perf_cnt_15,

	//AXI AR Channel for instruction
    output [31:0]	cpu_inst_araddr,
    input			cpu_inst_arready,
    output			cpu_inst_arvalid,
	output [2:0]	cpu_inst_arsize,
	output [1:0]	cpu_inst_arburst,
	output [7:0]	cpu_inst_arlen,

	//AXI R Channel for instruction
    input [31:0]	cpu_inst_rdata,
    output			cpu_inst_rready,
    input			cpu_inst_rvalid,
	input			cpu_inst_rlast,

	//AXI AR Channel for data
    output [31:0]	cpu_mem_araddr,
    input			cpu_mem_arready,
    output			cpu_mem_arvalid,
	output [2:0]	cpu_mem_arsize,
	output [1:0]	cpu_mem_arburst,
	output [7:0]	cpu_mem_arlen,

	//AXI AW Channel for mem
    output reg [31:0]	cpu_mem_awaddr,
    input				cpu_mem_awready,
    output reg 			cpu_mem_awvalid,
	output [2:0]	cpu_mem_awsize,
	output [1:0]	cpu_mem_awburst,
	output [7:0]	cpu_mem_awlen,

	//AXI B Channel for mem
    output			cpu_mem_bready,
    input			cpu_mem_bvalid,

	//AXI R Channel for mem
    input [31:0]	cpu_mem_rdata,
    output			cpu_mem_rready,
    input			cpu_mem_rvalid,
	input			cpu_mem_rlast,

	//AXI W Channel for mem
    output reg [31:0]	cpu_mem_wdata,
    input			cpu_mem_wready,
    output reg [3:0]	cpu_mem_wstrb,
    output reg			cpu_mem_wvalid,
	output reg			cpu_mem_wlast
);

wire [31:0] Address;
wire MemWrite;
wire [31:0] Write_data;
wire [3:0] Write_strb;
wire MemRead;
wire Mem_Req_Ack;

/* CPU Inst AR channel */
assign cpu_inst_arsize = 3'b010;
assign cpu_inst_arburst = 2'b01;
assign cpu_inst_arlen = 8'd0;

/* CPU MEM AR channel */
assign cpu_mem_araddr = {32{MemRead}} & Address;
assign cpu_mem_arvalid = MemRead;
assign cpu_mem_arsize = 3'b010;
assign cpu_mem_arburst = 2'b01;
assign cpu_mem_arlen = 8'd0;

/* CPU MEM AW and W channel */
assign cpu_mem_awsize = 3'b010;
assign cpu_mem_awburst = 2'b01;
assign cpu_mem_awlen = 8'd0;

reg aw_req_ack_tag;
reg w_req_ack_tag;

//AW channel
always @(posedge cpu_clk)
begin
	if (cpu_reset == 1'b1)
	begin
		cpu_mem_awaddr <= 'd0;
		cpu_mem_awvalid <= 1'b0;
		aw_req_ack_tag <= 1'b0;
	end

	else if (~cpu_mem_awvalid & (~cpu_mem_wvalid) & MemWrite & (~Mem_Req_Ack))
	begin
		cpu_mem_awaddr <= Address;
		cpu_mem_awvalid <= 1'b1;
		aw_req_ack_tag <= 1'b0;
	end

	else if (cpu_mem_awvalid & cpu_mem_awready)
	begin
		cpu_mem_awaddr <= 'd0;
		cpu_mem_awvalid <= 1'b0;
		aw_req_ack_tag <= 1'b1;
	end

	else if (aw_req_ack_tag & w_req_ack_tag)
	begin
		cpu_mem_awaddr <= 'd0;
		cpu_mem_awvalid <= 'd0;
		aw_req_ack_tag <= 1'b0;
	end
end

//W channel
always @(posedge cpu_clk)
begin
	if (cpu_reset == 1'b1)
	begin
		cpu_mem_wdata <= 'd0;
		cpu_mem_wstrb <= 4'b0;
		cpu_mem_wvalid <= 1'b0;
		cpu_mem_wlast <= 1'b0;
		w_req_ack_tag <= 1'b0;
	end

	else if (~cpu_mem_awvalid & (~cpu_mem_wvalid) & MemWrite & (~Mem_Req_Ack))
	begin
		cpu_mem_wdata <= Write_data;
		cpu_mem_wstrb <= Write_strb;
		cpu_mem_wvalid <= 1'b1;
		cpu_mem_wlast <= 1'b1;
		w_req_ack_tag <= 1'b0;
	end

	else if (cpu_mem_wvalid & cpu_mem_wready)
	begin
		cpu_mem_wdata <= 'd0;
		cpu_mem_wstrb <= 4'b0;
		cpu_mem_wvalid <= 1'b0;
		cpu_mem_wlast <= 1'b0;
		w_req_ack_tag <= 1'b1;
	end

	else if (aw_req_ack_tag & w_req_ack_tag)
	begin
		cpu_mem_wdata <= 'd0;
		cpu_mem_wstrb <= 'd0;
		cpu_mem_wvalid <= 1'b0;
		cpu_mem_wlast <= 1'b0;
		w_req_ack_tag <= 1'b0;
	end
end

assign Mem_Req_Ack = (MemWrite & aw_req_ack_tag & w_req_ack_tag) | (MemRead & cpu_mem_arready);

/* CPU MEM B channel */
assign cpu_mem_bready = 1'b1;

//custom CPU core
custom_cpu	u_cpu (	
	.clk			(cpu_clk),
	.rst			(cpu_reset),
	  
	.PC				(cpu_inst_araddr),
	.Inst_Req_Valid	(cpu_inst_arvalid),
	.Inst_Req_Ack	(cpu_inst_arready),
	  
	.Instruction	(cpu_inst_rdata),
	.Inst_Valid		(cpu_inst_rvalid),
	.Inst_Ack		(cpu_inst_rready),
	  
	.Address		(Address),
	.MemWrite		(MemWrite),
	.Write_data		(Write_data),
	.Write_strb		(Write_strb),
	.MemRead		(MemRead),
	.Mem_Req_Ack	(Mem_Req_Ack),
	  
	.Read_data		(cpu_mem_rdata),
	.Read_data_Valid(cpu_mem_rvalid),
	.Read_data_Ack	(cpu_mem_rready),

	.cpu_perf_cnt_0	(cpu_perf_cnt_0 ),
	.cpu_perf_cnt_1	(cpu_perf_cnt_1 ),
	.cpu_perf_cnt_2	(cpu_perf_cnt_2 ),
	.cpu_perf_cnt_3	(cpu_perf_cnt_3 ),
	.cpu_perf_cnt_4	(cpu_perf_cnt_4 ),
	.cpu_perf_cnt_5	(cpu_perf_cnt_5 ),
	.cpu_perf_cnt_6	(cpu_perf_cnt_6 ),
	.cpu_perf_cnt_7	(cpu_perf_cnt_7 ),
	.cpu_perf_cnt_8	(cpu_perf_cnt_8 ),
	.cpu_perf_cnt_9	(cpu_perf_cnt_9 ),
	.cpu_perf_cnt_10	(cpu_perf_cnt_10),
	.cpu_perf_cnt_11	(cpu_perf_cnt_11),
	.cpu_perf_cnt_12	(cpu_perf_cnt_12),
	.cpu_perf_cnt_13	(cpu_perf_cnt_13),
	.cpu_perf_cnt_14	(cpu_perf_cnt_14),
	.cpu_perf_cnt_15	(cpu_perf_cnt_15)
);

`ifdef POST_SIMU
	assign cpu_pc_sig = PC[2];
`endif

`ifdef UART_SIM
wire io_wr_ack = MemWrite & Address[16];
always @ (*)
begin
	if (io_wr_ack)
		$write("%c", Write_data[7:0]);
end
`endif

endmodule

