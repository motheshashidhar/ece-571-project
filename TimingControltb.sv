module top();
logic clk,reset,HLDA,DREQ,HRQ,DACK,AEN,ADSTB,ALE,DmaRead,DmaWrite,EOPn,ldUpperAddr,Isread,TerminalCount,ChipSelN,carryPresent,EOP;

  
parameter CLOCK_CYCLE = 40;
parameter CLOCK_WIDTH = CLOCK_CYCLE/2;
  
  TimingAndControl uut(clk,reset,HLDA,DREQ,ChipSelN,carryPresent,TerminalCount,HRQ,DACK,AEN,ADSTB,ALE);
  
  initial 
begin 
clk= 1'b0;
forever #CLOCK_WIDTH clk = ~clk;
end
  
  initial 
begin
reset=1'b1;
  @ (negedge clk);
reset = 1'b0;
end
  
  initial 
    begin 
	@(negedge clk) ChipSelN=1'b1; DREQ=1'b1;   //Active 0
	@(negedge clk)   HLDA=1'b1;				   //Should go in Active 1
	@(negedge clk) TerminalCount=1'b0; #10;    //Active 2
	@(negedge clk) ; #10; 					   //Active 4
	@(negedge clk) carryPresent=1'b1; #10;     //If carry present then go to Active 1 state
	@(negedge clk); #10;                       //Active 2 
	@(negedge clk) TerminalCount=1'b1; #10      //Active 4 NextState will be Inactive 0 as TC=1
	$finish;
    end
endmodule