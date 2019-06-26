package user_tree_pkg;
 
   parameter NUM_MSG_HIERARCHY = 2;
   parameter NUM_MSGS = 2;
   parameter MAX_NODES_PER_LEVEL = 1;
   parameter IDENTIFIER_SIZE = 5;
   
   // This is the address that logic will
   // receive and uses to map to node_data.
   typedef logic [4:0] identifier;
   typedef identifier [NUM_MSG_HIERARCHY-1:0] dependency;
   typedef dependency [NUM_MSGS-1:0] dependencies_t;

   const dependency person_dependency      = {5'h00, 5'h01};
   const dependency phonenumber_dependency = {5'h04, 5'h01};

   const dependencies_t dependencies  = {person_dependency, phonenumber_dependency};

   //this is what goes in the RAM/ROM lookup
   //after the node address is found
   typedef logic node_data; //this would be msg/var_type/etc
   const node_data Person_msg      = 0;
   const node_data PhoneNumber_msg = 1;

   const node_data [NUM_MSGS-1:0]  node_ROM = {PhoneNumber_msg, Person_msg};

endpackage
