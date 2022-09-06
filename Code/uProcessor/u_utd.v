`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2022 03:04:48 PM
// Design Name: 
// Module Name: u_utd
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module u_utd(input clk, input reset,  
            input [31:0] load_program, input IFF,
            output [11:0] w_addr, output [15:0] w_data,
            output [15:0] busA, output [15:0] busB, output [31:0] LP, output done);



assign LP = load_program;
reg [11:0] PC; //program counter
reg [11:0] PC_ID; //PC at instruction decode stage
reg [11:0] PC_EX; //PC at execution stage
wire [11:0] PC_INC1; //PC + 1
assign PC_INC1 = PC + 1;
wire [11:0] PC_INC2; //PC + 2
assign PC_INC2 = PC_EX + 2;
reg [11:0] SP; //stack pointer
wire [11:0] newSP; //stack pointer after a push or pop operation
reg [15:0] IR; //instruction register
wire Z;//zero flag
wire C; //carry flag
reg Z_reg;
reg C_reg;
reg Z_WB;
reg C_WB;
wire [11:0] INTVEC;
assign INTVEC = 12'b0010_0000_0000; //INTVEC address is 512
reg IFF_reg;
//module connnectors
wire [15:0] instruction;
//instrcution decoder outputs
wire RW;//register write 
wire [1:0] RS;//register select 
wire [1:0]M1;//M1 select 
wire M2;//M2 select 
wire [1:0]M3;//M3 select
wire [1:0]M4; //M4 select
wire [11:0]MA;//memory address 
wire MW;//memory write 
wire [7:0] FS; //function select
wire SW;//stack write 
wire SR; //stack read
wire R_ALL; //set if instructions requires data reads from both registers
wire INT; //interrupt on flag
wire isINTOFF;
wire isHALT;
wire isSKP; //if instruction is SZ or SC
wire isRET; //if instructon is return
wire [1:0]isJSR; //is instruction JSR

//registers to store instruction decoder outputs for execute stage
reg RW_EX; reg[1:0] RS_EX; reg [1:0]M1_EX; reg M2_EX; reg [1:0] M3_EX;
reg [1:0]M4_EX; reg [11:0]MA_EX; reg MW_EX; reg [7:0] FS_EX; reg SW_EX; reg SR_EX; reg [1:0]isJSR_EX;
reg RW_WB; reg[1:0] RS_WB; reg M2_WB; reg [11:0]MA_WB; reg INT_EX; reg isINTOFF_reg; reg isHALT_EX;
reg isSKP_EX; reg isRET_EX;
//reg isHALT_WB;
 
//multiplexer outputs
wire [11:0] m1Out; wire [15:0] m2Out; wire [11:0] m3Out; wire [15:0] m4Out;




//data buses
//wire [15:0] busA; wire [15:0] busB; 
reg [15:0] busA_EX; reg [15:0] busB_EX; wire [15:0] memOut; wire [15:0] alu_out;
reg[15:0] memOut_WB; reg [15:0] alu_out_WB; wire [15:0] mem_SP;
//module instances
registerFile regFileInst(clk, RW_WB, RS_WB, m2Out, busA, busB);
memory memInst(clk, m3Out, MW_EX, m4Out, PC, SW_EX, SR_EX, SP, instruction, memOut, newSP, w_addr, w_data, mem_SP);
ALU aluInst(busA_EX, busB_EX, FS_EX, alu_out, Z, C);
instructionDecoder IDinst(IR, C_WB, Z_WB, RW, RS, M1, M2, M3, M4, MA, MW, FS, SW, SR, R_ALL, 
                          isJSR, INT, isINTOFF, isHALT, isSKP, isRET);
//mux1 mux1_inst(PC_INC1, MA_EX, PC_INC2, memOut_WB[11:0], M1_EX, isHALT_EX, isRET_EX, m1Out); 
mux1 mux1_inst(PC_INC1, MA_EX, PC_INC2, mem_SP[11:0]+12'd1, M1_EX, isHALT_EX, isRET_EX, m1Out); 
mux2 mux2_inst(alu_out_WB, memOut_WB, M2_WB, m2Out);
mux3 mux3_inst(MA_EX, SP, load_program[27:16], MA_EX, M3_EX, m3Out); 
reg isLoad;
reg sentJSR;
mux4 mux4_inst(busA_EX, busB_EX, {4'b0000,PC_EX}, load_program[15:0], M4, isJSR_EX, isLoad, m4Out);


//Data Hazard Stall
wire DHS;
assign DHS = (~M2) & ((RS == RS_EX) | R_ALL) & RW_EX;//if processor needs to read from a register in which the results will be provided
//assign DHS = (~M2) & ((RS == RS_EX) || R_ALL || isSKP) & RW_EX;
//branch detection
wire BD;//0 means there is a branch
assign BD = ~(M1_EX[1] | M1_EX[0]);
//by an instruction in the execution stage before the write back

assign done = isHALT_EX;


always @(posedge clk)
begin
    if(!reset)
    begin
        PC <= 0;
        SP <= 12'b1111_1111_1111;
        PC_ID <= 0;
        PC_EX <= 0;
        M1_EX <= 0;
        IR <= instruction;
        C_reg <= 0;
        Z_reg <= 0;
        isLoad <= 0;
        INT_EX <= 0;
        IFF_reg <= 0;
        isHALT_EX <= 0;
        RW_EX <= 0;
        M3_EX <= 0;
        M4_EX <= 0;
        MW_EX <= 0;
        sentJSR <= 0;
        isRET_EX <= 0;
        //isHALT_WB <= 0;
    end
    else if(reset && load_program[31])
    begin
        M3_EX <= 2;
        M4_EX <= 3;
        MW_EX <= 1;
        isLoad <= 1;
    end
    else if(reset && !load_program[31])
    begin
        if(DHS == 0)
        begin
            PC_EX <= PC_ID;
            PC_ID <= PC;//_INC1;
            PC <= m1Out;
            if(BD == 0 || isHALT_EX)
                IR <= 16'b1111_1111_1111_1111;
            else
            begin
                if((IFF || INT_EX) && !sentJSR)//if interrupt flag has been set
                begin
                //if(IFF || INT)//if interrupt flag has been set
                    IR <= {4'b1000,INTVEC}; //jsr INTVEC
                    sentJSR <= 1;
                end
                else
                    begin
                    IR <= instruction;
                    sentJSR <= 0;
                    end
            end
        end
        
        Z_reg <= Z;
        C_reg <= C;
        Z_WB <= Z_reg;
        C_WB <= C_reg;
        //pass instruction decode outputs for pipelining 
        RW_WB <= RW_EX;
        RW_EX <= RW & ~DHS & BD & ~isHALT_EX; //pause register writes when DHS or branch occurs
        RS_WB <= RS_EX;
        RS_EX <= RS;
        M1_EX <= M1 & ~{2{DHS}} & {2{BD}};//dont process next branch 
        M2_WB <= M2_EX;
        M2_EX <= M2;
        M3_EX <= M3;
        M4_EX <= M4;
        MA_WB <= MA_EX;
        MA_EX <= MA;
        MW_EX <= MW & ~DHS & (BD | isJSR) & ~isHALT_EX; //pause memory writes when DHS or branch occurs
        FS_EX <= FS;
        SW_EX <= SW;
        SR_EX <= SR & BD; //pause pops when branch occurs 
        INT_EX <= INT;
        IFF_reg <= INT_EX;
        isSKP_EX <= isSKP;
        isJSR_EX <= isJSR;
        isRET_EX <= isRET;
        if(isHALT && !isHALT_EX && M1_EX != 2'b01)
        begin
            isHALT_EX <= isHALT;
        end
        busA_EX <= busA;
        busB_EX <= busB;
        SP <= newSP;
        memOut_WB <= memOut;
        alu_out_WB <= alu_out;
    end
  
end
endmodule 
