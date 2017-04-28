module  motion_cntrl_tb();
  

  logic clk, rst_n; 
  
  logic go, cnv_cmplt, strt_cnv, IR_in_en, IR_mid_en, IR_out_en;
  
  logic [10:0] lft, rht;
  logic [11:0]   A2D_res;  
  logic [2:0] chnnl;
  logic [7:0] LEDs;
    
    motion_cntrl iDUT(.go(go), .cnv_cmplt(cnv_cmplt), .A2D_res(A2D_res), .strt_cnv(strt_cnv), .chnnl(chnnl), .IR_in_en(IR_in_en), 
                    .IR_mid_en(IR_mid_en), .IR_out_en(IR_out_en), .LEDs(LEDs), .lft(lft), .rht(rht), .clk(clk), .rst_n(rst_n)
);



initial begin
		clk = 0;
		rst_n = 1'b0;

		go = 1'b0;
		cnv_cmplt = 1'b0;
		A2D_res = 12'b010101010110;
		@(posedge clk) rst_n = 1'b1;      // make rst_n low for a clk cycle

		///////////////read IR_in(chnnl 1, then chnnl 0)////////////////////
		go = 1'b1;

		@(posedge strt_cnv);
		repeat (3) @(posedge clk);
		cnv_cmplt = 1;
		repeat (2) @(posedge clk);
		cnv_cmplt = 0;



		@(posedge strt_cnv);
		repeat (3) @(posedge clk);
		cnv_cmplt = 1;
		A2D_res = 12'b01010000110;
		repeat (2) @(posedge clk);
		cnv_cmplt = 0;



		@(posedge strt_cnv);
		repeat (3) @(posedge clk);
		cnv_cmplt = 1;
		repeat (2) @(posedge clk);
		cnv_cmplt = 0;



		@(posedge strt_cnv);
		repeat (3) @(posedge clk);
		cnv_cmplt = 1;
		repeat (2) @(posedge clk);
		cnv_cmplt = 0;
	
	
		@(posedge strt_cnv);
		repeat (3) @(posedge clk);
		cnv_cmplt = 1;
		A2D_res = 12'b01010000110;
		repeat (2) @(posedge clk);
		cnv_cmplt = 0;


		@(posedge strt_cnv);
		repeat (3) @(posedge clk);
		cnv_cmplt = 1;
		A2D_res = 12'b01010000110;
		repeat (2) @(posedge clk);
		cnv_cmplt = 0;

		repeat (50) @(posedge clk);
		$stop;












	/*
		// #4 go = 1'b0;                      // assert go for a clk cycle
		@(posedge clk);

		if(IR_in_en == 1)
			$display("IR_in is enabled");
		else 
			$display("IR_in failed to enable");
		#564                               // The delay is to test PWM enable signal: Since the duty cycle is 0x8C, which is 140.
										// Since the clk period is 4, the time need to count to 140 is 560.//should be 0-0x8c, so 141 cycles
		if(IR_in_en == 0)
			$display("IR_in PWM is correct");
		else 
			$display("IR_in PWM is not correct");

		//#15820 
		repeat (4096)@(posedge clk);                             // wait for 4096 clk cycle to count to 4096 (timer is basically enabled when go is asserted. 
				// 4096*4 - 560 = 15824
		if(start_conv == 1'b1)
			$display("in_rht start successfully");
		else 
			$display("in_rht fail to start");

		if(chnnl == 3'b001)
			$display("chnnl 1 read correctly");
		else 
			$display("supposed to read chnnl 1, but reading %b now", chnnl);

		cnv_cmplt = 1'b1;
		#4                                 // assert cnv_cmplt for a clk cycle, duummy read, so conv_cmplt last 2 clock cycles
		A2D_res = 12'h001;
		#4 cnv_cmplt = 1'b0;
		#4 //one cycle for alu operation
		#128                               // wait for 32 clk cycle to count to 32
		if(start_conv == 1'b1)
			$display("in_lft start successfully");
		else 
			$display("in_lft fail to start");

		if(chnnl == 3'b000)
			$display("chnnl 0 read correctly");
		else 
			$display("supposed to read chnnl 0, but reading %b now", chnnl);

		cnv_cmplt = 1'b1;
		#4                // assert cnv_cmplt for a clk cycle
		A2D_res = 12'h002; 
		#4 cnv_cmplt = 1'b0;               // assert cnv_cmplt for a clk cycle
		///////////////read IR_mid(chnnl 4, then chnnl 2)////////////////////
		#4

		#16384                             // wait for 4096 clk cycle to count to 4096

		if(start_conv == 1'b1)
			$display("mid_rht start successfully");
		else 
			$display("mid_rht fail to start");

		if(chnnl == 3'b100)
			$display("chnnl 4 read correctly");
		else 
			$display("supposed to read chnnl 4, but reading %b now", chnnl);

		cnv_cmplt = 1'b1;
		#4                // assert cnv_cmplt for a clk cycle
		A2D_res = 12'h003;
		#4 cnv_cmplt = 1'b0;  
		#4
		#128                               // wait for 32 clk cycle to count to 32
		if(start_conv == 1'b1)
			$display("mid_lft start successfully");
		else 
			$display("mid_lft fail to start");

		if(chnnl == 3'b010)
			$display("chnnl 2 read correctly");
		else 
			$display("supposed to read chnnl 2, but reading %b now", chnnl);

		cnv_cmplt = 1'b1;
		#4                // assert cnv_cmplt for a clk cycle
		A2D_res = 12'h004; 
		#4 cnv_cmplt = 1'b0;  


		///////////////read IR_out(chnnl 3, then chnnl 7)////////////////////
		#4
		#16384                             // wait for 4096 clk cycle to count to 4096

		if(start_conv == 1'b1)
			$display("out_rht start successfully");
		else 
			$display("out_rht fail to start");

		if(chnnl == 3'b011)
			$display("chnnl 3 read correctly");
		else 
			$display("supposed to read chnnl 3, but reading %b now", chnnl);

		cnv_cmplt = 1'b1;
		#4               // assert cnv_cmplt for a clk cycle
		A2D_res = 12'h005;
		#4 cnv_cmplt = 1'b0;
		#4
		#128                               // wait for 32 clk cycle to count to 32
		if(start_conv == 1'b1)
			$display("out_lft start successfully");
		else 
			$display("out_lft fail to start");

		if(chnnl == 3'b111)
			$display("chnnl 7 read correctly");
		else 
			$display("supposed to read chnnl 7, but reading %b now", chnnl);

		cnv_cmplt = 1'b1;
		#4                // assert cnv_cmplt for a clk cycle
		A2D_res = 12'h006;
		#4 cnv_cmplt = 1'b0;

		#4
		#28
		#8                                 // wait for 2 extra clk cycle (no reason, just wait)

		////////////////////test if robot can stop correctly ////////////////////////////////////////
		//if(lft == 10'b0 && rht == 10'b0)
		//    $display("robot stops successfully");
		//else 
		//    $display("Error: robot are supposed to stop since go is deasserted");

		///////////////////test another iteration////////////////////////////////////////////////////
		///////////////read IR_in(chnnl 1, then chnnl 0)////////////////////
		go = 1'b1;
		if(IR_in_en == 1)
		$display("IR_in is enabled");
		else 
			$display("IR_in failed to enable");

		#4 go = 1'b0;                      // assert go for a clk cycle
		#568//#556                               // The delay is to test PWM enable signal: Since the duty cycle is 0x8C, which is 140.
										// Since the clk period is 4, the time need to count to 140 is 560.
		if(IR_in_en == 0)
		$display("IR_in PWM is correct");
		else 
			$display("IR_in PWM is not correct");

		#15820 //#15824                             // wait for 4096 clk cycle to count to 4096 (timer is basically enabled when go is asserted. 																	    4096*4 - 560 = 15824)

		if(start_conv == 1'b1)
			$display("in_rht start successfully");
		else 
			$display("in_rht fail to start");

		if(chnnl == 3'b001)
			$display("chnnl 1 read correctly");
		else 
			$display("supposed to read chnnl 1, but reading %b now", chnnl);

		cnv_cmplt = 1'b1;
		#4                // assert cnv_cmplt for a clk cycle
		A2D_res = 12'h001;
		#4 cnv_cmplt = 1'b0;

		#4

		#128                               // wait for 32 clk cycle to count to 32
		if(start_conv == 1'b1)
			$display("in_lft start successfully");
		else 
			$display("in_lft fail to start");

		if(chnnl == 3'b000)
			$display("chnnl 0 read correctly");
		else 
			$display("supposed to read chnnl 0, but reading %b now", chnnl);

		cnv_cmplt = 1'b1;
		#4                // assert cnv_cmplt for a clk cycle
		A2D_res = 12'h002; 
		#4 cnv_cmplt = 1'b0;

		$stop;
 
    
    */
    

  end
  
  
  
  
  


  always 
    clk = #2 ~clk;
 
  
  
endmodule