library ieee;
use ieee.std_logic_1164.all;
use user_tree_pkg.all;
 
package tree_pkg is
 
   type tree_node is record
     node_id : natural;
     parent_node_id : natural;
   end record;
   
   type node_list is array (0 to MAX_NODES_PER_LEVEL-1) of natural;
   
   type row_t is array (0 to MAX_NODES_PER_LEVEL-1) of tree_node;
   type tree_t is array (0 to NUM_MSG_HIERARCHY-1) of row_t;
   type path_t is array (0 to NUM_MSG_HIERARCHY) of natural;
   type tree_meta_t is record
      cur_node_id : natural;
      level : natural;
      cur_path : path_t;
   end record;

   function tree_generateTree(dependencies : dependency_arr_t)
                          return tree_t;
   function tree_GetChildNodes(tree : tree_t;
                               tree_meta : tree_meta_t)
                               return node_list;
   function tree_NodeExists(node_id : natural)
                            return std_logic;
   function tree_AdvanceNodePtr(tree : tree_t;
                                tree_meta : tree_meta_t;
                                unique_id : natural)
                                return tree_meta_t;
   function tree_RewindNodePtr(tree_meta : tree_meta_t)
                               return tree_meta_t;
                          
end package tree_pkg;

package body tree_pkg is

   function tree_generateTree(dependencies : dependency_arr_t)
                          return tree_t is
                          
      variable tree : tree_t := (others => (others => (others => 0)));
      variable cur_parent_node_id : natural := 0;
                          
begin 

   for i in 0 to NUM_MSGS-1 loop -- loop all the dependency arrays
      for level in 0 to NUM_MSG_HIERARCHY-1 loop -- loop through each dependency array idx
         if dependencies(i)(level) = 0 then  --null_node_id
            exit;
         end if;
         for k in 0 to MAX_NODES_PER_LEVEL-1 loop -- loop through slots in tree level j 
            if tree(level)(k).node_id = dependencies(i)(level) then
               -- node exists in the tree
               cur_parent_node_id := tree(level)(k).node_id; 
               exit;
            end if;
            if tree(level)(k).node_id = 0 then
               tree(level)(k).parent_node_id := cur_parent_node_id;
               tree(level)(k).node_id := unique_id;
               exit;
            end if;
      end loop;
   end loop;
   end loop;
   return tree;
end;
 
function tree_GetNodeUniqueId (tree_i : tree_t; level : natural; node_idx : natural)
                      return natural is
      variable tree_var : tree_t := tree_i;
begin
      return tree_var(level)(node_idx).node_id;
end function;

function tree_GetNodeParentId(tree : tree_t;
                      level : natural;
                      node_idx : natural)
                      return natural is
begin
      return tree(level)(node_idx).parent_node_id;
end function;

function tree_GetChildNodes(tree : tree_t;
                          tree_meta : tree_meta_t)
                          return node_list is
   variable level : natural := tree_meta.level;
   variable return_list : node_list;
begin 
   if tree_meta.level = NUM_MSG_HIERARCHY then
     return_list := (others => 0);
   else
   for i in 0 to MAX_NODES_PER_LEVEL-1 loop
       if tree_GetNodeParentId(tree, level, i) = tree_meta.cur_node_id then
         return_list(i) := tree_GetNodeUniqueId(tree, level, i);
       else
         return_list(i) := 0;
       end if;
   end loop;
   end if;
   return return_list;
end function;

function tree_NodeExists(node_id : natural)
                          return std_logic is
begin 
   if node_id /= 0 then
      return '1';
   end if;
   return '0';
end function;

 function tree_AdvanceNodePtr(tree_meta : tree_meta_t;
                             unique_id : natural)
                             return tree_meta_t is
  variable tree_meta_new : tree_meta_t;
begin 

   tree_meta_new.cur_node_id                   := unique_id;
   tree_meta_new.level                         := tree_meta.level + 1;
   tree_meta_new.cur_path(tree_meta.level + 1) := unique_id;
   return tree_meta_new;

end function;

function tree_RewindNodePtr(tree_meta : tree_meta_t)
                             return tree_meta_t is
   variable tree_meta_new : tree_meta_t;
begin 

   tree_meta_new.level       := tree_meta.level - 1;
   return tree_meta_new;

end function;
end package body tree_pkg;
