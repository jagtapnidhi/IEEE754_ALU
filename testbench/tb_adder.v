module ieee754_adder_tb;
    reg [31:0] a, b;
    wire [31:0] s;
    wire overflow, underflow;
    
    // Instantiate the module
    ieee754_adder adder (
        .a(a),
        .b(b),
        .s(s),
        .overflow(overflow),
        .underflow(underflow)
    );
    
    initial begin
        $monitor("Time=%0t a=%h b=%h s=%h overflow=%b underflow=%b", $time, a, b, s, overflow, underflow);
        
        // Test case 1: Simple addition
        a = 32'h3f800000; // 1.0 in IEEE 754
        b = 32'h40000000; // 2.0 in IEEE 754
        #10;
        
        // Test case 2: Addition with different exponents
        a = 32'h40400000; // 3.0
        b = 32'h3F800000; // 1.0
        #10;
        
        // Test case 3: Negative number addition
        a = 32'hC0000000; // -2.0
        b = 32'h40000000; // 2.0
        #10;
        
        // Test case 4: Overflow case
        a = 32'h7F7FFFFF; // Largest positive float
        b = 32'h3F800000; // 1.0
        #10;
        
        // Test case 5: Underflow case
        a = 32'h00800000; // Smallest normalized number
        b = 32'h80000000; // -0.0
        #10;
        
        $finish;
    end
endmodule
