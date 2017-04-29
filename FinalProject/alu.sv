module alu (
    mult2, // If asserted, Source 0 is mulplied by 2
    mult4, //If asserted, Source 0 is mulplied by 4
    sub, //If asserted, subtract Source 0
    src1sel, // Source selection in mux 1
    src0sel, //Source selection in mux 0
    Accum, //Input from Accum register for building up error term
    Iterm, //Input that represents the I term in the PI control (constant)
    Error, //Input from Error register
    Fwd, //Input from Fwd register that determines forward speed (constant)
    A2D_res, //Input from A2D converter
    Intgrl, //Input from Intgrl register
    Icomp, //Input from Icomp register that represents the I component of PI control
    Pcomp, //Input from Pcomp register that represents the P component of PI control
    Pterm, // Input that represents the P term in the PI control (constant)
    multiply, // If asserted, result will be that of 12x12 multiply
    saturate, // If asserted, output is
    dst // Result of ALU
);

input [15:0] Accum, Pcomp;
input [13:0] Pterm;
input [11:0] Iterm, Error, Fwd, A2D_res, Intgrl, Icomp;
input  mult2, mult4, sub, multiply, saturate;
input [2:0] src1sel, src0sel;
output [15:0] dst;

//wire [15:0] Accum2Src1, Iterm2Src1, Err2Src1, ErrDiv22Src1, Fwd2Src1;
//wire [15:0] A2D2Src0, intgrl2Src0, Icomp2Src0, Pcomp2Src0, Pterm2Src0;


wire [15:0] adder, src0, scaled_temp, multiplySaturated, saturated;
wire signed [29:0] signedMultiplyResult;
wire signed [15:0] src1, scaled_src0;
wire signed [14:0] signed_scaled_src0, signed_src1;


localparam Accum2Src1 =  3'b000; //Accum;
localparam Iterm2Src1 =  3'b001; //{4'b0000, Iterm};
localparam Err2Src1 =    3'b010; //{{4{Error[11]}}, Error};
localparam ErrDiv22Src1= 3'b011; // {{8{Error[11]}},Error[11:4]};
localparam Fwd2Src1 =    3'b100; //{4'b0000,Fwd};

localparam A2D2Src0 =    3'b000; //{4'b0000,A2D_res};
localparam Intgrl2Src0 = 3'b001; //{{4{Intgrl[11]}},Intgrl};
localparam Icomp2Src0 =  3'b010; //{{4{Icomp[11]}},Icomp};
localparam Pcomp2Src0 =  3'b011; //Pcomp;
localparam Pterm2Src0 =  3'b100; //{2'b00,Pterm};

// Mux for src1
assign src1 = (src1sel == Accum2Src1)?   Accum:
              (src1sel == Iterm2Src1)?   {4'b0000, Iterm}:
              (src1sel == Err2Src1)?     {{4{Error[11]}}, Error}:
              (src1sel == ErrDiv22Src1)? {{8{Error[11]}},Error[11:4]}:
              (src1sel == Fwd2Src1)?     {4'b0000,Fwd}:
              {1'b0};


// Mux for src0
assign src0 = (src0sel == A2D2Src0)?     {4'b0000,A2D_res}:
              (src0sel == Intgrl2Src0)?  {{4{Intgrl[11]}},Intgrl}:
              (src0sel == Icomp2Src0)?   {{4{Icomp[11]}},Icomp}:
              (src0sel == Pcomp2Src0)?   Pcomp:
              (src0sel == Pterm2Src0)?   {2'b00,Pterm}:
              {1'b0};


// Temporary scaled, but haven't deal with sub
assign scaled_temp = mult2? {src0[14:0], 1'b0} :
                     mult4? {src0[13:0], 1'b0, 1'b0} :
                     src0;


// Flip the scalled src0, but don't add 1, it's added as carry in in Adder module
assign scaled_src0 = sub? ~scaled_temp : scaled_temp;


// Adder module with carry in from sub
assign adder = src1 + scaled_src0 + sub;


// Saturate module for adder
assign saturated = (~saturate)? adder:
                    (adder[15])?
                        ( (adder < 16'hF800)? 16'hF800: adder ) :

                        ( (adder > 16'h07FF)? 16'h07FF: adder);

// Multiply module
assign signed_scaled_src0 = scaled_src0[14:0];
assign signed_src1 = src1[14:0];

assign signedMultiplyResult = signed_scaled_src0 * signed_src1;

// Saturate module for multiply module

assign multiplySaturated = (signedMultiplyResult[29] )?
                        // This is negative
                        ( (~&signedMultiplyResult[28:26] )? 16'hC000: signedMultiplyResult[27:12] ) :
                        // It's positive, or all the bits to check if its all 0
                        ( ( |signedMultiplyResult[28:26])? 16'h3FFF:
                         signedMultiplyResult[27:12]);

assign dst = multiply ? multiplySaturated : saturated;




endmodule
