`timescale 1ps/1ns
module FIR_using_KSA_Revmult (
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
	revmult_8bit mult(out,a,b); // Simple combinational multiplication
endmodule

//adder module

module adder (
    input wire [15:0] a,
    input wire [15:0] b,
    output wire [15:0] sum
);

	 wire cout;
    ksa_16 ksa(a,b,sum,cout);
	 //assign sum=a+b;
endmodule

//ripple carry 16 bit for instantiation

module ksa_16(
  //input  wire        c0,
  input  wire [15:0] i_a,
  input  wire [15:0] i_b,
  output wire [15:0] o_s,
  output wire        o_carry
);

wire [15:0] p1;
wire [15:0] g1;
wire        c1;

wire [14:0] p2;
wire [15:0] g2;
wire        c2;
wire [15:0] ps1;

wire [12:0] p3;
wire [15:0] g3;
wire        c3;
wire [15:0] ps2;

wire [8:0]  p4;
wire [15:0] g4;
wire        c4;
wire [15:0] ps3;

ks_1 s1(c0, i_a, i_b, p1, g1, c1);
ks_2 s2(c1, p1, g1, c2, p2, g2, ps1);
ks_3 s3(c2, p2, g2, ps1, c3, p3, g3, ps2);
ks_4 s4(c3, p3, g3, ps2, c4, p4, g4, ps3);
ks_5 s5(c4, g4, ps3, o_s, o_carry);

endmodule

module ks_5(
  input  wire        i_c0,
  input  wire [15:0] i_gk,
  input  wire [15:0] i_p_save,
  output wire [15:0] o_s,
  output wire        o_carry
);

assign o_carry = i_gk[15];
assign o_s = i_p_save ^ {i_gk[14:0], i_c0};

endmodule

module ks_4(
  input  wire        i_c0,
  input  wire [12:0] i_pk,
  input  wire [15:0] i_gk,
  input  wire [15:0] i_p_save,
  output wire        o_c0,
  output wire [8:0]  o_pk,
  output wire [15:0] o_gk,
  output wire [15:0] o_p_save
);

wire [12:0] gkj;
wire [8:0]  pkj;

assign o_c0      = i_c0;
assign o_p_save  = i_p_save;
assign gkj[0]    = i_c0;
assign gkj[12:1] = i_gk[11:0];
assign pkj       = i_pk[8:0];
assign o_gk[2:0] = i_gk[2:0];

grey gc_0(gkj[0], i_pk[0], i_gk[3], o_gk[3]);
grey gc_1(gkj[1], i_pk[1], i_gk[4], o_gk[4]);
grey gc_2(gkj[2], i_pk[2], i_gk[5], o_gk[5]);
grey gc_3(gkj[3], i_pk[3], i_gk[6], o_gk[6]);

black bc_0(pkj[0], gkj[4], i_pk[4], i_gk[7], o_gk[7], o_pk[0]);
black bc_1(pkj[1], gkj[5], i_pk[5], i_gk[8], o_gk[8], o_pk[1]);
black bc_2(pkj[2], gkj[6], i_pk[6], i_gk[9], o_gk[9], o_pk[2]);
black bc_3(pkj[3], gkj[7], i_pk[7], i_gk[10], o_gk[10], o_pk[3]);
black bc_4(pkj[4], gkj[8], i_pk[8], i_gk[11], o_gk[11], o_pk[4]);
black bc_5(pkj[5], gkj[9], i_pk[9], i_gk[12], o_gk[12], o_pk[5]);
black bc_6(pkj[6], gkj[10], i_pk[10], i_gk[13], o_gk[13], o_pk[6]);
black bc_7(pkj[7], gkj[11], i_pk[11], i_gk[14], o_gk[14], o_pk[7]);
black bc_8(pkj[8], gkj[12], i_pk[12], i_gk[15], o_gk[15], o_pk[8]);

endmodule

module ks_3(
  input  wire        i_c0,
  input  wire [14:0] i_pk,
  input  wire [15:0] i_gk,
  input  wire [15:0] i_p_save,
  output wire        o_c0,
  output wire [12:0] o_pk,
  output wire [15:0] o_gk,
  output wire [15:0] o_p_save
);

wire [14:0] gkj;
wire [12:0] pkj;

assign o_c0      = i_c0;
assign o_p_save  = i_p_save;
assign gkj[0]    = i_c0;
assign gkj[14:1] = i_gk[13:0];
assign pkj       = i_pk[12:0];
assign o_gk[0]   = i_gk[0];

grey gc_0(gkj[0], i_pk[0], i_gk[1], o_gk[1]);
grey gc_1(gkj[1], i_pk[1], i_gk[2], o_gk[2]);
black bc_0(pkj[0], gkj[2], i_pk[2], i_gk[3], o_gk[3], o_pk[0]);
black bc_1(pkj[1], gkj[3], i_pk[3], i_gk[4], o_gk[4], o_pk[1]);
black bc_2(pkj[2], gkj[4], i_pk[4], i_gk[5], o_gk[5], o_pk[2]);
black bc_3(pkj[3], gkj[5], i_pk[5], i_gk[6], o_gk[6], o_pk[3]);
black bc_4(pkj[4], gkj[6], i_pk[6], i_gk[7], o_gk[7], o_pk[4]);
black bc_5(pkj[5], gkj[7], i_pk[7], i_gk[8], o_gk[8], o_pk[5]);
black bc_6(pkj[6], gkj[8], i_pk[8], i_gk[9], o_gk[9], o_pk[6]);
black bc_7(pkj[7], gkj[9], i_pk[9], i_gk[10], o_gk[10], o_pk[7]);
black bc_8(pkj[8], gkj[10], i_pk[10], i_gk[11], o_gk[11], o_pk[8]);
black bc_9(pkj[9], gkj[11], i_pk[11], i_gk[12], o_gk[12], o_pk[9]);
black bc_10(pkj[10], gkj[12], i_pk[12], i_gk[13], o_gk[13], o_pk[10]);
black bc_11(pkj[11], gkj[13], i_pk[13], i_gk[14], o_gk[14], o_pk[11]);
black bc_12(pkj[12], gkj[14], i_pk[14], i_gk[15], o_gk[15], o_pk[12]);

endmodule

module ks_2(
  input  wire        i_c0,
  input  wire [15:0] i_pk,
  input  wire [15:0] i_gk,
  output wire        o_c0,
  output wire [14:0] o_pk,
  output wire [15:0] o_gk,
  output wire [15:0] o_p_save
);

wire [15:0] gkj;
wire [14:0] pkj;

assign o_c0      = i_c0;
assign o_p_save  = i_pk;
assign gkj[0]    = i_c0;
assign gkj[15:1] = i_gk[14:0];
assign pkj       = i_pk[14:0];

grey gc_0(gkj[0], i_pk[0], i_gk[0], o_gk[0]);
black bc_0(pkj[0], gkj[1], i_pk[1], i_gk[1], o_gk[1], o_pk[0]);
black bc_1(pkj[1], gkj[2], i_pk[2], i_gk[2], o_gk[2], o_pk[1]);
black bc_2(pkj[2], gkj[3], i_pk[3], i_gk[3], o_gk[3], o_pk[2]);
black bc_3(pkj[3], gkj[4], i_pk[4], i_gk[4], o_gk[4], o_pk[3]);
black bc_4(pkj[4], gkj[5], i_pk[5], i_gk[5], o_gk[5], o_pk[4]);
black bc_5(pkj[5], gkj[6], i_pk[6], i_gk[6], o_gk[6], o_pk[5]);
black bc_6(pkj[6], gkj[7], i_pk[7], i_gk[7], o_gk[7], o_pk[6]);
black bc_7(pkj[7], gkj[8], i_pk[8], i_gk[8], o_gk[8], o_pk[7]);
black bc_8(pkj[8], gkj[9], i_pk[9], i_gk[9], o_gk[9], o_pk[8]);
black bc_9(pkj[9], gkj[10], i_pk[10], i_gk[10], o_gk[10], o_pk[9]);
black bc_10(pkj[10], gkj[11], i_pk[11], i_gk[11], o_gk[11], o_pk[10]);
black bc_11(pkj[11], gkj[12], i_pk[12], i_gk[12], o_gk[12], o_pk[11]);
black bc_12(pkj[12], gkj[13], i_pk[13], i_gk[13], o_gk[13], o_pk[12]);
black bc_13(pkj[13], gkj[14], i_pk[14], i_gk[14], o_gk[14], o_pk[13]);
black bc_14(pkj[14], gkj[15], i_pk[15], i_gk[15], o_gk[15], o_pk[14]);

endmodule

module ks_1(
  input i_c0,
  input  wire [15:0]i_a,
  input  wire [15:0]i_b,
  output wire [15:0]o_pk_1,
  output wire [15:0]o_gk_1,
  output o_c0_1
);

assign o_c0_1 = i_c0;

pg pg_0(i_a[0], i_b[0], o_pk_1[0], o_gk_1[0]);
pg pg_1(i_a[1], i_b[1], o_pk_1[1], o_gk_1[1]);
pg pg_2(i_a[2], i_b[2], o_pk_1[2], o_gk_1[2]);
pg pg_3(i_a[3], i_b[3], o_pk_1[3], o_gk_1[3]);
pg pg_4(i_a[4], i_b[4], o_pk_1[4], o_gk_1[4]);
pg pg_5(i_a[5], i_b[5], o_pk_1[5], o_gk_1[5]);
pg pg_6(i_a[6], i_b[6], o_pk_1[6], o_gk_1[6]);
pg pg_7(i_a[7], i_b[7], o_pk_1[7], o_gk_1[7]);
pg pg_8(i_a[8], i_b[8], o_pk_1[8], o_gk_1[8]);
pg pg_9(i_a[9], i_b[9], o_pk_1[9], o_gk_1[9]);
pg pg_10(i_a[10], i_b[10], o_pk_1[10], o_gk_1[10]);
pg pg_11(i_a[11], i_b[11], o_pk_1[11], o_gk_1[11]);
pg pg_12(i_a[12], i_b[12], o_pk_1[12], o_gk_1[12]);
pg pg_13(i_a[13], i_b[13], o_pk_1[13], o_gk_1[13]);
pg pg_14(i_a[14], i_b[14], o_pk_1[14], o_gk_1[14]);
pg pg_15(i_a[15], i_b[15], o_pk_1[15], o_gk_1[15]);

endmodule

////////////
module grey(
  input  wire i_gj,
  input  wire i_pk,
  input  wire i_gk,
  output wire o_g
);

assign o_g = i_gk | (i_gj & i_pk);

endmodule

module black(
  input  wire i_pj,
  input  wire i_gj,
  input  wire i_pk,
  input  wire i_gk,
  output wire o_g,
  output wire o_p
);

assign o_g = i_gk | (i_gj & i_pk);
assign o_p = i_pk & i_pj;

endmodule

module pg(
  input  wire i_a,
  input  wire i_b,
  output wire o_p,
  output wire o_g
);

assign o_p = i_a ^ i_b;
assign o_g = i_a & i_b;

endmodule

	
	
//vedic 8 bit multiplier for instantiation

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

/////////////////////////////////////////////////

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

