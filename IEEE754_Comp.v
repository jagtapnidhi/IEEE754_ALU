module ieee754_comp (
    input [31:0] a,  // IEEE 754 single-precision floating-point number A
    input [31:0] b,  // IEEE 754 single-precision floating-point number B
    output reg gt,   // A > B
    output reg lt,   // A < B
    output reg eq    // A == B
);

    // Extract sign, exponent, and mantissa for A
    wire sign_a = a[31];
    wire [7:0] exp_a = a[30:23];
    wire [22:0] mant_a = a[22:0];

    // Extract sign, exponent, and mantissa for B
    wire sign_b = b[31];
    wire [7:0] exp_b = b[30:23];
    wire [22:0] mant_b = b[22:0];

    // Convert to unsigned representation for comparison (excluding sign bit)
    wire [30:0] unsigned_a = {exp_a, mant_a};
    wire [30:0] unsigned_b = {exp_b, mant_b};

    // Calculate the difference between unsigned_a and unsigned_b (as 32-bit values)
    wire [31:0] diff = {1'b0, unsigned_a} - {1'b0, unsigned_b};

    always @(*) begin
        // Default outputs
        gt = 0;
        lt = 0;
        eq = 0;

        // Handle special cases (NaN, Inf, zero)
        if ((exp_a == 8'hFF && mant_a != 0) || (exp_b == 8'hFF && mant_b != 0)) begin
            // At least one operand is NaN: outputs remain 0
        end else if (exp_a == 8'hFF && exp_b == 8'hFF) begin
            // Both are Inf: compare signs
            if (sign_a == sign_b) eq = 1;
            else if (sign_a) lt = 1;
            else gt = 1;
        end else if (exp_a == 8'hFF) begin
            // A is Inf: check sign
            gt = !sign_a;
            lt = sign_a;
        end else if (exp_b == 8'hFF) begin
            // B is Inf: check sign
            gt = sign_b;
            lt = !sign_b;
        end else if ((exp_a == 0 && mant_a == 0) && (exp_b == 0 && mant_b == 0)) begin
            // Both are zero
            eq = 1;
        end else if (sign_a != sign_b) begin
            // Opposite signs: positive is larger
            lt = sign_a;
            gt = !sign_a;
        end else begin
            // Same sign: compare magnitudes using diff
            if (diff == 0) begin
                eq = 1;
            end else begin
                // Determine magnitude order based on diff sign bit
                if (diff[31]) begin // unsigned_a < unsigned_b
                    if (sign_a) gt = 1; // Both negative: a is larger
                    else        lt = 1; // Both positive: a is smaller
                end else begin       // unsigned_a > unsigned_b
                    if (sign_a) lt = 1; // Both negative: a is smaller
                    else        gt = 1; // Both positive: a is larger
                end
            end
        end
    end

endmodule
