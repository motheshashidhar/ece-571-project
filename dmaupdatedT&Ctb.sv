module top();
logic clk,rst,HLDA,DREQ,HRQ,DACK,AEN,ADSTB,ALE,dmaRead,dmaWrite,EOPn,ldUpperAddr,isRead,TC,CS_N,carryPresent;

parameter clk_CYCLE = 40;
parameter clk_WIDTH = clk_CYCLE/2;
  
  TimingAndControl uut(clk,rst,HLDA,DREQ,CS_N,carryPresent,TC,HRQ,DACK,AEN,ADSTB,ALE);
  
  initial 
begin 
clk= 1'b0;
forever #clk_WIDTH clk = ~clk;
end
  
  initial 
begin
rst=1'b1;
  @ (negedge clk);
rst = 1'b0;
end
  
  initial 
    begin 
	@(negedge clk) CS_N=1'b1; DREQ=1'b1;  //Active 0
	@(negedge clk)   HLDA=1'b1;//Should go in Active 1
	@(negedge clk) TC=1'b0; #10; 
	@(negedge clk) ; #10;
	@(negedge clk) carryPresent=1'b1; #10;
	@(negedge clk); #10;
	@(negedge clk) TC=1'b1; #10

	
	$finish;
    end
endmodule