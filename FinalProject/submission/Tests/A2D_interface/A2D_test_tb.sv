module A2D_test_tb();


reg clk;
reg RST_n;
reg nxt_chnnl;
wire [7:0] LEDs;

A2D_test iA2D_test(.clk(clk),.RST_n(RST_n),.nxt_chnnl(nxt_chnnl),.LEDs(LEDs));

initial 
begin
clk = 1'b0;
RST_n=1'b1;

@(negedge clk) RST_n = 1'b0;
@(negedge clk) RST_n = 1'b1;

repeat (5) @(negedge clk) nxt_chnnl = 1'b0;
repeat (3) @(negedge clk) nxt_chnnl = 1'b1;
repeat (5) @(negedge clk) nxt_chnnl = 1'b0;
repeat (3) @(negedge clk) nxt_chnnl = 1'b1;
repeat (5) @(negedge clk) nxt_chnnl = 1'b0;
repeat (3) @(negedge clk) nxt_chnnl = 1'b1;
repeat (5) @(negedge clk) nxt_chnnl = 1'b0;
repeat (3) @(negedge clk) nxt_chnnl = 1'b1;
repeat (2) @(posedge iA2D_test.cnv_cmplt);
 
#1000;


 /*
repeat (5) @(negedge clk) nxt_chnnl = 1'b0;
repeat (3) @(negedge clk) nxt_chnnl = 1'b1;


repeat (600) @(negedge clk); 
repeat (3) @(negedge clk) nxt_chnnl = 1'b0; 
repeat (3) @(negedge clk) nxt_chnnl = 1'b1;

repeat (600) @(negedge clk); 
repeat (3) @(negedge clk) nxt_chnnl = 1'b0; 
repeat (3) @(negedge clk) nxt_chnnl = 1'b1;

repeat (600) @(negedge clk); 
repeat (3) @(negedge clk) nxt_chnnl = 1'b0; 
repeat (3) @(negedge clk) nxt_chnnl = 1'b1;

repeat (600) @(negedge clk); 
repeat (3) @(negedge clk) nxt_chnnl = 1'b0; 
repeat (3) @(negedge clk) nxt_chnnl = 1'b1;

repeat (600) @(negedge clk);
*/


$stop;

end

always begin
#5 clk = ~clk;
end


endmodule
