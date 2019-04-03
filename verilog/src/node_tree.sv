`include "pipeFlow_pkg.svh" 
import user_tree_pkg::*;
import tree_pkg::*;

module nodeTree
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

   const tree_object_t tree = tree_generateTree(dependencies);
   tree_meta_t tree_meta;
   `ifdef ROM
     node_ROM_t ROM = generateROM(dependencies);
   `else
     //TODO: add RAM
     node_ROM_t ROM = generateROM(dependencies);
   `endif
   
   integer node_addr;

   node_list possible_nodes;

   `ifdef ROM
     // delay is 2 assuming ROM lookup
     const int NODE_SEARCH_DELAY = 2;
   `else
     //TODO: Add RAM delay parameter
     //      its going to be a function of NODES_PER_LEVEL
     const int NODE_SEARCH_DELAY = 2;
   `endif

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
     `pipeFlowAttrb(DISABLE_PIPELINING)
     // number of pipeline delays is 2 for ROM
     parameter NODE_SEARCH_DELAY = 2;
     `pipeFlow(field_id, node, NODE_SEARCH_DELAY)

     possible_nodes <= tree_GetChildNodes(tree, tree_meta); 
     
     `ifdef ROM
       node_addr = tree_GetROMNodeAddr(field_id_i, possible_nodes, ROM);
       node    <= ROM[node_addr];
     `else
       //TODO: Add RAM reads
        node_addr = tree_GetROMNodeAddr(field_id_i, possible_nodes, ROM);
         node    <= ROM[node_addr];
     `endif

     if ((field_id_valid == 1) && 
         (node != null_node_data)       && 
         (node_rdy == 1)) begin
       //advance the node pointer
       tree_meta      <= tree_AdvanceNodePtr(tree_meta, 
                           node_addr);
     end

   end

endmodule

