// Code your testbench here
// or browse Examples

module top;
  logic clk = 0;
  logic rst;
  logic [7:0]data;
  logic read, write;
  logic [15:0] addr;
  
  
  dmaIF IF(clk, rst);
  dmaIFmain IF1();
  DataPath DP (.IF(IF.DataPath), .IF1(IF1.DataPath));
  TimingAndControl TC (.IF(IF.timingcontrol), .IF1(IF1.timingcontrol));
  always #5 clk = ~clk;
  assign IF1.dataBus = !IF1.CS_N ? (read ? 'bz : (write ? data : 'bz)): 'bz ;
  assign IF1.address = !IF1.CS_N ? addr : 'bz;
  assign IF1.IOR_N = !IF1.CS_N ? ~read : 'bz;
  assign IF1.IOW_N = !IF1.CS_N ? ~write : 'bz;
  initial
    begin
	
	clk = 1'b0; rst = 1'b1;
		@(negedge clk) rst <= 1'b0; write <= 1'b1; read <= 1'b0;
		//Writing to Base and Current Address registers in program mode
		IF1.CS_N <= 1'b0;//read <= 1'b0;
			for(int i=0;i<=6;i=i+2)
			begin
				addr <= 8'hc;data <= i*1;
				@(negedge clk) addr <= i;
				@(negedge clk) data <= i*2;
				repeat(2)@(negedge clk);
			end
			
			//Read all Base and Current Address registers in program mode
			for(int i =0;i<=6;i=i+2)
			begin
				addr<=8'hc; write<= '1;read <= '0;
				@(negedge clk)addr <= i;read <= '1; write<= '0;
				repeat(2)@(negedge clk);
			end
			
			//Write WordCount Registers
			for(int i =1;i<=7;i=i+2)
			begin
				addr<=8'hc;read <= '0;write <='1;data <= i*1;
				@(negedge clk) addr <= i;
				@(negedge clk) data <= i*2;
				repeat(2)@(negedge clk);
			end
      @(negedge clk) rst = 1'b0; IF1.CS_N = 1'b0;  read = 1'b0; write = 1'b1; addr = 8'b11111000; data = 8'b10000000; // write command register 
	  @(negedge clk) IF1.CS_N = 1'b0;  read = 1'b0; write = 1'b1; addr = 8'b11111001; data = 8'b10000100; // write request register
	  @(negedge clk) IF1.CS_N = 1'b0;  read = 1'b0; write = 1'b1; addr = 8'b11111011; data = 8'b10001000; // write mode register
	  @(negedge clk) IF1.CS_N = 1'b0;  read = 1'b0; write = 1'b1; addr = 8'b11111111; data = 8'b10001100; // write all mask register bits
	  @(negedge clk) IF1.CS_N = 1'b0;  read = 1'b0; write = 1'b1; addr = 8'b11111110; data = 8'b10001100; // clear mask register
	 // @(negedge clk) IF1.CS_N = 1'b0;  read = 1'b0; write = 1'b1; addr = 8'b11111100; data = 8'b10001100; // clear byte pointer ff
	 // @(negedge clk) IF1.CS_N = 1'b0;  read = 1'b0; write = 1'b1; addr = 8'b11111101; data = 8'b10001100; // master clear
	  @(negedge clk) IF1.CS_N = 1'b1; IF1.DREQ = 1'b1;  read = 1'b0; write = 1'b1; addr = 8'b11111111; data = 8'b11111111; // transfer mode
	  @(negedge clk) IF1.HLDA = 1'b1;
    end
endmodule