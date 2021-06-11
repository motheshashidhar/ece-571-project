module TimingAndControl(interface IF, IF1);
  logic dmaRead; // Data is written from memory to Peripheral device.
  logic dmaWrite; // Data is read from Peripheral device into the memory.
  logic EOPn ;

//[1] When Terminal Count is reached i.e. it is asserted EOPn(active low) is asserted.
property TerminalCount_p;
disable iff (IF.rst)
 @(posedge IF.clk)
 IF.TC|->(!EOP_N);
endproperty
 
TerminalCount_a: assert property TerminalCount_p;
 
 
 
//[2] In state Active 1 if Terminal Count is reached Next State goes to Inactive 0
property active1TC_p;
disable iff (IF.rst);
 @(posedge IF.clk)
 IF.TC &&(State==Active1)|->(NextState=Inactive0);
 endproperty
 
 active1TC_a:assert property active1TC_p;
 
 
 
//[3] In state Active 1 if Terminal Count is reached Next State goes to Inactive 0
property active1TC_p;
disable iff (IF.rst)
 @(posedge IF.clk)
 IF.TC && (State==Active1)|->(NextState=Inactive0);
 endproperty
 
 active1TC_a:assert property active1TC_p;
 
 
 
//[4] In state Active 2 if Terminal Count is reached Next State goes to Inactive 0
property active2TC_p;
disable iff (IF.rst);
 @(posedge IF.clk)
 IF.TC &&(State==Active2)|->(NextState=Inactive0);
 endproperty
 
 active2TC_a:assert property active2TC_p;
 
 
 
//[5] In state Active 4 if Terminal Count is reached Next State goes to Inactive 0
property active4TC_p;
disable iff (IF.rst);
 @(posedge IF.clk)
 IF.TC &&(State==Active4)|->(NextState=Inactive0);
 endproperty

 active4TC_a:assert property active4TC_p;
 
 
 
//[6]If State is Inactive 0 then HRQ should be asserted and IF1.AEN should be deasserted
property outputInactive0_p;
disable iff (IF.rst)
 @(posedge IF.clk)
 (State==Inactive0)|->(HRQ) && (!IF1.AEN);
 endproperty
 
 outputInactive0_a: assert property outputInactive0_p;
 
 
 
//[7]If state is Active 1 then IF1.AEN IF1.ADSTB ldUpperAddr IF1.DACK should be asserted
property outputActive1_p;
disable iff(IF.rst)
@(posedge IF.clk)
(State==Active1)|=>(IF1.AEN) && (IF1.ADSTB) && (IF1.ldUpperAddress) && (IF1.DACK);
endproperty

outputActive1_a:assert property outputActive1_p;



//[8]If state is Active 2 then IF1.ADSTB and ldUpperAddr should be deasserted
property outputActive2_p;
disable iff(IF.rst)
@(posedge IF.clk)
(State==Active2)|->(IF1.ADSTB) && (!IF1.ldUpperAddress)
endproperty

outputActive2_a:assert property outputActive2_p;



//[9]If state is Inactive0 then check Next State
property nextstateInactive0_p;
disable iff(IF.rst)
@(posedge IF.clk)
chipSelN && IF1.DREQ && (State=Inactive0)|=>(NextState=Active0);
endproperty

nextstateInactive0_a: assert property nextstateInactive0_p;



//[10]If state is Active 0 then check Next State
property nextstateActive0_p;
disable iff(IF.rst)
@(posedge IF.clk)
HLDA && (State=Active0)|=>(NextState=Active1);
endproperty

nextstateActive0_a: assert property nextstateActive0_p;



//[11]If state is Active 1 then check Next State
property nextstateActive1_p;
disable iff(IF.rst)
@(posedge IF.clk)
EOPn && (State=Active1) |=>(NextState=Active2);
endproperty

nextstateActive1_a: assert property nextstateActive1_p;



//[12]If state is Active 2 then check Next State 
property nextstateActive4_p;
disable iff(IF.rst)
@(posedge IF.clk)
EOPn && (State=Active2)|=>(NextSate=Active4);
endproperty

nextstateActive2_a: assert property nextstateActive2_p;



//[13]If state is Active 4 then check Next State if carry present
property carryPresentActive4_p;
disable iff(IF.rst)
@(posedge IF.clk)
IF.carryPresent && (State=Active4)|=>(NextSate=Active1);
endproperty

carryPresentActive4_a: assert property carryPresentActive4_p;



//[14]If state is Active 4 then check Next State if no carry present 
property noCarryActive4_p;
disable iff(IF.rst)
@(posedge IF.clk)
(!IF.carryPresent) && (State=Active4) |=>(NextState=Active2);
endproperty

noCarryActive4_a: assert property noCarryActive4_p;



//[15]If Address Strobe is high for only one cycle

property AddressStrobe_p;
disable iff(IF.rst)
	@(posedge IF.clk)
	chipSelN |-> IF1.ADSTB ##1 (~IF1.ADSTB);
endproperty

AddressStrobe_a: assert property (AddressStrobe_p);



//[16] EOPn is deasserted when transfer is complete

property EOPCheck_p;
disable iff(IF.rst)
	@(posedge IF.clk)
	((chipSelN) && (IF.TC)) |=> (!EOPn);
endproperty

EOPCheck_a: assert property (EOPCheck_p);



//[17]  When State is Active 4 and IF.isRead is zero then MEMWn and IORn are asserted (active low)
property isReadzero_p;
disable iff(IF.rst)
	@(posedge IF.clk)
	  (State==Active4) && (IF.isRead==0)|->(!MEMWn) && (!IORn)
endproperty

isReadzero_a: assert property (isReadzero_p);



//[18]  When State is Active 4 and IF.isRead is one then MEMRn and IOWn are asserted (active low)
property isReadone_p;
disable iff(IF.rst)
	@(posedge IF.clk)
	  (State==Active4) && (IF.isRead==1)|->(!MEMRn) && (!IOWn)
endproperty
isReadone_a: assert property (isReadone_p);

//[19]If state is inactive 0 NextState cannot be Active 1
property notNextstate1_p;
disable iff(IF.rst)
	@(posedge IF.clk)
	(State==Inactive0)|->(NextState!=Active1);
endproperty

notNextState1_a:assert property (notNextState1_p);

//[20]If state is inactive 0 NextState cannot be Active 2
property notNextstate2_p;
disable iff(IF.rst)
	@(posedge IF.clk)
	(State==Inactive0)|->(NextState!=Active2);
endproperty

notNextState2_a:assert property (notNextState2_p);

//[21]If state is inactive 0 NextState cannot be Active 4
property notNextstate3_p;
disable iff(IF.rst)
	@(posedge IF.clk)
	(State==Inactive0)|->(NextState!=Active4);
endproperty

notNextState3_a:assert property (notNextState3_p);


//[22]If state is Active 0 Nextstate cannot be Active 4
property notNextState4_p;
disable iff(IF.rst)
@(posedge IF.clk)
(State==Active0)|->(NextState!=Active4);
endproperty

notNextState4_a:assert property (notNextState4_p);

//[23]If state is Active1 NextState cannot be Active4
property notNextState5_p;
disable iff(IF.rst)
@(posedge IF.clk)
(State==Active1)|->(NextState!=Active4);
endproperty

notNextState5_a:assert property (notNextState5_p);

//[24]If state is Active2 NextState cannot be Active 1
property notNextState6_p;
disable iff(IF.rst)
@(posedge IF.clk)
(State==Active2)|->(NextState!=Active1);
endproperty

notNextState5_a:assert property(notNextState6_p);

//[25]If state is Active4 NextState cannot be Active0
property notNextState7_p;
disable iff(IF.rst)
@(posedge IF.clk)
(State==Active4)|->(NextState!=Active0);
endproperty

notNextState7_a: assert property(notNextState7_p);
