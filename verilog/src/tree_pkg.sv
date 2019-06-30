import user_tree_pkg::*;

package tree_pkg;

   parameter NODE_ADDR_SIZE = 8;
   typedef logic [NODE_ADDR_SIZE-1:0] child_node_addr_list_t [user_tree_pkg::MAX_NODES_PER_LEVEL];
   parameter NODE_SIZE = user_tree_pkg::IDENTIFIER_SIZE+NODE_ADDR_SIZE+(NODE_ADDR_SIZE*user_tree_pkg::MAX_NODES_PER_LEVEL);
   typedef logic [NODE_SIZE-1:0] tree_node;

 //typedef struct packed  
 //{
 //LSB - logic [IDENTIFIER_SIZE-1] node_id;
 //      logic [7:0]  child_node_addr_list [user_tree_pkg::MAX_NODES_PER_LEVEL];
 //MSB - logic [7:0]        parent_node_addr;
 //} tree_node;

   function logic [user_tree_pkg::IDENTIFIER_SIZE-1:0] SLICE_NODE_ID(tree_node node);
      return node[user_tree_pkg::IDENTIFIER_SIZE-1:0];
    endfunction;

   function logic [NODE_ADDR_SIZE-1:0] SLICE_CHILD_NODE_ADDR(input tree_node node, input integer idx);
     return node[(user_tree_pkg::IDENTIFIER_SIZE)+(idx*NODE_ADDR_SIZE)+NODE_ADDR_SIZE-1 -: NODE_ADDR_SIZE];
   endfunction;

   function tree_node ADD_CHILD_NODE_ADDR(input tree_node node, input integer idx, input logic [NODE_ADDR_SIZE-1:0] new_child_node_addr);
     tree_node temp = node;
     temp[(user_tree_pkg::IDENTIFIER_SIZE)+(idx*NODE_ADDR_SIZE)+NODE_ADDR_SIZE-1 -: NODE_ADDR_SIZE] = new_child_node_addr;
     return temp;
   endfunction;

   function tree_node FILL_NEW_NODE(input user_tree_pkg::identifier new_node_id, input logic [NODE_ADDR_SIZE-1:0] parent_node_addr);
     return {parent_node_addr, 8'h00, new_node_id};
   endfunction;

   typedef tree_node [user_tree_pkg::NUM_MSGS:0] tree_t;

   function logic tree_SearchChildNodes(input tree_t tree, inout logic [7:0] node_addr, input user_tree_pkg::identifier node_id);
     for (int k=0; k<user_tree_pkg::MAX_NODES_PER_LEVEL; k++) begin //loop through child nodes
      //if the field_id matches this this child nodes node_id
        if (SLICE_NODE_ID(tree[SLICE_CHILD_NODE_ADDR(tree[node_addr], k)]) == node_id) begin
          // node exists in the tree
          node_addr = SLICE_CHILD_NODE_ADDR(tree[node_addr], k); 
          return 1'b1;
        end;
      end;
      //node was not found
      return 1'b0;
    endfunction;

   
   function tree_t tree_generateTree(input user_tree_pkg::dependencies_t dep);
                          
     automatic tree_t tree = '{default:0};
     automatic logic[7:0] cur_node_addr = 0;
                            
     for (int i=0; i<user_tree_pkg::NUM_MSGS; i++) begin   // loop all the dependency arrays
       //Reset node address to beginning of tree
       cur_node_addr = 0;
       for (int level=0; level<user_tree_pkg::NUM_MSG_HIERARCHY; level++) begin // loop through each dependency array idx
         // check for "unused" indicator
           if (dep[i][level] == 0)
             break;
           if (!tree_SearchChildNodes(tree, cur_node_addr, dep[i][level])) begin
             // node wasnt found so make an entry at first available zeroed
             // child node
             for (int k=0; k<user_tree_pkg::MAX_NODES_PER_LEVEL; k++) begin //loop through child nodes
               if (SLICE_NODE_ID(tree[SLICE_CHILD_NODE_ADDR(tree[cur_node_addr], k)]) == '0) begin
                 //make an entry at first available 0 child node
                 tree[cur_node_addr] = ADD_CHILD_NODE_ADDR(tree[cur_node_addr], k, cur_node_addr + 1);
                 tree[cur_node_addr+1] = FILL_NEW_NODE(dep[i][level], cur_node_addr);
                 //Reset node address to beginning of tree
                 cur_node_addr = 0;
                 break;
               end
             end;
           end;
        end;
     end;
     return tree;
   endfunction;

   function logic [NODE_ADDR_SIZE-1:0] SLICE_PARENT_NODE_ADDR(input tree_node node);
     return node[NODE_ADDR_SIZE + (user_tree_pkg::MAX_NODES_PER_LEVEL*NODE_ADDR_SIZE) + (user_tree_pkg::IDENTIFIER_SIZE) - 1 -: NODE_ADDR_SIZE];
   endfunction;

endpackage
