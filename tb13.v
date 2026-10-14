
//==============================================================
// DAY 13 TESTBENCH
// PWM GENERATOR
//
// COMPLETE SELF-CHECKING VERIFICATION
//
// 1. Basic Gates
// 2. Half Adder
// 3. Full Adder
// 4. Incrementer
// 5. Counter
// 6. Comparator
// 7. PWM Duty 0
// 8. PWM Duty 1
// 9. PWM Duty 4
// 10. PWM Duty 8
// 11. PWM Duty 12
// 12. PWM Duty 15
// 13. Structural vs RTL
// 14. Reset
// 15. Rollover
//==============================================================

`timescale 1ns/1ps

module day13_tb;


//==============================================================
// CLOCK
//==============================================================

reg clk;

initial
begin
    clk = 1'b0;

    forever
        #5 clk = ~clk;
end


//==============================================================
// COMMON RESET
//==============================================================

reg reset;


//==============================================================
// TEST INPUTS
//==============================================================

reg A;
reg B;
reg CIN;


//==============================================================
// BASIC GATES OUTPUTS
//==============================================================

wire NOT_Y;
wire AND_Y;
wire OR_Y;
wire XOR_Y;


//==============================================================
// HALF ADDER OUTPUTS
//==============================================================

wire HA_SUM;
wire HA_CARRY;


//==============================================================
// FULL ADDER OUTPUTS
//==============================================================

wire FA_SUM;
wire FA_COUT;


//==============================================================
// INCREMENTER
//==============================================================

reg [3:0] inc_A;
wire [3:0] inc_Y;


//==============================================================
// COUNTER
//==============================================================

wire [3:0] counter_Q;


//==============================================================
// COMPARATOR
//==============================================================

reg [3:0] comp_A;
reg [3:0] comp_B;

wire comp_LT;


//==============================================================
// PWM
//==============================================================

reg [3:0] duty;

wire [3:0] count_structural;
wire pwm_structural;

wire [3:0] count_rtl;
wire pwm_rtl;


//==============================================================
// LOOP VARIABLES
//==============================================================

integer i;
integer j;
integer k;

integer errors;


//==============================================================
// BASIC GATES
//==============================================================

not_gate NOT_DUT
(
    .A(A),
    .Y(NOT_Y)
);

and_gate AND_DUT
(
    .A(A),
    .B(B),
    .Y(AND_Y)
);

or_gate OR_DUT
(
    .A(A),
    .B(B),
    .Y(OR_Y)
);

xor_gate XOR_DUT
(
    .A(A),
    .B(B),
    .Y(XOR_Y)
);


//==============================================================
// HALF ADDER
//==============================================================

half_adder HA_DUT
(
    .A(A),
    .B(B),
    .SUM(HA_SUM),
    .CARRY(HA_CARRY)
);


//==============================================================
// FULL ADDER
//==============================================================

full_adder FA_DUT
(
    .A(A),
    .B(B),
    .CIN(CIN),
    .SUM(FA_SUM),
    .COUT(FA_COUT)
);


//==============================================================
// INCREMENTER
//==============================================================

incrementer_4bit INC_DUT
(
    .A(inc_A),
    .Y(inc_Y)
);


//==============================================================
// COUNTER
//==============================================================

counter_4bit COUNTER_DUT
(
    .clk(clk),
    .reset(reset),
    .count(counter_Q)
);


//==============================================================
// COMPARATOR
//==============================================================

comparator_4bit COMP_DUT
(
    .A(comp_A),
    .B(comp_B),
    .LT(comp_LT)
);


//==============================================================
// PWM
//==============================================================

pwm_top PWM_DUT
(
    .clk(clk),
    .reset(reset),
    .duty(duty),

    .count_structural(count_structural),
    .pwm_structural(pwm_structural),

    .count_rtl(count_rtl),
    .pwm_rtl(pwm_rtl)
);


//==============================================================
// TASK : CHECK 1-BIT
//==============================================================

task check_1bit;

input actual;
input expected;
input [255:0] test_name;

begin

    if (actual === expected)
    begin
        $display(
            "PASS : %s | Actual=%b Expected=%b",
            test_name,
            actual,
            expected
        );
    end
    else
    begin
        $display(
            "FAIL : %s | Actual=%b Expected=%b",
            test_name,
            actual,
            expected
        );

        errors = errors + 1;
    end

end

endtask


//==============================================================
// TASK : CHECK 4-BIT
//==============================================================

task check_4bit;

input [3:0] actual;
input [3:0] expected;
input [255:0] test_name;

begin

    if (actual === expected)
    begin
        $display(
            "PASS : %s | Actual=%b Expected=%b",
            test_name,
            actual,
            expected
        );
    end
    else
    begin
        $display(
            "FAIL : %s | Actual=%b Expected=%b",
            test_name,
            actual,
            expected
        );

        errors = errors + 1;
    end

end

endtask


//==============================================================
// TASK : STRUCTURAL VS RTL
//==============================================================

task check_structural_rtl;

input [3:0] structural_count;
input [3:0] rtl_count;

input structural_pwm;
input rtl_pwm;

begin

    //----------------------------------------------------------
    // COUNTER
    //----------------------------------------------------------

    if (structural_count === rtl_count)
    begin
        $display(
            "PASS : COUNTER STRUCTURAL = RTL | %b",
            structural_count
        );
    end
    else
    begin
        $display(
            "FAIL : COUNTER STRUCTURAL != RTL | S=%b RTL=%b",
            structural_count,
            rtl_count
        );

        errors = errors + 1;
    end


    //----------------------------------------------------------
    // PWM
    //----------------------------------------------------------

    if (structural_pwm === rtl_pwm)
    begin
        $display(
            "PASS : PWM STRUCTURAL = RTL | %b",
            structural_pwm
        );
    end
    else
    begin
        $display(
            "FAIL : PWM STRUCTURAL != RTL | S=%b RTL=%b",
            structural_pwm,
            rtl_pwm
        );

        errors = errors + 1;
    end

end

endtask


//==============================================================
// TASK : PWM CHECK
//==============================================================

task check_pwm;

input [3:0] expected_count;
input [3:0] expected_duty;

reg expected_pwm;

begin

    //----------------------------------------------------------
    // EXPECTED PWM
    //----------------------------------------------------------

    if (expected_count < expected_duty)
        expected_pwm = 1'b1;
    else
        expected_pwm = 1'b0;


    //----------------------------------------------------------
    // STRUCTURAL COUNT
    //----------------------------------------------------------

    check_4bit(
        count_structural,
        expected_count,
        "PWM STRUCTURAL COUNT"
    );


    //----------------------------------------------------------
    // RTL COUNT
    //----------------------------------------------------------

    check_4bit(
        count_rtl,
        expected_count,
        "PWM RTL COUNT"
    );


    //----------------------------------------------------------
    // STRUCTURAL PWM
    //----------------------------------------------------------

    check_1bit(
        pwm_structural,
        expected_pwm,
        "PWM STRUCTURAL OUTPUT"
    );


    //----------------------------------------------------------
    // RTL PWM
    //----------------------------------------------------------

    check_1bit(
        pwm_rtl,
        expected_pwm,
        "PWM RTL OUTPUT"
    );


    //----------------------------------------------------------
    // STRUCTURAL VS RTL
    //----------------------------------------------------------

    check_structural_rtl(
        count_structural,
        count_rtl,
        pwm_structural,
        pwm_rtl
    );

end

endtask


//==============================================================
// MAIN TEST
//==============================================================

initial
begin

    //----------------------------------------------------------
    // INITIAL VALUES
    //----------------------------------------------------------

    errors = 0;

    A = 1'b0;
    B = 1'b0;
    CIN = 1'b0;

    inc_A = 4'b0000;

    comp_A = 4'b0000;
    comp_B = 4'b0000;

    duty = 4'b0000;

    reset = 1'b1;


    //==========================================================
    // TEST 1 : BASIC GATES
    //==========================================================

    $display("");
    $display("================================================");
    $display("TEST 1 : BASIC GATES");
    $display("================================================");

    for (i = 0; i < 2; i = i + 1)
    begin

        for (j = 0; j < 2; j = j + 1)
        begin

            A = i;
            B = j;

            #1;

            check_1bit(NOT_Y, ~A, "NOT GATE");
            check_1bit(AND_Y, A & B, "AND GATE");
            check_1bit(OR_Y, A | B, "OR GATE");
            check_1bit(XOR_Y, A ^ B, "XOR GATE");

        end

    end


    //==========================================================
    // TEST 2 : HALF ADDER
    //==========================================================

    $display("");
    $display("================================================");
    $display("TEST 2 : HALF ADDER");
    $display("================================================");

    for (i = 0; i < 2; i = i + 1)
    begin

        for (j = 0; j < 2; j = j + 1)
        begin

            A = i;
            B = j;

            #1;

            check_1bit(
                HA_SUM,
                A ^ B,
                "HALF ADDER SUM"
            );

            check_1bit(
                HA_CARRY,
                A & B,
                "HALF ADDER CARRY"
            );

        end

    end


    //==========================================================
    // TEST 3 : FULL ADDER
    //==========================================================

    $display("");
    $display("================================================");
    $display("TEST 3 : FULL ADDER");
    $display("================================================");

    for (i = 0; i < 2; i = i + 1)
    begin

        for (j = 0; j < 2; j = j + 1)
        begin

            for (k = 0; k < 2; k = k + 1)
            begin

                A = i;
                B = j;
                CIN = k;

                #1;

                check_1bit(
                    FA_SUM,
                    A ^ B ^ CIN,
                    "FULL ADDER SUM"
                );

                check_1bit(
                    FA_COUT,
                    (A & B) | (A & CIN) | (B & CIN),
                    "FULL ADDER COUT"
                );

            end

        end

    end


    //==========================================================
    // TEST 4 : INCREMENTER
    //==========================================================

    $display("");
    $display("================================================");
    $display("TEST 4 : 4-BIT INCREMENTER");
    $display("================================================");

    for (i = 0; i < 16; i = i + 1)
    begin

        inc_A = i;

        #1;

        check_4bit(
            inc_Y,
            inc_A + 1,
            "4-BIT INCREMENTER"
        );

    end


    //==========================================================
    // TEST 5 : COUNTER RESET
    //==========================================================

    $display("");
    $display("================================================");
    $display("TEST 5 : COUNTER RESET");
    $display("================================================");

    reset = 1'b1;

    @(posedge clk);
    #1;

    check_4bit(
        counter_Q,
        4'b0000,
        "COUNTER RESET"
    );


    //==========================================================
    // TEST 6 : COUNTER COUNTING
    //==========================================================

    $display("");
    $display("================================================");
    $display("TEST 6 : COUNTER 0 TO 15");
    $display("================================================");

    reset = 1'b0;

    for (i = 1; i <= 16; i = i + 1)
    begin

        @(posedge clk);
        #1;

        check_4bit(
            counter_Q,
            i % 16,
            "COUNTER COUNT"
        );

    end


    //==========================================================
    // TEST 7 : COMPARATOR
    //==========================================================

    $display("");
    $display("================================================");
    $display("TEST 7 : 4-BIT COMPARATOR");
    $display("================================================");

    for (i = 0; i < 16; i = i + 1)
    begin

        for (j = 0; j < 16; j = j + 1)
        begin

            comp_A = i;
            comp_B = j;

            #1;

            if (i < j)
                check_1bit(
                    comp_LT,
                    1'b1,
                    "COMPARATOR A < B"
                );
            else
                check_1bit(
                    comp_LT,
                    1'b0,
                    "COMPARATOR A >= B"
                );

        end

    end


    //==========================================================
    // TEST 8 : PWM RESET
    //==========================================================

    $display("");
    $display("================================================");
    $display("TEST 8 : PWM RESET");
    $display("================================================");

    duty = 4'd4;

    reset = 1'b1;

    @(posedge clk);
    #1;

    check_4bit(
        count_structural,
        4'b0000,
        "PWM STRUCTURAL RESET COUNT"
    );

    check_4bit(
        count_rtl,
        4'b0000,
        "PWM RTL RESET COUNT"
    );

    check_structural_rtl(
        count_structural,
        count_rtl,
        pwm_structural,
        pwm_rtl
    );


    //==========================================================
    // TEST 9 : PWM DUTY = 0
    //==========================================================

    $display("");
    $display("================================================");
    $display("TEST 9 : PWM DUTY = 0");
    $display("================================================");

    reset = 1'b1;
    duty = 4'd0;

    @(posedge clk);
    #1;

    reset = 1'b0;

    for (i = 0; i < 16; i = i + 1)
    begin

        #1;

        check_pwm(
            count_structural,
            duty
        );

        @(posedge clk);
        #1;

    end


    //==========================================================
    // TEST 10 : PWM DUTY = 1
    //==========================================================

    $display("");
    $display("================================================");
    $display("TEST 10 : PWM DUTY = 1");
    $display("================================================");

    reset = 1'b1;
    duty = 4'd1;

    @(posedge clk);
    #1;

    reset = 1'b0;

    for (i = 0; i < 16; i = i + 1)
    begin

        #1;

        check_pwm(
            count_structural,
            duty
        );

        @(posedge clk);
        #1;

    end


    //==========================================================
    // TEST 11 : PWM DUTY = 4
    //==========================================================

    $display("");
    $display("================================================");
    $display("TEST 11 : PWM DUTY = 4");
    $display("================================================");

    reset = 1'b1;
    duty = 4'd4;

    @(posedge clk);
    #1;

    reset = 1'b0;

    for (i = 0; i < 16; i = i + 1)
    begin

        #1;

        check_pwm(
            count_structural,
            duty
        );

        @(posedge clk);
        #1;

    end


    //==========================================================
    // TEST 12 : PWM DUTY = 8
    //==========================================================

    $display("");
    $display("================================================");
    $display("TEST 12 : PWM DUTY = 8");
    $display("================================================");

    reset = 1'b1;
    duty = 4'd8;

    @(posedge clk);
    #1;

    reset = 1'b0;

    for (i = 0; i < 16; i = i + 1)
    begin

        #1;

        check_pwm(
            count_structural,
            duty
        );

        @(posedge clk);
        #1;

    end


    //==========================================================
    // TEST 13 : PWM DUTY = 12
    //==========================================================

    $display("");
    $display("================================================");
    $display("TEST 13 : PWM DUTY = 12");
    $display("================================================");

    reset = 1'b1;
    duty = 4'd12;

    @(posedge clk);
    #1;

    reset = 1'b0;

    for (i = 0; i < 16; i = i + 1)
    begin

        #1;

        check_pwm(
            count_structural,
            duty
        );

        @(posedge clk);
        #1;

    end


    //==========================================================
    // TEST 14 : PWM DUTY = 15
    //==========================================================

    $display("");
    $display("================================================");
    $display("TEST 14 : PWM DUTY = 15");
    $display("================================================");

    reset = 1'b1;
    duty = 4'd15;

    @(posedge clk);
    #1;

    reset = 1'b0;

    for (i = 0; i < 16; i = i + 1)
    begin

        #1;

        check_pwm(
            count_structural,
            duty
        );

        @(posedge clk);
        #1;

    end


    //==========================================================
    // FINAL RESULT
    //==========================================================

    $display("");
    $display("================================================");
    $display("DAY 13 VERIFICATION SUMMARY");
    $display("================================================");

    if (errors == 0)
    begin

        $display("");
        $display("***********************************************");
        $display("*                                             *");
        $display("*       DAY 13 : ALL TESTS PASSED            *");
        $display("*                                             *");
        $display("***********************************************");
        $display("");
        $display("TOTAL ERRORS = %0d", errors);
        $display("");

    end
    else
    begin

        $display("");
        $display("***********************************************");
        $display("*                                             *");
        $display("*       DAY 13 : TEST FAILED                 *");
        $display("*                                             *");
        $display("***********************************************");
        $display("");
        $display("TOTAL ERRORS = %0d", errors);
        $display("");

    end


    #10;

    $finish;

end


//==============================================================
// MONITOR
//==============================================================

initial
begin

    $monitor(
        "TIME=%0t | RESET=%b | DUTY=%d | COUNT_STRUCT=%b | PWM_STRUCT=%b | COUNT_RTL=%b | PWM_RTL=%b",
        $time,
        reset,
        duty,
        count_structural,
        pwm_structural,
        count_rtl,
        pwm_rtl
    );

end


//==============================================================
// WAVEFORM
//==============================================================

initial
begin

    $dumpfile("day13.vcd");

    $dumpvars(0, day13_tb);

end


endmodule

