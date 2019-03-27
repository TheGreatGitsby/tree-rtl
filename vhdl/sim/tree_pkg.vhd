library ieee;
use ieee.std_logic_1164.all;
 
package user_tree_pkg is
 
   constant NUM_MSG_HIERARCHY : natural := 2;
   constant NUM_MSGS : natural := 2;
   constant MAX_NODES_PER_LEVEL : natural := 1;
   
   type msg_t is (NULL_MESSAGE, PERSON, PHONE_NUMBER); 

   type node_data is record
      field_id     : natural;
      msg_name     : msg_t;
   end record;

   constant Person_msg : node_data := (field_id => 1,
                                        msg_name => PERSON);

   constant PhoneNumber_msg : node_data := (field_id => 4,
                                        msg_name => PHONE_NUMBER);

   constant null_node_data : node_data := (field_id => 0,
                                        msg_name => NULL_MESSAGE);

   constant null_node_id : natural := 0;
   constant person_node_id : natural := 1;
   constant phone_number_node_id : natural := 2;

   type msg_rom_t is array (0 to NUM_MSG) of node_data;
   constant msg_rom : msg_rom_t := (null_node_id => Person_msg,
                                    person_node_id => person_node_id,    
                                    phone_number_node_id => PhoneNumber_msg);    

   type dependency_t is array (0 to NUM_MSG_HIERARCHY-1) of natural;

   constant person_dependency : dependency_t := (0 => person_node_id, others => null_node_id);
   constant PhoneNumber_dependency : dependency_t := (0 => person_node_id, 1 => phone_number_node_id);

    type dependency_arr_t is array (0 to NUM_MSGS-1) of dependency_t;
    constant dependencies : dependency_arr_t := (0 => person_dependency,
                                                 1 => PhoneNumber_dependency);

end package user_tree_pkg;

package body user_tree_pkg is
end package body user_tree_pkg;
