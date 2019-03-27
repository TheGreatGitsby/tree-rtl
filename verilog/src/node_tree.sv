`include pipeFlow_pkg.svh 
import tree_pkg::*;

module nodeTree
(
     input  identifier  field_id_i
     output logic       field_id_input_rdy;
     input  logic       field_id_valid;

     output logic       node_valid;
     input  logic       node_rdy;
     output node_data   node;

     input  logic       clk_i;
     input  logic       reset_i
);

   const tree_object_t tree = tree_generateTree(dependencies);

   node_list possible_nodes;
   node_data node;

   `ifdef(ROM)
     // delay is 2 assuming ROM lookup
     const int NODE_SEARCH_DELAY = 2;
   `else
     //TODO: Add RAM delay parameter
     //      its going to be a function of NODES_PER_LEVEL
     const int NODE_SEARCH_DELAY = 2;
   `endif

   always_ff @(pos_edge clk_i)
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
     `pipeFlow(field_id, NODE_SEARCH_DELAY)

     possible_nodes <= tree_GetChildNodes(tree, tree_meta); 
     
     `ifdef(ROM)
       node           <= tree_GetROMNodeData(field_id_i, possible_nodes);
     `else
       //TODO: Add RAM reads
       node           <= tree_GetROMNodeData(field_id_i, possible_nodes);
     `endif

     if ((field_id_out_valid == 1) && 
         (node != null_node)       && 
         (node_rdy == 1)) begin
       //advance the node pointer
       tree_meta      <= tree_AdvanceNodePtr(tree_meta, unique_id);
     end

   end

endmodule;

