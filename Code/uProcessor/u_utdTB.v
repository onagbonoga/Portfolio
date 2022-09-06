`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/15/2022 09:54:14 AM
// Design Name: 
// Module Name: modulesTB
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


module uutdTB();
    reg clk; reg reset; reg [31:0] load_program; reg IFF; wire [11:0]w_addr; wire [15:0]w_data;
     wire [15:0]busA; wire [15:0]busB; wire [31:0] LP; wire done; 
    u_utd UUT(clk, reset, load_program, IFF,  w_addr, w_data, busA, busB, LP, done);
    always begin
        #2;
        clk = ~clk;
    end
    initial begin
        reset = 1;
        //load_program[31] = 1;
        load_program = 32'b1000_0000_0000_0000_0000_0000_0000_0000;
        clk = 0;
        IFF = 0;
        #8;
        //reset = 0;
        //#20;
        load_program[27:16] = 16'h0103;
        load_program[15:0] = 16'b0000_0000_0000_0011;
        #8;
        load_program[27:16] = 0;
        load_program[15:0] = 16'h7400;//CLB
        #8;
        load_program[27:16] = 1;
        load_program[15:0] = 16'h7300;//CLA
        #8;
        load_program[27:16] = 2;
        load_program[15:0] = 16'h7800;//CLC
        #8;
        load_program[27:16] = 3;
        load_program[15:0] = 16'h7900;//CLZ
        #8;
        load_program[27:16] = 4;
        load_program[15:0] = 16'h1103;//LDB 0x0103
        #8;
        load_program[27:16] = 5;
        load_program[15:0] = 16'h7100;//ADD
        #8;
        load_program[27:16] = 6;
        load_program[15:0] = 16'h7700;//DECB
        #8;
        load_program[27:16] = 7;
        load_program[15:0] = 16'h7100;//ADD
        #8;
        load_program[27:16] = 8;
        load_program[15:0] = 16'h7d00;//SZ
        #8;
        load_program[27:16] = 9;
        load_program[15:0] = 16'h4006;//JMP6
        #8;
        //load_program[27:16] = 10;
        //load_program[15:0] = 16'hffff;//NOP
        //#8;
        load_program[27:16] = 10;
        load_program[15:0] = 16'hf400;//HALT
        #8;
                                
        load_program = 0;
        reset = 1;
        
        #8;
        reset = 0;
        #10;
        reset = 1;
        #150;
        $finish;
    end
endmodule


//test bench for when programs are loaded into the memory directly in the memory module without passing though the uutd top module
/*module uutdTB();
    reg clk; reg reset; reg [31:0] load_program; reg IFF; wire [11:0]w_addr; wire [15:0]w_data;
     wire [15:0]busA; wire [15:0]busB; wire [31:0] LP; wire done;
    u_utd UUT(clk, reset, load_program, IFF,  w_addr, w_data, busA, busB, LP, done);
    always begin
        #5;
        clk = ~clk;
    end
    initial begin
        load_program = 0;
        reset = 0;
        IFF = 0;
        clk = 0;
        #25;
        reset = 1;
        #30;
        //IFF = 1;
        #35;
        IFF = 0;
        #280;
        $finish;
    end
endmodule*/


