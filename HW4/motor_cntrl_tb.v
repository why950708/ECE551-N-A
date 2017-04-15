module moto_driver_tb();

reg clk, rst_n;
reg [10:0] lft, rht;

wire fwd_lft, rev_lft, fwd_rht, rev_rht; 

motor_cntrl mtr_ctrl (.clk(clk), .rst_n(rst_n), .lft(lft), .rht(rht), .fwd_lft(fwd_lft), .rev_lft(rev_lft), .fwd_rht(fwd_rht), .rev_rht(rev_rht));

initial begin
	clk = 0;
	rst_n = 0;
	repeat(10)@(posedge clk); 
	rst_n = 1;
	repeat(10)@(posedge clk);
	lft = 11'h400;
	rht = 11'h400;
	repeat(257)@(posedge clk);
	lft = 11'h100;
	rht = 11'h100;
	repeat(257)@(posedge clk);
	lft = 11'h0;
	rht = 11'h0;
	repeat(257) @(posedge clk);
	$stop;
	end
	

always @(clk)
	clk <= #5 ~clk;

endmodule	 