module SPI_mstr_tb();
reg wrt, clk, rst_n;

reg [15:0] cmd;

wire [15:0] rd_data;
wire done, MOSI, SS_n, SCLK, MISO, rdy;


SPI_slave iDUT2(.clk(clk), .rst_n(rst_n), .SS_n(SS_n), .MOSI(MOSI),
                .MISO(MISO), .rdy(rdy), .SCLK(SCLK)
                );

SPI_mstr iDUT (.wrt(wrt), .cmd(cmd), .done(done), 
                .rd_data(rd_data), .SCLK(SCLK),
                .MOSI(MOSI), .MISO(MISO), .SS_n(SS_n),
                .clk(clk), .rst_n(rst_n)
);


initial begin
    wrt = 0;
    cmd = 16'hDCBA;
    clk = 0;
    rst_n = 0;

    #5;
    rst_n = 1;
    #10;
    wrt = 1;
    @(negedge clk);
    @(posedge clk);
    wrt = 0;
    repeat (520) @(posedge clk); // Should wait 512 clock for transmission

    $stop;
    
end

always begin
    #5 clk = ~clk;
end

endmodule
