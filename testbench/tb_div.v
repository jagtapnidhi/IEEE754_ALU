
module ieee754_div_tb;
    reg [31:0] A, B;
    wire [31:0] OUT;
    wire OverFlow, UnderFlow;
    
    // Instantiate the IEEE754 divider module.
    ieee754_div #(32, 23, 8) uut (
        .A(A),
        .B(B),
        .OUT(OUT),
        .OverFlow(OverFlow),
        .UnderFlow(UnderFlow)
    );
    
    initial begin
        $monitor("Time=%0t: A=0x%h, B=0x%h, OUT=0x%h, Overflow=%b, UnderFlow=%b",
                 $time, A, B, OUT, OverFlow, UnderFlow);
        
        // Test Case 1: 1.0 / 2.0
        // A = 0x3F800000 (1.0), B = 0x40000000 (2.0)
        // Expected IEEE754 quotient ~ 0x3F000000 (0.5)
        A = 32'h3F800000;
        B = 32'h40000000;
        #10;
        
        // Test Case 2: 6.0 / 1.5
        // A = 0x40C00000 (6.0), B = 0x3FC00000 (1.5)
        // Expected quotient = 4.0, i.e. 0x40800000.
        A = 32'h40C00000;
        B = 32'h3FC00000;
        #10;
        
        // Test Case 3: 0.5 / 0.25
        // A = 0x3F000000 (0.5), B = 0x3E800000 (0.25)
        // Expected quotient = 2.0, i.e. 0x40000000.
        A = 32'h3F000000;
        B = 32'h3E800000;
        #10;
        
        // Test Case 4: 1.0 / 1.0
        // Expected quotient = 1.0, i.e. 0x3F800000.
        A = 32'h3F800000;
        B = 32'h3F800000;
        #10;
        
        // Test Case 5: 3.0 / 2.0
        // A = 0x40400000 (3.0), B = 0x40000000 (2.0)
        // Expected quotient = 1.5, i.e. 0x3FC00000.
        A = 32'h40400000;
        B = 32'h40000000;
        #10;
        
        $finish;
    end
endmodule

