////////////////////
// Reference Code //
////////////////////

//CLMUL:
module clmul 
#(
  parameter LEN = 32
)
(
    input logic [LEN-1:0] op_a_i,
    input logic [LEN-1:0] op_b_i,
    
    output logic [LEN-1:0] result_o
);
  logic [31:0] temp;
  logic [31:0] temp2;
  	
	always_comb begin
    temp = '0;
    for (integer i = 0; i < LEN; i++) begin
      temp = ((op_b_i >> i) & 1) ? temp ^ (op_a_i << (i)) : temp;
    end
    end
   
  //clmul
  assign result_o = temp;
  
  //clmulr
  for (genvar j=0; j<LEN; j++) begin
    //assign temp2[j] = temp[LEN-1-j];
    //assign result_o[j] = temp[LEN-1-j];
  end
  
  //clmulh
  //assign result_o = {1'b0, temp2[LEN-1:1]};
	
endmodule
  

//CLMULH:
module clmulh 
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
  

//CLMULR:
module clmulr 
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
        result_o = ((op_b_i >> i) & 1) ? result_o ^ (op_a_i >> (LEN - i - 1)) : result_o;
        
      end
    end

  
endmodule
  


////////////////////
// ibex           //
////////////////////

//Version 1/1
module clmul 
  #(
    parameter LEN = 32
   )
  (
  input logic [LEN-1:0] op_a_i,
  input logic [LEN-1:0] op_b_i,
    
    output logic [LEN-1:0] result_o
);
  
   logic [LEN-1:0] and_stage[LEN];
   logic [LEN-1:0] xor_stage1[16];
   logic [LEN-1:0] xor_stage2[8];
   logic [LEN-1:0] xor_stage3[4];
   logic [LEN-1:0] xor_stage4[2];

  
	for (genvar i=0; i<LEN; i++) begin : gen_and_op
      assign and_stage[i] = op_b_i[i] ? op_a_i << i : '0;
    end

      for (genvar i=0; i<16; i++) begin : gen_xor_op_l1
        assign xor_stage1[i] = and_stage[2*i] ^ and_stage[2*i+1];
      end

      for (genvar i=0; i<8; i++) begin : gen_xor_op_l2
        assign xor_stage2[i] = xor_stage1[2*i] ^ xor_stage1[2*i+1];
      end

      for (genvar i=0; i<4; i++) begin : gen_xor_op_l3
        assign xor_stage3[i] = xor_stage2[2*i] ^ xor_stage2[2*i+1];
      end

      for (genvar i=0; i<2; i++) begin : gen_xor_op_l4
        assign xor_stage4[i] = xor_stage3[2*i] ^ xor_stage3[2*i+1];
      end

      assign result_o = xor_stage4[0] ^ xor_stage4[1];
endmodule



module alu
  #(parameter LEN = 32
   )
  (
    input logic [LEN-1:0] op_a_i,
    input logic [LEN-1:0] op_b_i,
    input logic [1:0] operator_i,
    
    output logic [LEN-1:0] result_o
  );
  
  logic [LEN-1:0] op_a_rev;
  logic [LEN-1:0] op_b_rev;
  
  logic [LEN-1:0] op_a_clmul;
  logic [LEN-1:0] op_b_clmul;
  
  logic [LEN-1:0] clmul;
  logic [LEN-1:0] clmul_rev;
  
  
  for (genvar k = 0; k < 32; k++) begin
    assign op_a_rev[k] = op_a_i[LEN-1-k];
    assign op_b_rev[k] = op_b_i[LEN-1-k];
  end
  
  //00 - clmul
  //01 - clmul_h
  //10 - clmul_r
  
  assign op_a_clmul = (operator_i != 2'b00) ? op_a_rev : op_a_i;
  assign op_b_clmul = (operator_i != 2'b00) ? op_b_rev : op_b_i;
 
  
  clmul inst_clmul (
    .op_a_i(op_a_clmul), 
    .op_b_i(op_b_clmul), 
    .result_o(clmul)
  );
  
  for (genvar k = 0; k < 32; k++) begin
    assign clmul_rev[k] = clmul[LEN-1-k];
  end
  
      always_comb begin
        case(operator_i)
          //clmulh:
          2'b01: result_o = {1'b0, clmul_rev[31:1]};
          
          //clmulr:
          2'b10: result_o = clmul_rev;
          
          //clmul: 2'b00
          default: result_o = clmul;
        endcase
      end
endmodule


////////////////////
// isa            //
////////////////////

//Version 1/2
module alu2
  #(parameter LEN = 32
   )
  (
  input logic [31:0] op_a_i,
  input logic [31:0] op_b_i,
  input logic [1:0] operator_i,
  
  output logic [63:0] result_o
);
  
  logic [31:0] shift_a;
  logic [31:0] temp;
  
  always_comb begin
    temp = '0;
    shift_a = '0;
    for (integer i = 0; i < 32; i++) begin
      shift_a = (operator_i == 2'b00) ? (op_a_i << i) : (op_a_i >> (LEN - i));
      if(op_b_i[i]) temp = temp ^ shift_a; 
    end
  end
  
  assign result_o = (operator_i == 2'b01) ? {1'b0, temp[31:1]} : temp;
  
endmodule

//Version 2/2
module clmul(
  input logic [31:0] op_a_i,
  input logic [31:0] op_b_i,
  output logic [63:0] result_o
);
  
  logic [31:0] shift_a;
  
  always_comb begin
    result_o = '0;
    shift_a = '0;
    for (integer i = 0; i < 32; i++) begin
      shift_a = (op_a_i << i);
      if(op_b_i[i]) result_o = result_o ^ shift_a; 
    end
  end
endmodule

//Using rammeverket clumh and clmulr
module alu
  #(parameter LEN = 32
   )
  (
    input logic [LEN-1:0] op_a_i,
    input logic [LEN-1:0] op_b_i,
    input logic [1:0] operator_i,
    
    output logic [LEN-1:0] result_o
  );
  
  logic [LEN-1:0] op_a_rev;
  logic [LEN-1:0] op_b_rev;
  
  logic [LEN-1:0] op_a_clmul;
  logic [LEN-1:0] op_b_clmul;
  
  logic [LEN-1:0] clmul;
  logic [LEN-1:0] clmul_rev;
  
  
  for (genvar k = 0; k < 32; k++) begin
    assign op_a_rev[k] = op_a_i[LEN-1-k];
    assign op_b_rev[k] = op_b_i[LEN-1-k];
  end
  
  //00 - clmul
  //01 - clmul_h
  //10 - clmul_r
  
  assign op_a_clmul = (operator_i != 2'b00) ? op_a_rev : op_a_i;
  assign op_b_clmul = (operator_i != 2'b00) ? op_b_rev : op_b_i;
 
  
  clmul inst_clmul (
    .op_a_i(op_a_clmul), 
    .op_b_i(op_b_clmul), 
    .result_o(clmul)
  );
  
  for (genvar k = 0; k < 32; k++) begin
    assign clmul_rev[k] = clmul[LEN-1-k];
  end
  
      always_comb begin
        case(operator_i)
          //clmulh:
          2'b01: result_o = {1'b0, clmul_rev[31:1]};
          
          //clmulr:
          2'b10: result_o = clmul_rev;
          
          //clmul: 2'b00
          default: result_o = clmul;
        endcase
      end
endmodule

////////////////////
// wikipedia      //
////////////////////
//Version keep on going - not possible need to change pattern

//Version 2/3 change counting/pattern
module clmul2
  #( parameter LEN = 32
   )
  (
  input logic [31:0] op_a_i,
  input logic [31:0] op_b_i,
  input logic [1:0] operator_i,
  output logic [31:0] result_o
);

  logic [31:0] temp;
  
  //Legg inn mønsteret
  always_comb begin
    temp ='0;
    for (integer i = 0; i < 32; i++) begin
      for (integer j = 0; j < i+1; j++) begin
        if (operator_i == 2'b00) temp[i] = temp[i] ^ (op_a_i[i-j] & op_b_i[j]);
        else temp[LEN-1 - i] = temp[LEN-1 - i] ^ (op_a_i[LEN-1 - j] & op_b_i[LEN-1 - (i-j)]);
      end
    end
  end
  
  assign result_o = (operator_i == 2'b01) ? {1'b0, temp[31:1]} : temp;
endmodule

//Version 3/3 rammeverk
module clmul(
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

//ALU
module alu2
  #(parameter LEN = 32
   )
  (
    input logic [LEN-1:0] op_a_i,
    input logic [LEN-1:0] op_b_i,
    input logic [1:0] operator_i,
    
    output logic [LEN-1:0] result_o
  );
  
  logic [LEN-1:0] op_a_rev;
  logic [LEN-1:0] op_b_rev;
  
  logic [LEN-1:0] op_a_clmul;
  logic [LEN-1:0] op_b_clmul;
  
  logic [LEN-1:0] clmul;
  logic [LEN-1:0] clmul_rev;
  
  
  for (genvar k = 0; k < 32; k++) begin
    assign op_a_rev[k] = op_a_i[LEN-1-k];
    assign op_b_rev[k] = op_b_i[LEN-1-k];
  end
  
  //00 - clmul
  //01 - clmul_h
  //10 - clmul_r
  
  assign op_a_clmul = (operator_i != 2'b00) ? op_a_rev : op_a_i;
  assign op_b_clmul = (operator_i != 2'b00) ? op_b_rev : op_b_i;
 
  
  clmul inst_clmul (
    .op_a_i(op_a_clmul), 
    .op_b_i(op_b_clmul), 
    .result_o(clmul)
  );
  
  for (genvar k = 0; k < 32; k++) begin
    assign clmul_rev[k] = clmul[LEN-1-k];
  end
  
      always_comb begin
        case(operator_i)
          //clmulh:
          2'b01: result_o = {1'b0, clmul_rev[31:1]};
          
          //clmulr:
          2'b10: result_o = clmul_rev;
          
          //clmul: 2'b00
          default: result_o = clmul;
        endcase
      end
endmodule

////////////////////
// YouTubeBetter  //
////////////////////

//Version 1/2 take different part of result
module alu3(
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
  
  assign result_o = (operator_i == 2'b00) ? temp[32:0] : (operator_i == 2'b10) ? temp[62:31] : temp[63:32];

endmodule

//Version 2/2 rammeverk
module clmul(
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
  
  assign result_o = temp[31:0];

endmodule

module alu
  #(parameter LEN = 32
   )
  (
    input logic [LEN-1:0] op_a_i,
    input logic [LEN-1:0] op_b_i,
    input logic [1:0] operator_i,
    
    output logic [LEN-1:0] result_o
  );
  
  logic [LEN-1:0] op_a_rev;
  logic [LEN-1:0] op_b_rev;
  
  logic [LEN-1:0] op_a_clmul;
  logic [LEN-1:0] op_b_clmul;
  
  logic [LEN-1:0] clmul;
  logic [LEN-1:0] clmul_rev;
  
  
  for (genvar k = 0; k < 32; k++) begin
    assign op_a_rev[k] = op_a_i[LEN-1-k];
    assign op_b_rev[k] = op_b_i[LEN-1-k];
  end
  
  //00 - clmul
  //01 - clmul_h
  //10 - clmul_r
  
  assign op_a_clmul = (operator_i != 2'b00) ? op_a_rev : op_a_i;
  assign op_b_clmul = (operator_i != 2'b00) ? op_b_rev : op_b_i;
 
  
  clmul inst_clmul (
    .op_a_i(op_a_clmul), 
    .op_b_i(op_b_clmul), 
    .result_o(clmul)
  );
  
  for (genvar k = 0; k < 32; k++) begin
    assign clmul_rev[k] = clmul[LEN-1-k];
  end
  
      always_comb begin
        case(operator_i)
          //clmulh:
          2'b01: result_o = {1'b0, clmul_rev[31:1]};
          
          //clmulr:
          2'b10: result_o = clmul_rev;
          
          //clmul: 2'b00
          default: result_o = clmul;
        endcase
      end
endmodule
