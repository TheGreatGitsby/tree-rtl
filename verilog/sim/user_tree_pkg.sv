package user_tree_pkg;
 
   parameter NUM_MSG_HIERARCHY = 2;
   parameter NUM_MSGS = 2;
   parameter MAX_NODES_PER_LEVEL = 1;
   parameter IDENTIFIER_SIZE = 5;
   

   typedef enum {PERSON, PHONE_NUMBER} msg_t; 

   // This is the address that logic will
   // receive and uses to map to node_data.
   typedef logic [4:0] identifier;

   typedef logic [IDENTIFIER_SIZE-1:0] dependency_t [NUM_MSG_HIERARCHY];

   const dependency_t person_dependency [NUM_MSG_HIERARCHY] = {5'h1, 5'h0, 5'h0}
   const dependency_t phonenumber_node  = {5'h1, 5'h4, 5'h0}

   typedef  dependency_arr_t [NUM_MSGS];
   const dependency_arr_t dependencies = {person_dependency,
                                     PhoneNumber_dependency};  

   //this is what goes in the RAM/ROM lookup
   //after the node address is found
   typedef logic node_data; //this would be msg/var_type/etc
   const node_data Person_msg      = 0;
   const node_data PhoneNumber_msg = 1;

   const node_data node_ROM [NUM_MSGS-1] = {Person_msg, PhoneNumber_msg};

endpackage
