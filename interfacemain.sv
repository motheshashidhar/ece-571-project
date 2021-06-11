
	// Code your design here
interface dmaIFmain(input logic clk, rst);

  tri [7:0] dataBus;
  tri [7:0]address;
  tri IOW_N;
  tri IOR_N;
  logic MEMR_N;
  logic MEMW_N;
  logic CS_N;
  logic HLDA;
  logic[3:0] DREQ;
  logic HRQ;
  logic[3:0] DACK;
  logic AEN;
  logic ADSTB;

modport DataPath (
input 
IOW_N,
IOR_N,
MEMR_N,
MEMW_N,
CS_N,
inout
dataBus,
address
);  

modport timingcontrol (
input
HLDA,
DREQ,
CS_N,
output 
HRQ,
DACK,
ADSTB,
AEN
);

modport prioritylogic  (
output
DREQ,
DACK
);

modport CPU  (
inout   address,
		dataBus,
output  IOR_N,
		IOW_N,
		CS_N,
		HLDA,
input 	clk,
		HRQ,
		DREQ
);

endinterface


