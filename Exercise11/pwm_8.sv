module pwm_8(clk, rst_n, duty, PWM_sig);
input clk, rst_n;
input [7:0] duty;

//PWM as a flip flop
output reg PWM_sig;

    
reg [7:0] count;

//Counter flip flop
always @(posedge clk, negedge rst_n) begin
	if(!rst_n) 
	    count <= 0;
	else 
	    count <= count + 1;
    end

//PWM flip flop
always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
           PWM_sig <=  0;
			else if (count < duty)
			PWM_sig <= 1;
			else
			PWM_sig <= 0;
 end
endmodule