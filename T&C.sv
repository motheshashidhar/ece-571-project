//Timing and Control 
module TimingAndControl(input logic clk,rst,HLDA,DREQ,CS_N,carryPresent,TC,output logic HRQ,DACK,AEN,ADSTB,ALE);
  logic dmaRead; // Data is written from memory to Peripheral device.
  logic dmaWrite; // Data is read from Peripheral device into the memory.
  logic ldUpperAddr; //should be one internal signal. in state Active1 to load temp addr. connecting to data bus.
  logic isRead; 
  logic EOP_N;// internal signal coming from mode reg to inform if dma has to  perform read/write

  enum logic[4:0]{Inactive0=5'b00001,
                  Active0=5'b00010,
                  Active1=5'b00100,
                  Active2=5'b01000,
                  Active4=5'b10000}State,NextState; //explicit enum definition.

  assign MEMW_N = AEN ? (dmaWrite ?  1'b0 : 1'b1) : 1'bz; //.
  assign IOR_N  = AEN ? (dmaWrite ?  1'b0 : 1'b1) : 1'bz;
  assign MEMR_N= AEN ? (dmaRead ?  1'b0 : 1'b1) : 1'bz;
  assign IOW_N = AEN ? (dmaRead ?  1'b0 : 1'b1) : 1'bz;
  assign EOP_N=TC ? 1'b0 :1'b1;
 


  always_ff @ (posedge clk)
    begin

      if (rst)  State <= Inactive0;
      else  State <= NextState;
    end
//--------------------------------------------------------------------------Next State Logic.-----------------------------------------------------------------------------
  always_comb
    begin
	isRead=1'b0;
      NextState = State;

        unique case (State)
        Inactive0: begin
          if (CS_N && DREQ) NextState = Active0; //if chip is selected and there is a request on the channel,transition to Active0 state takes place.
          else NextState = Inactive0;
        end

        Active0: begin
          if  (!EOP_N || !DREQ) NextState = Inactive0;
          else if (HLDA) NextState  = Active1;
          else if(!HLDA) NextState = Active0;
        end

        Active1: begin
          if (!EOP_N) NextState = Inactive0; //EOP_N=0 then go to Inactive0
          else NextState = Active2;
       end

        Active2: begin
          if (!EOP_N) NextState = Inactive0;
          else NextState = Active4;
        end

        Active4: begin
          if(!EOP_N || TC) NextState = Inactive0;
          else if(carryPresent) NextState = Active1; //Active1 state will occur when A8-A15 need updating.
          else if (!carryPresent)  NextState = Active2;  //Only when Lower order bits change.
        end
      endcase
    end
//------------------------------------------------------------------------Output Logic----------------------------------------------------------------------
  always_comb begin
    {HRQ,DACK,ADSTB,AEN} = 4'b0;
     unique case (State)
      Inactive0 : begin
                  HRQ = 1'b1;
                  AEN = 1'b0;
                  end

      Active1   : begin
                  ADSTB = (!EOP_N ? 1'b0 : 1'b1);
                  AEN = (!EOP_N ? 1'b0 : 1'b1);
                  ldUpperAddr = (!EOP_N ? 1'b0 : 1'b1);
                  DACK = (!EOP_N ? 1'b0 : 1'b1);
                  end 

      Active2   : begin
                  ADSTB = 1'b0;
                  ldUpperAddr = 1'b0;
                  end

      Active4   : begin
                  dmaRead = (!EOP_N || TC) ? 1'b0 : (isRead ? 1'b1 : 1'b0);
                  dmaWrite = (!EOP_N || TC) ? 1'b0 : (!isRead ? 1'b1 : 1'b0);
                  AEN = (!EOP_N || TC) ? 1'b0 : 1'b1;
                 end
    endcase
  end

endmodule