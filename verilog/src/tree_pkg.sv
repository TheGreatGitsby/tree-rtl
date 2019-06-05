import user_tree_pkg::*;

package tree_pkg;

   typedef logic [7:0] child_node_addr_list_t [user_tree_pkg::MAX_NODES_PER_LEVEL];
   parameter NODE_SIZE = IDENTIFIER_SIZE+NODE_ADDR_SIZE+(NODE_ADDR_SIZE*user_tree_pkg::MAX_NODES_PER_LEVEL);
   typedef logic [NODE_SIZE-1:0] tree_node;

   //typedef struct packed  
   //{
   //  logic [IDENTIFIER_SIZE-1] node_id;
   //  logic [7:0]        parent_node_addr;
   //  logic [7:0]  child_node_addr_list [user_tree_pkg::MAX_NODES_PER_LEVEL];
   //} tree_node;

   `define SLICE_NODE_ID(tree_node) \
     return tree_node[x:y]

   `define SLICE_CHILD_NODE_ADDR(tree_node, idx) \
     return tree_node[(CHILD_ADDR_LIST_OFFSET)*(k*(NODE_SIZE)):(k*NODE_SIZE+CHILD_ADDR_LIST_OFFSET]

   `define ADD_CHILD_NODE_ADDR(tree_node, idx, new_child_node_Addr) \
     tree_node[(CHILD_ADDR_LIST_OFFSET)*(idx*(NODE_SIZE)):(idx*NODE_SIZE+CHILD_ADDR_LIST_OFFSET] = new_child_node_addr

   `define FILL_NEW_NODE(new_node_id, parent_node_addr) \
     return {new_node_id, parent_node_addr, 8'h00}

   typedef logic [NODE_SIZE-1] tree_t [NUM_MSGS-1]
   
   function tree_t tree_generateTree(input user_tree_pkg::dependency_arr_t dep);
                          
     automatic tree_t tree = '{default:0};
     automatic logic[7:0] cur_node_addr = 0;
                            
     for (int i=0; i<user_tree_pkg::NUM_MSGS; i++) begin   // loop all the dependency arrays
       for (int level=0; level<user_tree_pkg::NUM_MSG_HIERARCHY; level++) begin // loop through each dependency array idx
         // check for "unused" indicator
           if (dep[i][level] == 0)
             break;
           for (int k=0; k<user_tree_pkg::MAX_NODES_PER_LEVEL; k++) begin //loop through child nodes
            //if the field_id matches this this child nodes node_id
              if (SLICE_NODE_ID(tree[`SLICE_CHILD_NODE_ADDR(tree[cur_node_addr], k)) == dep[i][level]) begin
                // node exists in the tree
                cur_node_addr = `SLICE_CHILD_NODE_ADDR(tree[cur_node_addr], k); 
                break;
              end
              if (SLICE_NODE_ID(tree[`SLICE_CHILD_NODE_ADDR(tree[cur_node_addr], k)) == '0) begin
                //Node was not found, so make an entry
                ADD_CHILD_NODE_ADDR(tree[cur_node_addr], k, next_node_addr);
                tree[next_node_addr] = `FILL_NEW_NODE(dep[i][level], cur_node_addr);
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

   // If using ROM based node data          
   // +1 for the null_node at addr 0                          
   typedef user_tree_pkg::node_data node_ROM_t [user_tree_pkg::NUM_MSGS + 1];
                                     
   function node_ROM_t generateROM (input user_tree_pkg::dependency_arr_t dep_arr);
     node_ROM_t ROM;
     for (int i=0; i<user_tree_pkg::NUM_MSGS; i++) begin   // loop all the dependency arrays
       for (int level=0; level<user_tree_pkg::NUM_MSG_HIERARCHY; level++) begin 
         ROM[dep_arr[i][level].node_addr] = dep_arr[i][level].node;
       end;
     end;
     return ROM;
   endfunction;  

function integer tree_GetNodeUniqueId (input tree_t tree_i, input integer level, node_idx);
      return tree_i[level][node_idx].node_addr;
endfunction;

function integer tree_GetNodeParentId(input tree_t tree,
                      input integer level, node_idx);
      return tree[level][node_idx].parent_node_addr;
endfunction;

function node_list tree_GetChildNodes(input tree_t tree, input tree_meta_t tree_meta);

  automatic integer level = tree_meta.level + 1;
  node_list return_list;

  if (tree_meta.level == user_tree_pkg::NUM_MSG_HIERARCHY)
    return_list = '{default:0};
  else begin
    for (int i=0; i<user_tree_pkg::MAX_NODES_PER_LEVEL; i++)
    begin
      if (tree_GetNodeParentId(tree, level, i) == tree_meta.cur_node_id)
        return_list[i] = tree_GetNodeUniqueId(tree, level, i);
      else
        return_list[i] = 0;
    end
  end
  return return_list;
endfunction;

function logic tree_NodeExists(input integer node_id);
  if (node_id != 0)
     return 1;
  return 0;
endfunction;

function integer tree_GetROMNodeAddr(input user_tree_pkg::identifier rcvd_id,
                                    input node_list possible_nodes,
                                    input node_ROM_t rom);
 // if ROM we can loop though node_arr
 for (int i=0; i<user_tree_pkg::MAX_NODES_PER_LEVEL; i++)
 begin
   if (user_tree_pkg::node_hit(rcvd_id, rom[possible_nodes[i]])) 
     return possible_nodes[i];
 end

// handle error here....
return 0;  //null node

endfunction;


 function tree_meta_t tree_AdvanceNodePtr(input tree_meta_t tree_meta,
                             input integer unique_id);
  tree_meta_t  tree_meta_new;

   tree_meta_new.cur_node_id                   = unique_id;
   tree_meta_new.level                         = tree_meta.level + 1;
   tree_meta_new.cur_path                      = tree_meta.cur_path;
   tree_meta_new.cur_path[tree_meta.level + 1] = unique_id;

   return tree_meta_new;

endfunction;

function tree_meta_t tree_RewindNodePtr(input tree_meta_t tree_meta);
   tree_meta_t tree_meta_new;

   tree_meta_new.level       = tree_meta.level - 1;
   return tree_meta_new;

endfunction;

endpackage
