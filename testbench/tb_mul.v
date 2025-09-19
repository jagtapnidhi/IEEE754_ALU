module ieee754_mul_tb;
    reg [31:0] a, b;
    wire [31:0] s;
    wire OUVERFLOW, UNDERFLOW;

    // Instantiate the MULTIPLIER module
    ieee754_mul uut (
        .a(a),
        .b(b),
        .s(s),
        .OUVERFLOW(OUVERFLOW),
        .UNDERFLOW(UNDERFLOW)
    );

    initial begin
        // Test Case 1: Normal multiplication
        a = 32'h40400000; // 3.0 in IEEE 754
        b = 32'h40800000; // 4.0 in IEEE 754
        #10;
        
        // Test Case 2: Multiplication with a negative number
        a = 32'hC0400000; // -3.0 in IEEE 754
        b = 32'h40800000; // 4.0 in IEEE 754
        #10;
        
        // Test Case 3: Overflow case
        a = 32'h7F800000; // Infinity in IEEE 754
        b = 32'h40800000; // 4.0 in IEEE 754
        #10;
        
        // Test Case 4: Underflow case
        a = 32'h00800000; // Smallest normal number
        b = 32'h00800000; // Another small number
        #10;

        // Test Case 5: Zero multiplication
        a = 32'h00000000; // 0.0
        b = 32'h3F800000; // 1.0
        #10;

        $stop;
    end

    initial begin
        $monitor("Time = %0t | a = %h | b = %h | s = %h | OUVERFLOW = %b | UNDERFLOW = %b", 
                  $time, a, b, s, OUVERFLOW, UNDERFLOW);
    end
endmodule

