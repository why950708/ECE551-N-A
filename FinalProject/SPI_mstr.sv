module SPI_mstr (wrt, cmd, done, rd_data, SCLK, MOSI, MISO, SS_n, 
				clk, rst_n);

// clk should be 50MHz

input wrt, MISO, clk, rst_n;
input[15:0] cmd;
output reg [15:0] rd_data;
output reg done, MOSI, SS_n;
output SCLK;


///////////////////////////////////////////////
// Registers needed in design declared next //
/////////////////////////////////////////////
reg[2:0] state, next_state;

reg [15:0] shift_reg;	// SPI shift register for transmitted data
reg [4:0] SCLK_counter; // The counter for SCLK

reg [4:0] shift_counter;  // The counter for shift state, 5 bit

/////////////////////////////////////////////
// SM outputs declared as type logic next //
///////////////////////////////////////////

localparam IDLE = 2'b00;
localparam SHIFT = 2'b01;
localparam DONE =  2'b10;



logic load, inc_count, shift, update_rd_data;
logic [4:0] bit_counter;


assign MOSI = shift_reg[15];
// Logic for generating SCLK
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		SCLK_counter <= 5'b11011;
	end
    else if (!SS_n)
        SCLK_counter <= SCLK_counter + 1;
    else
        SCLK_counter <= 5'b11011; // 5th bit is 1, and this number
		// should not be very large so some addition will turn it into positive.
end
// The SCLK signal is generated using SCLK_counter bit 4;
assign SCLK = SCLK_counter[4];

always @(posedge clk, negedge rst_n) begin
    if (!rst_n)
        state <= IDLE;
    else
        state <= next_state;
end


always @(posedge clk or negedge rst_n) // it’s sequential because it’s a shift “register” 
  if (!rst_n) // start with reset case, not normal case 
    shift_reg <= 10'h3FF;
  else if (load) 
    shift_reg <= cmd;
  else if (shift) 
    shift_reg <= {shift_reg[14:0], MISO}; // LSB shifted out and idle state shifted in 

always @(posedge clk or negedge rst_n) 
  if (!rst_n) // start with reset case, not normal case 
    shift_counter <= 0; // reset to 0 on reset 
  else if (load )    //  load || shift
    shift_counter <= 0; // reset when baud count indicates 19200 baud 
  else if (inc_count) 
    shift_counter <= shift_counter+1; // only burn power incrementing if tranmitting

always @(posedge clk or negedge rst_n) 
  if (!rst_n) // start with reset case, not normal case 
    rd_data <= 12'h000; // reset to 0 on reset 
  else if (update_rd_data) 
    rd_data <= shift_reg; // reset when baud count indicates 19200 baud 
  else 
    rd_data <= rd_data; // only burn power incrementing if tranmitting


always @(posedge clk or negedge rst_n) 
  if (!rst_n) // start with reset case, not normal case 
    bit_counter <= 0; // reset to 0 on reset 
  else if (load )    //  load || shift
    bit_counter <= 0; // reset when baud count indicates 19200 baud 
  else if (shift) 
    bit_counter <= bit_counter +1; // only burn power incrementing if tranmitting


always_comb begin
    SS_n = 1;
    next_state = state;
    done = 0;
	load = 0;
	inc_count = 0;
	shift = 0;
	update_rd_data = 0;
	//rd_data = 16'h0;
    case (state)
      IDLE: begin 
		//bit_counter = 0;

        if (wrt) begin
			SS_n = 0;
			next_state = SHIFT;
			load = 1;
        end

	  end

	  SHIFT: begin
	  	  inc_count = 1;  // start incrementing the count for 32
	  	  SS_n = 0;

			if (bit_counter == 5'd16) begin // used to be 16 see how it goes
				next_state = DONE;
				update_rd_data = 1;
			//bit_counter = 5'd0; // Reset for new round
			//done = 1;
		   end

			if (shift_counter == 5'h1F) begin
				
				// we always shift
				shift = 1;  // bit counter will also increment
			end
	  end

	  DONE: begin
	  	  	SS_n = 1;
			//rd_data = shift_reg;
		  	done = 1;
			next_state = IDLE;
	  end
	  endcase
end

  

endmodule
