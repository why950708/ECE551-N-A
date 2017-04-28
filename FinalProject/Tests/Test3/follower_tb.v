module Follower_tb();

reg clk,rst_n;			// 50MHz clock and active low aysnch reset
reg OK2Move;
reg send_cmd,send_BC;
reg [7:0] cmd,Barcode;
reg clr_buzz_cnt;

wire a2d_SS_n, SCLK, MISO, MOSI;
wire rev_rht, rev_lft, fwd_rht, fwd_lft;
wire IR_in_en, IR_mid_en, IR_out_en;
wire buzz, buzz_n, prox_en, BC, TX_dbg;
wire [7:0] led;
wire [3:0] buzz_cnt,buzz_cnt_n;
wire [13:0] high_time;

localparam STOP = 8'h00;
localparam GO = 8'h40;

//////////////////////
// Instantiate DUT //
////////////////////
Follower iDUT(.clk(clk),.RST_n(rst_n),.led(led),.a2d_SS_n(a2d_SS_n),
              .SCLK(SCLK),.MISO(MISO),.MOSI(MOSI),.rev_rht(rev_rht),.rev_lft(rev_lft),.fwd_rht(fwd_rht),
			  .fwd_lft(fwd_lft),.IR_in_en(IR_in_en),.IR_mid_en(IR_mid_en),.IR_out_en(IR_out_en),
			  .in_transit(in_transit),.OK2Move(OK2Move),.buzz(buzz),.buzz_n(buzz_n),.RX(RX),.BC(BC));		
			  
//////////////////////////////////////////////////////
// Instantiate Model of A2D converter & IR sensors //
////////////////////////////////////////////////////
ADC128S iA2D(.clk(clk),.rst_n(rst_n),.SS_n(a2d_SS_n),.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI));

/////////////////////////////////////////////////////////////////////////////////////
// Instantiate 8-bit UART transmitter (acts as Bluetooth module sending commands) //
///////////////////////////////////////////////////////////////////////////////////
uart_tx iTX(.clk(clk),.rst_n(rst_n),.tx(RX),.strt_tx(send_cmd),.tx_data(cmd),.tx_done(cmd_sent));

//////////////////////////////////////////////
// Instantiate barcode mimic (transmitter) //
////////////////////////////////////////////
barcode_mimic iMSTR(.clk(clk),.rst_n(rst_n),.period(22'h1000),.send(send_BC),.station_ID(Barcode),.BC_done(BC_done),.BC(BC));

//////////////////////////////////////
// Instantiate buzz counter module //
////////////////////////////////////
buzz_counter iBCNTR(.clk(clk), .rst_n(rst_n), .buzz(buzz), .buzz_n(buzz_n), .clr_cnt(clr_buzz_cnt), .cnt(buzz_cnt),
                    .cnt_n(buzz_cnt_n), .high_time(high_time));

				
initial begin
  initialize;					// call initialization task

  send_command(GO | 8'h01);			// send command to go to station 1

  repeat(1000) @(negedge clk);		// Wait a bit for follower to start
  
  if (in_transit == 1'b0)
    begin
	  $display("ERROR: follower should be in transit now");
	  $stop;
	end

  repeat(10000) @(negedge clk);
  
  OK2Move = 0;
  
  repeat(1000) @(negedge clk);
  
  clr_buzz_cnt = 1;
  @(negedge clk);
  clr_buzz_cnt = 0;
  repeat(50000) @(negedge clk);
  if ((buzz_cnt<2) || (buzz_cnt_n<2))
    begin
      $display("ERROR: buzzer should be buzzing");
      $stop;
    end
  if ((high_time<6200) || (high_time>6300))
    begin
      $display("WARNING: Buzz toggling, but duty cycle of buzz not 50\n");
	  $stop;
	end
	
  $display("YAHOO! Test3 passed");
  $stop();
end

always
  #1 clk = ~ clk;
  
task initialize;
  begin
    clk = 0;
    rst_n = 0;
    OK2Move = 1;
    send_cmd = 0;
    send_BC = 0;
	clr_buzz_cnt = 0;
    @(posedge clk);
    @(negedge clk);
    rst_n = 1;
  end
endtask

task send_command;
  input [7:0] CMD;

  begin
    repeat(1000) @(negedge clk);
    cmd = CMD;
    send_cmd = 1;
    @(negedge clk);
    send_cmd = 0;
    @(posedge cmd_sent);
  end
endtask

task send_stationID;
  input [7:0] ID;
  
  begin
    @(negedge clk);
    Barcode = ID;
    send_BC = 1;
    @(negedge clk);
    send_BC = 0;
    @(posedge BC_done);
  end
endtask
  
  
endmodule