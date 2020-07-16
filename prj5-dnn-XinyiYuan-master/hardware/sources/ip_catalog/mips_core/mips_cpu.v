`timescale 10ns / 1ns

`define IF 8'b00000001
`define IW 8'b00000010
`define ID 8'b00000100
`define EX 8'b00001000
`define WB 8'b00010000
`define ST 8'b00100000
`define LD 8'b01000000
`define RDW 8'b10000000

module mips_cpu(
	input  rst,
	input  clk,

	//Instruction request channel
	output reg [31:0] PC,
	output reg Inst_Req_Valid,
	input Inst_Req_Ack,

	//Instruction response channel
	input  [31:0] Instruction,
	input Inst_Valid,
	output reg Inst_Ack,

	//Memory request channel
	output [31:0] Address,
	output MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,
	output MemRead,
	input Mem_Req_Ack,

	//Memory data response channel
	input  [31:0] Read_data,
	input Read_data_Valid,
	output Read_data_Ack,

    output [31:0]	mips_perf_cnt_0,
    output [31:0]	mips_perf_cnt_1,
    output [31:0]	mips_perf_cnt_2,
    output [31:0]	mips_perf_cnt_3,
    output [31:0]	mips_perf_cnt_4,
    output [31:0]	mips_perf_cnt_5,
    output [31:0]	mips_perf_cnt_6,
    output [31:0]	mips_perf_cnt_7,
    output [31:0]	mips_perf_cnt_8,
    output [31:0]	mips_perf_cnt_9,
    output [31:0]	mips_perf_cnt_10,
    output [31:0]	mips_perf_cnt_11,
    output [31:0]	mips_perf_cnt_12,
    output [31:0]	mips_perf_cnt_13,
    output [31:0]	mips_perf_cnt_14,
    output [31:0]	mips_perf_cnt_15
);
	//TODO
	wire			RF_wen;
	wire [4:0]		RF_waddr;
	wire [31:0]		RF_wdata;

	reg [5:0]op;
	reg [4:0]rs;
	reg [4:0]rt;
	reg [4:0]rd;
	reg [4:0]shamt;
	reg [5:0]funct;
	wire [2:0]ALUop;
	wire [31:0]A;
	wire [31:0]B;
	wire [31:0]B1;
	wire B1_sign;
	wire Overflow;
	wire Overflow1;
	wire Carryout;
	wire Carryout1;
	wire Zero;
	wire Zero1;
	wire Branch,Jump,Load,Store;
	wire [31:0]Result;
	wire [31:0]extend;
	wire [31:0]extend1;
	wire [31:0]PC1;
	wire [31:0]PCnext;
	wire [31:0]jumpnext;
	wire [31:0]next;
	wire [3:0]W_strb_sb;
	wire [3:0]W_strb_sh;
	wire [3:0]W_strb_swl;
	wire [3:0]W_strb_swr;
	wire [31:0]W_data_sb;
	wire [31:0]W_data_sh;
	wire [31:0]W_data_swl;
	wire [31:0]W_data_swr;
	wire addr_sign;
	wire [31:0]data;
	wire [31:0]data_load;
	wire [31:0]data_lb;
	wire [31:0]data_lbu;
	wire [31:0]data_lh;
	wire [31:0]data_lhu;
	wire [31:0]data_lwl;
	wire [31:0]data_lwr;
	wire [31:0]data_lw;
	wire Addiu, Addu, Subu, And, Andi, Nor, Or, Ori, Xor, Xori, Slt, Slti, Sltu, Sltiu, Sll, Sllv, Sra, Srav, Srl, Srlv, Bne, Beq, Bgez, Blez, Bltz, Bgtz, J, Jal, Jr, Jalr, Lb, Lh, Lw, Lbu, Lhu, Lwl, Lwr, Sb, Sh, Sw, Swl, Swr, Movn, Movz, Lui, Mul;
	//state machine
	reg [7:0]state;
	reg [7:0]nextstate;
	
	reg [31:0]instruction;
	reg [31:0]data1_load;
	
	//cycle counter
	reg [31:0]cycle_cnt;
	reg [31:0]memory_cnt;
	
	// cycle counter
	assign mips_perf_cnt_0=cycle_cnt;
	always@ (posedge clk)
	begin
		if (rst) cycle_cnt<=32'd0;
		else cycle_cnt<=cycle_cnt+32'd1;
	end
	
	assign mips_perf_cnt_1=memory_cnt;
	always@(posedge clk)
	begin
		if (rst) memory_cnt<=32'd0;
		else if (Read_data_Valid||Mem_Req_Ack) memory_cnt=memory_cnt+32'd1;
	end
	
	//state machine
	always@(posedge clk)
	begin
		if (rst) state<=`IF;
		else state<=nextstate;
	end
	
	always@(*)
	begin
		case(state)
		`IF:
			if (Inst_Req_Ack) nextstate=`IW;
			else nextstate=`IF;
		`IW: 
			if (Inst_Valid) nextstate=`ID;
			else nextstate=`IW;
		`ID:
			nextstate=`EX;
		`EX:
			if (Branch||Jump) nextstate=`IF;
			else if (Load) nextstate=`LD;
			else if (Store) nextstate=`ST;
			else nextstate=`WB;
		`ST:
			if (Mem_Req_Ack) nextstate=`IF;
			else nextstate=`ST;
		`WB:
			nextstate=`IF;
		`LD:
			if (Mem_Req_Ack) nextstate=`RDW;
			else nextstate=`LD;
		`RDW:
			if (Read_data_Valid) nextstate=`WB;
			else nextstate=`RDW;
		default:
			nextstate=`WB;
		endcase
			
	end
	
	always@(posedge clk)
	begin
		if (rst) instruction<=32'b0;
		else if (Inst_Valid && Inst_Ack) instruction<=Instruction;
	end
	
	always@(posedge clk)
	begin
		if (rst) Inst_Req_Valid<=0;
		else if (state==`IF) Inst_Req_Valid<=1;
		else if (state==`EX && (Branch||Jump)) Inst_Req_Valid<=1;
		else if (state==`ST && Mem_Req_Ack) Inst_Req_Valid<=1;
		else if (state==`WB) Inst_Req_Valid<=1;
		else Inst_Req_Valid<=0;
	end
	
	always@(posedge clk)
	begin
		if (rst) Inst_Ack<=1;
		else if (state==`IW) Inst_Ack<=1;
		else Inst_Ack<=0;
	end
	
	assign MemRead=(state==`LD)?1:0;
	assign MemWrite=(state==`ST)?1:0;
	assign Read_data_Ack=(state==`RDW)?1:0;
	
	//decode
	always@(posedge clk)
	begin
		if (state==`ID) begin
			op<=instruction[31:26];
			rs<=instruction[25:21];
			rt<=instruction[20:16];
			rd<=instruction[15:11];
			shamt<=instruction[10:6];  
			funct<=instruction[5:0];
		end
	end
	
	assign Addiu=(op==6'b001001);
	assign Addu=(op==6'b000000)&&(funct==6'b100001);
	assign Subu=(op==6'b000000)&&(funct==6'b100011);
	assign And=(op==6'b000000)&&(funct==6'b100100);
	assign Andi=(op==6'b001100);
	assign Nor=(op==6'b000000)&&(funct==6'b100111);
	assign Or=(op==6'b000000)&&(funct==6'b100101);
	assign Ori=(op==6'b001101);
	assign Xor=(op==6'b000000)&&(funct==6'b100110);
	assign Xori=(op==6'b001110);
	assign Slt=(op==6'b000000)&&(funct==6'b101010);
	assign Slti=(op==6'b001010);
	assign Sltu=(op==6'b000000)&&(funct==6'b101011);
	assign Sltiu=(op==6'b001011);
	assign Sll=(op==6'b000000)&&(funct==6'b000000);
	assign Sllv=(op==6'b000000)&&(funct==6'b000100);
	assign Sra=(op==6'b000000)&&(funct==6'b000011);
	assign Srav=(op==6'b000000)&&(funct==6'b000111);
	assign Srl=(op==6'b000000)&&(funct==6'b000010);
	assign Srlv=(op==6'b000000)&&(funct==6'b000110);
	assign Bne=(op==6'b000101);
	assign Beq=(op==6'b000100);
	assign Bgez=(op==6'b000001)&&(rt==5'b00001);
	assign Blez=(op==6'b000110);
	assign Bltz=(op==6'b000001);
	assign Bgtz=(op==6'b000111);
	assign J=(op==6'b000010);
	assign Jal=(op==6'b000011);
	assign Jr=(op==6'b000000)&&(funct==6'b001000);
	assign Jalr=(op==6'b000000)&&(funct==6'b001001);
	assign Lb=(op==6'b100000);
	assign Lh=(op==6'b100001);
	assign Lw=(op==6'b100011);
	assign Lbu=(op==6'b100100);
	assign Lhu=(op==6'b100101);
	assign Lwl=(op==6'b100010);
	assign Lwr=(op==6'b100110);
	assign Sb=(op==6'b101000);
	assign Sh=(op==6'b101001);
	assign Sw=(op==6'b101011);
	assign Swl=(op==6'b101010);
	assign Swr=(op==6'b101110);
	assign Movn=(op==6'b000000)&&(funct==6'b001011);
	assign Movz=(op==6'b000000)&&(funct==6'b001010);
	assign Lui=(op==6'b001111);
	assign Mul=(op==6'b011100)&&(funct==6'b000010);
	
	assign Branch=(Bne||Beq||Bgez||Blez||Bltz||Bgtz);
	assign Jump=(J||Jal||Jr||Jalr);
	assign Load=(Lw||Lb||Lbu||Lh||Lhu||Lwl||Lwr);
	assign Store=(Sw||Sb||Sh||Swl||Swr);
	
	assign extend=(Andi||Ori||Xori)?{16'd0,instruction[15:0]}:(Sra==1)?{26'd0,shamt}:{{16{instruction[15]}},instruction[15:0]};
	
	assign W_strb_sb=(Result[1:0]==2'b00)?4'b0001:
					(Result[1:0]==2'b01)?4'b0010:
					(Result[1:0]==2'b10)?4'b0100:
					(Result[1:0]==2'b11)?4'b1000:0;
	assign W_strb_sh=(Result[1]==1'b0)?4'b0011:
					(Result[1]==1'b1)?4'b1100:0;
	assign W_strb_swl=(Result[1:0]==2'b00)?4'b0001:
					(Result[1:0]==2'b01)?4'b0011:
					(Result[1:0]==2'b10)?4'b0111:
					(Result[1:0]==2'b11)?4'b1111:0;
	assign W_strb_swr=(Result[1:0]==2'b00)?4'b1111:
					(Result[1:0]==2'b01)?4'b1110:
					(Result[1:0]==2'b10)?4'b1100:
					(Result[1:0]==2'b11)?4'b1000:0;
	assign Write_strb=(Sb==1)?W_strb_sb:
					(Sh==1)?W_strb_sh:
					(Swl==1)?W_strb_swl:
					(Swr==1)?W_strb_swr:
					(Xori==1)?0:
					4'b1111;
	
	assign W_data_sb=(Write_strb==4'b0001)?{24'd0,B[7:0]}:
					(Write_strb==4'b0010)?{16'd0,B[7:0],8'd0}:
					(Write_strb==4'b0100)?{8'd0,B[7:0],16'd0}:
					(Write_strb==4'b1000)?{B[7:0],24'd0}:0;
	assign W_data_sh=(Write_strb==4'b0011)?{16'd0,B[15:0]}:
					(Write_strb==4'b1100)?{B[15:0],16'd0}:0;
	assign W_data_swl=(Write_strb==4'b0001)?{24'd0,B[31:24]}:
					(Write_strb == 4'b0011)?{16'd0,B[31:16]}:
					(Write_strb == 4'b0111)?{8'd0,B[31:8]}:
					(Write_strb == 4'b1111)?{B[31:0]}:0;
	assign W_data_swr=(Write_strb == 4'b1000)?{B[7:0],24'b0}:
					(Write_strb == 4'b1100)?{B[15:0],8'b0}:
					(Write_strb == 4'b1110)?{B[23:0],8'd0}:
					(Write_strb == 4'b1111)?{B[31:0]}:0;
	assign Write_data=(Sb==1)? W_data_sb:
					(Sh==1)?W_data_sh:
					(Swl==1)?W_data_swl:
					(Swr==1)?W_data_swr:
					B;
	
	assign RF_wen=(state==`EX && (Jal||Jalr))?1:
				(state==`WB && Movn && B!=0)?1:
				(state==`WB && Movz && B==0)?1:
				(state==`WB && op==6'b000000 && !Jr && !Movn && !Movz)?1:
				(state==`WB && Load)?1:
				(state==`WB && (Addiu||Andi||Ori||Xori||Slti||Sltiu||Lui||Mul))?1:
				0;
	
	assign addr_sign=(Sll||Sllv||Sltu||Slt||And||Or||Xor||Nor||Addu||Sra||Srav||Subu||Srl||Srlv||Movz||Movn||Jalr||Beq||Bgez||Mul);
	assign RF_waddr=(Jal)?5'b11111:(addr_sign)?rd:rt;
	
	always@(posedge clk)
	begin
		if (rst) PC<=32'b0;
		else if (state==`EX) PC<=PCnext;
	end
	
	assign next=PC+32'd4;
	assign jumpnext=((Jr||Jalr)==1)?A:{next[31:28],instruction[25:0],2'b00};
	assign extend1=extend<<2;
	alu alu1(next,extend1,3'b010,Overflow1,Carryout1,Zero1,PC1); //PC1= next+extend1 = PC+4+extend<<2
	assign PCnext=(Jump)?jumpnext:
				(Bgtz)?( (!Zero && (Result[31]==0))?PC1:next ):
				(Branch && !addr_sign && !Zero)?PC1:
				(Branch && addr_sign && Zero)?PC1:
				next;
	
	reg_file reg_file1(clk,rst,RF_waddr,rs,rt,RF_wen,RF_wdata,A,B);
	//r[RF_waddr]=RF_wdata, A=r[rs], B=r[rt]
	
	assign B1_sign=(Load||Store||Addiu||Sll||Slti||Sltiu||Andi||Ori||Xori||Lui||Sra);
	assign B1=(Srav==1)?A[4:0]:(Blez==1)?32'b1:((Movn||Movz||Bgez)==1)?31'd0:(B1_sign==1)?extend:B;
	
	assign data=((Movn||Movz||Sra||Srav||Sll)==1)?B:A;
	
	assign ALUop=(Or||Nor||Ori)?3'b001: //Or
				(Load||Store||Addiu||Addu||Lui||Movn||Movz||Bgtz)?3'b010: //Add
				(Xor||Xori)?3'b011: //Xor
				(Sra||Srav)?3'b100: //shift right
				(Sltu||Sltiu)?3'b101: //compare unsigned numbers
				(Bne||Beq||Subu)?3'b110: //Substract
				(Slt||Slti||Bgez||Blez||Bltz)?3'b111: //Slt, compare signed numbers
				3'b000; //And
	
	alu alu2(data,B1,ALUop,Overflow,Carryout,Zero,Result);
	
	assign Address=((Sb||Sh||Swl||Swr||Lb||Lbu||Lh||Lhu||Lwr||Lwl)==1)?{Result[31:2],2'b00}:Result;
	
	assign data_lb=(Result[1:0]==2'b00)?{{24{Read_data[7]}},Read_data[7:0]}:
					(Result[1:0]==2'b01)?{{24{Read_data[15]}},Read_data[15:8]}:
					(Result[1:0]==2'b10)?{{24{Read_data[23]}},Read_data[23:16]}:
					(Result[1:0]==2'b11)?{{24{Read_data[31]}},Read_data[31:24]}:
					0;
	assign data_lbu=(Result[1:0]==2'b00)?{24'b0,Read_data[7:0]}:
					(Result[1:0]==2'b01)?{24'b0,Read_data[15:8]}:
					(Result[1:0]==2'b10)?{24'b0,Read_data[23:16]}:
					(Result[1:0]==2'b11)?{24'b0,Read_data[31:24]}:
					0;
	assign data_lh=(Result[1]==1'b0 && Read_data[15]==1)?{16'hffff,Read_data[15:0]}:
					(Result[1]==1'b0 && Read_data[15]!=1)?{16'h0,Read_data[15:0]}:
					(Result[1]==1'b1 && Read_data[31]==1)?{16'hffff,Read_data[31:16]}:
					(Result[1]==1'b1 && Read_data[31]!=1)?{16'h0,Read_data[31:16]}:
					0;
	assign data_lhu=(Result[1]==1'b0)?$unsigned(Read_data[15:0]):
					(Result[1]==1'b1)?$unsigned(Read_data[31:16]):
					0;
	assign data_lwl=(Result[1:0]==2'b00)?{Read_data[7:0],B[23:0]}:
					(Result[1:0]==2'b01)?{Read_data[15:0],B[15:0]}:
					(Result[1:0]==2'b10)?{Read_data[23:0],B[7:0]}:
					(Result[1:0]==2'b11)?{Read_data[31:0]}:
					0;
	assign data_lwr=(Result[1:0]==2'b00)?{Read_data[31:0]}:
					(Result[1:0]==2'b01)?{B[31:24],Read_data[31:8]}:
					(Result[1:0]==2'b10)?{B[31:16],Read_data[31:16]}:
					(Result[1:0]==2'b11)?{B[31:8],Read_data[31:24]}:
					0;
	assign data_lw=Read_data;
	assign data_load=(Lb==1)?data_lb:
				(Lbu==1)?data_lbu:
				(Lh==1)?data_lh:
				(Lhu==1)?data_lhu:
				(Lwl==1)?data_lwl:
				(Lwr==1)?data_lwr:
				(Lw==1)?data_lw:
				0;
	
	always@(posedge clk)
	begin
		if (state==`RDW) data1_load<=data_load;
	end
	
	assign RF_wdata=(RF_wen==1)?(
						(Mul==1)?(A*B):
						(Nor==1)?~Result:
						(Srl==1)?(B>>shamt):
						(Srlv==1)?(B>>A[4:0]):
						(Sll==1)?(B<<shamt):
						(Sllv==1)?(B<<A[4:0]):
						((Jal||Jalr)==1)?next+32'd4:
						((Movn||Movz)==1)?A:
						(Lui==1)?{instruction[15:0],16'd0}:
						(Load==1)?data1_load:
						Result):
					0;
					
endmodule


