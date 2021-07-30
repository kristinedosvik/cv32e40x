module cv32e40x_alu_b_clmulh 
#(
  parameter LEN = 32
)
(
    input logic [LEN-1:0] op_a_i,
    input logic [LEN-1:0] op_b_i,
    
    output logic [LEN-1:0] result_o
);

	always_comb begin
    result_o = '0;
    for (integer i = 0; i < LEN; i++) begin
      result_o = ((op_b_i >> i) & 1) ? result_o ^ (op_a_i >> (LEN - i)) : result_o;
    end  
  end
endmodule
