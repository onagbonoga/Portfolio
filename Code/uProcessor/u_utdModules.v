`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2022 03:03:44 PM
// Design Name: 
// Module Name: u_utdModules
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


module registerFile(input clk, input write_enable, input[1:0] register_select, input [15:0] data_in, output [15:0] A_Data, output [15:0] B_Data);
reg [15:0]registerBlock[1:0];
assign A_Data = registerBlock[0];
assign B_Data = registerBlock[1];

always@(negedge clk)
begin
    if(write_enable)
        registerBlock[register_select] = data_in;
end
endmodule

module memory(input clk, input [11:0] address, input write_en, input [15:0] data_in, 
              input [11:0] PC, input SW,input SR, input [11:0]SP, 
              output [15:0] instruction, output reg [15:0] data_out, 
              output reg [11:0] newSP, output reg[11:0] w_addr, output reg[15:0] w_data, output [15:0] mem_SP);
 reg [15:0]mem[4095:0];
 reg [16:0] SP_temp;
 assign instruction = mem[PC];//provides data at program counter
 assign mem_SP = mem[SP + 4'h0001];//provides data at the top of the stack
   //initial begin
   /*mem[82] = 16'habcd;
   mem[256] = 16'h0000;
   mem[257] = 16'h0001;
   mem[258] = 16'h0002;
   mem[259] = 16'h0003;
   mem[260] = 16'hffff;
   mem[261] = 16'haaaa;*/
   
   //test1
   /*mem[0] = 16'h7400;//CLB
   mem[1] = 16'h7300;//CLA
   mem[2] = 16'h1104;//LDB 0x0104
   mem[3] = 16'h0102;//LDA 0x0102
   mem[4] = 16'h7500;//CMB
   mem[5] = 16'h7600;//INCB 
   mem[6] = 16'h7100;//ADD
   mem[7] = 16'h1103;//LDB 0x0103
   mem[8] = 16'h7200;//AND
   mem[9] = 16'h2500;//STA 0x0500
   mem[10] = 16'h3500;//LDB 0x0500
   mem[11] = 16'hf400;//HALT
   mem[12] = 16'h0000;//GARBAGE
   mem[13] = 16'h0000;//GARBAGE
   mem[14] = 16'h0000;//GARBAGE*/
   
    //test2
   /*mem[0] = 16'h7400;//CLB
   mem[1] = 16'h7300;//CLA
   mem[2] = 16'h7800;//CLC
   mem[3] = 16'h7900;//CLZ
   mem[4] = 16'h1103;//LDB 0x0103
   mem[5] = 16'h7100;//ADD
   mem[6] = 16'h7700;//DECB
   mem[7] = 16'h7100;//ADD
   mem[8] = 16'h7d00;//SZ
   mem[9] = 16'h4006;//JMP6
   mem[10] = 16'hf400;//HALT
   mem[11] = 16'h0000;//GARBAGE
   mem[12] = 16'h0000;//GARBAGE
   mem[13] = 16'h0000;//GARBAGE*/
   
  //test3
  /*mem[0] = 16'h7400;//CLB
  mem[1] = 16'h7300;//CLA
  mem[2] = 16'h7a00;//ION
  mem[3] = 16'h0104;//LDA 0x0104
  //mem[4] = 16'hc000;//POPA
  mem[4] = 16'hf400;//HALT
  mem[5] = 16'h0000;//GARBAGE
  mem[6] = 16'h0000;//GARBAGE
  mem[7] = 16'h0000;//GARBAGE
  
  //ISR
  mem[512] = 16'h0052;//LDA 0x0052
  mem[513] = 16'h1101;//LDB 0x0101
  mem[514] = 16'h7100;//ADD
  mem[515] = 16'h7400;//CLB
  mem[516] = 16'he000;//RET
  mem[517] = 16'h0000;//GARBAGE
  mem[518] = 16'h0000;//GARBAGE
  mem[519] = 16'h0000;//GARBAGE*/
  
  /*mem[0] = 16'b0000_0000_0101_0110;//LDA M[86]
     mem[1] = 16'b1010_0000_0000_0000;//PUSH A
     mem[2] = 16'b0000_0000_0101_0000;//LDA M[80]
     mem[3] = 16'b0001_0000_0101_0001;//LDB M[81]
     mem[4] = 16'b0010_0000_0101_0010;//STA M[82]
     mem[5] = 16'b0011_0000_0101_0011;//STB M[83]
     mem[6] = 16'b1010_0000_0000_0000;//PUSH A
     mem[7] = 16'b0000_0000_0101_0101;//LDA M[85]
     mem[8] = 16'b1100_0000_0000_0000;//POP A
     mem[9] = 16'b1110_0000_0000_0000;//RET
     mem[80] = 16'b0000_0000_0000_0011;
     mem[81] = 16'b0000_0000_0000_1111;
     mem[85] = 16'b0000_0000_0000_1100;
     mem[86] = 16'b0000_0000_0000_0000;*/
   
    //Option 1
    /*mem[80] = 6; //size of array
    mem[81] = 82; //starting index
    mem[82] = 16'd131;
    mem[83] = 16'd82;
    mem[84] = 16'd77;
    mem[85] = -50;
    mem[86] = 16'd452;
    mem[87] = 16'd241;
    mem[90] = 0;
    
    mem[0] = 16'h0052; //LDA M[82]
    mem[1] = 16'ha000; //PUSH A
    mem[2] = 16'h0053; //LDA M[83]
    mem[3] = 16'ha000; //PUSH A
    mem[4] = 16'h0054; //LDA M[84]
    mem[5] = 16'ha000; //PUSH A
    mem[6] = 16'h0055; //LDA M[85]
    mem[7] = 16'ha000; //PUSH A
    mem[8] = 16'h0056; //LDA M[86]
    mem[9] = 16'ha000; //PUSH A
    mem[10] = 16'h0057; //LDA M[87]
    mem[11] = 16'ha000; //PUSH A
    mem[12] = 16'h7300; //CLA
    mem[13] = 16'h1050; //LDB M[80]
    
    mem[14] = 16'h3050; //STB M[80] //keep track of counter
    mem[15] = 16'h105a; //LDB M[90] //get current sum result
    mem[16] = 16'hc000; //POP A
    mem[17] = 16'h7100; //ADD
    mem[18] = 16'h205a; //STA M[90]
    mem[19] = 16'h1050; //LDB M[80] //load counter value
    mem[20] = 16'h7300;//CLA
    mem[21] = 16'h7700;//DECB
    mem[22] = 16'h7100;//ADD
    mem[23] = 16'h7d00;//SZ
    mem[24] = 16'h400e;//JMP 14
    mem[25] = 16'hf400;//HALT
    mem[26] = 16'h0000;//GARBAGE
    mem[27] = 16'h0000;//GARBAGE
    mem[28] = 16'h0000;//GARBAGE*/
    
    //option 2
   /* mem[80] = 16'h8000;
    mem[81] = 16'h0050; //input A
    mem[82] = 16'h0002; //input B
    
    //subroutine
    mem[100] = 16'h7100; //ADD
    mem[101] = 16'hf300; //double A
    mem[102] = 16'h1050; //LDB M[80]
    mem[103] = 16'h205a; //STA M[90]
    mem[104] = 16'h105a; //LDB M[90]
    mem[105] = 16'h7500; //CMB
    mem[106] = 16'h7600; //INCB
    mem[107] = 16'h305a; //STB M[90]
    mem[108] = 16'he000;//RET
    
    //main routine
    mem[0] = 16'h0051; //LDA M[81]
    mem[1] = 16'h1052; //LDB M[82]
    mem[2] = 16'h8064; //JSR 100
    mem[3] = 16'hf400;//HALT*/
   //end
  
   always@(negedge clk)
   begin
        newSP = SP;
        if(write_en) begin
            mem[address] = data_in;
            w_addr = address;//w_addr and w_data drive the outputs to thte top uUTD module
            w_data = data_in;
            if(SW)//if we push to the stack
            begin
                newSP = SP - 1;
                if(newSP < 0)
                    newSP = 0;
            end
        end

        
        if(SR)//if we intend to pop from the stack
        begin
            SP_temp = SP + 1;
            if(SP_temp > 4095)
                newSP = 4095;
            else
                newSP = SP_temp;
            data_out = mem[newSP]; 
        end
        else
            data_out = mem[address];
   end
   
endmodule

module ALU(input [15:0] a, input [15:0] b, input [7:0] fs, output reg [15:0] alu_out, output reg Z, output reg C);
    reg [16:0] z;//temporary register to perfrom operations and detect overflows
    always@(fs, a, b) begin
        C=0;
        Z=0;
        case(fs)//case of opCode
            8'b0111_0001:begin//ADD
                z = a + b;
                if (z[16] == 1 && fs != 8'b0000_1000)
                    C = 1;
            end 
            8'b0111_0010:begin//AND
                z = a & b;
            end 
            8'b0111_0011:begin//CLA
                z = 0;
            end 
            8'b0111_0100:begin//CLB
                z = 0;
            end
            8'b0111_0101:begin//CMB
                //z = ~b;
                z = b ^ 17'b11111_1111_1111_1111;
            end
            8'b0111_0110:begin//INCB
                z = b + 16'b0000_0000_0001;
            end 
            8'b0111_0111:begin//DECB
                z = b - 16'b0000_0000_0001;
                
            end 
            8'b0111_1000:begin//CLC
                C = 0;
            end
            8'b0111_1001:begin//CLZ
                Z = 0;
            end
            8'b1111_0000:begin//left shift a by b
                z = a << b;
            end
            8'b1111_0001:begin//right shift a by b
                z = a >> b;
            end
            8'b1111_0010:begin//is even (a <- 1 if b is even and a <- 0 if b is odd)
                if (b[0] == 0)
                    z = 1;
                else
                    z = 0;
            end
            8'b1111_0011:begin//double a
                z = a << 1;
            end
            default:begin
            end 
        endcase
        alu_out = z[15:0];
        if (alu_out == 0 && fs != 8'b0000_1000)
            Z=1;
    end  
endmodule

module instructionDecoder(input [15:0]instruction, input C, input Z, output reg RW, output reg[1:0] RS, output reg [1:0]M1, output reg M2, 
                          output reg[1:0] M3, output reg [1:0]M4, output reg [11:0]MA, output reg MW, output reg [7:0] FS, 
                          output reg SW, output reg SR, output reg R_ALL, output reg [1:0]isJSR, output reg INT, output reg isINTOFF, 
                          output reg isHALT, output reg isSKP, output reg isRET);
    reg [7:0] opCode;
    reg [3:0] opCode_h;
    always@(instruction)
    begin
    MA = instruction[11:0];
    FS = instruction[15:8];
    opCode = instruction[15:8];
    opCode_h = instruction[15:12];
       RW = 0;     RS = 2'b00;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     
       MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;     isJSR = 0;     INT = 0;
       isINTOFF = 0;    isHALT = 0;     isSKP = 0;   isRET = 0;
   
    if(opCode_h != 4'b0111)//if instruction uses direct or stack addressing
        begin
        case(opCode_h)//only look at most significant 4 bits
            4'b0000: //LDA
                begin
                    RW = 1;     RS = 0;    M1 = 2'b00;     M2 = 1;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;
                end
            4'b0001: //LDB
                begin
                    RW = 1;     RS = 1;    M1 = 2'b00;     M2 = 1;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;
                 end
            4'b0010: //STA
                 begin
                     RW = 0;    RS = 0;    M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 1;     SW = 0;     SR = 0;      R_ALL = 0;
                 end
             4'b0011: //STB
                 begin
                     RW = 0;     RS = 1;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b01;     MW = 1;     SW = 0;     SR = 0;      R_ALL = 0;   isJSR = 2'b10;
                  end
             4'b0100: //JMP
                 begin
                     RW = 0;     RS = 0;   M1 = 2'b01;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;
                 end
             4'b1000: //JSR
                 begin
                     RW = 0;     RS = 0;   M1 = 2'b01;     M2 = 0;     M3 = 1;     M4 = 2'b10;     MW = 1;     SW = 1;     SR = 0;      R_ALL = 0; isJSR = 1;
                  end
             4'b1010: //PUSHA
                 begin
                     RW = 0;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 1;     M4 = 2'b01;     MW = 1;     SW = 1;     SR = 0;      R_ALL = 0;
                 end
             4'b1100: //POPA
                 begin
                     RW = 1;     RS = 0;   M1 = 2'b00;     M2 = 1;     M3 = 1;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 1;      R_ALL = 0;
                  end
             4'b1110: //RET
                 begin
                     RW = 0;     RS = 0;   M1 = 2'b11;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 1;      R_ALL = 0;      INT = 0;
                     isRET = 1;
                 end
        endcase
 ///////////////////////////////////////////////////////// Custom Instructions /////////////////////////////////////////////////////////    
                case(opCode)
                8'b1111_0000: //Left shift a by b
                    begin
                        RW = 1;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 1;    isJSR = 0;
                    end
                8'b1111_0001: //right shift a by b
                    begin
                        RW = 1;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 1;    isJSR = 0;
                    end
                8'b1111_0010: //isEven (a <- 1 if b is even and a <- 0 if b is odd) 
                    begin
                        RW = 1;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 1;    isJSR = 0;
                    end    
                8'b1111_0011: //double a <- 2a 
                    begin
                        RW = 1;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;    isJSR = 0;
                    end
                8'b1111_0100: //Halt
                    begin
                        RW = 0;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;    isJSR = 0;
                        isHALT = 1;
                    end         
               endcase
        end
    else
        begin
        case(opCode)
            8'b0111_0001: //ADD
                 begin
                     RW = 1;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 1;
                 end
            8'b0111_0010: //AND
                 begin
                     RW = 1;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 1;
                 end
             8'b0111_0011: //CLA
                 begin
                     RW = 1;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;
                  end
             8'b0111_0100: //CLB
                 begin
                     RW = 1;     RS = 1;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;
                 end
             8'b0111_0101: //CMB
                 begin
                     RW = 1;     RS = 1;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b10;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;
                  end
             8'b0111_0110: //INCB
                 begin
                     RW = 1;     RS = 1;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b01;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;
                 end
             8'b0111_0111: //DECB
                 begin
                     RW = 1;     RS = 1;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;
                  end
             8'b0111_1000: //CLC
                 begin
                     RW = 0;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;
                 end
             8'b0111_1001: //CLZ
                 begin
                     RW = 0;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;
                 end
             8'b0111_1010: //ION
                 begin
                     RW = 0;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;      INT = 1;
                 end
             8'b0111_1011: //IOF
                 begin
                     RW = 0;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;      isINTOFF = 1;
                 end 
             8'b0111_1100: //SC
                 begin
                     RW = 0;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;    
                    isSKP = 1;
                    if(C == 1)
                        M1 = 2'b10;
                 end 
             8'b0111_1101: //SZ
                begin
                     RW = 0;     RS = 0;   M1 = 2'b00;     M2 = 0;     M3 = 0;     M4 = 2'b00;     MW = 0;     SW = 0;     SR = 0;      R_ALL = 0;    
                    isSKP = 1;
                    if(Z == 1)
                         M1 = 2'b10;
                end              
        endcase
        end
    end
endmodule

module mux4(//MUX4 selects what data gets written into memory
    input [15:0] a,
    input [15:0]b,
    input [15:0]c,
    input [15:0]d,
    input [1:0] sel,
    input [1:0]isJSR,
    input isLoad,
    output reg [15:0] z
    );
    always@(*) begin
        case(sel)
            2'b00: z=a; 
            2'b01: z=b; 
            2'b10: z=c; 
            2'b11: z=d;
         endcase
         if(isJSR == 2'b01)
            z = c;
         else if(isJSR == 2'b10)
            z = b;
         if(isLoad)
            z = d;
    end
endmodule

module mux1(//mux 1 selects what address gets written into the PC register
    input [11:0] a,
    input [11:0]b,
    input [11:0]c,
    input [11:0]d,
    input [1:0] sel,
    input isHALT,
    input isRET,
    output reg [11:0] z
    );
    always@(*) begin
        case(sel)
            2'b00: z=a; 
            2'b01: z=b; 
            2'b10: z=c; 
            2'b11: z=d;
         endcase
         if(isHALT)
            z = a - 1; //return current PC if halt is called
    end
endmodule

module mux2(//mux2 selects what data gets written into the register file 
    input [15:0] a,
    input [15:0]b,
    input  sel,
    output reg [15:0] z
    );
    always@(*) begin
        case(sel)
            1'b0: z=a; 
            1'b1: z=b; 
         endcase
    end
endmodule

module mux3(//mux 3 selects what address is used in the memory module
    input [11:0] a,
    input [11:0] b,
    input [11:0] c,
    input [11:0] d,
    input  [1:0] sel,
    output reg [11:0] z
    );
    always@(*) begin
        case(sel)
            2'b00: z=a; 
            2'b01: z=b; 
            2'b10: z=c; 
            2'b11: z=d; 
         endcase
    end
endmodule