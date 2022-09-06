/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
//#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"

//#define MY_PWM XPAR_MY_PWM_CORE_0_S00_AXI_BASEADDR //Because of a bug in Vivado 2015.3 and 2015.4, this value is not correct.
#define RESET 0x43C00000 //This value is found in the Address editor tab in Vivado (next to Diagram tab)
#define LOAD 0x43C00000 + 4
#define IFF 0x43C00000 + 8
void delay(){
	int i;
	for(i=0;i<5; i++);
}
void loadToMem(int addr, int instr){
	int input = 0x80000000;
	//input |= 1 << 30;
    addr = addr << 16;
    input = input + addr + instr;
    Xil_Out32(LOAD, input);

    delay();
    //printf("Input %X\n",input);
    //printf("Xin %X\n-----------------\n",Xil_In32(LOAD));
}

void test0(){//my test
	loadToMem(0,0b0000000001010110); //LDA M[86]
	loadToMem(1,0b1010000000000000); //PUSHA
	loadToMem(2,0b0000000001010000); //LDA M[80]
	loadToMem(3,0b0010000001010010); //STA M[82]
	loadToMem(4,0b0001000001010001); //LDB M[81]
	loadToMem(5,0b0111000100000000); //ADD
	loadToMem(6,0b0010000001010011); //STA M[83]
	loadToMem(7,0b0000000001010111); //LDA M[87]
	loadToMem(8,0b1110000000000000); //RET
	loadToMem(80,5);
	loadToMem(81,4);
	loadToMem(86,0);
	loadToMem(87,1);
}

void loadDemo_data(){
	loadToMem(0x0052,0xabcd); //replaced 0x0000 as addr because program uses that address
	loadToMem(0x0100,0x0000);
	loadToMem(0x0101,0x0001);
	loadToMem(0x0102,0x0002);
	loadToMem(0x0103,0x0003);
	loadToMem(0x0104,0xffff);
	loadToMem(0x0105,0xaaaa);
}

void test1(){
	loadToMem(0,0x7400); //CLB
	loadToMem(1,0x7300); //CLA
	loadToMem(2,0x1104); //LDB 0x0104
	loadToMem(3,0x0102); //LDA 0x0102
	loadToMem(4,0x7500); //CMB
	loadToMem(5,0x7600); //INCB
	loadToMem(6,0x7100); //ADD
	loadToMem(7,0x1103); //LDB 0x0103
	loadToMem(8,0x7200); //AND
	loadToMem(9,0x2500); //STA 0x0500
	loadToMem(10,0x3500); //LDB 0x0500
	loadToMem(11,0xf400); //HALT
}

void test2(){
	loadToMem(0,0x7400); //CLB
	loadToMem(1,0x7300); //CLA
	loadToMem(2,0x7800); //CLC
	loadToMem(3,0x7900); //CLZ
	loadToMem(4,0x1103); //LDB 0x0103
	loadToMem(5,0x7100); //ADD
	loadToMem(6,0x7700); //DECB
	loadToMem(7,0x7100); //ADD
	loadToMem(8,0x7d00); //SZ
	loadToMem(9,0x4006); //JMP6
	loadToMem(10,0xf400); //HALT
	//loadToMem(10,0x4000); //JMP0
}

void test3(){
	int INTVEC = 512;
	loadToMem(0,0x7400); //CLB
	loadToMem(1,0x7300); //CLA
	loadToMem(2,0x7a00); //ION
	loadToMem(3,0x0104); //LDA 0x0104
	loadToMem(4,0x7c00); //POPA
	loadToMem(5,0xf400); //HALT

	//ISR
	loadToMem(INTVEC,0x0052); //LDA 0x0052
	loadToMem(INTVEC + 1,0x1101); //LDB 0x0101
	loadToMem(INTVEC + 2,0x7100); //ADD
	loadToMem(INTVEC + 3,0x7400); //CLB
	loadToMem(INTVEC + 4,0xe000); //RET  516

}

void option1(){
	loadToMem(80,6); //size of array
	loadToMem(82,131);
	loadToMem(83,82);
	loadToMem(84,77);
	loadToMem(85,0xffce);
	loadToMem(86,452);
	loadToMem(87,241);
	loadToMem(90,0);


	loadToMem(0,0x0052); //LDA M[82]
	loadToMem(1,0xa000); //PUSH A
	loadToMem(2,0x0053); //LDA M[83]
	loadToMem(3,0xa000); //PUSH A
	loadToMem(4,0x0054); //LDA M[84]
	loadToMem(5,0xa000); //PUSH A
	loadToMem(6,0x0055); //LDA M[85]
	loadToMem(7,0xa000); //PUSH A
	loadToMem(8,0x0056); //LDA M[86]
	loadToMem(9,0xa000); //PUSH A
	loadToMem(10,0x0057); //LDA M[87]
	loadToMem(11,0xa000); //PUSH A
	loadToMem(12,0x7300); //CLA
	loadToMem(13,0x1050); //LDB M[80]

	loadToMem(14,0x3050);//STB M[80] //keep track of counter
    loadToMem(15,0x105a);//LDB M[90] //get current sum result
    loadToMem(16,0xc000);//POP A
    loadToMem(17,0x7100);//ADD
    loadToMem(18,0x205a);//STA M[90]
    loadToMem(19,0x1050);//LDB M[80] //load counter value
    loadToMem(20,0x7300);//CLA
    loadToMem(21,0x7700);//DECB
    loadToMem(22,0x7100);//ADD
    loadToMem(23,0x7d00);//SZ
    loadToMem(24,0x400e);//JMP 14
    loadToMem(25,0xf400);//HALT
}

void option2(){
	loadToMem(81,80); //input A
	loadToMem(82,2); //input B

	//subroutine
	loadToMem(100,0x7100);//ADD
    loadToMem(101,0xf300);//double A
    //loadToMem(102,0x1050);//LDB M[80]
    loadToMem(102,0x205a);//STA M[90]
    loadToMem(103,0x105a);//LDB M[90]
    loadToMem(104,0x7500);//CMB
    loadToMem(105,0x7600);//INCB
    loadToMem(106,0x305a);//STB M[90]
    loadToMem(107,0xe000);//RET

    //main routine
    loadToMem(0,0x0051);//LDA M[81]
    loadToMem(1,0x1052);//LDB M[82]
    loadToMem(2,0x8064);//JSR 100
    loadToMem(3,0xf400);//HALT
}
int main(){
	Xil_Out32(IFF, 0);
	Xil_Out32(RESET, 1);
	Xil_Out32(LOAD, 0x80000000);
	delay();
	//Load Program after this line

	//loadDemo_data();
	//test3();
	option2();
	//end load Program
	//Xil_Out32(LOAD, 0x00000000);
	//Xil_Out32(RESET, 1);

	delay();
    Xil_Out32(RESET, 0);
    delay();
    Xil_Out32(LOAD, 0x00000000);
    delay();
    Xil_Out32(RESET, 1);
   // printf("DONE\n");

}
