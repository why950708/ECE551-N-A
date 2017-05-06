module A2D_intf_tb ();

reg strt_cnv, clk, rst_n;
reg [2:0] chnnl;

reg [11:0] mem[0:7];
reg [11:0] key, resp;
integer i;


wire cnv_cmplt;
wire [11:0] res;

// Wire between A2D_intf to ADC128S
wire a2d_SS_n, SCLK, MOSI, MISO;


A2D_intf iA2D (.clk (clk), .rst_n(rst_n), .strt_cnv(strt_cnv), .cnv_cmplt(cnv_cmplt),
                .chnnl(chnnl), .res(res), .a2d_SS_n (a2d_SS_n), .SCLK(SCLK), .MOSI(MOSI), .MISO(MISO));

ADC128S iADC (.clk(clk),.rst_n(rst_n), .SS_n(a2d_SS_n), .SCLK(SCLK),
              .MISO(MISO),.MOSI(MOSI));


initial begin
    clk = 0;
    strt_cnv = 0;
    chnnl = 0;
    rst_n = 0;
    resp = 0;
    i = 0;
    key = 0;
    $readmemh("analog.dat", mem);

    #10 rst_n = 1;

    for ( i = 0  ; i <= 7; i++) begin
        key = mem[i];  
        
        chnnl = i[2:0];

        strt_cnv = 1;
        @(negedge clk);
        @(negedge clk);
        repeat (500) @(posedge clk);  // just wait for about 500 cycles

        strt_cnv = 0;

        @(posedge cnv_cmplt);

        repeat (100) @(posedge clk);  // Wait before the next transmission for 100 cycles

        strt_cnv = 1;
        @(negedge clk);
        @(negedge clk);

        strt_cnv = 0;

        @(posedge cnv_cmplt);
        
        resp = ~res;

        repeat (100) @(posedge clk);  // Wait before the next transmission for 100 cycles

    
        if ( key != resp)begin
            $display("i is %d, Correct is %h, my resp is %h.", i, key, resp);
            $stop;
        end
    end

    $display("All tests passed.");
    $stop;


end



always begin
    #5 clk =  ~clk;
end




endmodule