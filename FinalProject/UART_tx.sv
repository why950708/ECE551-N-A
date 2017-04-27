module UART_tx (clk, rst_n, trmt,  TX, tx_data, tx_done);
output reg tx_done;
output wire TX;
input clk, rst_n, trmt;
input [7:0] tx_data;

reg [11:0] baud_cnt;
reg [3:0] bit_cnt;
reg [1:0] state, next_state;
reg [9:0] shift_reg;  // shift register
reg load, trnsmttng, set_done, clr_done;
wire shift;

localparam IDLE = 2'b00;
localparam TRANSMIT = 2'b01;
localparam DONE = 2'b10;


always @(posedge clk or negedge rst_n) 
  if (!rst_n) // start with reset case, not normal case 
    state <= IDLE; 
  else  
    state <= next_state;


always @(posedge clk or negedge rst_n) // it’s sequential because it’s a shift “register” 
  if (!rst_n) // start with reset case, not normal case 
    shift_reg <= 10'h3FF; // fill in with bit 1’s because the LSB should should be the stop bit in IDLE state 
  else if (load) 
    shift_reg <= {1'b1,tx_data,1'b0}; // start bit and stop bit are loaded as well as data to TX 
  else if (shift) 
    shift_reg <= {1'b1,shift_reg[9:1]}; // LSB shifted out and idle state shifted in 

// 12 bit counter;
always @(posedge clk or negedge rst_n) 
    if (!rst_n) // start with reset case, not normal case 
      baud_cnt <= 12'h000; // reset to 0 on reset 
    else if (load || shift) 
      baud_cnt <= 12'h000; // reset when baud count indicates 19200 baud 
    else if (trnsmttng) 
      baud_cnt <= baud_cnt + 1; // only burn power incrementing if tranmitting

// Done register;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        tx_done = 0;
    else if (set_done)
        tx_done = 1;
    else if (clr_done)
        tx_done = 0;
end



// always for 4-bit counter
always @(posedge clk or negedge rst_n) 
    if (!rst_n) // start with reset case, not normal case 
      bit_cnt <= 4'h0; // reset to 0 on reset 
    else if (load) 
      bit_cnt <= 4'h0; // reset when just started.
    else if (shift) 
      bit_cnt <= bit_cnt + 1 ; // only burn power incrementing if tranmitting


assign shift = (baud_cnt == 12'hA2B); // assert shift when baud_cnt reaches 2603 (small cloud in the middle of the diagram)
assign TX = shift_reg[0];

always_comb begin
    load = 0;
    trnsmttng = 0;
    next_state = IDLE;
    set_done = 0;
    clr_done = 0;
    case (state)
        IDLE: begin
            if (trmt) begin
                load = 1;
                next_state = TRANSMIT;
                clr_done = 1;
            end
            else begin
                next_state = IDLE;
            end
        end

        TRANSMIT: begin
            if (bit_cnt == 4'd10) begin
                next_state = DONE;
            end
            else begin
                next_state = TRANSMIT;
                trnsmttng = 1;
            end

        end

        DONE: begin
            set_done = 1;
        end
    endcase
end



endmodule