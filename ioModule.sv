

module memory();

	tri IOWn,IORn;
	tri MEMRn,MEMWn;
	
	input logic [7:0]addressbus;
	inout logic [7:0]databus;
	
	input logic AEN,ADSTB;
	
	logic [7:0][15:0]Memory;
	logic [15:0]address;
	logic [7:0]data;
	
	
	assign AddrUp = AEN ? (ld_highAdd ?'1:'0):'0;
	assign AddrLow= AEN ? '1:'0;
	
	
	assign databus = ld_data ? Memory[address] : 'z;
	assign Memory[address] = ld_mem ? databus:Memory[address];
	
	always_ff@(posedge clock)
	begin
		if(AddrUp)
			address[15:0] <= databus;
		else
			address[15:0] <= address[15:0];
		if(AddrLow)
			address[7:0] <= databus;
		else
			address[7:0] <= address[7:0];
	end
	
	always_ff@(posedge clock)
	begin
		if(AEN)
			if(!IORn)
				ld_mem <='1;
			else
				ld_mem <='0;
		else
			ld_mem <='0;
	end
	
	always_ff@(posedge clock)
	begin
		if(AEN)
			if(!IOWn)
				ld_data <='1;
			else
				ld_data <='0;
		else
			ld_data <='0;
	end
		
		
endmodule