module cv32e40x_clmulr_sva
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
    assert property (@(posedge clk)
                    result_o == result_expect_clmulr)
      else `uvm_error("clmulr", "CLMULR result check failed")

endmodule // cv32e40x_clmulr
