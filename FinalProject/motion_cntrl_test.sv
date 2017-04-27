module  motion_cntrl_test();
  logic clk, rst_n; 
  
  logic go, cnv_cmplt, start_conv, IR_in_en, IR_mid_en, IR_out_en;
  
  logic [10:0] lft, rht;
  logic [11:0]   A2D_res;  
  logic [2:0] chnnl;
    
    motion_cntrl iDut(.go(go), .cnv_cmplt(cnv_cmplt), .A2D_res(A2D_res), .start_conv(start_conv), .chnnl(chnnl), .IR_in_en(IR_in_en), 
                    .IR_mid_en(IR_mid_en), .IR_out_en(IR_out_en), .LEDs(LEDs), .lft(lft), .rht(rht), .clk(clk), .rst_n(rst_n)
);

localparam station1 = 8'b00010101;
localparam station2 = 8'b00101010;
localparam station3 = 8'b00111111;
// +  invalid?  station ?
localparam GO_SIG_1 = 8'b01010101;
localparam GO_SIG_2 = 8'b01101010;
localparam GO_SIG_3 = 8'b01111111;
localparam STOP_SIG = 0;
// clk 
always
	clk = #5 ~clk; 

initial begin
cmd_rdy = 0;
cmd = 0;
ID = station1;  
OK2Move = 1; 
rst_n = 0;
@(negedge clk);
rst_n = 1;
@(negedge clk);
// Test1: Sends GO command to station1. Checks that the in_transit signal is set.
cmd_rdy = 1;
cmd = GO_SIG_1;
@(negedge clk);
if(~in_transit) 
	$stop("Test1 gua le");

// Test2: Sends GO command to station1. Then sends a station2 barcode, follower should not stop. 
// Then sends a station 1 barcode. Follower should stop and braking controls should be applied.
@(negedge clk);
cmd = GO_SIG_1;
ID = station2;  
@(negedge clk);
if(~go)
	$stop("Test2: station2 gua le")
ID = station1;  
@(negedge clk);
	$stop("Test2: station1 gua le")


// Test3: Sends GO command to station1. Checks that the in_transit signal is set.
// Then deasserts OK2Move. Checks that the buzzer signals start toggling.
@(negedge clk);
cmd = GO_SIG_1;
if(~in_transit) 
	$stop("Test3 gua le");

// Test4: Sends Go command to station1. Uses analog.dat and checks that first calc is
// zero, and 2nd is full left

//Test5: Uses a 2nd version of analog.dat (analog2.dat) Checks 2nd and 4th values
// for non-railed PWM output

// Test6: Runs for a long time with a DC error term. Used to check if Iterm is having
// an effect.

//Test7: Sends GO command to station1. Then sends a go command to station3.
//then sends a station1 barcode, follower should not stop. Then sends station1
//barcode...should stop.

end  