package user_tree_pkg
 
   const integer NUM_MSG_HIERARCHY = 2;
   const integer NUM_MSGS = 2;
   const integer MAX_NODES_PER_LEVEL = 1;
   
   typedef enum msg_t (NULL_MESSAGE, PERSON, PHONE_NUMBER); 

   // This is the identifier that logic will
   // receive and uses to map to node_data.
   typedef logic [4:0] identifier;

   typedef struct node_data
   {
      identifier field_id;
      msg_t   msg_name;
   }

   const node_data Person_msg = (.field_id = 1,
                                 .msg_name = PERSON);

   const node_data PhoneNumber_msg = (.field_id = 4,
                                      .msg_name = PHONE_NUMBER);

   const node_data null_node_data = (.field_id = 0,
                                        .msg_name = NULL_MESSAGE);

   const integer null_node_id = 0;
   const integer person_node_id = 1;
   const integer phone_number_node_id = 2;


   typedef integer [NUM_MSG_HIERARCHY-1:0] dependency_t;

   const dependency_t person_dependency = [person_node_id, null_node_id);
   const dependency_t PhoneNumber_dependency = [person_node_id, phone_number_node_id];

   typedef dependency_t [NUM_MSGS-1:0] dependency_arr_t;
   const dependency_t dependencies = [person_dependency,
                                     PhoneNumber_dependency];

   // If using ROM based node data                                   
   const node_data [NUM_MSG:0] node_arr = [null_node_data,
                                           Person_msg,    
                                           PhoneNumber_msg];    

//  Callback function to find a node hit
//  Returns 1 for hit, 0 for miss
function logic node_hit(input identifier rcv_id;
                        input node_data tree_node);

   if (rcv_id == tree_node.field_id)
     return 1;

   return 0;

endfunction;

endpackage;
