module ieee754_sub_tb;
    // Testbench signals
    reg  [31:0] a;
    reg  [31:0] b;
    wire [31:0] s;
    wire        overflow;
    wire        underflow;

    // Instantiate the subtractor module
    ieee754_sub uut (
        .a(a),
        .b(b),
        .s(s),
        .overflow(overflow),
        .underflow(underflow)
    );

    // Apply clock-free stimulus since the subtractor is purely combinational
    // (If you later decide to pipeline this, add a clock generator)
    initial begin
        // Initialize inputs
        a = 32'd0;
        b = 32'd0;
        #20;
        
        // Test Case 1: 6.0 - 3.0 = 3.0
        // IEEE-754 representations:
        // 6.0  -> 0x40C00000, 3.0 -> 0x40400000
        a = 32'h447FC000; 
        b = 32'h44430000;
        #20;
        
        // Test Case 2: 3.0 - 6.0 = -3.0
        a = 32'h40400000; 
        b = 32'h40C00000;
        #20;
        
        // Test Case 3: (-6.0) - 3.0 = -9.0
        // -6.0 -> 0xC0C00000, 3.0 -> 0x40400000
        a = 32'hC0C00000; 
        b = 32'h40400000;
        #20;
        
        // Test Case 4: (-3.0) - (-6.0) = 3.0
        // -3.0 -> 0xC0400000, -6.0 -> 0xC0C00000
        a = 32'hC0400000;
        b = 32'hC0C00000;
        #20;
        
        // Test Case 5: 5.5 - 5.5 = 0.0
        // 5.5 is represented as 0x40B00000 in IEEE-754 single precision
        a = 32'h40B00000;
        b = 32'h40B00000;
        #20;
        
        $finish;
    end

    // Monitor the simulation outputs
    initial begin
        $monitor("Time=%0t | a=%h | b=%h | s=%h | overflow=%b | underflow=%b",
                 $time, a, b, s, overflow, underflow);
    end

endmodule
