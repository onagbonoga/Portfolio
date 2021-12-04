`timescale 1ms/1ms
`include "carwash_syn.v"
//`include "carwash.v"

module carwash_tb;
	//definitions for inputs and outputs to the module
	wire [3:0] state; 
	wire complete;
	reg [1:0] selection;
	reg reset;
	reg clk;
	reg timerClk;
	reg approvalStatus;
	

	carwash c0(.state(state),
				.complete(complete),
				.selection(selection),
				.reset(reset),
				.clk(clk),
				.timerClk(timerClk),
				.approvalStatus(approvalStatus));

	always #1000 clk = ~clk; //0.5 Hz clock period
	always #500 timerClk = ~timerClk; //1Hz clock period
	initial begin
		$dumpfile("carwash.vcd");
		$dumpvars(0, carwash_tb);
		clk <= 0;
		timerClk <= 0; //initialize clock values
		reset <= 1; //reset carwash module
		#2000
		selection <= 3; //make selection 1 - BasicWash, 2 - BasicWash+, 3 - Detailwash
		approvalStatus <= 1; //approval status
		#2000
		reset <= 0;
		#1000


		#140000
		$finish;
	end
endmodule

/*module pos_tb;
	wire [2:0] state;
	wire approved;
	//wire [2:0] selection;
	reg [2:0] selectionInput;
	reg approvalStatus;
	reg reset;
	reg clk;
	

	pos c0(.state(state),
				.approved(approved),
				//.selection(selection),
				.reset(reset),
				.clk(clk),
				.approvalStatus(approvalStatus),
				.selectionInput(selectionInput));

	always #500 clk = ~clk; //toggle the clock every 05 sec

	initial begin
		$dumpfile("pos.vcd");
		$dumpvars(0, pos_tb);
		clk <= 0;
		reset <= 1; //dont run the timer yet
		#1000
		selectionInput <= 10;
		approvalStatus <= 1;
		#1000
		reset <= 0;
		#1000


		#20000
		$finish;
	end
endmodule 

module timer_tb;
	wire [15:0] state; 
	wire complete;
	reg [15:0] time_s;
	reg [15:0] time_m;
	wire [15:0] sec;
	wire [15:0] min;
	reg reset;
	reg clk;
	

	timer t0(.state(state),
				.complete(complete),
				.time_m(time_m),
				.time_s(time_s),
				.reset(reset),
				.clk(clk),
				.sec(sec),
				.min(min));

	always #500 clk = ~clk; //toggle the clock every 05 sec

	initial begin
		$dumpfile("timer.vcd");
		$dumpvars(0, timer_tb);
		clk <= 0;
		reset <= 1; //dont run the timer yet
		#1000
		time_m <= 00;
		time_s <= 10;
		#1000
		reset <= 0;
		#1000


		#20000
		$finish;
	end
endmodule*/