#include <stdlib>
#include "Vnode_tree.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv)
{
   Verilated::commandArgs(argc, argv);

   Vnode_tree * tb = new Vnode_tree;

   Verilated::traceEverOn(true);
   VerilatedVcdC * trace = new VerilatedVcdC;
   tb->trace(trace, 99)
   trace->open("sim.vcd");

   uint32_t edge_cnt = 0;

   while(!Verilated::gotFinish())
   {
      tb->clk = 1;
      edge_cnt++;

      //do some rising edge stuff
      
      tb->eval();

      if(edge_cnt < 1000)
         trace->dump(edge_cnt);

      tb->clk = 0;
      edge_cnt++;

      //do some falling edge stuff

      tb->eval();

      if(edge_cnt < 1000)
         trace->dump(edge_cnt);
      else
         trace->close();

   }
  exit(EXIS_SUCCESS); 
}
