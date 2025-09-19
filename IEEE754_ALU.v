module ieee754_alu(
    input  wire [31:0] a,          // IEEE-754 input A
    input  wire [31:0] b,          // IEEE-754 input B
    input  wire [2:0]  opcode,     // Operation selector
    output wire [31:0] out_ieee,   // Result in IEEE-754 format
    output wire [31:0] dec_out,    // Result scaled by 10 (integer format)
    output wire [31:0] a_dec,      // Input A scaled by 10 (integer format)
    output wire [31:0] b_dec,      // Input B scaled by 10 (integer format)
    output wire        overflow,   // Global overflow flag
    output wire        underflow,  // Global underflow flag
    output wire        gt,         // Comparator flag: A > B
    output wire        lt,         // Comparator flag: A < B
    output wire        eq          // Comparator flag: A == B
);
    // Opcode definitions (you may adjust these if desired)
    localparam OP_COMPARE = 3'b000;
    localparam OP_ADD     = 3'b001;
    localparam OP_SUB     = 3'b010;
    localparam OP_MUL     = 3'b011;
    localparam OP_DIV     = 3'b100;
    
    // Internal wires for arithmetic results.
    wire [31:0] comp_result;
    wire [31:0] add_result;
    wire [31:0] sub_result;
    wire [31:0] mul_result;
    wire [31:0] div_result;
    
    // Comparator outputs (internal wires)
    wire comp_gt, comp_lt, comp_eq;
    
    // Pack comparator flags into a 32-bit word (only lower 3 bits used).
    assign comp_result = {29'b0, comp_gt, comp_lt, comp_eq};
    
    // Instantiate the arithmetic modules.
    ieee754_adder add_inst (.a(a),.b(b),.s(add_result),.overflow(), .underflow());
    ieee754_sub sub_inst (.a(a),.b(b),.s(sub_result),.overflow(),.underflow());
    ieee754_mul mul_inst (.a(a),.b(b),.s(mul_result),.overflow(),.underflow());
    ieee754_div div_inst ( .A(a),.B(b),.OUT(div_result),.OverFlow(),.UnderFlow());
    ieee754_comp comp_inst (.a(a),.b(b),.gt(comp_gt),.lt(comp_lt),.eq(comp_eq));
    // *** NEW: Drive the top-level comparator outputs ***
    assign gt = comp_gt;
    assign lt = comp_lt;
    assign eq = comp_eq;
    // Multiplexer to select the arithmetic result.
    wire [31:0] arith_result = (opcode == OP_ADD) ? add_result :
                               (opcode == OP_SUB) ? sub_result :
                               (opcode == OP_MUL) ? mul_result :
                               (opcode == OP_DIV) ? div_result :
                               32'd0;
    // Final output: if opcode == OP_COMPARE, use comparator result; otherwise arithmetic result.
    assign out_ieee = (opcode == OP_COMPARE) ? comp_result : arith_result; 
    // Instantiate the conversion module to convert an IEEE754 number into a fixed-point integer (scaled by 10).
    wire signed [31:0] fixed_decimal;
    ieee754_to_decimal conv_inst (.ieee_in(out_ieee),.dec_out(fixed_decimal) );
    assign dec_out = fixed_decimal;
    // Instantiate converters for the input operands.
    ieee754_to_decimal conv_a (.ieee_in(a),.dec_out(a_dec));
    ieee754_to_decimal conv_b (.ieee_in(b),.dec_out(b_dec));
    // Global overflow and underflow flags come from the arithmetic modules.
    assign overflow = (opcode == OP_ADD) ? add_inst.overflow :
                      (opcode == OP_SUB) ? sub_inst.underflow :
                      (opcode == OP_MUL) ? mul_inst.overflow :
                      (opcode == OP_DIV) ? div_inst.OverFlow :
                      1'b0;
    assign underflow = (opcode == OP_ADD) ? add_inst.underflow :
                       (opcode == OP_SUB) ? sub_inst.underflow :
                       (opcode == OP_MUL) ? mul_inst.underflow :
                       (opcode == OP_DIV) ? div_inst.UnderFlow :
                       1'b0;
endmodule    
