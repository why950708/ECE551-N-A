module UART_rcv_tb();  // Test bench for UART_tx, see the waveform for more info
reg clk,			// simulated clock
    rst_n, // synchronized reset
    RX,    // transmit start signal
    rx_rdy_clr; // clear rx_rdy
wire rx_rdy;	// from UART Transmitter

wire [7:0]   rx_data;  // Data received

//// Instantiate UART Transmitter ////
UART_rcv iDUT(.clk(clk), .rst_n(rst_n), .RX(RX), .rx_rdy_clr(rx_rdy_clr), .rx_data(rx_data), .rx_rdy(rx_rdy));

initial begin
    clk = 1;
    rst_n = 0;  
    RX = 1;  // High when idle
    rx_rdy_clr = 0;
    
    #3;
    rst_n = 1;  // Finish the reset
    repeat ( 110) @(posedge clk);   

    RX = 0;  // Start bit
    repeat ( 2604) @(posedge clk);   

    // bit 0:
    RX = 1;  
    repeat ( 2604) @(posedge clk);   

    //1
    RX = 0; 
    repeat ( 2604) @(posedge clk);   
    
    // bit 2:
    RX = 1;  
    repeat ( 2604) @(posedge clk);   

    // bit 3:
    RX = 1;  
    repeat ( 2604) @(posedge clk); 

    // bit 4:
    RX = 0; 
    repeat ( 2604) @(posedge clk);   
    
    // bit 5:
    RX = 1;  
    repeat ( 2604) @(posedge clk);   

    // bit 6:
    RX = 0;  
    repeat ( 2604) @(posedge clk);   
    
    // bit 7:
    RX = 1;  
    repeat ( 2604) @(posedge clk);   
    
    // bit STOP:
    RX = 1;  
    repeat ( 2604) @(posedge clk);   
    RX = 1;  
   
    repeat ( 1000) @(posedge clk);   
    rx_rdy_clr = 1;
    repeat ( 1000) @(posedge clk);   

    #1;

// answer should be 10101101
    $stop;
end

always begin
    #5 clk = ~clk;
end

endmodule