package tree_pkg;
 
   typedef struct tree_node 
   {
     integer node_id;
     integer parent_node_id;
   }
   
   typedef integer [MAX_NODES_PER_LEVEL-1:0] node_list;

   typedef tree_node [MAX_NODES_PER_LEVEL-1:0] row_t;
   typedef row_t   [NUM_MSG_HIERARCHY-1:0] tree_t;
   typedef integer  [NUM_MSG_HIERARCHY-1:0] path_t;

   typedef struct tree_meta_t
   {
      integer cur_node_id;
      integer level;
      path_t  cur_path;
   }


   function tree_t tree_generateTree(input dependency_arr_t dependencies);
                          
     tree_t tree = '0;
     integer cur_parent_node_id = 0;
                            
     for (int i=0; i<NUM_MSGS; i++) begin   // loop all the dependency arrays
       for (int level=0; level<NUM_MSG_HIERARCHY; level++) begin // loop through each dependency array idx
           if (dependencies(i)(level) == 0) //null_node_id
              break;
           for (int k=0; k< MAX_NODES_PER_LEVEL; k++) begin //loop through slots in tree level j 
            if (tree(level)(k).node_id == dependencies(i)(level)) 
            begin
               // node exists in the tree
               cur_parent_node_id = tree(level)(k).node_id; 
               break;
            end;
            if (tree(level)(k).node_id == 0) 
            begin
               tree(level)(k).parent_node_id = cur_parent_node_id;
               tree(level)(k).node_id = unique_id;
               break;
            end;
           end;
        end;
     end;
     return tree;
   endfunction;

   const tree_object_t tree = tree_generateTree(dependencies);

function integer tree_GetNodeUniqueId (input tree_t tree_i; input integer level, node_idx);
      return tree_i(level)(node_idx).node_id;
end function;

function integer tree_GetNodeParentId(input tree_t tree;
                      input integer level, node_idx);
      return tree(level)(node_idx).parent_node_id;
end function;

function node_list tree_GetChildNodes(input tree_t tree; input tree_meta_t tree_meta);

  integer level = tree_meta.level;
  node_list return_list;

  if (tree_meta.level == NUM_MSG_HIERARCHY)
    return_list = '0;
  else
  begin
    for (int i=0; i<MAX_NODES_PER_LEVEL; i++)
    begin
      if (tree_GetNodeParentId(tree, level, i) == tree_meta.cur_node_id)
        return_list(i) = tree_GetNodeUniqueId(tree, level, i);
      else
        return_list(i) = 0;
      end if;
    end;
  end if;
  return return_list;
endfunction;

function logic tree_NodeExists(input integer node_id);
  if (node_id /= 0)
     return 1;
  return 0;
endfunction;

function node_data tree_GetNodeData(input identifier rcvd_id;
                                    input node_list possible_nodes);
 // if ROM we can loop though node_arr
 for (int i=0; i<MAX_NODES_PER_LEVEL; i++)
 begin
   if (node_hit(rcvd_id, node_arr[possible_nodes[i]]) 
     return node_arr[i];
 end;

//if RAM TODO

// handle error here....
return node_arr[0];  //null node

endfunction;


 function tree_meta_t tree_AdvanceNodePtr(input tree_meta_t tree_meta;
                             input integer unique_id);
  tree_meta_t  tree_meta_new;

   tree_meta_new.cur_node_id                   = unique_id;
   tree_meta_new.level                         = tree_meta.level + 1;
   tree_meta_new.cur_path(tree_meta.level + 1) = unique_id;

   return tree_meta_new;

endfunction;

function tree_meta_t tree_RewindNodePtr(input tree_meta_t tree_meta);
   tree_meta_t tree_meta_new;

   tree_meta_new.level       = tree_meta.level - 1;
   return tree_meta_new;

endfunction;

endpackage;
