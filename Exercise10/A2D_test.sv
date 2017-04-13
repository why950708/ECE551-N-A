module A2D_test(clk,RST_n,nxt_chnnl,LEDs, a2d_SS_n, MOSI, SCLK, MISO);
input clk,RST_n;		// 50MHz clock and active low unsynchronized reset from push button
input nxt_chnnl;		// unsynchronized push button.  Advances to convert next chnnl
output reg [7:0] LEDs;		// upper bits of conversion displayed on LEDs

input  MISO;
output a2d_SS_n, MOSI, SCLK;

/*
wire a2d_SS_n;		// Active low slave select to A2D (part of SPI bus)
wire MOSI;			// Master Out Slave In to A2D (part of SPI bus)
wire MISO;				// Master In Slave Out from A2D (part of SPI bus)
wire SCLK;			// Serial clock of SPI bussS
*/

///////////////////////////////////////////////////
// Declare any registers or wires you need here //
/////////////////////////////////////////////////
wire [11:0] res;		// result of A2D conversion
wire cnv_cmplt;
reg [5:0] cnv_counter;  // 5:0
reg conv;

wire sync_button;

reg [2:0] chnnl;
reg strt_cnv;
wire rst_n;

/////////////////////////////////////
// Instantiate Reset synchronizer //
///////////////////////////////////
reset_synch iRST(.clk(clk), .RST_n(RST_n), .rst_n(rst_n));

////////////////////////////////
// Instantiate A2D Interface //
//////////////////////////////
A2D_intf iA2D(.clk(clk), .rst_n(rst_n), .strt_cnv(strt_cnv), .cnv_cmplt(cnv_cmplt), .chnnl(chnnl),
              .res(res), .a2d_SS_n(a2d_SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));


////////////////////////////////////////
// Synchronize nxt_chnnl push button //
//////////////////////////////////////
rise_edge_detector re(.next_byte(nxt_chnnl), .rst_n(rst_n), .clk(clk), .out(sync_button));
 
///////////////////////////////////////////////////////////////////
// Implement method to increment channel and start a conversion //
// with every release of the nxt_chnnl push button.            //
////////////////////////////////////////////////////////////////
always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        chnnl <= 0  ;   // !!!!!!!!!!!!!!!!!!!!!!   0
    end
    else if (sync_button)begin
        chnnl <= chnnl + 1;
    end
    else begin
        chnnl <= chnnl;

    end

end


always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		strt_cnv <= 1;
		conv <= 0;
        LEDs <= 0;
	end
	
	else if(cnv_cmplt) begin
        LEDs <= res[11:4];
        conv <= 1;
    end
	else if(cnv_counter == 6'd32) begin
		strt_cnv <= 1;
		conv <= 0;
	end
	else begin
        strt_cnv <= 0;
        //conv <= conv;
    end	
end

always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		cnv_counter <= 6'b0;
	end
    else if (conv)
        cnv_counter <= cnv_counter + 1;
    else
        cnv_counter <= 6'b0; 
end

	
//////////////////////////////////////////////////////////
// Demo 1: ADC128S                                      //
//////////////////////////////////////////////////////////

//ADC128S  ADC128S_0(.clk(clk), .rst_n(rst_n), .SS_n(a2d_SS_n), .SCLK(SCLK), .MISO(MISO), .MOSI(MOSI));


//////////////////////////////////////////////////////////////////////////
// Demo 2: ADC128S                                           			//
// Modify this file and .qsf to connect to the physical ADC. 			//
// - Remove the instantiation of ADC128S.                   			//
// - Add SPI ports to the top module and map them to pins in .qsf file. //
//////////////////////////////////////////////////////////////////////////

//assign
//	LEDs = res[11:4];

endmodule
    
