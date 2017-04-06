module UART_test_tb ();

wire [7:0] out;
reg key, RST_n, clk;



UART_test iDUT (.clk (clk), .RST_n (RST_n), .next_byte (key), .LEDs(out));

always 
    #1 clk = ~clk;

initial begin
    
    RST_n = 0;
    key = 0;
    clk = 0;

    repeat ( 26040 ) @(posedge clk);   
    RST_n = 1;
    repeat ( 26040 ) @(posedge clk);   
    key = 1;
    repeat ( 26040 ) @(posedge clk);   
    key = 0;
        repeat ( 26040 ) @(posedge clk);   

        key = 1;
            repeat ( 26040 ) @(posedge clk);   
            key = 0;
                        repeat ( 26040 ) @(posedge clk);   

$stop;
end
endmodule