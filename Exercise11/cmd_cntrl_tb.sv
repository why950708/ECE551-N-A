
module cmd_contrl_tb();
  reg clk;
  
  reg [7:0] cmd;  //Command received
  reg cmd_rdy; //Indicates command is ready
  wire clr_cmd_rdy; //Clears cmd_rdy
  wire in_transit;//Froms enable to proximity sensor
  reg OK2Move; //Low if there’s an obstacle and has to stop. (See diagram in previous page.)
  wire go; //Tells motion controller to move forward. (See diagram in previous page)
  wire buzz; //To piezo buzzer. 4KHz when obstacle detected.(See diagram in previous page)
  wire buzz_n; //Inversion of buzz. (Piezo buzzer is driven by a differential pair.)
  
  reg [7:0] ID //Station ID
  reg ID_vld; 
  wire clr_ID_vld;//Clears ID_vld
  
  //wires connecting between different components
  
 
  // iDUT
  cmd_contrl iDUT (.cmd(cmd), .cmd_rdy(cmd_rdy), .clr_cmd_rdy(clr_cmd_rdy), .in_transit(in_transit),
                   .OK2Move(OK2Move), .go(go), .buzz(buzz), .buzz_n(buzz_n),.clr_ID_vld(clr_ID_vld), 
                   .ID_vld(ID_vld), .ID(ID), .clk(clk))
	
  //Instantiate UART_receiver maybe use the uart_send.
  //Instantiate barcode ? 

initial begin
	rst_n = 0;
  //clr_cmd_rdy = 0;
  cmd_rdy = 0;
  OK2Move = 1;
  cmd= 8'b00111111; //cmd not ready and the dest_ID is equal to 111111
  
  ID = 0;
  ID_vld = 0;

  repeat (5) @ (negedge clk);
	rst_n = 1;
  cmd_rdy = 1;
	cmd= 8'b01111111; //cmd = go  and the dest_ID is equal to 111111
  //Simulate UART_rcv
  //repeat (5) @ (negedge clk);
  @ (posedge clr_cmd_rdy);
  cmd_rdy = 0;
  //cmd[7:6] = 2'b00; //cmd rdy to false to simulate the uart transmittion period
  
  repeat (5) @ (negedge clk);
  ID_vld = 1;
  ID = 8'b01100000 //False station ID so the car should not stop
  
  @ (posedge clr_ID_vld);
  ID_vld = 0;
  
  //repeat (5) @ (negedge clk);
  //cmd_rdy //cmd_rdy to false to stop the car to wait for the transmittion
  //ID_vld = 0;
  
  repeat (5) @ (negedge clk);
  ID_vld = 1;
  ID = 8'b001111111; //Correct station ID so the car should stop and in_transit shoud be false;
  
  // Supposed to stop
  @(negedge in_transit);
  
  
  
  
  // Restart the next run;
  cmd_rdy = 1;
	cmd= 8'b01001111; //cmd = go  and the dest_ID is equal to 111111
	
  repeat (5) @ (negedge clk);
  ID_vld = 1;
  ID = 8'b0010000000 //False station ID so the car should not stop
  
  @ (posedge clr_ID_vld);
  ID_vld = 0;
  
  
  
  cmd_rdy = 1;
	cmd= 8'b01011111; //cmd = go  and the dest_ID is equal to 00011111
  
  ///////////////////////////Destination ID:   011,111   ///////////////////////////////////
  repeat (5) @ (negedge clk);
  ID_vld = 1;
  //Although ID equals first cmd, since the cmd is updated, the car should keep going
  ID = 8'b00001111 ; 
  
  @ (posedge clr_ID_vld);
  ID_vld = 0;
  
  repeat (5) @ (negedge clk);
  ID_vld = 1;
  ID = 8'b00011111;  // ID = destination ID, car should stop
  
    
  @ (posedge clr_ID_vld);
  ID_vld = 0;
  
  @ (negedge in_transit);
  // car should stop
  
  @ (posedge clk);
    if (in_transit != 0) begin
      $stop("Should already stop and exit");
	  end
  
  
    
end

  // clk 
always 
	clk = #5 ~clk;

endmodule