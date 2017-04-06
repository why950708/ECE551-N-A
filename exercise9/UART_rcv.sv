module UART_rcv (rx_rdy_clr, clk, rst_n, RX, rx_rdy, rx_data);
	input RX;  // Serial data input
	input rx_rdy_clr; // Asserted to clear rx_rdy

	input clk;
	input rst_n; 

	output reg rx_rdy;
	output reg [7:0] rx_data; 

	reg [3:0] bit_cnt;   // counter used for bits 
	reg [11:0] baud_cnt; // 12-bit baud rate counter

	reg RX1, RX2;  // Flip-flop used for double flip flop

	reg baud_clr;  // clear baud counter
	reg baud_inc;  // increment baud coutner

	reg bit_clr;   // clear bit counter
	reg bit_inc;   // increment bit counter (0-7)

	reg shift;    // asserted means shift a new one in

	reg rx_rdy_val;


	typedef enum reg[1:0] {IDLE, LOAD ,RECEVING, CLR} state_type;
	state_type state, nxt_state;

	// double flopping 
	always_ff @(posedge clk) begin : double_flopping
			RX1 <= RX;
			RX2 <= RX1;
	end




	// logic for baud_cnt;
	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n || baud_clr) begin
			baud_cnt <= 0;
		end
		else if (baud_inc) begin
			baud_cnt <= baud_cnt + 1;
		end
	end

	// logic for bit_cnt;
	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n || bit_clr) begin
			bit_cnt <= 0;
		end
		else if (bit_inc) begin
			bit_cnt <= bit_cnt + 1;
		end
	end

	// logic for rx_rdy;
	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			rx_rdy <= 0;
		end
		else begin
			rx_rdy <= rx_rdy_val;  // NOTE: rx_rdy_val should store its value
		end
	end

	// logic for rx_data;
	always_ff @(posedge clk or negedge rst_n) begin
		if(~rst_n ) begin
			rx_data <= 0;
		end
		else if (shift) begin
			rx_data <= { RX2 , rx_data[7:1] };  // Shift RX2 into MSB
		end
	end

	// Logic for state transition
	always_ff @(posedge clk or negedge rst_n) begin : proc_fsm
		if(~rst_n) begin
			state <= IDLE;
		end 
		else begin
			state <= nxt_state;
		end
	end


	// FSM combinational logic output
	always_comb begin
		// default value 
		rx_rdy_val = 0; // Stores the value to be put into rx_rdy
		nxt_state = state;

		// Below are the new variables: 
		baud_clr = 0; 
		baud_inc = 0;

		bit_clr = 0;
		bit_inc = 0;
		shift = 0;
		case(state)
			IDLE: begin 
			if(!RX2) // We have a start bit coming
				baud_clr = 1;
				nxt_state = LOAD;
		end
			
			LOAD: begin 
				// When first into LOAD, wait for 1302 clocks
				baud_inc = 1;
				if (baud_cnt == 12'd1302) begin
					// already waited for 1302 clocks
					baud_clr = 1;
					nxt_state = RECEVING;
				end
		end 
		
			RECEVING: begin 
				
				baud_inc = 1;
				if (baud_cnt == 12'd2604) begin
					// already waited for 2604 clocks
					baud_clr = 1;
					bit_inc = 1; // increase one bit
					shift = 1;
				end
				
				if(bit_cnt == 4'd8) begin  // At the 9th bit stop
					rx_rdy_val = 1;		// set rx_rdy to 1
					bit_clr = 1; // clear the bit counter
					nxt_state = CLR;
				end 


		end 

			CLR: begin
				rx_rdy_val = 1;
				if (rx_rdy_clr | !RX2 )begin
					rx_rdy_val = 0;
					nxt_state = IDLE;
				end

			end  
		endcase 
	end

endmodule 