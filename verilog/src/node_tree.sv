`include "pipeFlow_pkg.svh" 
import user_tree_pkg::*;
import tree_pkg::*;

module node_tree
(
     input  identifier  field_id_i,
     output logic       field_id_rdy,
     input  logic       field_id_valid,

     output logic       node_valid,
     input  logic       node_rdy,
     output node_data   node,

     input  logic       clk_i,
     input  logic       reset_i
);

   const tree_t tree = tree_generateTree(user_tree_pkg::dependencies);
   
   const node_ROM_t ROM = generateROM(user_tree_pkg::dependencies);

   parameter NODE_SEARCH_DELAY = 2;
   
   always_ff @(posedge clk_i)
   begin

     // this does the delay pipeline for a node lookup.
     // field_id_out_valid will go high after the node
     // search is complete. input is field_id_in_valid.
     //
     // DISABLE_PIPELINING since we dont want to begin a
     // search until the last one has completely finished
     // since the node pointer may have advanced. NO, this
     // is not a very good pipeline but that's okay.
      
     `delayFlow(field_id, node, NODE_SEARCH_DELAY)
      
     
     if(stage_valid[0]) begin
       if (tree_SearchChildNodes(tree, cur_node_addr) != 0) 
         cur_node_addr = tree_SearchChildNodes(tree, cur_node_addr);
     end

     if(stage_valid[1])
       node <= node_ROM[cur_node_addr];

   end

endmodule

