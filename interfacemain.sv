// Code your design here
interface dmaIFmain();

  tri [7:0] dataBus;
  tri [7:0]address;
  logic IOW_N;
  logic IOR_N;
  logic MEMR_N;
  logic MEMW_N;
  logic CS_N;

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
endinterface


