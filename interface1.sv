
interface InternalBus(input logic clk, rst);

  wire  [1:0]channelNo;
  logic [3:0]requestRegister;
  logic	isRead;
  logic [3:0]maskRegister;
  logic [7:0]statusRegister;
  logic	transferMode;
  logic	RotatingPriority;
  logic FixedPriority;
  logic	DREQ_Sense;
  logic	DACK_Sense;
  logic TC;
  logic ldAck;
  logic Carry;
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
    output
    Carry,
    TC,
    isRead,
    transferMode,
    RotatingPriority,
    FixedPriority,
    DREQ_Sense,
    DACK_Sense,
    requestRegister,
    statusRegister,
    maskRegister
  );

  modport TimingAndControl (
    input TC,
    isRead,
    carry,
    ldUpperAddress,
  );


endinterface
