`timescale 1ps/1ns
module filterdesign4bit_carrysave (
    input wire clk,
    input wire rst,
    input wire [7:0] data_in,
    output wire [15:0] data_out
);
    wire [7:0] shift_reg [7:0]; // Shift register storage
    wire [15:0] mult_out [7:0]; // Multiplier outputs
    wire [15:0] sum_stage [5:0]; // Sum stages

    // 8 tap coefficients (Fixed values, can be changed)
    wire [7:0] coeffs [7:0];
    assign coeffs[0] = 8'd15;
    assign coeffs[1] = 8'd15;
    assign coeffs[2] = 8'd15;
    assign coeffs[3] = 8'd15;
    assign coeffs[4] = 8'd15;
    assign coeffs[5] = 8'd15;
    assign coeffs[6] = 8'd15;
    assign coeffs[7] = 8'd15;

    // Shift Register using D Flip-Flops
    d_flip_flop dff0 (clk, rst, data_in, shift_reg[0]);
    d_flip_flop dff1 (clk, rst, shift_reg[0], shift_reg[1]);
    d_flip_flop dff2 (clk, rst, shift_reg[1], shift_reg[2]);
    d_flip_flop dff3 (clk, rst, shift_reg[2], shift_reg[3]);
    d_flip_flop dff4 (clk, rst, shift_reg[3], shift_reg[4]);
    d_flip_flop dff5 (clk, rst, shift_reg[4], shift_reg[5]);
    d_flip_flop dff6 (clk, rst, shift_reg[5], shift_reg[6]);
    d_flip_flop dff7 (clk, rst, shift_reg[6], shift_reg[7]);

    // Multiplication with coefficients
    multiplier mult0 (shift_reg[0], coeffs[0], mult_out[0]);
    multiplier mult1 (shift_reg[1], coeffs[1], mult_out[1]);
    multiplier mult2 (shift_reg[2], coeffs[2], mult_out[2]);
    multiplier mult3 (shift_reg[3], coeffs[3], mult_out[3]);
    multiplier mult4 (shift_reg[4], coeffs[4], mult_out[4]);
    multiplier mult5 (shift_reg[5], coeffs[5], mult_out[5]);
    multiplier mult6 (shift_reg[6], coeffs[6], mult_out[6]);
    multiplier mult7 (shift_reg[7], coeffs[7], mult_out[7]);

    // Adder tree structure
    adder add0 (mult_out[0], mult_out[1], sum_stage[0]);
    adder add1 (mult_out[2], mult_out[3], sum_stage[1]);
    adder add2 (mult_out[4], mult_out[5], sum_stage[2]);
    adder add3 (mult_out[6], mult_out[7], sum_stage[3]);

    adder add4 (sum_stage[0], sum_stage[1], sum_stage[4]);
    adder add5 (sum_stage[2], sum_stage[3], sum_stage[5]);

    adder add6 (sum_stage[4], sum_stage[5], data_out);

endmodule

//dflipflop module

module d_flip_flop (
    input wire clk,
    input wire rst,
    input wire [7:0] d,
    output wire [7:0] q
);
    reg [7:0] q_reg;
    assign q = q_reg;
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            q_reg <= 8'b00000000;
        else
            q_reg <= d;
    end
endmodule

//multipllier module

module multiplier (
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [15:0] out
);
    //assign out = a * b;
	vedic8x8_carrysave mult(a,b,out); // Simple combinational multiplication
endmodule

//adder module

module adder (
    input wire [15:0] a,
    input wire [15:0] b,
    output wire [15:0] sum
);

	 wire cout;
    carrysave_16bit ripplecarryadder(a,b,sum,cout);
	 //assign sum=a+b;
endmodule

//ripple carry 16 bit for instantiation

module carrysave_16bit(
	input [15:0]a,b,
	//output [16:0]sum
	output [15:0]sum,
	output c4
	);
	
	wire c1,c2,c3;
	//wire c4;
	carrysave_4bit add1(a[3:0],b[3:0],1'b0,sum[3:0],c1);
	carrysave_4bit add2(a[7:4],b[7:4],c1,sum[7:4],c2);
	carrysave_4bit add3(a[11:8],b[11:8],c2,sum[11:8],c3);
	carrysave_4bit add4(a[15:12],b[15:12],c3,sum[15:12],c4);
	//assign sum[16]=c4;
endmodule

	
	
//vedic 8 bit multiplier for instantiation

module vedic8x8_carrysave(
input [7:0]a,b,
output [15:0]product
);

wire [7:0]m1,m2,m3,m4;//multiplier outputs for each 
wire [7:0]m5,m6,m7;//adder outputs
wire ca1,ca2,ca3;//carry outputs
wire hasum,hacarry;

vedic4x4 mult1(a[3:0],b[3:0],m1);
vedic4x4 mult2(a[3:0],b[7:4],m2);
vedic4x4 mult3(a[7:4],b[3:0],m3);
vedic4x4 mult4(a[7:4],b[7:4],m4);

//adding
carrysave_8bit adder1(m2,m3,m5,ca1);
carrysave_8bit adder2(m5,{4'b0000,m1[7:4]},m6,ca2);
half_adder halfadd(ca1,ca2,hasum,hacarry);
carrysave_8bit adder3(m4,{2'b00,hacarry,hasum,m6[7:4]},m7,ca3);
assign product[3:0]=m1[3:0];
assign product[7:4]=m6[3:0];
assign product[15:8]=m7;

endmodule



module vedic4x4(a,b,p);
input[3:0]a,b;
output[7:0]p;
wire [3:0]p1,p2,p3,p4;
wire c1,c2;
wire [3:0]sum1,sum2,sum3;
wire s,c;
//output of vedic multplier 2x2
vedic_2x2 v1(a[1:0],b[1:0],p1);
vedic_2x2 v3(a[1:0],b[3:2],p3);
vedic_2x2 v2(a[3:2],b[1:0],p2);
vedic_2x2 v4(a[3:2],b[3:2],p4);
//
carrysave_4bit rca1(p3,p2,1'b0,sum1,c1);
carrysave_4bit rca2(sum1,{2'b00,p1[3:2]},1'b0,sum2,c2);
half_adder ha(c1,c2,s,c);
carrysave_4bit rca3(p4,{c,s,sum2[3:2]},1'b0,p[7:4],c3);
assign p[3:2]=sum2[1:0];
assign p[1:0]=p1[1:0];
endmodule

module vedic_2x2 (
    input [1:0] A, // 2-bit multiplicand
    input [1:0] B, // 2-bit multiplier
    output [3:0] p // 4-bit product
);
    //wire p0, p1, p2, p3; // Partial product terms
    wire carry1,carry2,carry3; // Crosswise terms and carry
    // Step 1: Vertical Multiplication (LSBs)
    assign {carry1,p[0]} = A[0] & B[0];
    // Step 2: Crosswise Multiplication and Summation
    assign w1 = (A[0]&B[1]);
    assign w2 = (A[1]&B[0]);
    full_adder f1(w1,w2,carry1,p[1],carry2);
    // Step 3: Vertical Multiplication (MSBs)
    assign w3 = (A[1]&B[1]);
    half_adder h1(w3,carry2,p[2],p[3]);
endmodule

module carrysave_8bit(
	input [7:0] a, b,
	output [7:0] sum,
	output cout
	);
	wire c1;
	carrysave_4bit add1(a[3:0], b[3:0], 1'b0, sum[3:0], c1);
	carrysave_4bit add2(a[7:4], b[7:4], c1, sum[7:4], cout);
endmodule

module carrysave_4bit(
    input [3:0] A,
    input [3:0] B,
    input cin, 
    output [3:0] sum,
    output Cout
);

    wire [6:0] carry;
    wire [2:0] partial_sum; 
	 wire w;

    full_adder fa1(A[0], B[0], cin,sum[0], carry[0]); 
    half_adder ha1(A[1], B[1],partial_sum[0], carry[1]);
    half_adder ha2(A[2], B[2],partial_sum[1], carry[2]);
    half_adder ha3(A[3], B[3],partial_sum[2], carry[3]);
    half_adder ha4(carry[0], partial_sum[0],sum[1], carry[4]);
    full_adder fa2(carry[1], partial_sum[1], carry[4],sum[2], carry[5]);
    full_adder fa3(carry[2], partial_sum[2], carry[5],sum[3], carry[6]);
    half_adder ha5(carry[3], carry[6],Cout, w);

endmodule
 

module full_adder(a,b,cin,sum,carry);
input a,b,cin;
output sum,carry;
wire w1,w2,w3;
half_adder h1(a,b,w1,w2);
half_adder h2(w1,cin,sum,w3);
assign carry=w2|w3;
endmodule

module half_adder(a,b,s,c);
input a,b;
output s,c;
xor g0(s,a,b);
and g1(c,a,b);
endmodule