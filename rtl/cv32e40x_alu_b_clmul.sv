module cv32e40x_alu_b_clmul(
  input logic [31:0] op_a_i,
  input logic [31:0] op_b_i,
  output logic [31:0] result_o
);
  
  always_comb begin
    result_o ='0;
    for (integer i = 0; i < 32; i++) begin
      for (integer j = 0; j < i+1; j++) begin
        result_o[i] = result_o[i] ^ (op_a_i[i-j] & op_b_i[j]);  
      end
    end
  end
endmodule

   
