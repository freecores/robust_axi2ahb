
------------------------------ Remark ----------------------------------------
This code is a generic code written in RobustVerilog. In order to convert it to Verilog a RobustVerilog parser is required. 
It is possible to download a free RobustVerilog parser from www.provartec.com/edatools.

We will be very happy to receive any kind of feedback regarding our tools and cores. 
We will also be willing to support any company intending to integrate our cores into their project.
For any questions / remarks / suggestions / bugs please contact info@provartec.com.
------------------------------------------------------------------------------

RobustVerilog generic AXI to AHB bridge

In order to create the Verilog design use the run.sh script in the run directory (notice that the run scripts calls the robust binary (RobustVerilog parser)).

The RobustVerilog top source file is axi2ahb.v, it calls the top definition file named def_axi2ahb.txt.

The default definition file def_axi2ahb.txt generates a 32 data bit bridge.

Changing the interconnect parameters should be made only in def_axi2ahb.txt in the src/base directory (changing slave num etc.).




