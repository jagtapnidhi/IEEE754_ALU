module ieee754_sub (
    input  [31:0] a,   // Minuend in IEEE 754 format
    input  [31:0] b,   // Subtrahend in IEEE 754 format
    output reg [31:0] s,       // Result (a - b) in IEEE 754 format
    output reg      overflow,  // Overflow flag
    output reg      underflow  // Underflow flag
);
    // Internal signals
    reg [31:0] b_neg;  // b negated: sign bit flipped
    reg signed [8:0] exp;
    reg [23:0] mantisa_a, mantisa_b;
    reg [24:0] mantisa_out;
    reg [22:0] mantisa_last;

    always @(*) begin
        // Negate b by inverting its sign bit.
        b_neg = {~b[31], b[30:0]};
        
        // Align exponents (using a and b_neg)
        if (a[30:23] >= b_neg[30:23]) begin
            mantisa_a = {1'b1, a[22:0]};
            // Right-shift the mantissa of b_neg to align the exponent difference
            mantisa_b = {1'b1, b_neg[22:0]} >> (a[30:23] - b_neg[30:23]);
            exp = a[30:23];
        end else begin
            mantisa_a = {1'b1, a[22:0]} >> (b_neg[30:23] - a[30:23]);
            mantisa_b = {1'b1, b_neg[22:0]};
            exp = b_neg[30:23];
        end

        // Now perform the addition: a + (-b) = a - b.
        // (Since b_neg has its sign bit inverted, its sign differs from a.)
        if ( a[31] ^ b_neg[31] ) begin
            // Signs differ so perform subtraction of mantissas.
            if (mantisa_a >= mantisa_b) begin
                mantisa_out = mantisa_a - mantisa_b;
                s[31] = a[31]; // Sign comes from the larger magnitude operand (here, a)
            end else begin
                mantisa_out = mantisa_b - mantisa_a;
                s[31] = b_neg[31]; // Otherwise, use the sign from b_neg (which is the inverse of b)
            end
        end else begin
            // (This branch is unlikely for subtraction since we expect b_neg to have the opposite sign)
            mantisa_out = mantisa_a + mantisa_b;
            s[31] = a[31];
        end

        // Normalization: shift mantissa_out so that the implicit leading bit is in place.
        if (mantisa_out[24] == 1'b1) begin
            mantisa_last = mantisa_out[23:1];
            exp = exp + 1;
        end else if (mantisa_out[23] == 1'b1) begin
            mantisa_last = mantisa_out[22:0];
        end else if (mantisa_out[22] == 1'b1) begin
            mantisa_last = {mantisa_out[21:0], 1'b0};
            exp = exp - 1;
        end else if (mantisa_out[21] == 1'b1) begin
            mantisa_last = {mantisa_out[20:0], 2'b00};
            exp = exp - 2;
        end else if (mantisa_out[20] == 1'b1) begin
            mantisa_last = {mantisa_out[19:0], 3'b000};
            exp = exp - 3;
        end else if (mantisa_out[19] == 1'b1) begin
            mantisa_last = {mantisa_out[18:0], 4'b0000};
            exp = exp - 4;
        end else if (mantisa_out[18] == 1'b1) begin
            mantisa_last = {mantisa_out[17:0], 5'b00000};
            exp = exp - 5;
        end else if (mantisa_out[17] == 1'b1) begin
            mantisa_last = {mantisa_out[16:0], 6'b000000};
            exp = exp - 6;
        end else if (mantisa_out[16] == 1'b1) begin
            mantisa_last = {mantisa_out[15:0], 7'b0000000};
            exp = exp - 7;
        end else if (mantisa_out[15] == 1'b1) begin
            mantisa_last = {mantisa_out[14:0], 8'b00000000};
            exp = exp - 8;
        end else if (mantisa_out[14] == 1'b1) begin
            mantisa_last = {mantisa_out[13:0], 9'b000000000};
            exp = exp - 9;
        end else if (mantisa_out[13] == 1'b1) begin
            mantisa_last = {mantisa_out[12:0], 10'b0000000000};
            exp = exp - 10;
        end else if (mantisa_out[12] == 1'b1) begin
            mantisa_last = {mantisa_out[11:0], 11'b00000000000};
            exp = exp - 11;
        end else if (mantisa_out[11] == 1'b1) begin
            mantisa_last = {mantisa_out[10:0], 12'b000000000000};
            exp = exp - 12;
        end else if (mantisa_out[10] == 1'b1) begin
            mantisa_last = {mantisa_out[9:0], 13'b0000000000000};
            exp = exp - 13;
        end else if (mantisa_out[9] == 1'b1) begin
            mantisa_last = {mantisa_out[8:0], 14'b00000000000000};
            exp = exp - 14;
        end else if (mantisa_out[8] == 1'b1) begin
            mantisa_last = {mantisa_out[7:0], 15'b000000000000000};
            exp = exp - 15;
        end else if (mantisa_out[7] == 1'b1) begin
            mantisa_last = {mantisa_out[6:0], 16'b0000000000000000};
            exp = exp - 16;
        end else if (mantisa_out[6] == 1'b1) begin
            mantisa_last = {mantisa_out[5:0], 17'b00000000000000000};
            exp = exp - 17;
        end else if (mantisa_out[5] == 1'b1) begin
            mantisa_last = {mantisa_out[4:0], 18'b000000000000000000};
            exp = exp - 18;
        end else if (mantisa_out[4] == 1'b1) begin
            mantisa_last = {mantisa_out[3:0], 19'b0000000000000000000};
            exp = exp - 19;
        end else if (mantisa_out[3] == 1'b1) begin
            mantisa_last = {mantisa_out[2:0], 20'b00000000000000000000};
            exp = exp - 20;
        end else if (mantisa_out[2] == 1'b1) begin
            mantisa_last = {mantisa_out[1:0], 21'b000000000000000000000};
            exp = exp - 21;
        end else if (mantisa_out[1] == 1'b1) begin
            mantisa_last = {mantisa_out[0], 22'b0000000000000000000000};
            exp = exp - 22;
        end else if (mantisa_out[0] == 1'b1) begin
            mantisa_last = 0;
            exp = exp - 23;
        end else begin
            mantisa_last = 0;
            exp = 0;
            s[31] = 0;
        end

        // Pack exponent and mantissa into the final result
        if (exp > 254) begin
            overflow  = 1;
            underflow = 0;
            s[30:0] = {8'hff, mantisa_last}; // Represent overflow as infinity
        end else if (exp < 0) begin
            overflow  = 0;
            underflow = 1;
            s[30:0] = {8'b00000000, mantisa_last}; // Underflow: result is zero (or denormalized if desired)
        end else begin
            overflow  = 0;
            underflow = 0;
            s[30:0] = {exp[7:0], mantisa_last};
        end
    end

endmodule
