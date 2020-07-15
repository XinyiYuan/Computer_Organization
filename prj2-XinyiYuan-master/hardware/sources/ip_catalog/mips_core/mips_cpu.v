`timescale 10ns / 1ns


module mips_cpu(
	input  rst,
	input  clk,

	output reg [31:0] PC,
	input  [31:0] Instruction,

	output [31:0] Address,
	output MemWrite,
	output [31:0] Write_data,
	output [3:0] Write_strb,

	input  [31:0] Read_data,
	output MemRead
);

	// THESE THREE SIGNALS ARE USED IN OUR TESTBENCH
	// PLEASE DO NOT MODIFY SIGNAL NAMES
	// AND PLEASE USE THEM TO CONNECT PORTS
	// OF YOUR INSTANTIATION OF THE REGISTER FILE MODULE
	wire			RF_wen;
	wire [4:0]		RF_waddr;
	wire [31:0]		RF_wdata;
			 
	// TODO: PLEASE ADD YOUT CODE BELOW
	
	wire [5:0]op;
	wire [4:0]rs;
	wire [4:0]rt;
	wire [4:0]rd;
	wire [4:0]shamt;
	wire [5:0]funct;
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
	wire Branch;
	wire [31:0]Result;
	wire [31:0]extend;
	wire [31:0]extend1;
	wire [31:0]PC1;
	wire [31:0]PCnext;
	wire [31:0]next;
	wire [31:0]next1;
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
	wire [31:0]data1;
	wire [31:0]data1_lb;
	wire [31:0]data1_lbu;
	wire [31:0]data1_lh;
	wire [31:0]data1_lhu;
	wire [31:0]data1_lwl;
	wire [31:0]data1_lwr;
	wire [31:0]data1_lw;
	wire Addiu, Addu, Subu, And, Andi, Nor, Or, Ori, Xor, Xori, Slt, Slti, Sltu, Sltiu, Sll, Sllv, Sra, Srav, Srl, Srlv, Bne, Beq, Bgez, Blez, Bltz, J, Jal, Jr, Jalr, Lb, Lh, Lw, Lbu, Lhu, Lwl, Lwr, Sb, Sh, Sw, Swl, Swr, Movn, Movz, Lui;
	
	assign op=Instruction[31:26];
	assign rs=Instruction[25:21];
	assign rt=Instruction[20:16];
	assign rd=Instruction[15:11];
	assign shamt=Instruction[10:6];  
	assign funct=Instruction[5:0];
	
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
	
	assign MemRead=(Lw||Lb||Lbu||Lh||Lhu||Lwl||Lwr);
	assign MemWrite=(Sw||Sb||Sh||Swl||Swr);
	assign ALUop=(Or||Nor||Ori)?3'b001:
				(Addiu||Addu||Lb||Lbu||Lw||Lwl||Lwr||Sb||Sh||Sw||Swl||Swr||Lh||Lhu||Lui||Movn||Movz)?3'b010:
				(Xor||Xori)?3'b011:
				(Sra||Srav)?3'b100:
				(Sltu||Sltiu)?3'b101:
				(Bne||Beq||Subu)?3'b110:
				(Slt||Slti||Bgez||Blez||Bltz)?3'b111:
				3'b000;
	assign Branch=(Bne||Beq||Bgez||Blez||Bltz);
	assign extend=(Andi||Ori||Xori)?{16'd0,Instruction[15:0]}:(Sra==1)?{26'd0,shamt}:(Instruction[15]==1)?{16'hffff,Instruction[15:0]}:{16'd0,Instruction[15:0]};
	
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
					(Xori==1)?0:4'b1111;
	
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
					(Swr==1)?W_data_swr:B;
	
	assign RF_wen=(Addiu||Addu||Subu||Sll||Sllv||Slt||Slti||Sltu||Sltiu||And||Andi||Or||Ori||Nor||Xor||Xori||Jal||Jalr||(Lw&&Address[1:0]==2'b0)||Lui||Lb||Lbu||Lh||Lhu||Lwl||Lwr||(Movn&&!Zero)||(Movz&&Zero)||Sra||Srav||Srl||Srlv);
	
	assign addr_sign=(Sll||Sllv||Sltu||Slt||And||Or||Xor||Nor||Addu||Beq||Bgez||Sra||Srav||Subu||Srl||Srlv||Movz||Movn||Jalr);
	assign RF_waddr=(Jal)?5'b11111:(addr_sign)?rd:rt;
	
	assign extend1=extend<<2;
	alu alu1(next1,extend1,3'b010,Overflow1,Carryout1,Zero1,PC1);
	assign PCnext=(J||Jal||Jalr||Jr)?next:(Branch&&!addr_sign&&!Zero)?PC1:(Branch&&addr_sign&&Zero)?PC1:next1;
	
	always@(posedge clk)
	begin
		if (rst) PC<=32'b0;
		else PC<=PCnext;
	end
	
	assign next1=PC+32'd4;
	assign next=((Jr||Jalr)==1)?A:{next1[31:28],Instruction[25:0],2'b00};
	
	reg_file reg_file1(clk,rst,RF_waddr,rs,rt,RF_wen,RF_wdata,A,B);
	
	assign B1_sign=((Addiu||Lb||Lbu||Lh||Lhu||Sw||Sll||Slti||Sltiu||Andi||Ori||Xori||Lw||Lwl||Lwr||Lui||Sb||Sh||Swl||Swr||Sra)==1)?1:0;
	assign B1=(Srav==1)?A[4:0]:(Blez==1)?32'b1:((Movn||Movz||Bgez)==1)?31'd0:(B1_sign==1)?extend:B;
	
	assign data=((Movn||Movz||Sra||Srav||Sll)==1)?B:A;
	
	alu alu2(data,B1,ALUop,Overflow,Carryout,Zero,Result);
	
	assign Address=((Sb||Sh||Swl||Swr||Lb||Lbu||Lh||Lhu||Lwr||Lwl)==1)?{Result[31:2],2'b00}:Result;
	
	assign data1_lb=(Result[1:0]==2'b00 && Read_data[7]==1)?{24'hffffff,Read_data[7:0]}:
					(Result[1:0]==2'b00 && Read_data[7]!=1)?{24'h0,Read_data[7:0]}:
					(Result[1:0]==2'b01 && Read_data[15]==1)?{24'hffffff,Read_data[15:8]}:
					(Result[1:0]==2'b01 && Read_data[15]!=1)?{24'h0,Read_data[15:8]}:
					(Result[1:0]==2'b10 && Read_data[23]==1)?{24'hffffff,Read_data[23:16]}:
					(Result[1:0]==2'b10 && Read_data[23]!=1)?{24'h0,Read_data[23:16]}:
					(Result[1:0]==2'b11 && Read_data[31]==1)?{24'hffffff,Read_data[31:24]}:
					(Result[1:0]==2'b11 && Read_data[31]!=1)?{24'h0,Read_data[31:24]}:
					0;
	assign data1_lbu=(Result[1:0]==2'b00)?{24'b0,Read_data[7:0]}:
					(Result[1:0]==2'b01)?{24'b0,Read_data[15:8]}:
					(Result[1:0]==2'b10)?{24'b0,Read_data[23:16]}:
					(Result[1:0]==2'b11)?{24'b0,Read_data[31:24]}:
					0;
	assign data1_lh=(Result[1]==1'b0 && Read_data[15]==1)?{16'hffff,Read_data[15:0]}:
					(Result[1]==1'b0 && Read_data[15]!=1)?{16'h0,Read_data[15:0]}:
					(Result[1]==1'b1 && Read_data[31]==1)?{16'hffff,Read_data[31:16]}:
					(Result[1]==1'b1 && Read_data[31]!=1)?{16'h0,Read_data[31:16]}:
					0;
	assign data1_lhu=(Result[1]==1'b0)?$unsigned(Read_data[15:0]):
					(Result[1]==1'b1)?$unsigned(Read_data[31:16]):
					0;
	assign data1_lwl=(Result[1:0]==2'b00)?{Read_data[7:0],B[23:0]}:
					(Result[1:0]==2'b01)?{Read_data[15:0],B[15:0]}:
					(Result[1:0]==2'b10)?{Read_data[23:0],B[7:0]}:
					(Result[1:0]==2'b11)?{Read_data[31:0]}:
					0;
	assign data1_lwr=(Result[1:0]==2'b00)?{Read_data[31:0]}:
					(Result[1:0]==2'b01)?{B[31:24],Read_data[31:8]}:
					(Result[1:0]==2'b10)?{B[31:16],Read_data[31:16]}:
					(Result[1:0]==2'b11)?{B[31:8],Read_data[31:24]}:
					0;
	assign data1_lw=Read_data;
	assign data1=(Lb==1)?data1_lb:
				(Lbu==1)?data1_lbu:
				(Lh==1)?data1_lh:
				(Lhu==1)?data1_lhu:
				(Lwl==1)?data1_lwl:
				(Lwr==1)?data1_lwr:
				(Lw==1)?data1_lw:
				0;
	assign RF_wdata=(Nor==1)?~Result:
					(Srl==1)?(B>>shamt):
					(Srlv==1)?(B>>A[4:0]):
					(Sll==1)?(B<<shamt):
					(Sllv==1)?(B<<A[4:0]):
					((Jal||Jalr)==1)?next1+32'd4:
					((Movn||Movz)==1)?A:
					(Lui==1)?{Instruction[15:0],16'd0}:
					(MemRead==1)?data1:
					Result;
	
endmodule
					
