
INCLUDE def_axi2ahb.txt
OUTFILE PREFIX_axi2ahb_ctrl.v

module  PREFIX_axi2ahb_ctrl (PORTS);


   input                  clk;
   input                  reset;

   revport                GROUP_AHB;
   
   output                 ahb_finish;
   output                 rdata_phase;
   output                 wdata_phase;
   output                 data_last;

   input                  rdata_ready;
   input                  wdata_ready;        
   input                  cmd_empty;
   input                  cmd_read;
   input [ADDR_BITS-1:0]  cmd_addr;
   input [3:0]            cmd_len;
   input [1:0]            cmd_size;
   
   parameter              TRANS_IDLE   = 2'b00;
   parameter              TRANS_BUSY   = 2'b01;
   parameter              TRANS_NONSEQ = 2'b10;
   parameter              TRANS_SEQ    = 2'b11;
   
   parameter              BURST_SINGLE = 3'b000;
   parameter              BURST_INCR4  = 3'b011;
   parameter              BURST_INCR8  = 3'b101;
   parameter              BURST_INCR16 = 3'b111;

   
   wire                   data_ready;
   wire                   ahb_idle;
   wire                   ahb_ack;
   wire                   ahb_ack_last;
   wire                   ahb_start;
   wire                   ahb_last;
   wire                   data_last;
   reg [4:0]              cmd_counter;
   reg                    rdata_phase;
   reg                    wdata_phase;
   wire                   data_phase;
   reg [1:0]              HTRANS;
   reg [2:0]              HBURST;
   reg [1:0]              HSIZE;
   reg                    HWRITE;
   reg [ADDR_BITS-1:0]    HADDR;             
   

   assign                 ahb_finish   = ahb_ack_last;
   
   assign                 data_ready   = cmd_read ? rdata_ready : wdata_ready;
   assign                 data_phase   = wdata_phase | rdata_phase;
   
   assign                 ahb_idle     = HTRANS == TRANS_IDLE;
   assign                 ahb_ack      = HTRANS[1] & HREADY;
   assign                 ahb_ack_last = ahb_last & ahb_ack;
   assign                 ahb_start    = (~cmd_empty) & data_ready & ahb_idle & (HREADY | (~data_phase));
   assign                 data_last    = HREADY & (ahb_idle || (HTRANS == TRANS_NONSEQ));
   
   always @(posedge clk or posedge reset)
     if (reset)
       cmd_counter <= #FFD 4'd0;
     else if (ahb_ack_last)
       cmd_counter <= #FFD 4'd0;
     else if (ahb_ack)
       cmd_counter <= #FFD cmd_counter + 1'b1;

   assign             ahb_last = cmd_counter == cmd_len;
   
   always @(posedge clk or posedge reset)
     if (reset)
       rdata_phase <= #FFD 1'b0;
     else if (ahb_ack & (~HWRITE))
       rdata_phase <= #FFD 1'b1;
     else if (data_last)
       rdata_phase <= #FFD 1'b0;
   
   always @(posedge clk or posedge reset)
     if (reset)
       wdata_phase <= #FFD 1'b0;
     else if (ahb_ack & HWRITE)
       wdata_phase <= #FFD 1'b1;
     else if (data_last)
       wdata_phase <= #FFD 1'b0;
   
   always @(posedge clk or posedge reset)
     if (reset)
       HTRANS <= #FFD TRANS_IDLE;
     else if (ahb_start)
       HTRANS <= #FFD TRANS_NONSEQ;
     else if (ahb_ack_last)
       HTRANS <= #FFD TRANS_IDLE;
     else if (ahb_ack)
       HTRANS <= #FFD TRANS_SEQ;

   always @(posedge clk or posedge reset)
     if (reset)
       HBURST <= #FFD BURST_SINGLE;
     else if (ahb_start & (cmd_len == 4'd0))
       HBURST <= #FFD BURST_SINGLE;
     else if (ahb_start & (cmd_len == 4'd3))
       HBURST <= #FFD BURST_INCR4;
     else if (ahb_start & (cmd_len == 4'd7))
       HBURST <= #FFD BURST_INCR8;
     else if (ahb_start & (cmd_len == 4'd15))
       HBURST <= #FFD BURST_INCR16;
   
   always @(posedge clk or posedge reset)
     if (reset)
       HSIZE <= #FFD 2'b00;
     else if (ahb_start)
       HSIZE <= cmd_size;
  
   always @(posedge clk or posedge reset)
     if (reset)
       HWRITE <= #FFD 2'b00;
     else if (ahb_start)
       HWRITE <= (~cmd_read);
   
   always @(posedge clk or posedge reset)
     if (reset)
       HADDR <= #FFD {ADDR_BITS{1'b0}};
     else if (ahb_start)
       HADDR <= #FFD cmd_addr;
     else if (ahb_ack_last)
       HADDR <= #FFD {ADDR_BITS{1'b0}};
     else if (ahb_ack)
       HADDR <= #FFD HADDR + (
                              HSIZE == 2'b00 ? 4'd1 :
                              HSIZE == 2'b01 ? 4'd2 :
                              HSIZE == 2'b10 ? 4'd4 :
                              HSIZE == 2'b11 ? 4'd8 : 
                              4'd0);
   

endmodule

   
