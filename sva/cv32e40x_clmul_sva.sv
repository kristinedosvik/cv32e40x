module cv32e40x_clmul_sva
  import uvm_pkg::*;
  import cv32e40x_pkg::*;
  (// Module signals
   input logic [31:0] op_a_i,
   input logic [31:0] op_b_i,
   input logic [31:0] result_o
);

  ////////////////////////////////////////
  ////  Assertion on the algorithm    ////
  ////////////////////////////////////////

  //CLMUL
    function logic [31:0] clmul_spec(input [31:0] op_a_i, input [31:0] op_b_i);
      clmul_spec = '0;  
      for(integer i = 0; i < 32; i++) begin
        clmul_spec = ((op_b_i >> i) & 1) ? (clmul_spec ^ (op_a_i << i)) : clmul_spec;
      end
    endfunction : clmul_spec
  
  logic [31:0] result_expect_clmul;
  assign result_expect_clmul = clmul_spec(op_a_i, op_b_i);
  //assign result_expect = op_a_i * op_b_i;
  a_clmul_result : // check carrless multiplication result for CLMUL according to the SPEC algorithm
    assert property (
                    result_o == result_expect_clmul)
      else `uvm_error("clmul", "CLMUL result check failed")

/* MUST BE IN THEIR OWN MODULES!
    //CLMULH
    function logic [31:0] clmulh_spec(input [31:0] op_a_i, input [31:0] op_b_i);
      clmulh_spec = '0;  
      for(integer i = 0; i < 32; i++) begin
        clmulh_spec = ((op_b_i >> i) & 1) ? (clmulh_spec ^ (op_a_i >> (32 - i))) : clmulh_spec;
      end
    endfunction : clmulh_spec
  
  logic [31:0] result_expect_clmulh;
  assign result_expect_clmulh = clmulh_spec(op_a_i, op_b_i);
  //assign result_expect = op_a_i * op_b_i;
  a_clmulh_result : // check carrless multiplication result for CLMULH according to the SPEC algorithm
    assert property (
                    result_o == result_expect_clmulh)
      else `uvm_error("clmulh", "CLMULH result check failed")

    

    //CLMULR
    function logic [31:0] clmulr_spec(input [31:0] op_a_i, input [31:0] op_b_i);
      clmulr_spec = '0;  
      for(integer i = 0; i < 32; i++) begin
        clmulr_spec = ((op_b_i >> i) & 1) ? (clmulr_spec ^ (op_a_i >> (32-i-1))) : clmulr_spec;
      end
    endfunction : clmulr_spec
  
  logic [31:0] result_expect_clmulr;
  assign result_expect_clmulr = clmulr_spec(op_a_i, op_b_i);
  //assign result_expect = op_a_i * op_b_i;
  a_clmulr_result : // check carrless multiplication result for CLMUL according to the SPEC algorithm
    assert property (
                    result_o == result_expect_clmulr)
      else `uvm_error("clmulr", "CLMULR result check failed")
*/

endmodule // cv32e40x_clmul
