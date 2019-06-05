package user_tree_pkg;
 
   parameter NUM_MSG_HIERARCHY = 2;
   parameter NUM_MSGS = 2;
   parameter MAX_NODES_PER_LEVEL = 1;
   parameter IDENTIFIER_SIZE = 5;
   

   typedef enum {PERSON, PHONE_NUMBER} msg_t; 

   // This is the address that logic will
   // receive and uses to map to node_data.
   typedef logic [4:0] identifier;


   typedef struct packed
   {
      logic [IDENTIFIER_SIZE-1:0] field_id;
      msg_t   msg_name;
   } node_data;

   const node_data Person_msg      = {5'h1,
                                       PERSON};

   const node_data PhoneNumber_msg = {5'h4,
                                       PHONE_NUMBER};


   typedef logic [IDENTIFIER_SIZE-1:0] dependency_t [NUM_MSG_HIERARCHY];

   const dependency_t person_dependency [NUM_MSG_HIERARCHY] = {5'h1, 5'h0, 5'h0}
   const dependency_t phonenumber_node  = {5'h1, 5'h4, 5'h0}

   typedef  dependency_arr_t [NUM_MSGS];
   const dependency_arr_t dependencies = {person_dependency,
                                     PhoneNumber_dependency};  

//  Callback function to find a node hit
//  Returns 1 for hit, 0 for miss
function logic node_hit(input identifier rcv_id,
                        input node_data tree_node);

   if (rcv_id == tree_node.field_id)
     return 1;

   return 0;

endfunction;

endpackage
