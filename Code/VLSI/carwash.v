//this module describes the behaviour of a carwash system
module carwash(output reg [3:0]state, //this outputs the current state pf the carwash
				output reg complete,//output = 1 when the carwash completes a cycle
				input [1:0] selection, //user selected service
				input reset,//resets to entry state
				input clk, //clock input
				input timerClk, //clock input for timer
				input approvalStatus);//payment approval status 

	//selection definitions 
	parameter noSelection = 0;
	parameter basicWash = 1;
	parameter basicWash_plus = 2;
	parameter detailWash = 3;

	//state definitions 
	parameter makeSelection = 0; //default state
	parameter preSoak = 1;
	parameter tireSoak = 2;
	parameter curtainWipe = 3;
	parameter foamApp = 4;
	parameter sealantApp = 5;
	parameter scrub = 6;
	parameter tireScrub = 7;
	parameter waterJet = 8;
	parameter underCarJet= 9;
	parameter rinse = 10;
	parameter underCarRinse = 11;
	parameter wax = 12;
	parameter dry = 13;
	parameter washComplete = 14;

	//time for each step
	parameter preSoak_time_s = 5; //seconds
	parameter tireSoak_time_s = 3;
	parameter curtainWipe_time_s = 2;
	parameter foamApp_time_s = 7;
	parameter sealantApp_time_s = 3;
	parameter scrub_time_s = 3;
	parameter tireScrub_time_s = 3;
	parameter waterJet_time_s = 1;
	parameter underCarJet_time_s = 5;
	parameter rinse_time_s = 10;
	parameter underCarRinse_time_s = 5;
	parameter wax_time_s = 3;
	parameter dry_time_s = 4;

	//pos variables
	wire [255:0] paymentApproved; //when the payment is approved this will be 
	wire [255:0] posState;//store the state of the pos
	reg [255:0] resetPos; //reset pos
	
	//timer variables
	reg [255:0] resetTimer; //reset timer
	reg [255:0]timer_s; //timer second input
	wire timerComplete; //when the timer reached 0
	wire [255:0] timerState;
	wire [255:0] sec;


	//creating pos module instance
	pos myPos(paymentApproved, posState, resetPos, selection, approvalStatus, clk);

	//creating timer module instance
	timer myTimer(timerClk, resetTimer, timer_s,sec, timerComplete, timerState);
	
	always @(posedge clk) begin //on the rising edge of the input clock
		if (reset) begin//if reset is set to 1 make the state the default state
			state <= makeSelection;
			complete <= 0; //mark the was cycle as incomplete
			resetPos <= 1; //reset the POS
			resetTimer <= 1; //reset the timer
		end
		else case(state)

			makeSelection: begin
							resetPos <= 0;
							//if a selection is made when the carwash is not in reset and payment is approved
							if (selection != noSelection && !reset && !complete && paymentApproved) 
								state <= preSoak;
							end 
			
			preSoak: begin
						if (!timerComplete)begin //if the timer has just been reset, load the new time
							timer_s <= preSoak_time_s; //load
							resetTimer <= 0; //set and let the timer run
						end
						else begin //if the timer is has completed the countdown, reset it and switch states
							resetTimer <= 1;
							if (selection != basicWash)
								state <= tireSoak;
							else
								state <= curtainWipe;
						end
					end 
			
			tireSoak: begin 
						if (!timerComplete)begin
							timer_s <= tireSoak_time_s;
							resetTimer <= 0; //set and let the timer run
						end
						 else begin 
						 	state <= curtainWipe;
						 	resetTimer <= 1;
						 end 
					end 
			
			curtainWipe: begin 
							if (!timerComplete) begin
								timer_s <= curtainWipe_time_s;
								resetTimer <= 0; //set and let the timer run
							end
							else begin
								state <= foamApp;
								resetTimer <= 1;
							end 
						end
			foamApp: begin 
						if (!timerComplete) begin
							timer_s <= foamApp_time_s;
							resetTimer <= 0; //set and let the timer run
						end
						else begin  
							if (selection == detailWash) begin
								state <= sealantApp;
								resetTimer <= 1;
							end 
							else begin 
								state <= scrub;
								resetTimer <= 1;
							end  
						end
					end

			sealantApp: begin 
							if (!timerComplete) begin
								timer_s <= sealantApp_time_s;
								resetTimer <= 0; //set and let the timer run
							end
							else begin 
								state <= scrub;
								resetTimer <= 1;
							end 
						end
			
			scrub: begin 
						if (!timerComplete) begin
							timer_s <= scrub_time_s;
							resetTimer <= 0; //set and let the timer run
						end
						else begin 
							if (selection != basicWash)begin
								state <= tireScrub;
								resetTimer <= 1;
							end 
							else begin 
								state <= waterJet;
								resetTimer <= 1;
							end 
						end 
					end 
			
			tireScrub: begin
							if (!timerComplete) begin
								timer_s <= tireScrub_time_s;
								resetTimer <= 0; //set and let the timer run
							end 
							else begin  
								state <= waterJet;
								resetTimer <= 1;
							end 
						end
			
			waterJet: begin
						if (!timerComplete) begin
							timer_s <= waterJet_time_s;
							resetTimer <= 0; //set and let the timer run
						end 
						else begin 
							if (selection == detailWash) begin
								state <= underCarJet;
								resetTimer <= 1;
							end 
							else begin 
								state <= rinse;
								resetTimer <= 1;
							end 
						end
					end  

			underCarJet: begin
							if (!timerComplete) begin
								timer_s <= underCarJet_time_s;
								resetTimer <= 0; //set and let the timer run
							end 
							else begin 
							 	state <= rinse;
							 	resetTimer <= 1;
							 end 
						 end 
			
			rinse: begin 
						if (!timerComplete) begin
							timer_s <= rinse_time_s;
							resetTimer <= 0; //set and let the timer run
						end 
						else begin 
						if (selection == detailWash) begin
							state <= underCarRinse;
							resetTimer <= 1;
						end 
						else begin 
							state <= dry;
							resetTimer <= 1;
						end 
						end
					end  
			
			underCarRinse: begin
								if (!timerComplete) begin
									timer_s <= underCarRinse_time_s;
									resetTimer <= 0; //set and let the timer run
								end 
								else begin  
									state <= wax;
									resetTimer <= 1;
								end
							end  
			
			wax: begin
					if (!timerComplete) begin
						timer_s <= wax_time_s;
						resetTimer <= 0; //set and let the timer run
					end 
					else begin  
						state <= dry;
						resetTimer <= 1;
					end 
				end 
			
			dry: begin 
					if (!timerComplete) begin
							timer_s <= dry_time_s;
							resetTimer <= 0; //set and let the timer run
						end 
					else begin 
						state <= washComplete;
						resetTimer <= 1;
					end 
				end 
			
			washComplete: begin
							complete <= 1;
							state <= makeSelection;
							resetTimer <= 1;
						end 
			
			default: begin state <= makeSelection;
				resetTimer <= 1;
			end 
		
		endcase

	end 
endmodule // carwash

//this module describes the behaviour of a point of sale sysstem used to approve payments
module pos (output reg [255:0] approved, //= 1 when payment is approved
			output reg [255:0] state,
			input [255:0] reset,	//resets the pos
			input [1:0] selectionInput, //input to capture the selection of the user
			input approvalStatus, //if = 1 the payment will be approved
			input clk); 

//input definitions
	parameter noSelection = 2'b00;
	parameter basicWash = 2'b01;
	parameter basicWash_plus = 2'b10;
	parameter detailWash = 2'b11;


//state definitions
	parameter makeSelection = 2'b00;
	parameter awaitingApproval = 2'b01;
	parameter printReciept = 2'b10;
	
	always @(posedge clk) begin //on rising edege of the clock 
		if (reset) begin//if reset is set to 1 make the state the default state
			state <= makeSelection;
			approved <= 0;
		end 
		else case(state)

			makeSelection: begin
								if(selectionInput != noSelection && !reset && !approved)
									state <= awaitingApproval;
							end
			awaitingApproval: begin
									if (approvalStatus) //if payment is approved
										state <= printReciept;
									else 
										state <= makeSelection;
								end 
			printReciept: begin
								approved <= 1;
								state <= makeSelection;
							end 
			default: state <= makeSelection;

		endcase
	end
endmodule

module timer(input clk, //clock input 
				input [255:0] reset, //resets the timer and complete flag if reset = 0 the timer runs
				input [255:0] time_s, //seconds time input
				output reg[255:0] sec, //seconds time output
				output reg complete,
				output reg [255:0] state);
//state definitions
parameter setTime = 2'b00;
parameter countdown = 2'b01;
parameter finish = 2'b10;
always @(posedge clk) begin //on rising edge of the clock
	if(reset) begin //if timer is reset
		state <= setTime;
		complete <= 0;
	end 
	else case(state)
		setTime: begin
					if(!reset & !complete)begin //if not in reset or the timer hasnt completed a countdown
						sec <= time_s;
						state <= countdown; //set the outputs and switch to running state
					end
					else begin
						sec <= 0;
					end  
				end
		countdown: begin
						sec <= sec -1;
						if (sec == 1)
							state <= finish;
					end
		finish: begin
				complete <= 1;
				state <= setTime;
				end
		default: state <= setTime;  
	endcase 
end 
endmodule 
 