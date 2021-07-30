module cv32e40x_clmulh_sva
  import uvm_pkg::*;
  import cv32e40x_pkg::*;
  (// Module signals
   input logic clk,
   input logic [31:0] op_a_i,
   input logic [31:0] op_b_i,
   input logic [31:0] result_o
);

  ////////////////////////////////////////
  ////  Assertion on the algorithm    ////
  ////////////////////////////////////////

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
    assert property (@(posedge clk)
                    result_o == result_expect_clmulh)
      else `uvm_error("clmulh", "CLMULH result check failed")
  

endmodule // cv32e40x_clmulh
