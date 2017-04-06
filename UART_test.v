module UART_test(clk,RST_n,next_byte,LEDs);

input clk,RST_n;	// 50MHz clock & unsynched active low reset from push button
input next_byte;	// active low unsynched push button to send next byte over UART

output [7:0] LEDs;	// received byte of LEDs will be displayed over LEDs

reg [7:0] cnt;
wire RX,send_next;

//// Instantiate reset synchronizer ////
reset_synch iRST(.clk(clk), .RST_n(RST_n), .rst_n(rst_n));

//// Make or instantiate a push button release detector /////


//// Instantiate your UART_tx...data to transmit comes from 8-bit counter ////


//// Instantiate your UART_rx...output byte should be connected to LEDs[7:0] ////


//// Make or instantiate an 8-bit counter to provide data to test with /////


	
endmodule
