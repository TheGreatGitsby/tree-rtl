import user_tree_pkg::*;

package tree_pkg;
 
   typedef struct  
   {
     integer node_addr;
     integer parent_node_addr;
   } tree_node;
   
   typedef int node_list [user_tree_pkg::MAX_NODES_PER_LEVEL];

   typedef tree_node row_t [user_tree_pkg::MAX_NODES_PER_LEVEL];
   typedef row_t tree_t [user_tree_pkg::NUM_MSG_HIERARCHY];
   typedef integer path_t [user_tree_pkg::NUM_MSG_HIERARCHY];

   typedef struct
   {
      integer cur_node_id;
      integer level;
      path_t  cur_path;
   }tree_meta_t;

   function tree_t tree_generateTree(input user_tree_pkg::dependency_arr_t dependencies);
                          
     automatic tree_t tree = '{default:0};
     automatic integer cur_parent_node_id = 0;
                            
     for (int i=0; i<user_tree_pkg::NUM_MSGS; i++) begin   // loop all the dependency arrays
       for (int level=0; level<user_tree_pkg::NUM_MSG_HIERARCHY; level++) begin // loop through each dependency array idx
           if (dependencies[i][level].node_addr == 0) //null_node_id
              break;
           for (int k=0; k< user_tree_pkg::MAX_NODES_PER_LEVEL; k++) begin //loop through slots in tree level j 
            if (tree[level][k].node_addr == dependencies[i][level].node_addr) 
            begin
               // node exists in the tree
               cur_parent_node_id = tree[level][k].node_addr; 
               break;
            end
            if (tree[level][k].node_id == 0) 
            begin
               tree[level][k].parent_node_id = cur_parent_node_id;
               tree[level][k].node_addr = dependencies[i][level].addr;
               break;
            end;
           end;
        end;
     end;
     return tree;
   endfunction;

   // If using ROM based node data                                    
   typedef node_data node_ROM_t [user_tree_pkg::NUM_MSGS];
                                     
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
      return tree_i[level][node_idx].node_id;
endfunction;

function integer tree_GetNodeParentId(input tree_t tree,
                      input integer level, node_idx);
      return tree[level][node_idx].parent_node_id;
endfunction;

function node_list tree_GetChildNodes(input tree_t tree, input tree_meta_t tree_meta);

  automatic integer level = tree_meta.level;
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
   tree_meta_new.cur_path[tree_meta.level + 1] = unique_id;

   return tree_meta_new;

endfunction;

function tree_meta_t tree_RewindNodePtr(input tree_meta_t tree_meta);
   tree_meta_t tree_meta_new;

   tree_meta_new.level       = tree_meta.level - 1;
   return tree_meta_new;

endfunction;

endpackage
