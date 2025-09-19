`timescale 1ns / 1ps
module alu_tb;
    reg  [31:0] a, b;
    reg  [2:0]  opcode;
    wire [31:0] out_ieee, dec_out, a_dec, b_dec;
    wire overflow, underflow;
    wire gt, lt, eq;
    
    // For simulation display: convert fixed-point (scaled by 10) to real numbers.
    real real_result, real_a, real_b;
    always @(*) begin
        real_result = dec_out / 10.0;
        real_a      = a_dec / 10.0;
        real_b      = b_dec / 10.0;
    end

    // Instantiate the ALU module.
    ieee754_alu alu_inst (
        .a(a),
        .b(b),
        .opcode(opcode),
        .out_ieee(out_ieee),
        .dec_out(dec_out),
        .a_dec(a_dec),
        .b_dec(b_dec),
        .overflow(overflow),
        .underflow(underflow),
        .gt(gt),
        .lt(lt),
        .eq(eq)
    );
    
    initial begin
        $display("Time\tOpcode\ta (hex,real)\tb (hex,real)\tout_ieee (hex)\t dec_out (int,real)\tovf\tudf\tgt\tlt\teq");
        $monitor("%0t: opcode=%b, a=0x%h (%.2f), b=0x%h (%.2f) => out_ieee=0x%h, dec_out=%d (%.2f), ovf=%b, udf=%b, gt=%b, lt=%b, eq=%b",
                 $time, opcode, a, real_a, b, real_b, out_ieee, dec_out, real_result, overflow, underflow, gt, lt, eq);
       
        //----------------------------------------------------------
        // Negative Input Test Cases (IEEE-754 representations):
        //   -10.0 = 32'hC1200000  
        //   -20.0 = 32'hC1A00000  
        //   -30.0 = 32'hC1F00000  
        //   20.0  = 32'h41A00000  (for mixed-sign multiplication)
        //   (Note: For division, (-30.0)/(-10.0) should yield 3.0)
        //----------------------------------------------------------
        
        // Test 1: Addition: -10.0 + (-20.0) = -30.0
        opcode = 3'b001;  // OP_ADD
        a = 32'hC1200000; // -10.0
        b = 32'hC1A00000; // -20.0
        #10;
        
        // Test 2: Subtraction: -20.0 - (-10.0) = -10.0
        opcode = 3'b010;  // OP_SUB
        a = 32'hC1A00000; // -20.0
        b = 32'hC1200000; // -10.0
        #10;
        
        // Test 3: Multiplication: -10.0 * 20.0 = -200.0
        // 20.0 is 32'h41A00000; expected result -200.0 would be represented in IEEE-754
        opcode = 3'b011;  // OP_MUL
        a = 32'hC1200000; // -10.0
        b = 32'h41A00000; // 20.0
        #10;
        
        // Test 4: Division: (-30.0) / (-10.0) = 3.0
        opcode = 3'b100;  // OP_DIV
        a = 32'hC1F00000; // -30.0
        b = 32'hC1200000; // -10.0
        #10;
        
        // Test 5: Comparator: Compare -10.0 vs. -20.0.
        // Since -10.0 > -20.0, expect: gt = 1, lt = 0, eq = 0.
        opcode = 3'b000;  // OP_COMPARE
        a = 32'hC1200000; // -10.0
        b = 32'hC1A00000; // -20.0
        #10;
        
        // Test 6: Comparator: Compare -20.0 vs. -20.0.
        // Expect: equality: gt = 0, lt = 0, eq = 1.
        opcode = 3'b000;  // OP_COMPARE
        a = 32'hC1A00000; // -20.0
        b = 32'hC1A00000; // -20.0
        #10;
        
        // Test 7: Comparator: Compare -30.0 vs. -10.0.
        // Since -30.0 < -10.0, expect: gt = 0, lt = 1, eq = 0.
        opcode = 3'b000;  // OP_COMPARE
        a = 32'hC1F00000; // -30.0
        b = 32'hC1200000; // -10.0
        #10;
        
        $finish;
    end
endmodule
