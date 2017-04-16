module barcode_tb();
logic rst_n, BC_done, BC, send, ID_vld, clr_ID_vld, clk;
logic [21:0] period;
logic [7:0] station_ID, ID;

//Initilize the barcode_mimic
  barcode_mimic bm (.clk(clk),.rst_n(rst_n),.period(period), .send(send), .station_ID(station_ID), .BC_done(BC_done), .BC(BC));
//Initilize the barcode iDUT
  barcode barcode(.clk(clk), .rst_n(rst_n), .ID_vld(ID_vld), .clr_ID_vld(clr_ID_vld), .ID(ID), .BC(BC));

initial begin
    station_ID = 8'h1A;
    rst_n = 0;
    period = 22'd1024; 
  	clk = 1;
    clr_ID_vld = 0;
    send = 0;
end
  
always begin
  
  @(negedge clk); 
    rst_n = 0;
    @(negedge clk);
    rst_n = 1;
    
    send = 1;
    @(negedge clk);
    @(negedge clk);

    send = 0;
  	//Wait until BC_done

    @(posedge BC_done); // PERFECT!
 		//$monitor(ID == station_ID);
     
    // display two values and stop simulation if two are different 
  	if(ID != station_ID ) begin
      
      $display("station ID is %h, received:  %h", station_ID, ID);
      $stop;
    end

    if (ID_vld != 1 && ( ~|station_ID[7:6])) begin
      $display("ID_vld wrong!");
      $stop;
    end

    if((station_ID == 0 )) begin
        $display ("all tests passed!!");
        $stop;
    end
 		//Test different values
    clr_ID_vld = 1;
		station_ID = station_ID << 1;
    repeat (5) @(posedge clk);
    if(ID_vld == 1) begin
      $display ("ID_vld not deasserted!!");
      $stop;
    end
    clr_ID_vld = 0;
end

  // clk
always begin
  clk = #5 ~clk;
end
  
  // OK???
  // ???compile???
  // GOOD?
endmodule