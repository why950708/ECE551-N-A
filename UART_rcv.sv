module UartRx (clr_rdy, clk, rst_n, RX, rdy, cmd);
	input RX; 
	input clr_rdy;

	input clk;
	input rst_n; 

	output reg rdy;
	output [7:0] cmd; 

	reg [3:0] bit_cnt; 
	reg [11:0] baud_cnt; 
	reg [8:0] shift_reg;
	reg Rx1, Rx2;
	reg load; 
	reg receving;

	wire shift;
	wire [3:0] bit_cnt_val;
	wire [11:0] baud_cnt_val; 
	wire [8:0] shift_val;

	logic rdy_val;


	typedef reg[1:0] {IDLE, LOAD ,RECEVING, CLR} state_type;
	state_type state, nxt_state;

	// double flopping 
	always_ff @(posedge clk) begin : double_flopping
			RX1 <= RX;
			RX2 <= RX1;
	end

	// reg values 
	assign bit_cnt_val = (load)? 4'd0: (shift)? : bit_cnt + 1: bit_cnt;
	assign baud_cnt_val = (load)? 12'd3906: (receving)? : baud_cnt - 1: baud_cnt;
	assign shift_val = (load)? 9'h0: (shift)? {RX2,shift_reg[8:1]}: shift_reg;
	// output 
	assign cmd = shift_reg[7:0];

	assign shift = receving ? ((~|baud_cnt)? 1: 0) :0;
	// fsm
	always_ff @(posedge clk or negedge rst_n) begin : proc_fsm
		if(~rst_n) begin
			bit_cnt <= 0;
			baud_cnt <= 12'd2604;
			shift_reg <= 0;
			state <= IDLE;
			rdy <= 0;
		end 

		else begin
			bit_cnt <= bit_cnt_val;
			baud_cnt <= (shift)? 12'd3906: baud_cnt_val;
			shift_reg <= shift_val;
			state <= nxt_state;
			rdy <= rdy_val;
		end
	end

	always_comb begin
		// default value 
		load = 0;
		receving = 0;
		rdy_val = 0;
		nxt_state = state;
		case(state)
			IDLE: begin 
			if(!RX2)
				nxt_state = LOAD;
		end
			LOAD: begin 
				load = 1;
				nxt_state = RECEVING;
		end 
			RECEVING: begin 
				receving = 1;		
				if(bit_cnt = 4'd9)begin
					rdy_val = 1;			
					nxt_state = CLR;
				end 

		end 
			CLR: begin
				rdy_val = 1;
				if (clr_rdy | !RX2)begin
					rdy_val = 0;
					nxt_state = IDLE;
				end

			end  
		endcase // state
	end

endmodule 