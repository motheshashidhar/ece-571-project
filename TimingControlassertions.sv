//Assertions 

//[1] When Terminal Count is reached i.e. it is asserted EOPn(active low) is asserted.
property TerminalCount_p;
disable iff (rst);
 @(posedge clk)
 TC|->(!EOPn)
 endproperty
 
 TermialCount_a:assert property TerminalCount_p;
 
 
 
//[2] In state Active 1 if Terminal Count is reached Next State goes to Inactive 0
property active1TC_p;
disable iff (rst);
 @(posedge clk)
 TC &&(State==Active1)|->(NextState=Inactive0);
 endproperty
 
 active1TC_a:assert property active1TC_p;
 
 
 
//[3] In state Active 1 if Terminal Count is reached Next State goes to Inactive 0
property active1TC_p;
disable iff (rst)
 @(posedge clk)
 TC && (State==Active1)|->(NextState=Inactive0);
 endproperty
 
 active1TC_a:assert property active1TC_p;
 
 
 
//[4] In state Active 2 if Terminal Count is reached Next State goes to Inactive 0
property active2TC_p;
disable iff (rst);
 @(posedge clk)
 TC &&(State==Active2)|->(NextState=Inactive0);
 endproperty
 
 active2TC_a:assert property active2TC_p;
 
 
 
//[5] In state Active 4 if Terminal Count is reached Next State goes to Inactive 0
property active2TC_p;
disable iff (rst);
 @(posedge clk)
 TC &&(State==Active4)|->(NextState=Inactive0);
 endproperty

 active4TC_a:assert property active4TC_p;
 
 
 
//[6]If State is Inactive 0 then HRQ should be asserted and AEN should be deasserted
property outputInactive0_p;
disable iff (rst)
 @(posedge clk)
 (State==Inactive0)|->(HRQ) && (!AEN);
 endproperty
 
 outputInactive0_a: assert property outputInactive0_p;
 
 
 
//[7]If state is Active 1 then AEN ADSTB ldUpperAddr DACK should be asserted
property outputActive1_p;
disable iff(rst)
@(posedge clk)
(State==Active1)|=>(AEN) && (ADSTB) && (ldUpperAddress) && (DACK);
endproperty

outputActive1_a:assert property outputActive1_p;



//[8]If state is Active 2 then ADSTB and ldUpperAddr should be deasserted
property outputActive2_p;
disable iff(rst)
@(posedge clk)
(State==Active2)|->(ADSTB) && (!ldUpperAddress)
endproperty

outputActive2_a:assert property outputActive2_p;



//[9]If state is Inactive0 then check Next State
property nextstateInactive0_p;
disable iff(rst)
@(posedge clk)
chipSelN && DREQ && (State=Inactive0)|=>(NextState=Active0);
endproperty

nextstateInactive0_a: assert property nextstateInactive0_p;



//[10]If state is Active 0 then check Next State
property nextstateActive0_p;
disable iff(rst)
@(posedge clk)
HLDA && (State=Active0)|=>(NextState=Active1);
endproperty

nextstateActive0_a: assert property nextstateActive0_p;



//[11]If state is Active 1 then check Next State
property nextstateActive1_p;
disable iff(rst)
@(posedge clk)
EOPn && (State=Active1) |=>(NextState=Active2);
endproperty

nextstateActive1_a: assert property nextstateActive1_p;



//[12]If state is Active 2 then check Next State 
property nextstateActive4_p;
disable iff(rst)
@(posedge clk)
EOPn && (State=Active2)|=>(NextSate=Active4);
endproperty

nextstateActive2_a: assert property nextstateActive2_p;



//[13]If state is Active 4 then check Next State if carry present
property carryPresentActive4_p;
disable iff(rst)
@(posedge clk)
carryPresent && (State=Active4)|=>(NextSate=Active1);
endproperty

carryPresentActive4_a: assert property carryPresentActive4_p;



//[14]If state is Active 4 then check Next State if no carry present 
property noCarryActive4_p;
disable iff(rst)
@(posedge clk)
(!carryPresent) && (State=Active4) |=>(NextState=Active2);
endproperty

noCarryActive4_a: assert property noCarryActive4_p;



//[15]If Address Strobe is high for only one cycle

property AddressStrobe_p;
disable iff(rst)
	@(posedge clk)
	chipSelN |-> ADSTB ##1 (~ADSTB);
endproperty

AddressStrobe_a: assert property (AddressStrobe_p);



//[16] EOPn is deasserted when transfer is complete

property EOPCheck_p;
disable iff(rst)
	@(posedge clk)
	((chipSelN) && (TC)) |=> (!EOPn);
endproperty

EOPCheck_a: assert property (EOPCheck_p);



//[17]  When State is Active 4 and isRead is zero then MEMWn and IORn are asserted (active low)
property isReadzero_p;
disable iff(rst)
	@(posedge clk)
	  (State==Active4) && (isRead==0)|->(!MEMWn) && (!IORn)
endproperty

isReadzero_a: assert property (isReadzero_p);



//[18]  When State is Active 4 and isRead is one then MEMRn and IOWn are asserted (active low)
property isReadone_p;
disable iff(rst)
	@(posedge clk)
	  (State==Active4) && (isRead==1)|->(!MEMRn) && (!IOWn)
endproperty

isReadone_a: assert property (isReadone_p);





 
 