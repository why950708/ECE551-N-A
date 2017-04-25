module motion_cntrl (
 input go;
 input cnv_cmplt;
 input [11:0]A2D_res;
 output start_conv;
 output [2:0] chnnl;
 output IR_in_en;
 output IR_mid_en;
 output IR_out_en;
 output [7:0]LEDs;
 output [10:0]lft;
 output [10:0]rht;
 input clk;
);

reg[15:0] Accum;
reg[11:0] Error;
reg[15:0] Pcomp;
reg[11:0] Intgrl;
reg[11:0] Icomp;
reg[11:0] lft_reg;
reg[11:0] rht_reg;
reg[11:0] Fwd;
reg[12:0] 4096_counter;
reg[5:0] 32_counter;
wire[9:0] duty;
reg[2:0] chnnl_counter;
reg ir_counter;
reg[13:0] Pterm;
reg[11:0] Iterm;
typedef enum reg {IDLE,STTL,INNER_R,MID_R,OUTER_R,SHRT_WAIT,INNER_L,MID_L,OUTER_L,INTG,ITERM,PTERM,MRT_R1,MRT_R2,MRT_L1,MRT_L2} state_t;
state_t state, next_state;
logic 4096_start,32_start;
wire PWM_sig;
pwm pwm(.duty(duty),.clk(clk),.rst_n(rst_n),.PWM_sig(PWM_sig)); 
  
  
  
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      state <= WAIT;
    end else begin
      state <=next_state ;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
     4096_counter <= 0;
  end else if(4096_start) begin
     4096_counter <= 0;
  end else begin
     4096_counter <= 4096_counter + 1;
  end
end


always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
     32_counter <= 0;
  end else if(32_start) begin
     32_counter <= 0;
  end else begin
     32_counter <= 32_counter + 1;
  end
end

always_comb begin
  ir_counter = 0;
  chnnl_counter = 0;
  Iterm = 12'h500;
  Pterm = 14'h3680;

  case(state)
    STTL:begin
    	if(ir_counter == 0)begin
    		IR_in_en = 1;
    		IR_mid_en = 0;
      		IR_out_en = 0;
    	end
    	else if(ir_counter == 1)begin
    		IR_in_en = 0;
      		IR_mid_en = 1;
      		IR_out_en = 0;    
    	end
    	else if(ir_counter == 2)begin
    		IR_in_en = 0;
      		IR_mid_en = 0;
      		IR_out_en = 1; 
    	end
	


    	4096_start = 1; // is it in this state or previous state?  enable timer?

    	if(4096_counter == 12'd4096) begin// timer == 4096
      		//A2D conversion
        	start_conv = 1; //start conversion
   	 		chnnl = 3'd1; //set chnnl number
      	if(cnv_cmplt)begin
        	//based on chnnl counter, move to different state
        	start_conv = 0; // after conversion is completed, should we deassert start_conv?
        if(chnnl_counter == 0)begin
        	//inner_R
        	
        	next_state = INNER_R;
        end
        else if(chnnl_counter == 2)begin
        	
        	next_state = MID_R;
        end
        else if(chnnl_counter == 4)begin
        	
        	next_state =  OUTER_R;
        end
      end
   	end
   INNER_R:begin
   		Accum = A2D_res ; // Accum = IR_in_rht;
   		next_state = SHRT_WAIT;
   		4096_start = 0; //clear timer

   		chnnl_counter = chnnl_counter + 1; //increment chnnl counter
	end
	SHRT_WAIT:begin

		32_start = 1;
		if(32_counter == 5'd32)begin
			chnnl = 3'd0;
			start_conv = 1;
			if(cnv_cmplt)begin
			start_conv = 0;
				if(chnnl_counter == 1)begin
					next_state = INNER_L;
				end	
				if(chnnl_counter == 3)begin
					next_state = MID_L;
				end
				if(chnnl_counter == 5)begin
					next_state = OUTER_L;
				end
			end
		end
	
	end
	INNER_L:begin
		Accum = Accum - A2D_res;
		next_state = STTL;
		32_start = 0//clear timer
		chnnl_counter = chnnl_counter + 1; 
	end
	MID_R:begin
		Accum = Accum + A2D_res * 2;
		next_state = SHRT_WAIT;
		4096_start = 0;
		chnnl_counter = chnnl_counter + 1;
	end
	MID_L:begin
		Accum = Accum - A2D_res * 2;
		next_state = STTL;
		32_start = 0//clear timer
		chnnl_counter = chnnl_counter + 1; 
	end
	OUTER_R:begin
		Accum = Accum + A2D_res * 4;
		next_state = SHRT_WAIT;
		4096_start = 0;
		chnnl_counter = chnnl_counter + 1;
	end
	OUTER_L:begin
		Accum = Accum -A2D_res * 4;
		next_state = INTG;
		32_start = 0//clear timer
		chnnl_counter = chnnl_counter + 1; 
	end
	INTG:begin
		Intgrl =Error>>4 + Intgrl;
		next_state = ITERM;
	end
	ITERM:begin
		Icomp = Iterm * Intgrl;
		next_state = PTERM;
	end
	PTERM:begin
		Pcomp = Error * Pterm;
		next_state = MRT_R1;
	end
	MRT_R1:begin
		Accum = Fwd - Pcomp;
		next_state = MRT_R2;
	end
	MRT_R2:begin
		rht_reg = Accum - Icomp;
		next_state = MRT_L1;
	end
	MRT_L1:begin
		Accum = Fwd + Pcomp;
		next_state = MRT_L2;
	end
	MRT_L2:begin
		lft_reg = Accum + Icomp;
		next_state = IDLE;
	end
	default:begin //IDLE state
		chnnl = 0;
		Accum = 0;
		next_state = STTL;
	end
  endcase // state
end 

 
endmodule