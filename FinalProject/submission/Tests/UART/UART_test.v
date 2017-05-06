module UART_test(clk,RST_n,next_byte,LEDs);

input clk,RST_n;	// 50MHz clock & unsynched active low reset from push button
input next_byte;	// active low unsynched push button to send next byte over UART

output [7:0] LEDs;	// received byte of LEDs will be displayed over LEDs

reg [7:0] cnt;
wire out; // output from rising edge detector
wire data; // rx and tx
reg rx_rdy_clr = 0;

//// Instantiate reset synchronizer ////
reset_synch iRST(.clk(clk), .RST_n(RST_n), .rst_n(rst_n));

//// Make or instantiate a push button release detector /////
rise_edge_detector button(.next_byte(next_byte), .rst_n(rst_n), .clk(clk), .out(out));
	

//// Instantiate your UART_tx...data to transmit comes from 8-bit counter ////
UART_tx tx (.clk(clk), .rst_n(rst_n), .trmt(out),  .TX(data), .tx_data(cnt));  // tx_done not connected


//// Instantiate your UART_rx...output byte should be connected to LEDs[7:0] ////
UART_rcv rx (.clk(clk), .rst_n(rst_n), .RX(data), .rx_data(LEDs), .rx_rdy_clr(rx_rdy_clr) ); //rx_rdy_clr(rx_rdy_clr),.rx_rdy(rx_rdy)


//// Make or instantiate an 8-bit counter to provide data to test with /////
	// logic for cnt;
	always @(posedge clk or negedge rst_n) begin
		if(~rst_n ) begin
			cnt <= 8'b00000001;   // Setting 1 here, will make sure the value sent to tx_data starts with 1, so we won't have to press twice for the first light to be on after reset.
		end
		else if (out)
            cnt <= cnt + 1;
		else 
			cnt <= cnt;
	end
	

endmodule
