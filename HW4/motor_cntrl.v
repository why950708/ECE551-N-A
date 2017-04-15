module motor_cntrl(clk, rst_n, lft, rht, 
fwd_lft, rev_lft, //left motor 
fwd_rht, rev_rht //right motor
);

input clk, rst_n;
input [10:0] lft, rht;
	
output wire fwd_lft, rev_lft, fwd_rht, rev_rht;
	
//wire [9:0] mag_lft, mag_rht;
wire PWM_left, PWM_right;

//assign mag_lft = lft[9:0];0
//assign mag_rht = rht[9:0];
	
pwm pwm_lft(.clk(clk), .rst_n(rst_n), .duty(lft[9:0]), /*magnitude*/ .PWM_sig(PWM_left));
pwm pwm_rht(.clk(clk), .rst_n(rst_n), .duty(rht[9:0]), /*magnitude*/ .PWM_sig(PWM_right));
	

	
assign fwd_lft = lft[10] ? 0 : 
				 (|lft)  ? PWM_left : 1;
assign rev_lft = lft[10] ? ~PWM_left :
				 (|lft)  ?   0      :1;  
		
assign fwd_rht = rht[10] ? 0 : 
				 (|lft)  ? PWM_right : 1;
assign rev_rht = rht[10] ? ~PWM_right : 
				 (|lft)  ?   0       :1;
	

endmodule
