// Handsome? 
module cmd_contrl(
 
  cmd,  //Command received
  cmd_rdy, //Indicates command is ready
  clr_cmd_rdy, //Clears cmd_rdy
  in_transit, //Froms enable to proximity sensor
  OK2Move, //Low if there’s an obstacle and has to stop. (See diagram in previous page.)
  go, //Tells motion controller to move forward. (See diagram in previous page)
  buzz, //To piezo buzzer. 4KHz when obstacle detected.(See diagram in previous page)
  buzz_n, //Inversion of buzz. (Piezo buzzer is driven by a differential pair.)
  clr_ID_vld, //Clears ID_vld
//Inversion of buzz
  ID_vld, 
  ID, //Station ID
  clk, //50Mhz system clk
  rst_n
  );

input [7:0] cmd, ID;
input cmd_rdy, OK2Move, ID_vld;
input clk, rst_n;

reg [5:0] dest_ID;  // stores the destination ID
reg update_dest_ID;  // flag to update the destination ID


output reg  clr_cmd_rdy,  in_transit, clr_ID_vld, buzz;
output wire buzz_n, go;


assign go = in_transit && OK2Move; 
assign en = ~OK2Move && in_transit;

assign  buzz_n = ~buzz;
  

typedef enum reg {STOP, GO} state_t;
state_t state, next_state;

    
//12500
reg [13:0] counter; 
      
// Logic for the buzz counter:
  always_ff @(posedge clk, negedge rst_n) begin
    if(~rst_n) begin 
    	counter <= 13'd12500;
      	buzz <= 0;
    end 
    else begin
      buzz <= 0;
      if (en) begin
          counter <= counter - 1;
      end
      else if (counter == 0) begin // reset the counter 
      		counter <= 13'd12500;  
        	buzz <= 1; // 
       
      end
      else begin
          counter <= counter; //  
      end
    end
  end
    
// Logic for dest_ID flip flop
always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n)begin
        dest_ID <= 0;
    end
    else if (update_dest_ID) begin
        dest_ID <= cmd[5:0];
    end
    else begin
        dest_ID <= dest_ID;
    end
end


    
always_ff @(posedge clk, negedge rst_n) begin 
      if(!rst_n) begin
      state <= STOP;
//           bit_cnt <= 0;
//           duration_cnt <= 0;
//           shift_reg <= 0;
//           timing_cnt <= 0;
      end
      else begin
//           bit_cnt <= bit_counter_val;
//           duration_cnt <= duration_counter_val;
//           timing_cnt <= timing_counter_val;
//           shift_reg <= shift_reg_val;
      state <= next_state;     
      end
  end

  
always_comb begin
  //defaults
  next_state = STOP;  
  clr_cmd_rdy = 0;
  in_transit = 0;
  //go = 0;  should be in a separate assign
  //buzz = 0;
  //buzz_n = 1;
  clr_ID_vld = 0;
  update_dest_ID = 0;
  case(state) 
	STOP:begin
        if(cmd_rdy==1 && (cmd[7:6] == 2'b01)) begin //cmd_rdy cmd == go && cmd_rdy
          next_state = GO;
          //dest_ID = cmd[5:0];
          update_dest_ID = 1;
          in_transit = 1;
        end

        else if(~cmd_rdy || (cmd_rdy& cmd[7:6] != 2'b01)) begin  //cmd != rdy ||  cmd != go)
            next_state = STOP;
            clr_cmd_rdy =1;
        end
      
    end
    
    default:begin //GO state
        next_state = GO;
        if(cmd_rdy && (cmd[7:6] != 2'b01) && (cmd[7:6] ==2'b00) )begin 
          next_state = STOP;
          clr_cmd_rdy = 1;
          in_transit = 0;
        end
        else if(ID == dest_ID && ID_vld)begin
              clr_ID_vld = 1;
              in_transit = 0;
          end

        else if(ID_vld && ID !=dest_ID)begin
          clr_ID_vld = 1;
        end

        else if(cmd_rdy && cmd == 2'b01 ) begin
          clr_cmd_rdy = 1;
          //dest_ID = cmd[5:0];
          update_dest_ID = 1;
        end

    end
  endcase
        
  
end
      
endmodule