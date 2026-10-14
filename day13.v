//==============================================================
// DAY 13 - PWM GENERATOR
//
// Digital VLSI / Verilog RTL / Hierarchical Design
//
// Hierarchy:
//
// LEVEL 1 : Basic Gates
// LEVEL 2 : Half Adder
// LEVEL 3 : Full Adder
// LEVEL 4 : 4-bit Incrementer
// LEVEL 5 : 4-bit Counter
// LEVEL 6 : 4-bit Comparator
// LEVEL 7 : PWM Generator - Structural
// LEVEL 8 : PWM Generator - RTL
// LEVEL 9 : TOP MODULE
//
// PWM EQUATION:
//
// PWM = 1 when COUNT < DUTY
// PWM = 0 when COUNT >= DUTY
//==============================================================


//==============================================================
// LEVEL 1A : NOT GATE
//==============================================================

module not_gate (
    input A,
    output Y
);

assign Y = ~A;

endmodule


//==============================================================
// LEVEL 1B : AND GATE
//==============================================================

module and_gate (
    input A,
    input B,
    output Y
);

assign Y = A & B;

endmodule


//==============================================================
// LEVEL 1C : OR GATE
//==============================================================

module or_gate (
    input A,
    input B,
    output Y
);

assign Y = A | B;

endmodule


//==============================================================
// LEVEL 1D : XOR GATE
//==============================================================

module xor_gate (
    input A,
    input B,
    output Y
);

assign Y = A ^ B;

endmodule


//==============================================================
// LEVEL 2 : HALF ADDER
//==============================================================

module half_adder (
    input A,
    input B,
    output SUM,
    output CARRY
);

xor_gate X1 (
    .A(A),
    .B(B),
    .Y(SUM)
);

and_gate A1 (
    .A(A),
    .B(B),
    .Y(CARRY)
);

endmodule


//==============================================================
// LEVEL 3 : FULL ADDER
//==============================================================

module full_adder (
    input A,
    input B,
    input CIN,
    output SUM,
    output COUT
);

wire sum1;
wire carry1;
wire carry2;

half_adder HA1 (
    .A(A),
    .B(B),
    .SUM(sum1),
    .CARRY(carry1)
);

half_adder HA2 (
    .A(sum1),
    .B(CIN),
    .SUM(SUM),
    .CARRY(carry2)
);

or_gate OR1 (
    .A(carry1),
    .B(carry2),
    .Y(COUT)
);

endmodule


//==============================================================
// LEVEL 4 : 4-BIT INCREMENTER
//
// Y = A + 1
//==============================================================

module incrementer_4bit (
    input [3:0] A,
    output [3:0] Y
);

wire c1;
wire c2;
wire c3;
wire c4;

full_adder FA0 (
    .A(A[0]),
    .B(1'b1),
    .CIN(1'b0),
    .SUM(Y[0]),
    .COUT(c1)
);

full_adder FA1 (
    .A(A[1]),
    .B(1'b0),
    .CIN(c1),
    .SUM(Y[1]),
    .COUT(c2)
);

full_adder FA2 (
    .A(A[2]),
    .B(1'b0),
    .CIN(c2),
    .SUM(Y[2]),
    .COUT(c3)
);

full_adder FA3 (
    .A(A[3]),
    .B(1'b0),
    .CIN(c3),
    .SUM(Y[3]),
    .COUT(c4)
);

endmodule


//==============================================================
// LEVEL 5A : D FLIP-FLOP WITH SYNCHRONOUS RESET
//==============================================================

module dff_sync_reset (
    input clk,
    input reset,
    input D,
    output reg Q
);

always @(posedge clk)
begin

    if (reset)
        Q <= 1'b0;

    else
        Q <= D;

end

endmodule


//==============================================================
// LEVEL 5B : 4-BIT COUNTER
//
// Counter = Counter + 1
//==============================================================

module counter_4bit (
    input clk,
    input reset,
    output [3:0] count
);

wire [3:0] next_count;

incrementer_4bit INC (
    .A(count),
    .Y(next_count)
);

dff_sync_reset FF0 (
    .clk(clk),
    .reset(reset),
    .D(next_count[0]),
    .Q(count[0])
);

dff_sync_reset FF1 (
    .clk(clk),
    .reset(reset),
    .D(next_count[1]),
    .Q(count[1])
);

dff_sync_reset FF2 (
    .clk(clk),
    .reset(reset),
    .D(next_count[2]),
    .Q(count[2])
);

dff_sync_reset FF3 (
    .clk(clk),
    .reset(reset),
    .D(next_count[3]),
    .Q(count[3])
);

endmodule


//==============================================================
// LEVEL 6 : 1-BIT LESS-THAN COMPARATOR
//==============================================================

module comparator_1bit (
    input A,
    input B,
    output LT
);

wire not_A;
wire A_less_B;

not_gate N1 (
    .A(A),
    .Y(not_A)
);

and_gate A1 (
    .A(not_A),
    .B(B),
    .Y(A_less_B)
);

assign LT = A_less_B;

endmodule


//==============================================================
// LEVEL 6 : 4-BIT COMPARATOR
//
// LT = 1 when A < B
//
// MSB has highest priority.
//==============================================================

module comparator_4bit (
    input [3:0] A,
    input [3:0] B,
    output LT
);

wire eq3;
wire eq2;
wire eq1;
wire eq0;

wire lt3;
wire lt2;
wire lt1;
wire lt0;

wire not_xor3;
wire not_xor2;
wire not_xor1;
wire not_xor0;

wire term3;
wire term2;
wire term1;
wire term0;


//--------------------------------------------------------------
// Bit 3
//--------------------------------------------------------------

xor_gate X3 (
    .A(A[3]),
    .B(B[3]),
    .Y(not_xor3)
);

not_gate N3 (
    .A(not_xor3),
    .Y(eq3)
);

comparator_1bit C3 (
    .A(A[3]),
    .B(B[3]),
    .LT(lt3)
);


//--------------------------------------------------------------
// Bit 2
//--------------------------------------------------------------

xor_gate X2 (
    .A(A[2]),
    .B(B[2]),
    .Y(not_xor2)
);

not_gate N2 (
    .A(not_xor2),
    .Y(eq2)
);

comparator_1bit C2 (
    .A(A[2]),
    .B(B[2]),
    .LT(lt2)
);


//--------------------------------------------------------------
// Bit 1
//--------------------------------------------------------------

xor_gate X1 (
    .A(A[1]),
    .B(B[1]),
    .Y(not_xor1)
);

not_gate N1 (
    .A(not_xor1),
    .Y(eq1)
);

comparator_1bit C1 (
    .A(A[1]),
    .B(B[1]),
    .LT(lt1)
);


//--------------------------------------------------------------
// Bit 0
//--------------------------------------------------------------

xor_gate X0 (
    .A(A[0]),
    .B(B[0]),
    .Y(not_xor0)
);

not_gate N0 (
    .A(not_xor0),
    .Y(eq0)
);

comparator_1bit C0 (
    .A(A[0]),
    .B(B[0]),
    .LT(lt0)
);


//--------------------------------------------------------------
// LESS-THAN TERMS
//--------------------------------------------------------------

assign term3 = lt3;

assign term2 = eq3 & lt2;

assign term1 = eq3 & eq2 & lt1;

assign term0 = eq3 & eq2 & eq1 & lt0;


//--------------------------------------------------------------
// FINAL LESS-THAN
//--------------------------------------------------------------

assign LT = term3 |
            term2 |
            term1 |
            term0;

endmodule


//==============================================================
// LEVEL 7 : PWM GENERATOR - STRUCTURAL
//
// Counter + Comparator
//
// PWM = COUNT < DUTY
//==============================================================

module pwm_generator_structural (
    input clk,
    input reset,
    input [3:0] duty,

    output [3:0] count,
    output pwm
);

counter_4bit COUNTER (
    .clk(clk),
    .reset(reset),
    .count(count)
);

comparator_4bit COMP (
    .A(count),
    .B(duty),
    .LT(pwm)
);

endmodule


//==============================================================
// LEVEL 8 : PWM GENERATOR - RTL
//==============================================================

module pwm_generator_rtl (
    input clk,
    input reset,
    input [3:0] duty,

    output reg [3:0] count,
    output pwm
);

always @(posedge clk)
begin

    if (reset)
        count <= 4'b0000;

    else
        count <= count + 4'b0001;

end

assign pwm = (count < duty);

endmodule


//==============================================================
// LEVEL 9 : TOP MODULE
//==============================================================

module pwm_top (
    input clk,
    input reset,
    input [3:0] duty,

    output [3:0] count_structural,
    output pwm_structural,

    output [3:0] count_rtl,
    output pwm_rtl
);

pwm_generator_structural STRUCTURAL (
    .clk(clk),
    .reset(reset),
    .duty(duty),
    .count(count_structural),
    .pwm(pwm_structural)
);

pwm_generator_rtl RTL (
    .clk(clk),
    .reset(reset),
    .duty(duty),
    .count(count_rtl),
    .pwm(pwm_rtl)
);

endmodule