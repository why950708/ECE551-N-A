// Hongyi & TZR & SHENYI IS HANDSOME, YiFei is DATING & SB
module barcode(clk, rst_n, BC, ID_vld, ID, clr_ID_vld);
input BC; 
input clr_ID_vld;
input clk, rst_n;
output [7:0] ID;
output logic ID_vld;
  
  reg reg1, reg2, reg3, reg4;
  reg reset_timing_counter, duration_cnt_start, shift;
  reg  [21:0]  duration_counter;
  wire [21:0] timing_counter_val;
  reg [21:0] timing_cnt;
  
  wire [3:0] bit_counter_val;
  reg [3:0] bit_cnt;
  
  wire [21:0] duration_counter_val;
  reg [21:0] duration_cnt;
  
  wire [7:0] shift_reg_val;
  reg  [7:0] shift_reg;
  
// State assignment
  typedef enum reg[2:0]{IDLE, TIMING, SAMPLING, IDLE2, DONE} state_t;
state_t state, next_state;

  
 //Falling edge detector
      always @(posedge clk, negedge rst_n)begin 
        if(~rst_n) begin
          reg1 <= 1;
            reg2 <= 1;
            reg3 <= 1;
            reg4 <= 1;
        end
        else  begin 
          reg1 <= BC;
          reg2 <= reg1;   //Double flopping async sig to avoid meta stability
            
            reg3 <= reg2;
            reg4 <= reg3; //For falling edge
        end 
      end 
  
  
//Bit count counter
  assign bit_counter_val = (shift)? bit_cnt + 1: bit_cnt;

//Capture the duration for each period
  assign duration_counter_val = (duration_cnt_start) ? duration_cnt + 1 : duration_cnt;
  
//count for the captured period
  assign timing_counter_val = (reset_timing_counter) ? (duration_counter_val >> 1) : timing_cnt - 1;
  
//Shift logic
  assign shift_reg_val =  (shift) ? {shift_reg[6:0], reg2} : shift_reg;

assign falling_edge = ~reg3&reg4;
assign timing_counter_time_out = ~(|timing_cnt);
  
  always_ff @(posedge clk, negedge rst_n) begin 
      if(!rst_n) begin
      state <= IDLE;
          bit_cnt <= 0;
          duration_cnt <= 0;
          shift_reg <= 0;

      end
      else begin
          bit_cnt <= bit_counter_val;
          duration_cnt <= duration_counter_val;
          timing_cnt <= timing_counter_val;
          
        state <= next_state;     
      end
  end

  // FSM 
always_comb begin
  //default case
  next_state = IDLE;
  
  duration_cnt_start = 0;
  shift = 0;
  reset_timing_counter = 0;
  case(state)
  IDLE:begin
      if(falling_edge) 
        next_state = TIMING;
    end
    
  TIMING: begin
    next_state = TIMING;


    //Wait till next falling edge
    if(falling_edge) begin
      next_state = SAMPLING;
      //Count for the next start
      reset_timing_counter = 1;
    end
end
    

  SAMPLING: begin
    next_state = SAMPLING;
    if(timing_counter_time_out) begin
      shift = 1;
      if(bit_cnt == 8) begin
      next_state = DONE;
      end
      else next_state = IDLE2;
    end   
  end
    
  IDLE2: begin
    next_state = IDLE2;
    if(falling_edge) begin 
    next_state = SAMPLING;
	reset_timing_counter = 1;
	end
   end
  //Default State: DONE State
    default: begin
      //Test if the upper 2-bits are 2'b00
      ID_vld = ~|shift_reg[7:6];
      next_state = DONE;
      // wait for clr_ID_vld
      if(clr_ID_vld) next_state = IDLE;
    end

  endcase 

  end

    
endmodule
      
    
    
    

    
      