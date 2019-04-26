package user_tree_pkg;
 
   parameter NUM_MSG_HIERARCHY = 3;  //null message is hierarchy 1
   parameter NUM_MSGS = 2;
   parameter MAX_NODES_PER_LEVEL = 1;
   
   typedef enum {NULL_MESSAGE, PERSON, PHONE_NUMBER} msg_t; 

   // This is the address that logic will
   // receive and uses to map to node_data.
   typedef logic [4:0] identifier;

   typedef struct
   {
      identifier field_id;
      msg_t   msg_name;
   } node_data;

   parameter node_data Person_msg = {field_id: 5'h1,
                                 msg_name: PERSON};

   parameter node_data PhoneNumber_msg = {field_id: 5'h4,
                                      msg_name: PHONE_NUMBER};

   parameter node_data null_node_data = {field_id: 5'h0,
                                     msg_name: NULL_MESSAGE};
                                     
   typedef struct
   {
     integer node_addr;
     node_data node;                               
   } tree_node_t;

   parameter tree_node_t null_node = {node_addr:0, node:null_node_data};
   parameter tree_node_t person_node = {node_addr:1, node:Person_msg};
   parameter tree_node_t phonenumber_node = {node_addr:2, node:PhoneNumber_msg};

   typedef tree_node_t dependency_t [NUM_MSG_HIERARCHY];

   parameter dependency_t person_dependency = {null_node, person_node, null_node};
   parameter dependency_t PhoneNumber_dependency = {null_node, person_node, phonenumber_node};

   typedef dependency_t dependency_arr_t [NUM_MSGS];
   parameter dependency_arr_t dependencies = {person_dependency,
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
