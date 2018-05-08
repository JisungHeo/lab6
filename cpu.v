`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size
//`include "Multiplexer16bit2to1.v"
module cpu(clk, reset_n, readM1, address1, data1, readM2, writeM2, address2, data2, num_inst, output_port, is_halted);
	input clk;
	wire clk;
	input reset_n;
	wire reset_n;

	output readM1;
	wire readM1;
	output [`WORD_SIZE-1:0] address1;
	wire [`WORD_SIZE-1:0] address1;
	output readM2;
	wire readM2;
	output writeM2;
	wire writeM2;
	output [`WORD_SIZE-1:0] address2;
	wire [`WORD_SIZE-1:0] address2;

	input [`WORD_SIZE-1:0] data1;
	wire [`WORD_SIZE-1:0] data1;
	inout [`WORD_SIZE-1:0] data2;
	wire [`WORD_SIZE-1:0] data2;

	output [`WORD_SIZE-1:0] num_inst;
	reg [`WORD_SIZE-1:0] num_inst;
	output [`WORD_SIZE-1:0] output_port;
	wire [`WORD_SIZE-1:0] output_port;
	output is_halted;
	wire is_halted;
	
	//wire declaration
	//IF
	wire [`WORD_SIZE-1:0] PCin;
	wire [`WORD_SIZE-1:0] PC;
	wire [`WORD_SIZE-1:0] IF_PC4;
	wire [`WORD_SIZE-1:0] IF_instruction;
	//ID
	wire [`WORD_SIZE-1:0] ID_PC4;
	wire [`WORD_SIZE-1:0] ID_instruction;
	wire [3:0]opcode;
	wire [5:0]funct;
	/*wire RegWrite;
	wire MemtoReg;
	wire MemWrite;
	wire MemRead;
	wire Branch;
	wire ALUSrc;
	wire RegDst;*/
	wire JRControl;
	wire JLControl;
	wire [16:0]ControlInput;
	wire [16:0]ID_ControlInput;
	wire [1:0] ID_rs,ID_rt,ID_rd;
	wire [`WORD_SIZE-1:0] readData1,readData2;
	wire [7:0] ID_immediate;
	wire [`WORD_SIZE-1:0] im16_ext;
	//EX
	wire [1:0] WB;
	wire [1:0] MEM;
	wire [1:0] EX_WB;
	wire EX_Branch, EX_ALUSrc, EX_RegDst;
	wire [3:0] EX_opcode;
	wire[5:0] EX_funct;
	wire EX_JRControl;
	wire EX_JLControl;
	wire [15:0] EX_PC4;
	wire [15:0] EX_im16_ext, EX_ReadData1, EX_ReadData2;
	wire [1:0] EX_rs, EX_rt, EX_rd;
	wire [`WORD_SIZE-1:0] branch_addr;
	wire [`WORD_SIZE-1:0] BusA_ALU,BusB_ALU,BusB_forwarded;
	wire [3:0] aluControlInput;
	wire bcond;
	wire [`WORD_SIZE-1:0] EX_ALUResult;
	wire [1:0] EX_RegDstResult;
	wire [1:0] EX_WriteRegister;
	wire mispredict;
	wire [`WORD_SIZE-1:0] PC1,PC2,PCj;
	wire Jump, JumpFlush;
	//MEM
	wire [1:0] WB_forwarded;
	wire MEM_MemWrite, MEM_MemRead;
	wire MEM_RegWrite;
	wire [15:0] MEM_PC4, MEM_ALUResult, MEM_BusB_forwarded;
	wire[1:0] MEM_WriteRegister;
	wire MEM_JLControl;
	wire [`WORD_SIZE-1:0] MEM_ReadDataOfMem;
	wire [1:0] ForwardA, ForwardB;
	//WB
	wire WB_RegWrite;
	wire WB_MemtoReg;
	wire [`WORD_SIZE-1:0] WB_PC4, WB_ReadDataOfMem, WB_ALUResult;
	wire [1:0] WB_WriteRegister;
	wire WB_JLControl;
	wire [`WORD_SIZE-1:0] WB_WriteData_tmp;
	wire [`WORD_SIZE-1:0] WB_WriteData;

	//discard,stall,flush
	wire PC_WriteEn;
	wire IF_flush;
	wire IFID_WriteEn;
	wire IFID_flush;
	wire ID_flush;
	wire Stall_flush;
	wire flush;


//---------------------------------------------Output code
	always @(reset_n) begin
		num_inst = 0;
	end

	wire ID_valid;
	reg EX_valid;
	reg MEM_valid;
	reg WB_valid;
	reg [1:0]MEM_rs;
	reg [1:0]WB_rs;

	always @(reset_n) begin
		EX_valid = 1'b0;
		MEM_valid = 1'b0;
		WB_valid = 1'b0;

		MEM_rs = 2'b00;
		WB_rs = 2'b00;
	end

	assign ID_valid = ~flush;

	always @(posedge clk) begin
		EX_valid <= ID_valid;
		MEM_valid <= EX_valid;
		WB_valid <= MEM_valid;

		MEM_rs <= EX_rs;
		WB_rs <= MEM_rs;
	end

	always @(posedge clk) begin
		if (MEM_valid==1'b1) begin
			num_inst = num_inst + 1;
		end
	end

//---------------------------------------------is_halted code
	wire halt;
	reg EX_halt, MEM_halt, WB_halt;
	assign halt = (opcode == 4'b1111) && (funct == 6'b011101);
	always @(posedge clk) begin
		EX_halt <= halt;
		MEM_halt <= EX_halt;
		WB_halt <= MEM_halt;
	end
	assign is_halted = ((WB_halt == 1'b1) && (WB_valid == 1'b1));

//----------------------------------------------2 bit global predictor with BTB
	wire [15:0] EX_PC = EX_PC4-1;
	wire valid;
	wire [9:0] tag;
	wire [15:0] nextPC;
	BTB btb(clk, reset_n, PC[5:0], mispredict, EX_PC, branch_addr, valid, tag, nextPC);
	
	wire prediction;
	Predictor pred(clk, reset_n, EX_Branch, bcond, prediction);

	
	wire [15:0] newPC;
	wire hit = (tag == PC[15:6]);
	wire newPCControl;
	assign newPCControl = (hit==1'b1 && prediction == 1'b1 && valid == 1'b1);

	assign newPC = newPCControl ? nextPC : PCin;

	reg ID_newPCControl, EX_newPCControl;

	always @(reset_n) begin
		ID_newPCControl <= 1'b0;
		EX_newPCControl <= 1'b0;
	end

	always @(posedge clk) begin
		ID_newPCControl <= newPCControl;
		EX_newPCControl <= ID_newPCControl;
	end


//----------------------------------------------
	//PC update
	PC_Register PC_update(clk, reset_n, newPC, PC_WriteEn, PC);

	//add 4 to PC
	ADD ADD_PC_4(PC,16'h0001,IF_PC4);

	assign readM1 = 1'b1;
	assign address1 = PC;

	//Instruction Memory - Instruction in data1
	//Memory IF(clk, reset_n, readM1, address1, data1, readM2, writeM2, address2, data2);
//-------------------------------------------------------------------
	//IF_ID Register
	assign IF_instruction = data1;
	IFID_Register IFID_register_update(clk, reset_n, IF_PC4, IF_instruction , IF_flush, IFID_WriteEn, ID_PC4, ID_instruction, IFID_flush);
	
	//ControlUnit
	assign opcode = ID_instruction[15:12];
	assign funct = ID_instruction[5:0];
	ControlUnit controlUnit_call(opcode, funct, ControlInput,Jump);
	seventeenBitMultiplexer2to1 controlInput_select(ControlInput, 17'h00, flush, ID_ControlInput);


	//Reg File **WB_regwrite,writeReg,wirteData, 
	assign ID_rs=ID_instruction[11:10];
	assign ID_rt=ID_instruction[9:8];
	assign ID_rd =ID_instruction[7:6];
	registerHandle register_file_call(WB_RegWrite, ID_rs, ID_rt, WB_WriteRegister, WB_WriteData, WB_rs, readData1, readData2, output_port, clk, reset_n);
	

	//signExtend
	assign ID_immediate = ID_instruction[7:0];
	SignExtend immediate_extend(ID_immediate, im16_ext);
	
	//JR Control
	JRControlBlock JRControl_call(opcode, funct, JRControl);
	//JL Control
	JLControlBlock JLControl_call(opcode, funct, JLControl);
	
//-----------------------------------------------
	//ID_EX Register
	IDEX_Register IDEX_Register_update(clk, reset_n, ID_PC4, ID_ControlInput, readData1, readData2, im16_ext, ID_rs, ID_rt, ID_rd, JRControl, JLControl, //control and data input
		     WB, MEM, //bunch output
		     EX_Branch, EX_ALUSrc, EX_RegDst, EX_opcode, EX_funct, EX_JRControl, EX_JLControl, //control output
		     EX_PC4, EX_im16_ext, EX_ReadData1, EX_ReadData2, EX_rs, EX_rt, EX_rd);

	//ADD EX_PC4, Ex_im16_Ext
	ADD ADD_EX_PC4(EX_PC4,EX_im16_ext,branch_addr);

	//Choose A for ALU
	sixteenBitMultiplexer4to1 MUX_A_ALU(EX_ReadData1, WB_WriteData, MEM_ALUResult, 16'h0, ForwardA,BusA_ALU);
	
	//Choose B for ALU
	sixteenBitMultiplexer4to1 MUX_B_tmp_ALU(EX_ReadData2, WB_WriteData, MEM_ALUResult, 16'h0, ForwardB ,BusB_forwarded);
	sixteenBitMultiplexer2to1 MUX_B_ALU(BusB_forwarded, EX_im16_ext, EX_ALUSrc, BusB_ALU);

	//ALU control input
	aluControl aluControl_call(EX_funct, EX_opcode, aluControlInput);
	//ALU 
	ALU ALU_call(BusA_ALU,BusB_ALU,aluControlInput,bcond,EX_ALUResult);

	//Choose RegDst
	twoBitMultiplexer2to1 MUX_EX_RegDst(EX_rt, EX_rd, EX_RegDst, EX_RegDstResult);
	//Choose EX_WriteRegister
	twoBitMultiplexer2to1 MUX_EX_JLContorl(EX_RegDstResult, 2'b10, EX_JLControl, EX_WriteRegister);
	
	//UPPER branch part
	wire [15:0] PCb;
	assign branchControl = EX_Branch&bcond;
	assign mispredict = (EX_newPCControl ^ branchControl); //in fact it's misprediction
	assign JumpFlush = Jump&(~IFID_flush);
	assign PCjControl = JumpFlush&(~mispredict);
	assign PCj = {ID_PC4[15:12], ID_instruction[11:0]};
	sixteenBitMultiplexer2to1 MUX_branchControl(EX_PC4, branch_addr, branchControl, PCb);
	sixteenBitMultiplexer2to1 MUX_mispredict(IF_PC4,PCb,mispredict,PC1);
	sixteenBitMultiplexer2to1 MUX_PCjControl(PC1,PCj,PCjControl,PC2);//******
	sixteenBitMultiplexer2to1 MUX_EX_JRControl(PC2,BusA_ALU,EX_JRControl,PCin);

//----------------------------------------------------------------
	EXMEM_Register EXMEM_Register_update(clk, reset_n, WB, MEM, EX_PC4, EX_ALUResult, BusB_forwarded, EX_WriteRegister, EX_JLControl, // input
		      WB_forwarded, MEM_MemWrite, MEM_MemRead, MEM_RegWrite,// control output
		      MEM_PC4, MEM_ALUResult, MEM_BusB_forwarded, MEM_WriteRegister, MEM_JLControl); // data output
	
	//Data memory
	assign address2 = MEM_ALUResult;
	assign data2 = writeM2 ? MEM_BusB_forwarded: `WORD_SIZE'hzzzz;
	assign readM2 = MEM_MemRead; //iorD deleted ?????
	assign writeM2 = MEM_MemWrite;
	assign MEM_ReadDataOfMem = data2;

	//forward unit
	ForwardingUnit ForwardingUnit_call(MEM_WriteRegister, MEM_RegWrite, WB_WriteRegister, WB_RegWrite, EX_rs, EX_rt, ForwardA, ForwardB);

//------------------------------------------------------------------------
	MEMWB_Register MEMWB_Register_update(clk, reset_n, WB_forwarded, MEM_PC4, MEM_ReadDataOfMem, MEM_ALUResult, MEM_WriteRegister, MEM_JLControl,// input
		      WB_RegWrite, WB_MemtoReg, // control output
		      WB_PC4, WB_ReadDataOfMem, WB_ALUResult, WB_WriteRegister, WB_JLControl); // data output
	
	//Choose WB_WriteData
	sixteenBitMultiplexer2to1 MUX_WB_WriteData_tmp(WB_ALUResult, WB_ReadDataOfMem, WB_MemtoReg, WB_WriteData_tmp);
	sixteenBitMultiplexer2to1 MUX_WB_WriteData(WB_WriteData_tmp, WB_PC4, WB_JLControl, WB_WriteData);

//----------------------------------------------------------------------------
	//DiscardInstruction, Stall, flush
	DiscardInstruction discard_inst(Jump, mispredict, EX_JRControl, IF_flush, ID_flush);
	StallUnit stall(MEM[0], EX_rt, ID_rs, ID_rt, opcode, PC_WriteEn, IFID_WriteEn, Stall_flush);
	Flush flush_call(IFID_flush, ID_flush, Stall_flush, flush);
	

//WB: RegWrite, MemtoReg
//MEM: MemWrite, MemRead
//EX: Branch, ALUSrc, RegDst, opcode, funct
endmodule
