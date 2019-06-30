#include <stdlib.h>
#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv)
{
   Verilated::commandArgs(argc, argv);

   Vtop * tb = new Vtop;

   Verilated::traceEverOn(true);
   VerilatedVcdC * trace = new VerilatedVcdC;
   tb->trace(trace, 99);
   trace->open("sim.vcd");

   uint32_t edge_cnt = 0;

   while(!Verilated::gotFinish())
   {
      tb->clk_i = 1;
      edge_cnt++;

      //do some rising edge stuff
         //default rising edge signals
      tb->field_id_valid = 0;
      tb->field_id = 0;

      if (edge_cnt == 5)
      {
         tb->field_id_valid = 1;
         tb->field_id = 0xAA;
      }
      if (edge_cnt == 11)
      {
         tb->field_id_valid = 1;
         tb->field_id = 0xBB;
      }
      
      tb->eval();

      if(edge_cnt < 1000)
         trace->dump(edge_cnt);

      tb->clk_i = 0;
      edge_cnt++;

      //do some falling edge stuff

      tb->eval();

      if(edge_cnt < 1000)
         trace->dump(edge_cnt);
      else
      {
         trace->close();
         exit(EXIT_SUCCESS); 
      }

   }
  exit(EXIT_SUCCESS); 
}
