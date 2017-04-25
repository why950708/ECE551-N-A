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
  
  reg [7:0] ID; //Station ID
  reg ID_vld; 
  wire clr_ID_vld;//Clears ID_vld
  
  reg rst_n;
  //wires connecting between different components
  
 
  // iDUT
  cmd_contrl iDUT (.cmd(cmd), .cmd_rdy(cmd_rdy), .clr_cmd_rdy(clr_cmd_rdy), .in_transit(in_transit),
                   .OK2Move(OK2Move), .go(go), .buzz(buzz), .buzz_n(buzz_n),.clr_ID_vld(clr_ID_vld), 
                   .ID_vld(ID_vld), .ID(ID), .clk(clk), .rst_n (rst_n) );
	
  //Instantiate UART_receiver maybe use the uart_send.
  //Instantiate barcode ? 

initial begin
	rst_n = 0;   
  //clr_cmd_rdy = 0;
  cmd_rdy = 0;
  OK2Move = 1;
  cmd= 8'b00111111; //cmd not ready and the dest_ID is equal to 111111
  clk = 0;
  ID = 0;
  ID_vld = 0;
  repeat (5) @ (negedge clk);
	rst_n = 1;

  // Finished the reset, should not move
  repeat (2) @ (negedge clk);
  
  cmd_rdy = 1;	

  // Still should not move
  repeat (3) @ (negedge clk);
  //@ (posedge clr_cmd_rdy);
  cmd_rdy = 0;
  repeat (2) @(negedge clk);
	
  cmd= 8'b01111111; //cmd = go  and the dest_ID is equal to 111111
  repeat (2) @(negedge clk);
  cmd_rdy = 1;
  // Now it should move, into go state

  //repeat (2) @ (negedge clk);

  //Simulate UART_rcv
  //repeat (5) @ (negedge clk);
  @ (posedge clr_cmd_rdy);
  @ (negedge clk);

  cmd_rdy = 0;

  
  repeat (5) @ (negedge clk);
  // Test cmd= rdy and new go command;
  cmd_rdy = 1;
  cmd = 8'b01001111;  // Now the new destinatio is 001111
    
  @ (posedge clr_cmd_rdy);
  repeat (2) @(negedge clk);
  cmd_rdy = 0;

  repeat (5) @ (negedge clk);


  // Now test the process that ID is valid but not the destination
  ID = 8'b01100000; //False station ID so the car should not stop
  ID_vld = 1;

  @ (posedge clr_ID_vld);
  @(negedge clk);

  ID_vld = 0;

  
  //repeat (5) @ (negedge clk);
  //cmd_rdy //cmd_rdy to false to stop the car to wait for the transmittion
  //ID_vld = 0;
  
  repeat (5) @ (negedge clk);
  ID_vld = 1;
  ID = 8'b00001111; //Correct station ID so the car should stop and in_transit shoud be false;
  
  // Supposed to stop
  @(negedge in_transit);

  repeat (10) @ (negedge clk);
  // Now the next run!!!  //////////////////////////////////////
    
  
  cmd_rdy = 1;
	cmd= 8'b01000011; //cmd = go  and the dest_ID is equal to 000011, we test cmd = stop
	
  @ (posedge clr_cmd_rdy);
  @ (negedge clk);
  cmd_rdy = 0;
  
  repeat (5) @ (negedge clk);
  cmd_rdy = 1;
  cmd = 8'b00000000;  // cmd = stop;
  @ (negedge in_transit);
  // the car should stop 
  repeat (10) @ (negedge clk);

  
  $stop();
end

  // clk 
always 
	clk = #5 ~clk;

endmodule