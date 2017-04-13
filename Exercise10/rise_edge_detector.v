module rise_edge_detector(next_byte, rst_n, clk, out);
input rst_n, clk, next_byte;
output wire  out;
reg Sig_FF1, Sig_FF2, Sig_FF3;

always @(posedge clk) begin

if(!rst_n) begin
  Sig_FF1 <= 1;
  Sig_FF2 <= 1;
  Sig_FF3 <= 1;
 end

/********************************************
* Sig is asynchronous and has to be double flopped *
* for meta-stability reasons prior to use ************
*********************************/
Sig_FF1 <= next_byte;
Sig_FF2 <= Sig_FF1; // double flopped meta-stability free
Sig_FF3 <= Sig_FF2; // flop again for use in edge detection
end
/**********************************************
* Start bit in protocol initiated by falling edge of Sig line *
**********************************************/
assign out = (Sig_FF2 && ~Sig_FF3) ? 1'b1 : 1'b0;

endmodule
