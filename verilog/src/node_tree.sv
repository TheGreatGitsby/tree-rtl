`include "pipeFlow_pkg.svh" 
import user_tree_pkg::*;
import tree_pkg::*;

module node_tree
(
     input  identifier  field_id_i,
     output logic       field_id_rdy,
     input  logic       field_id_valid,

     output logic       node_add_valid,
     input  logic       node_add_rdy,
     output logic [7:0] node_addr,

     input  logic       clk_i,
     input  logic       reset_i
);

   const tree_t tree = tree_generateTree(user_tree_pkg::dependencies);
   
   const node_ROM_t ROM = generateROM(user_tree_pkg::dependencies);

   parameter NODE_SEARCH_DELAY = 1;
   
   always_ff @(posedge clk_i)
   begin

     // this does the delay pipeline for a node lookup.
     // field_id_out_valid will go high after the node
     // search is complete. input is field_id_in_valid.
      
     `delayFlow(field_id, node, NODE_SEARCH_DELAY)
      
     if(stage_valid[0])
        node_addr <= tree_SearchChildNodes(tree, cur_node_addr);
   end

endmodule

