module pwm ( duty, clk, rst_n, PWM_sig);

input [9:0] duty;  // PWM duty, unsigned
input clk, rst_n; // Clock and synchronized reset
output reg PWM_sig;  // PWM signal

wire rst_n; // Synchronized reset

reg [9:0] cnt; // 10 bit counter



always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin 
        PWM_sig <= 0; // Reset the PWM signal
        cnt <= 0;     // also reset the count
    end
    else begin
    // reset is not pressed
        if (cnt <= duty) begin
            PWM_sig <= 1;
        end
        else begin
            PWM_sig <= 0;
        end
        cnt <= cnt + 1;  // always increment count as long as not async reset

    end
end

endmodule
