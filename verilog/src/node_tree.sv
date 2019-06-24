import user_tree_pkg::*;
import tree_pkg::*;

module node_tree
(
     input  user_tree_pkg::identifier  field_id,
     input  logic       field_id_valid,

     output logic       node_addr_valid,
     output logic [7:0] node_addr,

     input  logic       clk_i,
     input  logic       reset_i
);

   const tree_t tree = tree_generateTree(user_tree_pkg::dependencies);
   
   parameter NODE_SEARCH_DELAY = 1;
   
   always_ff @(posedge clk_i)
   begin
     node_addr_valid <= 0;

     if(field_id_valid) begin
       if(tree_SearchChildNodes(tree, node_addr, field_id))
          node_addr_valid <= 1;
      end;
   end

endmodule

