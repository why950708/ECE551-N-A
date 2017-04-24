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
typedef enum reg {IDLE,STTL,INNER_R,MID_R,OUTER_R,SHRT_WAIT,INNER_L,MID_L,OUTER_L,INTG,ITERM,PTERM,MRT_R1,MRT_R2,MRT_L1,MRT_L2} state_t;
state_t state, next_state;
logic 4096_start,32_start;

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




  case(state)
    IDLE: begin

    next_state = CACL;


    end
    CACL: begin
    4096_start = 1; // is it in this state or previous state?  enable timer?
    if(4096_counter == 12'd4096) begin// timer == 4096
      //A2D conversion
      if(cnv_cmplt)begin
        //addition
      end
    end
      4096_start = 0; //clear timer
     chnnl = chnnl + 1;

    32_start = 1;
    if(32_counter == 5'd32)begin
      //A2Dconverison
      if(cnv_cmplt)begin
        //subtraction
      end
    end
      32_start = 0;
      chnnl = chnnl + 1;


      if(chnnl == 6)begin
        next_state = UPDATE;
       end 
    end
    UPDATE: begin
      //update
    end

    default:begin // wait state
      chnnl = 0;  // i am wondering if is that possible these two lines could be in default output area in this always_comb?
      Accum = 0;
    end
  endcase // state
end 

 
endmodule