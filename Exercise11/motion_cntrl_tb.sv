module  motion_cntrl_tb();
  

  logic clk, rst_n; 
  
  logic go, cnv_cmplt, start_conv, IR_in_en, IR_mid_en, IR_out_en;
  
  logic [10:0] lft, rht;
  logic [11:0]   A2D_res;  
  logic [2:0] chnnl;
    
    motion_cntrl iDut(.go(go), .cnv_cmplt(cnv_cmplt), .A2D_res(A2D_res), .start_conv(start_conv), .chnnl(chnnl), .IR_in_en(IR_in_en), 
                    .IR_mid_en(IR_mid_en), .IR_out_en(IR_out_en), .LEDs(LEDs), .lft(lft), .rht(rht), .clk(clk), .rst_n(rst_n)
);
  
  initial begin
    clk = 0;
  	rst_n = 0;
  	
    repeat (5) @(negedge clk);
  	rst_n = 1;
    
    repeat (100) @(negedge clk);
    A2D_res = 12'd2323;
    
    repeat (1000000) @(negedge clk);
    cnv_cmplt = 1;
    
    repeat (1000000) @(negedge clk);
    cnv_cmplt = 0;
    
    repeat (100000) @(negedge clk);
    cnv_cmplt = 1;
    
    repeat (1000000) @(negedge clk);
    cnv_cmplt = 0;
    
    

    
 
    
    
    

  end
  
  
  
  
  


  always 
    clk = #5 ~clk;
 
  
  
endmodule