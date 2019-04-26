import user_tree_pkg::*;

module tbench_top;
  
  //clock and reset signal declaration
  bit clk;
  bit reset;

  identifier  field_id_i;
  logic       field_id_rdy;
  logic       field_id_valid;

  node_data   node;
  logic       node_valid;
  logic       node_rdy;

  
  //clock generation
  always #5 clk = ~clk;
  
  //reset Generation
  initial begin
    reset = 1;
    #5 reset =0;
  end

  initial begin
    field_id_valid = 0;
    node_rdy = 1;
    field_id_i = 0; 
    #50
    @(posedge clk) #1;
    field_id_valid = 1;
    field_id_i = 1; 
    @(posedge clk); #1;
    field_id_valid = 0;
    @(posedge clk); #1;
    @(posedge clk); #1;
  //  @(posedge clk);
    field_id_valid = 1;
    field_id_i = 4;
    do begin
     @(posedge clk);
    end while(!field_id_rdy); 
    #1;
    field_id_valid = 0;   
    end
    
  
  //DUT instance, interface signals are connected to the DUT ports
  node_tree DUT (

    .field_id_i(field_id_i),
    .field_id_rdy(field_id_rdy),
    .field_id_valid(field_id_valid),

    .node_valid(node_valid),
    .node_rdy(node_rdy),
    .node(node),

    .clk_i(clk),
    .reset_i(reset)
   );
  
endmodule
