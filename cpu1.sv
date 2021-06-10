
module top;  

  logic CLK = 1;
  logic RESET = 0;
  tri CS_N, IOR_N, IOW_N, MEMR_N, MEMW_N;
  tri [7:0] DB, ADDR;

  always #5 CLK = ~CLK;


  //instantiating interface1
  dmaIF interface1 (CLK,RESET);
  //instantiaitng CPU module
  CPUM cpu1(interface1);
  //instantiating DMA
  
endmodule
//interface definition

    
  
  module CPUM (dmaIF.CPU pins);
    logic [3:0] DREQ_R;
    
    logic [15:0] BCadd0;
    logic [15:0] BCCount0;
    
    logic [15:0] BCadd1;
    logic [15:0] BCCount1;
    
    logic [15:0] BCadd2;
    logic [15:0] BCCount2;
    
    logic [15:0] BCadd3;
    logic [15:0] BCCount3;
    
    logic [7:0] Command_R;
    logic [7:0] Mode_R;
    
    logic [7:0] DummyAddr;
    logic [7:0] DummyDB;
    logic DummyCS_N;
    logic DummyIOR_N;
    logic DummyIOW_N;
    
    
    
    initial
      begin
        BCadd0=16'h0000;
        BCCount0=16'h000F;
        
        BCadd1=16'h0000;
        BCCount1=16'h000F;
        
        BCadd2=16'h0000;
        BCCount2=16'h000F;
        
        BCadd3=16'h0000;
        BCCount3=16'h000F;
        
        Command_R=8'b10000000;
        Mode_R=8'b10100100;  
      end
    
    assign pins.address = (!pins.CS_N)?DummyAddr:8'bzzzzzzzz;
    assign pins.dataBus = (!pins.CS_N)?DummyDB:8'bzzzzzzzz;
    //assign pins.CS_N= (!pins.CS_N)?1'b1:1'bz;
    assign pins.IOR_N=(!pins.CS_N)?'0:1'bz;
    assign pins.IOW_N=(!pins.CS_N)?'1:1'bz;
    
    
    always @ (posedge pins.CLK)
      begin
      
        if (pins.HRQ==1)
          begin
        DREQ_R=pins.DREQ;
        taskdrive;
          end
      end
      
    task taskdrive;
      begin
        pins.CS_N = '0;
        repeat(2) @(posedge pins.CLK);
//        pins.CS_N=1'b0;
        
        //writing into command register
        @(posedge pins.CLK);
        DummyAddr=8'b00001000;
        DummyDB<=Command_R;
        
        //writing into mode register
        @(posedge pins.CLK);
        DummyAddr<=8'b00001011;
        DummyDB=Mode_R;
        
        if (DREQ_R[0]==1)
          begin
            //write channel0 adrress register
            @ (posedge pins.CLK);
            DummyAddr<=8'b00000000; 
            DummyDB<=BCadd0[15:8];
            
            @(posedge pins.CLK)
            DummyDB<=BCadd0[7:0];
            
            //write channel0 word count
            @(posedge pins.CLK);
            DummyAddr<=8'b00000001; 
            DummyDB<=BCCount0[15:8];
            
            @(posedge pins.CLK);
            DummyDB<=BCCount0[7:0];
            
            
          end
        
        else if (DREQ_R[1]==1)
          begin
            // write channel1 Adress register
            @(posedge pins.CLK);
            DummyAddr<=8'b00000010;
            DummyDB<=BCadd1[15:8];
            
            @(posedge pins.CLK);
            DummyDB<=BCadd1[7:0];
            
            //write channel1 word count
            @(posedge pins.CLK);
            DummyAddr<=8'b00000011; 
            DummyDB<=BCCount1[15:8];
            
            @(posedge pins.CLK);
            DummyDB<=BCCount1[7:0];
          end
        
        else if (DREQ_R[2]==1)
          begin
            // write channel2 Address register
            @(posedge pins.CLK);
            DummyAddr<=8'b00000100;
            DummyDB<=BCadd2[15:8];
            
            @(posedge pins.CLK);
            DummyDB<=BCadd2[7:0];
            
            //write channel2 word count
            @(posedge pins.CLK)
            DummyAddr<=8'b00000101; 
            DummyDB<=BCCount2[15:8];
            
            @(posedge pins.CLK);
            DummyDB<=BCCount2[7:0];
          end
        
        else if (DREQ_R[3]==1)
          begin
            
            //Write channel3 Address register
            @(posedge pins.CLK);
            DummyAddr<=8'b00000110;
            DummyDB<=BCadd3[15:8];
            
            @(posedge pins.CLK);
            DummyDB<=BCadd3[7:0];
            
            //write channel3 word count
            @(posedge pins.CLK);
            DummyAddr<=8'b00000111; 
            DummyDB<=BCCount3[15:8];
            
            @(posedge pins.CLK);
            DummyDB<=BCCount3[7:0]; 
          end
        
        repeat(2) @ (posedge pins.CLK);
        pins.CS_N=1'b1;
        
        repeat(2) @ (posedge pins.CLK);
        pins.HLDA=1'b1;
        
        
      end
    endtask
  
  endmodule
