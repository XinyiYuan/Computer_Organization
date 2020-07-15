`timescale 10ns / 1ns

`define N 9'b000000001
`define IF 9'b000000010
`define IW 9'b000000100
`define ID 9'b000001000
`define EX 9'b000010000
`define WB 9'b000100000
`define ST 9'b001000000
`define LD 9'b010000000
`define RDW 9'b100000000

module custom_cpu(
	input  rst,
	input  clk,

	//Instruction request channel
	output reg [31:0] PC,
	output reg Inst_Req_Valid,
	input Inst_Req_Ack,

	//Instruction response channel
	input  [31:0] Instruction,
	input Inst_Valid,
	output Inst_Ack,

	//Memory request channel
	output [31:0] Address,
	output reg MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,
	output reg MemRead,
	input Mem_Req_Ack,

	//Memory data response channel
	input  [31:0] Read_data,
	input Read_data_Valid,
	output Read_data_Ack, 

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
    output [31:0]	cpu_perf_cnt_15

);

  //TODO: Please add your RISC-V CPU code here
	wire RF_wen;
	wire [4:0] RF_waddr;
	wire [31:0] RF_wdata;
	wire [31:0] Data_load;
	
	wire [6:0] op;
	wire [4:0] rd;
	wire [2:0] func;
	wire [4:0] rs1;
	wire [4:0] rs2;
	wire [6:0] top7;
	
	wire Lui, Auipc, Jal, Jalr, Beq, Bne, Blt, Bge, Bltu, Bgeu, Lb, Lh, Lw, Lbu, Lhu, Sb, Sh, Sw, Addi, Slti, Sltiu, Xori, Ori, Andi, Slli, Srli, Srai, Add, Sub, Sll, Slt, Sltu, Xor, Srl, Sra, Or, And;
	wire Branch,Load,Store,B1_sign;
	
	wire [2:0] ALUop;
	wire Overflow,CarryOut,Zero;
	wire [31:0] Result;
	wire [31:0] data;
	wire [31:0] A;
	wire [31:0] B;
	wire [31:0] B1;
	wire [31:0] extend;
	reg [31:0] PC1;
	wire [31:0] PC2;
	wire [31:0] PC3;
	wire [31:0] PCjump;
	
	reg [8:0] state;
	reg [8:0] nextstate;
	reg [31:0] instruction;
	reg [31:0] Read_data1;

//state machine	
	always@(posedge clk)
	begin
		if(rst) state <= `N;
		else state <= nextstate;
	end
	
	always@(*)
	begin
		case(state)
		`N:
			nextstate = `IF;
		`IF:
			if(Inst_Req_Ack & Inst_Req_Valid) nextstate = `IW;
			else nextstate = `IF;
		`IW:
			if(Inst_Valid & Inst_Ack) nextstate = `ID;
			else nextstate = `IW;
		`ID:
			nextstate = `EX;
		`EX:
			if (Branch) nextstate = `IF;
			else if (Load) nextstate = `LD;
			else if (Store) nextstate = `ST;
			else nextstate = `WB;
		`WB:
			nextstate = `IF;
		`ST:
			if (Mem_Req_Ack & MemWrite) nextstate = `IF;
			else nextstate = `ST;
		`LD:
			if (Mem_Req_Ack & MemRead) nextstate = `RDW;
			else nextstate = `LD;
		`RDW:
			if (Read_data_Valid & Read_data_Ack) nextstate = `WB;
			else nextstate = `RDW;
		default:
			nextstate = `N;
		endcase
	end
	
	always@(posedge clk)
	if(rst) instruction <= 32'd0;
	else if(Inst_Valid && Inst_Ack) instruction <= Instruction;

	always@(posedge clk)
	if(rst) Read_data1 <= 32'd0;
	else if(Read_data_Valid && Read_data_Ack ) Read_data1 <= Read_data;
	
	always@(posedge clk)
	begin
		if (rst) Inst_Req_Valid <= 0;
		else if (state==`IF)
		begin
			if (Inst_Req_Valid==0) Inst_Req_Valid <= 1;
			else if (Inst_Req_Valid & Inst_Req_Ack) Inst_Req_Valid <= 0;
		end
		else Inst_Req_Valid <= 0;
	end
	
	assign Inst_Ack = (state == `IW) | (state == `IF && Inst_Valid);
	assign Read_data_Ack = (state == `RDW);
	
	always@(posedge clk)
	begin
		if (rst) MemRead <= 0;
		else if (state==`LD)
		begin
			if (MemRead==0) MemRead <= 1;
			else if (MemRead & Mem_Req_Ack) MemRead <= 0;
		end
		else MemRead <= 0;
	end
	
	always@(posedge clk)
	begin
		if (rst) MemWrite <= 0;
		else if (state==`ST)
		begin
			if (MemWrite==0) MemWrite <= 1;
			else if (MemWrite & Mem_Req_Ack) MemWrite <= 0;
		end
		else MemWrite <= 0;
	end
	
// break up instruction into 6 parts
	assign op = instruction[6:0];
	assign rd = instruction[11:7];
	assign func = instruction[14:12];
	assign rs1 = instruction[19:15];
	assign rs2 = instruction[24:20];  
	assign top7 = instruction[31:25];
	
	assign Lui = (op==7'b0110111);
	assign Auipc = (op == 7'b0010111);
	assign Jal = (op == 7'b1101111);
	assign Jalr = (op == 7'b1100111) && (func == 3'b000);
	assign Beq = (op == 7'b1100011) && (func == 3'b000);
	assign Bne = (op == 7'b1100011) && (func == 3'b001);
	assign Blt = (op == 7'b1100011) && (func == 3'b100);
	assign Bge =  (op == 7'b1100011) && (func == 3'b101);
	assign Bltu = (op == 7'b1100011) && (func == 3'b110);
	assign Bgeu = (op == 7'b1100011) && (func == 3'b111);
	assign Lb = (op == 7'b0000011) && (func == 3'b000);
	assign Lh = (op == 7'b0000011) && (func == 3'b001);
	assign Lw = (op == 7'b0000011) && (func == 3'b010);
	assign Lbu = (op == 7'b0000011) && (func == 3'b100);
	assign Lhu = (op == 7'b0000011) && (func == 3'b101);
	assign Sb = (op == 7'b0100011) && (func == 3'b000);
	assign Sh = (op == 7'b0100011) && (func == 3'b001);
	assign Sw = (op == 7'b0100011) && (func == 3'b010);
	assign Addi = (op == 7'b0010011) && (func == 3'b000);
	assign Slti = (op == 7'b0010011) && (func == 3'b010);
	assign Sltiu =  (op == 7'b0010011) && (func == 3'b011);
	assign Xori = (op == 7'b0010011) && (func == 3'b100);
	assign Ori = (op == 7'b0010011) && (func == 3'b110);
	assign Andi = (op == 7'b0010011) && (func == 3'b111);
	assign Slli = (op == 7'b0010011) && (func == 3'b001) && (top7 == 7'b0000000);
	assign Srli = (op == 7'b0010011) && (func == 3'b101) && (top7 == 7'b0000000);
	assign Srai = (op == 7'b0010011) && (func == 3'b101) && (top7 == 7'b0100000);
	assign Add = (op == 7'b0110011) && (func == 3'b000) && (top7 == 7'b0000000);
	assign Sub = (op == 7'b0110011) && (func == 3'b000) && (top7 == 7'b0100000);
	assign Sll = (op == 7'b0110011) && (func == 3'b001) && (top7 == 7'b0000000);
	assign Slt = (op == 7'b0110011) && (func == 3'b010) && (top7 == 7'b0000000);
	assign Sltu = (op == 7'b0110011) && (func == 3'b011) && (top7 == 7'b0000000);
	assign Xor = (op == 7'b0110011) && (func == 3'b100) && (top7 == 7'b0000000);
	assign Srl = (op == 7'b0110011) && (func == 3'b101) && (top7 == 7'b0000000);
	assign Sra = (op == 7'b0110011) && (func == 3'b101) && (top7 == 7'b0100000);
	assign Or = (op == 7'b0110011) && (func == 3'b110) && (top7 == 7'b0000000);
	assign And = (op == 7'b0110011) && (func == 3'b111) && (top7 == 7'b0000000);
	
	assign Branch = (Beq || Bne || Blt || Bge || Bltu || Bgeu); //B-type
	assign Store =(Sb || Sh ||Sw); //S-type
	assign Load = (Lb || Lh || Lw || Lbu || Lhu); //I-type Load 
	
	assign ALUop = (Lui || Auipc || Jal || Jalr || Load || Store || Addi || Add)?3'b010: //And
					(Bne || Beq || Sub)?3'b110: //Substract
					(Srai ||Sra)?3'b100: //shift right
					(Ori ||Or)?3'b001: //Or
					(Slt || Slti || Blt || Bge)?3'b111: //Slt
					(Sltiu || Sltu || Bltu || Bgeu)?3'b101: //compare unsigned numbers
					(Xori || Xor)?3'b011: //Xor
					3'b000; //And                
	
	assign extend = (Lui||Auipc)? {instruction[31:12],12'd0}:
					(Jal)? {{11{instruction[31]}},instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0}:
					(Jalr || Load || Addi || Slti || Sltiu || Xori || Ori || Andi)? {{20{instruction[31]}},instruction[31:20]}:
					(Branch)? {{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0}:
					{{20{instruction[31]}},instruction[31:25],instruction[11:7]};
	
	assign Write_strb = (Sb && (Result[1:0]==2'b00))?4'b0001:
							(Sb && (Result[1:0]==2'b01))?4'b0010:
							(Sb && (Result[1:0]==2'b10))?4'b0100:
							(Sb && (Result[1:0]==2'b11))?4'b1000:
							(Sh && (Result[1]==1'b0))?4'b0011:
							(Sh && (Result[1]==1'b1))?4'b1100:
							4'b1111;
	assign Write_data = (Sb && (Write_strb == 4'b0001))?{24'd0,B[7:0]}:
							(Sb && (Write_strb == 4'b0010))?{16'd0,B[7:0],8'd0}:
							(Sb && (Write_strb == 4'b0100))?{8'd0,B[7:0],16'd0}:
							(Sb && (Write_strb == 4'b1000))?{B[7:0],24'd0}:
							(Sh && (Write_strb == 4'b0011))?{16'd0,B[15:0]}:
							(Sh && (Write_strb == 4'b1100))?{B[15:0],16'd0}:
							B;
	
	assign Address = (Lb||Lbu||Lh||Lhu||Sb||Sh)?{Result[31:2],2'b00}:Result;

	assign RF_wen = (state == `WB); 
	assign RF_waddr = rd;
	assign RF_wdata = (Slli)?(A<<rs2):
						(Sll)?(A<<{B[4:0]}):
						(Srli)?(A>>rs2):
						(Srl)?(A>>{B[4:0]}):
						(Lb || Lbu || Lh || Lhu)?Data_load:
						(Jal || Jalr)? PC1+32'd4:
						(Lui)?{instruction[31:12],12'd0}:
						(Load)?Read_data1:
						Result;
	assign Data_load = (Lb)?
							(Result[1:0]==2'b00)?{{24{Read_data1[7]}},Read_data1[7:0]}:
							(Result[1:0]==2'b01)?{{24{Read_data1[15]}},Read_data1[15:8]}:
							(Result[1:0]==2'b10)?{{24{Read_data1[23]}},Read_data1[23:16]}:
							(Result[1:0]==2'b11)?{{24{Read_data1[31]}},Read_data1[31:24]}:
							0:
						(Lbu)?
							(Result[1:0]==2'b00)?$unsigned(Read_data1[7:0]):
							(Result[1:0]==2'b01)?$unsigned(Read_data1[15:8]):
							(Result[1:0]==2'b10)?$unsigned(Read_data1[23:16]):
							(Result[1:0]==2'b11)?$unsigned(Read_data1[31:24]):
							0:
						(Lh)?
							(Result[1]==1'b0)?{{16{Read_data1[15]}},Read_data1[15:0]}:
							(Result[1]==1'b1)?{{16{Read_data1[31]}},Read_data1[31:16]}:
							0:
						(Lhu)?
							(Result[1]==1'b0)?$unsigned(Read_data1[15:0]):
							(Result[1]==1'b1)?$unsigned(Read_data1[31:16]):
							0:
						0;
	
	always@(posedge clk)
	begin
		if (rst) PC <= 32'b0;
		else if (state == `EX) PC <= PC2;
	end
	
	always@(posedge clk)
	begin
		if(rst) PC1 <= 32'd0;
		else if(state == `IF) PC1 <= PC;
	end
	
	assign PC3 = PC + 32'd4;
	assign PCjump = (Jal || Jalr)?{Result[31:1],1'b0}:(PC+extend);
	assign PC2 = (Jal || Jalr || ((Beq || Bge || Bgeu) && Zero)||((Bne || Blt || Bltu ) && !Zero))?PCjump:PC3;
	
	reg_file reg_file1(clk,rst,RF_waddr,rs1,rs2,RF_wen,RF_wdata,A,B);
		
	assign data = (Jal)?PC:(Auipc)?PC1:A;
	assign B1_sign = (Auipc || Jal || Jalr || Load || Store || Addi || Slti || Sltiu || Xori || Ori || Andi);
	assign B1 = (Srai)?rs2:(B1_sign)?extend:B;
	
	alu alu1(data,B1,ALUop,Overflow,CarryOut,Zero,Result);
	
endmodule

