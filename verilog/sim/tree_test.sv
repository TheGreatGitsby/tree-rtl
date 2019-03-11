`include tree_pkg;

module tree_test
(
     output logic [4:0] field_id_i
     input  logic clk_i;
     input  logic reset_i
);
   node_list possible_nodes;
   node_data node;

   always_ff @(pos_edge clk_i)
   begin

     possible_nodes <= tree_GetChildNodes(tree, tree_meta); 
     node <= tree_GetNodeData(field_id_i, possible_nodes);

   end
   const tree_object_t tree_test_obj = tree_generateTree(dependencies);

endmodule;

