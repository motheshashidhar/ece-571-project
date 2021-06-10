interface dmaIF(input logic clk, rst);

  wire  [1:0]channelNo;					
  logic [3:0]requestRegister;
  logic	isRead;
  logic [3:0]maskRegister;
  logic [7:0]statusRegister;
  logic	[1:0]transferMode;
  logic	RotatingPriority;
  logic FixedPriority;
  //logic	DREQ_Sense;
  //logic	DACK_Sense;
  logic TC;							
  logic ldAck;						
  logic carrypresent;						
  logic [3:0] dmaReq;					
  logic AddrGen;					
  logic ldUpperAddress;					
  logic	ldLowerAddress;					
  logic ldTempRegister;					
  logic ldTempAddr;
  logic PriorityGen;


  modport DataPath	(
    input 	
    ldLowerAddress,
    ldUpperAddress,
    AddrGen,
    channelNo,
    ldTempRegister,
    ldTempAddr,
    dmaReq,
    clk,
    rst,
    output 		
    carrypresent,			
    TC,
    isRead,
    transferMode,			
    RotatingPriority,
    FixedPriority,
    //DREQ_Sense,				
    //DACK_Sense,				
    requestRegister,
    statusRegister,
    maskRegister								
  );
  
endinterface



