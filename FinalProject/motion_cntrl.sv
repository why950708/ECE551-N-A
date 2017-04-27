module motion_cntrl (
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
input clk, rst_n;

output reg start_conv;
output reg [2:0] chnnl;
output wire IR_in_en, IR_out_en, IR_mid_en;  // PWM output
output wire [10:0] lft, rht;
output wire [7:0] LEDs;

 
  
reg[11:0] lft_reg, rht_reg;
  
reg[12:0] counter_4096;
reg[5:0] counter_32;
  
reg rst_chnnl,  inc_chnnl;

wire[7:0] duty;
reg[2:0] chnnl_counter;
reg ir_counter;

//alu related regs
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

reg inc_4096, inc_32, rst_4096, rst_32, rst_mult, start_mult;

  
reg multiply_counter;  //ff


typedef enum reg [4:0] {IDLE,STTL,INNER_R,MID_R,OUTER_R,SHRT_WAIT,INNER_L,MID_L,OUTER_L,INTG,ITERM,ITERM_WAIT,PTERM,PTERM_WAIT,MRT_R1,MRT_R2,MRT_L1,MRT_L2} state_t;
state_t state, next_state;
  

wire PWM_sig;  // output from PWM
  
// instantiate pwm and alu
pwm_8 iPWM(.duty(duty),.clk(clk),.rst_n(rst_n),.PWM_sig(PWM_sig)); 
  
alu iALU(.mult2(mult2),.mult4(mult4),.sub(sub),.src1sel(src1sel),.src0sel(src0sel),.Accum(Accum),.Iterm(Iterm),.Error(Error),.Fwd(Fwd),.A2D_res(A2D_res),.Intgrl(Intgrl)
          ,.Icomp(Icomp),.Pcomp(Pcomp),.Pterm(Pterm),.multiply(multiply),.saturate(saturate),.dst(dst)); 
  

// chnnl counter ff
always_ff @(posedge clk, negedge rst_n) begin 
	if (!rst_n)
		chnnl_counter <= 0;
	else if (rst_chnnl) 
		chnnl_counter <= 0; 
	else if (inc_chnnl) 
		chnnl_counter <= chnnl_counter + 1;
end 

  
// FF for Fwd
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
    if(!rst_n) 
		state <= IDLE;
    else
		state <= next_state;
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
  end else if(inc_4096)begin
     counter_4096 <= counter_4096 + 1;
  end
end

// Counter 32
always_ff @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
     counter_32 <= 0;
  end else if(rst_32) begin
     counter_32 <= 0;
  end else if(inc_32)begin
     counter_32 <= counter_32 + 1;
  end
end

  
always_comb begin
<<<<<<< HEAD
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
      src1sel = 3'b000; // Accum2Src1： 0
     	src0sel = 3'b000; // A2D2Src0
     	dst2Accum = 1;
     
		  inc_chnnl = 1;
     	next_state = SHRT_WAIT;
	end
    
   MID_R:begin
		//Accum = Accum + A2D_res * 2;
      	src1sel = 3'b000; // Accum2Src1
      	src0sel = 3'b000; //A2D2Src0
      	mult2 = 1;
      	dst2Accum = 1; 
     
		next_state = SHRT_WAIT;
		inc_chnnl = 1;
	end
    
    OUTER_R:begin
		//Accum = Accum + A2D_res * 4;
      	src1sel = 3'b000; // Accum2Src1
      	src0sel = 3'b000; //A2D2Src0
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
		src1sel = 3'b000; // Accum2Src1
      	src0sel = 3'b000; //A2D2Src0
      	sub = 1;	// Accum = Accum - Ir_in_lft
      	dst2Accum = 1;
        
    	next_state = STTL;
		inc_chnnl = 1;
	end
	
	MID_L:begin
		//Accum = Accum - A2D_res * 2;
        src1sel = 3'b000; // Accum2Src1
      	src0sel = 3'b000; //A2D2Src0
      	sub = 1;
      	mult2 = 1;
      	dst2Accum = 1;
		
      	next_state = STTL;
		inc_chnnl = 1;
	end
    
    OUTER_L:begin
		src1sel = 3'b000; // Accum2Src1
      	src0sel = 3'b000; //A2D2Src0
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
		src1sel  = 3'b001; // Iterm2Src1
      	src0sel  = 3'b001; //Intgrl2Src0
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
    dst2Pcmp = 1;  
		next_state = PTERM_WAIT;
	end
    
    PTERM_WAIT:begin
      	dst2Pcmp = 1;
      	next_state = MRT_R1;
    end
    
	MRT_R1:begin
		//Accum = Fwd - Pcomp;
      	src1sel = 3'b100; //Fwd2Src1
      	src0sel = 3'b011;// Pcomp2Src0
      	sub = 1;
      	dst2Accum = 1;
		next_state = MRT_R2;
	end
    
	MRT_R2:begin
		//rht_reg = Accum - Icomp;
      	src1sel = 3'b000; // Accum2Src1
      	src0sel = 3'b010; // Icomp2Src0
      	sub = 1;
      	dst2rht = 1;
		next_state = MRT_L1;
	end
    
	MRT_L1:begin
		//Accum = Fwd + Pcomp;
    src1sel = 3'b100; // Fwd2Src1
    src0sel = 3'b011; // Pcomp2Src0
    dst2Accum = 1;
		next_state = MRT_L2;
	end
    
	MRT_L2:begin
		//lft_reg = Accum + Icomp;
      	src1sel = 3'b000; // Accum2Src1
      	src0sel = 3'b010; // Icomp2Src0
      	dst2lft = 1;
		next_state = IDLE;
	end
    
	default:begin //IDLE state
		//Accum = 0
=======
	//defalut cases
	ir_counter = 0;
	
	rst_chnnl = 0;
	inc_chnnl = 0;
	
	Iterm = 12'h500;
	Pterm = 14'h3680;
	
	inc_4096 = 0;
	inc_32 = 0;
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
	rst_chnnl = 0;
	next_state = state;
	
	case(state)
		
		STTL:begin
			inc_4096 = 1; // is it in this state or previous state?  enable timer?
			
			// **************  Enable PWM is not implemented  **********************
					
			if(counter_4096 == 12'd4095) begin// Wait 4096 clk until conv
				start_conv = 1; //start A2D conversion, high for 1 clk 
			end
		
			if(cnv_cmplt) begin
				//based on chnnl counter, move to different state
			
				if ( chnnl_counter == 3'd0 ) 
					next_state = INNER_R;
				else if(chnnl_counter == 3'd2) 
					next_state = MID_R;
				else if(chnnl_counter == 3'd4) 
					next_state =  OUTER_R;
				else 
					$stop ("Should have not happened");

			end
		end
		
		
		INNER_R: begin
			// Accum should be 0 now!
			// Accum = A2D
			src1sel = 3'b000; // Accum	
			src0sel = 3'b111; // src0 should be 0
			dst2Accum = 1;

			inc_chnnl = 1;  // chnnl should be 1 in next state
			next_state = SHRT_WAIT;
			rst_32 = 1;
		end
		
		MID_R: begin
			//Accum = Accum + A2D_res * 2;
			src1sel = 3'b000; // Accum
			src0sel = 3'b000; //a2d_res
			mult2 = 1;
			dst2Accum = 1; 
		
			next_state = SHRT_WAIT;
			inc_chnnl = 1;
			rst_32 = 1;

		end
	
		OUTER_R:begin
			//Accum = Accum + A2D_res * 4;
			src1sel = 3'b000; // Accum
			src0sel = 3'b000; //a2d_res
			mult4 = 1;
			dst2Accum = 1;
		
			next_state = SHRT_WAIT;
			inc_chnnl = 1;
			rst_32 = 1;

		end
	
		SHRT_WAIT: begin
			inc_32 = 1;
		
			if(counter_32 == 5'd31)begin  // at 32th state start conv
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
		
		INNER_L: begin
			src1sel = 3'b000; // Accum
			src0sel = 3'b000; //a2d_res
			sub = 1;	// Accum = Accum - Ir_in_lft
			dst2Accum = 1;
			
			next_state = STTL;
			inc_chnnl = 1;
			rst_4096 = 1;  // !!!
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
			rst_4096 = 1;  // !!!

		end
		
		OUTER_L:begin
			src1sel = 3'b000; // Accum
			src0sel = 3'b000; //a2d_res
			sub = 1;
			mult4 = 1; 
			dst2Err = 1;
		
			next_state = INTG;
			inc_chnnl = 1;  // chnnl should equal to 6

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
>>>>>>> 7cdcefca799a47d5294228c939b383bfd995f33a
		
		default:begin //IDLE state
			//Accum = 0
			
			if (chnnl_counter == 0) begin
				next_state = STTL;
				dst2Accum = 1;
				rst_4096 = 1;
				rst_chnnl = 1;
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
    

endmodule