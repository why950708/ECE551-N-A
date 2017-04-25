module motion_cntrl (
<<<<<<< HEAD
 go,                     // read page 35 and 36 in specification
 cnv_cmplt,
 A2D_res,
 start_conv,
 chnnl,
 IR_in_en,    // wire
 IR_mid_en,   // wire
 IR_out_en,   // wire, hasn't been assigned
 LEDs,
 lft,
 rht,
 clk,
 rst_n
);
  
input go, cnv_cmplt;
input [11:0] A2D_res;
output reg start_conv;
output reg [2:0] chnnl;
output wire IR_in_en, IR_out_en, IR_mid_en;
input clk, rst_n;
output wire [10:0] lft, rht;
output wire [7:0] LEDs;

 
  
reg[11:0] lft_reg, rht_reg;
  
reg[12:0] counter_4096;
reg[5:0] counter_32;
  
reg reset_chnnl,  inc_chnnl;
  
  
wire[7:0] duty;
=======
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




reg[11:0] lft_reg;
reg[11:0] rht_reg;

reg[12:0] 4096_counter;
reg[5:0] 32_counter;
wire[9:0] duty;
>>>>>>> origin/master
reg[2:0] chnnl_counter;
reg ir_counter;

//alu
<<<<<<< HEAD
  reg[13:0] Pterm;  // 14h3680
  reg[11:0] Iterm;  // 12'h500
  reg sub,mult2,mult4,multiply,saturate;   // Assigned in always_comb
  reg[2:0] src0sel,src1sel;     // always_comb
  reg dst2Accum,dst2Err,dst2Int,dst2Icmp,dst2Pcmp,dst2lft,dst2rht;  // always_comb
  reg[15:0] Accum;   // always_ff
  reg[11:0] Error;   // ff
  reg[11:0] Fwd;     // ff
  reg[11:0] Intgrl;   // ff
  reg[15:0] Pcomp;    //ff
  reg[11:0] Icomp;    //ff
  wire [15:0] dst;      
  
  
reg multiply_counter;  //ff

  typedef enum  reg [4:0] {IDLE,STTL,INNER_R,MID_R,OUTER_R,SHRT_WAIT,INNER_L,MID_L,OUTER_L,INTG,ITERM,ITERM_WAIT,PTERM,PTERM_WAIT,MRT_R1,MRT_R2,MRT_L1,MRT_L2} state_t;
state_t state, next_state;
  
reg start_4096, start_32, rst_4096, rst_32, rst_mult, start_mult;

wire PWM_sig;  // output from PWM
  
// instantiate pwm and alu
  pwm_8 ipwm(.duty(duty),.clk(clk),.rst_n(rst_n),.PWM_sig(PWM_sig)); 
  
  alu alu(.mult2(mult2),.mult4(mult4),.sub(sub),.src1sel(src1sel),.src0sel(src0sel),.Accum(Accum),.Iterm(Iterm),.Error(Error),.Fwd(Fwd),.A2D_res(A2D_res),.Intgrl(Intgrl)
          ,.Icomp(Icomp),.Pcomp(Pcomp),.Pterm(Pterm),.multiply(multiply),.saturate(saturate),.dst(dst)); 
  
  // chnnl counter ff
  always_ff @(posedge clk, negedge rst_n) begin 
	if (!rst_n)
		chnnl_counter <= 0;
    else if (reset_chnnl) 
		chnnl_counter <= 0; 
    else if (inc_chnnl) 
		chnnl_counter <= chnnl_counter + 1;
  end 
  
  
  always_ff @(posedge clk, negedge rst_n) begin 
	if (!rst_n)
		Fwd <= 12'h000;
	else if (~go) // if go deasserted Fwd knocked down so
		Fwd <= 12'b000; // we accelerate from zero on next start.
	else if (dst2Int & ~&Fwd[10:8]) // 43.75% full speed
		Fwd <= Fwd + 1'b1;
  end 
  
  always_ff @(posedge clk, negedge rst_n) begin 
	if (!rst_n) begin
		rht_reg <= 12'h000;
  		lft_reg <= 12'h000;
    end
    else if (!go) begin
		rht_reg <= 12'h000;
  		lft_reg <= 12'h000;
    end
    else if (dst2rht)
		rht_reg <= dst[11:0];
    else if (dst2lft)
      lft_reg <= dst[11:0];
  end 
  
  
// State transition
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      state <= IDLE;
    end 
    else begin
      state <= next_state;
    end
end

  
  
//Registers for the ALU units
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
  	Error <= 0;
    Accum <= 0;
  	Intgrl <= 0;   
  	Pcomp <= 0;    
  	Icomp <= 0;    
  end
  else begin
    	
    if(dst2Err) 
      Error <= dst[11:0];
    
    else if(dst2Accum)
      Accum <= dst;
    
    else if(dst2Icmp)
      Icomp <= dst[11:0];
    
    else if(dst2Int)
      Intgrl <= dst[11:0]; 
    
    else if(dst2Pcmp)
      Pcomp <= dst;   
  	end
	
  end  

always_ff @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		multiply_counter <= 0;
    end else if(rst_mult) begin
		multiply_counter <= 0;
    end else if(start_mult)begin
		multiply_counter <= multiply_counter + 1;
	end
end
  
  
//Counter 4096
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
     counter_4096 <= 0;
  end else if(rst_4096) begin
     counter_4096 <= 0;
  end else if(start_4096)begin
     counter_4096 <= counter_4096 + 1;
  end
end

// Counter 32
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
     counter_32 <= 0;
  end else if(rst_32) begin
     counter_32 <= 0;
  end else if(start_32)begin
     counter_32 <= counter_32 + 1;
  end
end

  
always_comb begin
  //defalut cases
  ir_counter = 0;
  
  reset_chnnl = 0;
  inc_chnnl = 0;
  
  Iterm = 12'h500;
  Pterm = 14'h3680;
  
  start_4096 = 0;
  start_32 = 0;
  
  rst_4096 = 0;
  rst_32 = 0;
  
  
  //default registers for alu input
  mult2 = 0;
  mult4 = 0;
  sub = 0;
  src1sel = 3'b111; // default value is 0
  src0sel = 3'b111;
  multiply = 0;
  saturate = 0;
  // flags for reg
  dst2Accum = 0;
  dst2Icmp = 0;
  dst2Err = 0;
  dst2Int = 0;
  dst2Pcmp = 0;
  dst2lft = 0;
  dst2rht = 0;
  inc_chnnl = 0;
  reset_chnnl = 0;
  next_state = state;
  
  case(state)
    //default values 
    STTL:begin
    	start_4096 = 1; // is it in this state or previous state?  enable timer?
		
      	// **************  Enable PWM is not implemented  **********************
      	      	 
        if(counter_4096 == 12'd4096) begin// timer == 4096
            //A2D conversion
            start_conv = 1; //start conversion
        end
      
        if(cnv_cmplt)begin
              //based on chnnl counter, move to different state
         
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
          	else begin
              $stop ("Should have not happened");
            end
        end
   	end
    
    
   INNER_R:begin
   		//ALU  pls don't delete my code.... 
        src1sel = 3'b000; // Accum	
     	src0sel = 3'b111; // src0 should be 0
     	dst2Accum = 1;
     
		inc_chnnl = 1;
     	next_state = SHRT_WAIT;
	end
    
   MID_R:begin
		//Accum = Accum + A2D_res * 2;
      	src1sel = 3'b000; // Accum
      	src0sel = 3'b000; //a2d_res
      	mult2 = 1;
      	dst2Accum = 1; 
     
		next_state = SHRT_WAIT;
		inc_chnnl = 1;
	end
    
    OUTER_R:begin
		//Accum = Accum + A2D_res * 4;
      	src1sel = 3'b000; // Accum
      	src0sel = 3'b000; //a2d_res
      	mult4 = 1;
      	dst2Accum = 1;
      
		next_state = SHRT_WAIT;
		inc_chnnl = 1;
	end
    
	SHRT_WAIT:begin
		start_32 = 1;
      
      	if(counter_32 == 5'd32)begin
             start_conv = 1;
        end
      
        if(cnv_cmplt) begin
              if(chnnl_counter == 1)begin
                  next_state = INNER_L;
              end	
              else if(chnnl_counter == 3)begin
                  next_state = MID_L;
              end
              else if(chnnl_counter == 5)begin
                  next_state = OUTER_L;
              end
              else begin
              	  $stop ("Should have not happened");
              end
        end	
	end
      
	INNER_L:begin
		src1sel = 3'b000; // Accum
      	src0sel = 3'b000; //a2d_res
      	sub = 1;	// Accum = Accum - Ir_in_lft
      	dst2Accum = 1;
        
    	next_state = STTL;
		inc_chnnl = 1;
	end
	
	MID_L:begin
		//Accum = Accum - A2D_res * 2;
        src1sel = 3'b000; // Accum
      	src0sel = 3'b000; //a2d_res
      	sub = 1;
      	mult2 = 1;
      	dst2Accum = 1;
		
      	next_state = STTL;
		inc_chnnl = 1;
	end
    
    OUTER_L:begin
		src1sel = 3'b000; // Accum
      	src0sel = 3'b000; //a2d_res
      	sub = 1;
      	mult4 = 1; 
      	dst2Err = 1;
    
		next_state = INTG;
		inc_chnnl = 1;
	end
    
    
	INTG:begin
		src1sel = 3'b011; //ErrDiv22Src1
        src0sel = 3'b001; //Intgrl2Src0
		dst2Int = 1;      
		next_state = ITERM;
	end
    
	ITERM:begin
		src1sel  = 3'b001;
      	src0sel  = 3'b001;
      	multiply = 1;
        dst2Icmp = 1;
		next_state = ITERM_WAIT;
	end
    
    ITERM_WAIT:begin
      	dst2Icmp = 1;
      	next_state = PTERM;
    end  
    
	PTERM:begin
		src1sel = 3'b010; //Err2Src1		
      	src0sel = 3'b100; //Pterm2Src0
		multiply = 1;		
      
		next_state = PTERM_WAIT;
	end
    
    PTERM_WAIT:begin
      	dst2Pcmp = 1;
      	next_state = MRT_R1;
    end
    
	MRT_R1:begin
		//Accum = Fwd - Pcomp;
      	src1sel = 3'b100; //Fwd2Src1
      	src0sel = 3'b011;// Pcomp
      	sub = 1;
      	dst2Accum = 1;
		next_state = MRT_R2;
	end
    
	MRT_R2:begin
		//rht_reg = Accum - Icomp;
      	src1sel = 3'b000;
      	src0sel = 3'b010;
      	sub = 1;
      	dst2rht = 1;
		next_state = MRT_L1;
	end
    
	MRT_L1:begin
		//Accum = Fwd + Pcomp;
		next_state = MRT_L2;
	end
    
	MRT_L2:begin
		//lft_reg = Accum + Icomp;
      	src1sel = 3'b000;
      	src0sel = 3'b010;
      	dst2lft = 1;
		next_state = IDLE;
	end
    
	default:begin //IDLE state
		//Accum = 0
		
        if (chnnl_counter == 0) begin
              next_state = STTL;
              dst2Accum = 1;
        end
    end
  endcase 
end 

assign LEDs = Error[11:4];

//Drop the last bit to deal with the width difference
assign lft = lft_reg[11:1];
assign rht = rht_reg[11:1];

assign duty = 8'h8C;

//Chnnl assign
    assign chnnl = (chnnl_counter == 0) ? 1 :
      (chnnl_counter == 1) ? 0 : 
      (chnnl_counter == 2)? 4  :
      (chnnl_counter == 3)? 2 : 
      (chnnl_counter == 4) ? 3 :
      (chnnl_counter == 5) ? 7 :
      chnnl; 
  
  //IR enables
  assign IR_out_en =  (chnnl == 1 || chnnl == 0 ) ? 0 : 
    (chnnl == 4 || chnnl == 2 ) ? 0 : 
    (chnnl == 3 || chnnl == 7 ) ? PWM_sig : 
    IR_out_en;
  
  assign IR_mid_en =  (chnnl == 1 || chnnl == 0 ) ? 0 : 
    (chnnl == 4 || chnnl == 2 ) ? PWM_sig :
    (chnnl == 3 || chnnl == 7 ) ? 0 : 
    IR_mid_en;
  
  assign IR_in_en  =  (chnnl == 1 || chnnl == 0 ) ? PWM_sig :
    (chnnl == 4 || chnnl == 2 ) ? 0 : 
    (chnnl == 3 || chnnl == 7 ) ? 0 : 
    IR_in_en; 
    

=======
reg[13:0] Pterm;
reg[11:0] Iterm;
reg sub,mult2,mult4,multiply,saturate;
reg[2:0] src0sel,src1sel;
reg dst2Accum,dst2Err,dst2Int,dst2Icmp,dst2Pcmp,dst2lft,dst2rht;
reg[15:0] Accum;
reg[11:0] Error;
reg[11:0] Fwd;
reg[11:0] Intgrl;
reg[15:0] Pcomp;
reg[11:0] Icomp;
reg[15:0] dst;
reg multiply_counter;

typedef enum reg {IDLE,STTL,INNER_R,MID_R,OUTER_R,SHRT_WAIT,INNER_L,MID_L,OUTER_L,INTG,ITERM,PTERM,MRT_R1,MRT_R2,MRT_L1,MRT_L2} state_t;
state_t state, next_state;
logic 4096_start,32_start,4096_rst,32_rst,multiply_rst,multiply_start;
wire PWM_sig;
pwm pwm(.duty(duty),.clk(clk),.rst_n(rst_n),.PWM_sig(PWM_sig)); 
alu alu(.mult2(mult2),.mult4(mult4),.sub(sub),.src1sel(src1sel),.src0sel(src0sel),.Accum(Accum),.Iterm(Iterm),.Error(Error),.Fwd(Fwd),.A2D_res(A2D_res),.Intgrl(Intgrl)
	,.Icomp(Icomp),.Pcomp(Pcomp),.Pterm(Pterm),.multiply(multiply),.saturate(saturate),.dst(dst));
  
  
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      state <= WAIT;
    end else begin
      state <=next_state ;
    end
end

always_ff @(posedge clk or negedge rst_n) begin :
	if(!rst_n) begin
		multiply_counter <= 0;
	end else if(multiply_rst) begin
		multiply_counter <= 0;
	end else if(multiply_start)begin
		multiply_counter <= multiply_counter + 1;
	end
end
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
     4096_counter <= 0;
  end else if(4096_rst) begin
     4096_counter <= 0;
  end else if(4096_start)begin
     4096_counter <= 4096_counter + 1;
  end
end


always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
     32_counter <= 0;
  end else if(32_rst) begin
     32_counter <= 0;
  end else if(32_start)begin
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

assign LEds = Error[11:4];
assign lft = lft_reg[11:1];
assign rht = rht_reg[11:1];

 
>>>>>>> origin/master
endmodule