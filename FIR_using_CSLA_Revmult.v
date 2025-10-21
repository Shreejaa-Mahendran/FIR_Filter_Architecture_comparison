`timescale 1ps/1ns
module FIR_using_CSLA_Revmult (
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

module multiplier (
    input wire [7:0] a,
    input wire [7:0] b,
    output wire [15:0] out
);
    //assign out = a * b;
	revmult_8bit mult(out,a,b); // Simple combinational multiplication
endmodule

//adder module

module adder (
    input wire [15:0] a,
    input wire [15:0] b,
    output wire [15:0] sum
);

	 wire cout;
    carryselect_16bit adder(a,b,sum,cout);
	
endmodule

module
*/
module revmult_8bit(
	output [15:0]y,
	input [7:0]a,b
	);
wire [7:0]q0,q1,q2,q3,qa,qb;
wire c1,c2,c3;
wire sum1,carry1,sum2,carry2;
wire sum3,carry3,sum4,carry4;
revmult_4bit mult4_1(q0,a[3:0],b[3:0]);
revmult_4bit mult4_2(q1,a[3:0],b[7:4]);
revmult_4bit mult4_3(q2,a[7:4],b[3:0]);
revmult_4bit mult4_4(q3,a[7:4],b[7:4]);

revadd_8bit add8_1(qa,c1,q1,q2);
revadd_8bit add8_2(qb,c2,qa,{q3[3:0],q0[7:4]});
rev_or REV_ORGATE(c3,c1,c2);
rev_ha intermediate_add1(sum1,carry1,c3,q3[4]);
rev_ha intermediate_add2(sum2,carry2,carry1,q3[5]);
rev_ha intermediate_add3(sum3,carry3,carry2,q3[6]);
rev_ha intermediate_add4(sum4,carry4,carry3,q3[7]);

assign y[3:0] = q0[3:0];
assign y[11:4] = qb;
assign y[15:12] = {sum4,sum3,sum2,sum1};

endmodule



module revadd_8bit(
	output [7:0]s,
	output c8,
	input [7:0]a,b,
	input cin);
wire g0,g1,g2,g3,g4,g5,g6,g7;
wire g8,g9,g10,g11,g12,g13,g14,g15;
wire c1,c2,c3;
wire c4,c5,c6,c7;

hng HNG1(g0,g1,s[0],c1,a[0],b[0],cin,1'b0);
hng HNG2(g2,g3,s[1],c2,a[1],b[1],c1,1'b0);
hng HNG3(g4,g5,s[2],c3,a[2],b[2],c2,1'b0);
hng HNG4(g6,g7,s[3],c4,a[3],b[3],c3,1'b0);
hng HNG5(g8,g9,s[4],c5,a[4],b[4],c4,1'b0);
hng HNG6(g10,g11,s[5],c6,a[5],b[5],c5,1'b0);
hng HNG7(g12,g13,s[6],c7,a[6],b[6],c6,1'b0);
hng HNG8(g14,g15,s[7],c8,a[7],b[7],c7,1'b0);

endmodule




module revmult_4bit(
	output [7:0]y,
	input [3:0]a,b
	);
wire [3:0]q0,q1,q2,q3,qa,qb;
wire c1,c2,c3;
wire sum1,carry1,sum2,carry2;
revmult mult1(q0,a[1:0],b[1:0]);
revmult mult2(q1,a[3:2],b[1:0]);
revmult mult3(q2,a[1:0],b[3:2]);
revmult mult4(q3,a[3:2],b[3:2]);

revadd_4bit add1(qa,c1,q1,q2);
revadd_4bit add2(qb,c2,qa,{q3[1:0],q0[3:2]});
rev_or REV_ORGATE(c3,c1,c2);
rev_ha intermediate_ha1(sum1,carry1,c3,q3[2]);
rev_ha intermediate_ha2(sum2,carry2,carry1,q3[3]);

assign y[1:0] = q0[1:0];
assign y[5:2] = qb;
assign y[7:6] = {sum2,sum1};

endmodule



module revadd_4bit(
	output [3:0]s,
	output c4,
	input [3:0]a,b,
	input cin);
wire g0,g1,g2,g3,g4,g5,g6,g7;
wire c1,c2,c3;

hng HNG1(g0,g1,s[0],c1,a[0],b[0],cin,1'b0);
hng HNG2(g2,g3,s[1],c2,a[1],b[1],c1,1'b0);
hng HNG3(g4,g5,s[2],c3,a[2],b[2],c2,1'b0);
hng HNG4(g6,g7,s[3],c4,a[3],b[3],c3,1'b0);
endmodule



module rev_or(
	output out,
	input a,b);
wire g1,g2;
rmux1 RMUX1_OR_GATE(g1,g2,out,a,1'b0,b);
endmodule

module rev_ha(
	output sout,cout,
	input a,b);
wire g;
peres PERES_HALFADDER(g,sout,cout,a,b,1'b0);
endmodule
  
module revmult(
	output [3:0]q,
	input [1:0]a,b
	
	);
wire bvfw,bvfx,bvfy,bvfz;
wire bme1x,bme1y,bme1w,bme1z;
wire bme2x,bme2y,bme2w,bme2z;
wire peresw,peresx,peresy;
wire I0,I1;

bvf BVF_GATE(bvfw,bvfx,bvfy,bvfz,b[0],1'b0,b[1],1'b0);
assign I0 = bvfx;
assign I1 = bvfz;

bme BME1_GATE(bme1w,bme1x,bme1y,bme1z,a[0],bvfw,1'b0,bvfy);
assign q[0] = bme1x;

bme BME2_GATE(bme2w,bme2x,bme2y,bme2z,a[1],I0,1'b0,I1);

peres PERES_GATE(peresw,peresx,peresy,bme1y,bme2x,1'b0);
assign q[1] = peresx;

cnot CNOT_GATE(q[3],q[2],peresy,bme2y);
endmodule

module hng(w,x,y,z,a,b,c,d);
output w,x,y,z;
input a,b,c,d;
assign w = a;
assign x = b;
assign y = a^b^c;
assign z = ((a^b)&c)^(a&b)^d;
endmodule

module bme(w,x,y,z,a,b,c,d);
output w,x,y,z;
input a,b,c,d;
assign w = a;
assign x = (a&b)^c;
assign y = (a&d)^c;
assign z = ((~a)&b)^c^d;
endmodule

module rmux1(w,x,y,a,b,c);
output w,x,y;
input a,b,c;
assign w = a;
assign x = ((~a)&b)|(a&c);
assign y = ((~a)&c)|(a&(~b));
endmodule

module peres(w,x,y,a,b,c);
output w,x,y;
input a,b,c;
assign w = a;
assign x = a^b;
assign y = (a&b)^c;
endmodule

module bvf(w,x,y,z,a,b,c,d);
output w,x,y,z;
input a,b,c,d;
assign w = a;
assign x = a^b;
assign y = c;
assign z = c^d;
endmodule

module cnot(w,x,a,b);
output w,x;
input a,b;
assign w = a;
assign x = a^b;
endmodule

  module carryselect_16bit(
	input [15:0]a,b,
	//output [16:0]sum
	output [15:0]sum,
	output c4
	);
	
	wire c1,c2,c3;
	//wire c4;
	carryselect_4bit add1(a[3:0],b[3:0],1'b0,sum[3:0],c1);
	carryselect_4bit add2(a[7:4],b[7:4],c1,sum[7:4],c2);
	carryselect_4bit add3(a[11:8],b[11:8],c2,sum[11:8],c3);
	carryselect_4bit add4(a[15:12],b[15:12],c3,sum[15:12],c4);
	//assign sum[16]=c4;
endmodule

  module carryselect_4bit
        (   input [3:0] A,B,
            input cin,
            output [3:0] S,
            output cout
            );
        

wire [3:0] temp0,temp1,carry0,carry1;

//for carry 0
full_adder fa00(A[0],B[0],1'b0,temp0[0],carry0[0]);
full_adder fa01(A[1],B[1],carry0[0],temp0[1],carry0[1]);
full_adder fa02(A[2],B[2],carry0[1],temp0[2],carry0[2]);
full_adder fa03(A[3],B[3],carry0[2],temp0[3],carry0[3]);

//for carry 1
full_adder fa10(A[0],B[0],1'b1,temp1[0],carry1[0]);
full_adder fa11(A[1],B[1],carry1[0],temp1[1],carry1[1]);
full_adder fa12(A[2],B[2],carry1[1],temp1[2],carry1[2]);
full_adder fa13(A[3],B[3],carry1[2],temp1[3],carry1[3]);

//mux for carry
multiplexer2 mux_carry(carry0[3],carry1[3],cin,cout);
//mux's for sum
multiplexer2 mux_sum0(temp0[0],temp1[0],cin,S[0]);
multiplexer2 mux_sum1(temp0[1],temp1[1],cin,S[1]);
multiplexer2 mux_sum2(temp0[2],temp1[2],cin,S[2]);
multiplexer2 mux_sum3(temp0[3],temp1[3],cin,S[3]);

endmodule 

module full_adder
        (   input a,b,cin,
            output sum,carry
            );

assign sum = a ^ b ^ cin;
assign carry = (a & b) | (cin & b) | (a & cin);

endmodule

module multiplexer2
        (   input i0,i1,sel,
            output reg bitout
            );

always@(i0,i1,sel)
begin
if(sel == 0)
    bitout = i0;
else
    bitout = i1; 
end

endmodule

