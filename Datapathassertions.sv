module DataPath ( interface IF );
  logic [3:0][15:0]currentAddressRegister;
  logic [3:0][15:0]currentWordCountRegister;
  logic [3:0][15:0]baseAddressRegister;
  logic [3:0][15:0]baseWordCountRegister;
  logic [15:0]temporaryAddressRegister;
  logic [15:0]temporaryWordCountRegister;
  logic [7:0] temp;
  logic [7:0]commandRegister;
  logic [3:0]maskRegister;
  logic [3:0]requestRegister;
  logic [3:0][5:0]modeRegister;
  logic [7:0]statusRegister;
  bit bytePointerlow;

  bit ldCommandRegister;
  bit ldRequestRegister;
  bit ldSingleMaskbitRegister;
  bit ldModeRegister;
  bit enStatusRegister;
  bit enTemporaryRegister;
  bit clearBytePointerFF;
  bit masterClear;
  bit ldMaskRegister;
  bit clearMaskRegister;
  bit ldAddrReg;
  bit ldWordCountReg;
  bit enAddrReg;
  bit enWordCountReg;


  logic [7:0]dataBus;
  logic IOR_N;
  logic IOW_N;
  logic MEMR_N;
  logic MEMW_N;
  logic [7:0] address;
  logic  clk;
  logic rst;
  logic CS_N;

//Datapath assertions

//[1]Reset Current Address Register 
property resetCAR_p;
@(posedge IF.clk)
(IF.rst|masterClear)|=>(currentAddressRegister==baseAddressRegister);
endproperty

resetCAR_a:assert property resetCAR_p;



//[2]Reset Current Word Register 
property resetCWR_p;
@(posedge IF.clk)
(IF.rst|masterClear)|=>(currentWordRegister==baseWordRegister);
endproperty

resetCWR_a: assert property resetCWR_p;



//[3]reset Request register
property requestRegReset_p;
@(posedge IF.clk)
(IF.rst|masterClear)|=>(IF.requestRegister==='0);
endproperty

requestRegReset_a: assert property requestRegtReset_p;


//[4]reset status register 
property statusRegReset_p;
@(posedge IF.clk)
(IF.rst|masterClear)|=>(IF.statusRegister==='0);
endproperty

statusRegReset_a: assert property statusRegReset_p;


//[5]Reset Temporary Register
property tempReset_p;
@(posedge IF.clk)
(IF.rst|masterClear)|=>(temp==='0);
endproperty

tempReset_a: assert property tempReset_p;


//[6]Reset Temporary IF1.address register
property tempaddrRegReset_p;
@(posedge IF.clk)
(IF.rst|masterClear)|=>(tempAddressRegister==='0);
endproperty

tempaddrRegReset_a: assert property tempaddrRegReset_p;


//[7]Reset Temporary Word Count Register
property tempwordRegReset_p;
@(posedge IF.clk)
(IF.rst|masterClear)|=>(TempWordCountRegister==='0);
endproperty

tempwordRegReset_a: assert property tempwordRegReset_p;


//[8]IF1.IOW_N and IF1.IOR_N cannot be asserted at the same time
property iorORiow_p;
@(posedge IF.clk)
!IF1.CS_N|->!(!IF1.IOR_N &&!IF1.IOW_N);
endproperty

iorORiow_a:assert property iorORiow_p;


//[9]IF1.MEMR_N and MEMW_N cannot be asserted at the same time
property memrORmemw_p;
@(posedge IF.clk)
!IF1.CS_N|-> !(!IF1.MEMR_N && !MEMW_N);
endproperty

memrORmemw_a: assert property memrORmemw_p;

//[10]Address should be valid during write and read
property addressValid_p;
@(posedge IF.clk)
!(IF1.CS_N)|->(!IORW_N)||(!IF1.IOW_N)|->! $isunknown(IF1.address);
endproperty

addressValid_a:assert property addressValid_p;

//[11]Data should be valid during write 
property dataValid_p;
@(posedge IF.clk)
!(IF1.CS_N)|->(!IF1.IOW_N)|->! $isunknown(data);
endproperty

dataValid_a:assert property dataValid_p;

//[12]Data should be valid during read
property dataValidRead_p;
@(posedge IF.clk)
!(IF1.CS_N)|->(!IF1.IOR_N)|=> $isunknown(data);
endproperty

dataValidRead_a:assert property dataValidRead_p;

//[13]read lower byte to Current Address Register 
property addressRegReadlower_p;
disable iff(IF.rst|masterClear)
@(posedge IF.clk)
!IF1.CS_N & bytePointerlow & enAddrReg |-> (data == currentAddressRegister[IF.channelNo][7:0]);
endproperty

addressRegRead_a:assert property addressRegRead_p;

//[14]read higher bye to Current Address Register
property addressRegReadhigh_p;
disable iff(IF.rst|masterClear)
@(posedge IF.clk)
!IF1.CS_N & !bytePointerlow & enAddrReg |-> (data == currentAddressRegister[IF.channelNo][15:8]);
endproperty

addressRegReadhigh_a:assert property addressRegReadhigh_p;


//[15]BaseAddress does not change(stable) during transfer
property nochangeBaseAddr_p;
@(posedge IF.clk)
$stable(baseAddressRegister);
endproperty

nochangeBaseAddr_a:assert property nochangeBaseAddr_p;


//[16]BaseWord does not change(stable) during transfer
property nochangeBaseWord_p;
@(posedge IF.clk)
$stable(baseWordRegister);
endproperty

nochangeBaseWord_a:assert property nochangeBaseWord_p;
