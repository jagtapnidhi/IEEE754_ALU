module ieee754_mul (a, b, s, overflow  , underflow);
input [31:0] a, b;
output reg [31:0] s;
output reg overflow, underflow;
reg sign;
reg [8:0] exp;
reg [47:0] mantisa; // For multiplication
reg [22:0] mantisa2; // To extract mantisa

always @ (*) begin
    sign = a[31] ^ b[31];
    exp = a[30:23] + b[30:23] - 127;

    mantisa = {1'b1, a[22:0]} * {1'b1, b[22:0]};
    if (mantisa[47] == 1) begin
        mantisa2 = mantisa[46:24]; // Taking only 23 bits
        exp = exp + 1;
    end else begin
        mantisa2 = mantisa[45:23];
    end

    if (exp > 255) begin
        overflow= 1;
        underflow = 0;
        s = {sign, 8'b11111111, mantisa2};
    end else if (exp < 0) begin
        underflow= 1;
        overflow = 0;
        s = {sign, 8'b00000000, mantisa2};
    end else begin
        underflow = 0;
        overflow = 0;
        s = {sign, exp[7:0], mantisa2};
    end
end

endmodule
