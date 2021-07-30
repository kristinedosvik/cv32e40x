//YouTubeBetter
/*
module cv32e40x_alu_b_clmul(
  input logic [31:0] op_a_i,
  input logic [31:0] op_b_i,
  input logic [1:0] operator_i,
  output logic [31:0] result_o
);
  logic [63:0] temp;
  
  always_comb begin
    temp = {'0, op_b_i};
  for(integer i = 0; i < 32; i++) begin
      temp[63:32] = (temp[0]) ? temp[63:32] ^ op_a_i : temp[63:32];
      temp = temp >> 1;
  	end
  end
  
  assign result_o = (operator_i == 2'b00) ? temp[31:0] : (operator_i == 2'b10) ? temp[62:31] : temp[63:32];

endmodule
*/
 
//WikipediaBilde
module cv32e40x_alu_b_clmul(
  input logic [31:0] op_a_i,
  input logic [31:0] op_b_i,
  output logic [31:0] result_o
);
  
  //Legg inn mønsteret
  always_comb begin
    result_o ='0;
    for (integer i = 0; i < 32; i++) begin
      for (integer j = 0; j < i+1; j++) begin
        result_o[i] = result_o[i] ^ (op_a_i[i-j] & op_b_i[j]);  
      end
    end
  end
endmodule

   
