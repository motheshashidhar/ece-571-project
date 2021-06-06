// Code your design here
module TimingAndControl(input logic clk,reset,HLDA,DREQ,EOPn,ChipSelN,UpperAddr,TerminalCount,Isread,output logic HRQ,DACK,AEN,ADSTB,ALE);
  logic DmaRead; // Data is written from memory to Peripheral device.
  logic DmaWrite; // Data is read from Peripheral device into the memory.
  //logic ChipSelN; //ChipSelect:if low,chip is selected.
  //alias CS_N = ChipSelN;
  logic EOP; //active low End of process signal.
  logic ldUpperAddr; //should be one internal signal. in state Active1 to load temp addr. connecting to data bus.
  //logic Isread; // internal signal coming from mode reg to inform if dma has to  perform read/write
  //logic TerminalCount; //internal signal to check TC.

   /*enum {SIbit = 0,
         S0bit = 1,
         S1bit = 3,
         S2bit = 4,
         S4bit = 5}*/
  enum logic[4:0]{Inactive0=5'b00001,
                  Active0=5'b00010,
                  Active1=5'b00100,
                  Active2=5'b01000,
                  Active4=5'b10000}State,NextState; //explicit enum definition.

  assign MEMWn = AEN ? (DmaWrite ?  1'b0 : 1'b1) : 1'bz; //.
  assign IORn  = AEN ? (DmaWrite ?  1'b0 : 1'b1) : 1'bz;
  assign MEMRn = AEN ? (DmaRead ?  1'b0 : 1'b1) : 1'bz;
  assign IOWn  = AEN ? (DmaRead ?  1'b0 : 1'b1) : 1'bz;
  assign EOPn= EOP ? 1'b0 : 1'b1;



  always_ff @ (posedge clk)
    begin

      if (reset)  State <= Inactive0;
      else  State <= NextState;
    end
//--------------------------------------------------------------------------Next State Logic.-----------------------------------------------------------------------------
  always_comb
    begin
      NextState = State;

       case (State)
        Inactive0: begin
          if (ChipSelN && DREQ) NextState = Active0; //if chip is selected and there is a request on the channel,transition to Active0 state takes place.
          else NextState = Inactive0;
        end

        Active0: begin
          if  (!EOPn || !DREQ) NextState = Inactive0;
          else if (HLDA) NextState  = Active1;
          else   NextState = Active0;
        end

        Active1: begin
          if (!EOPn) NextState = Inactive0;
          else NextState = Active2;
       end

        Active2: begin
          if (!EOPn) NextState = Inactive0;
          else NextState = Active4;
        end

        Active4: begin
          if(!EOPn || TerminalCount) NextState = Inactive0;
          else if(UpperAddr) NextState = Active1; //Active1 state will occur when A8-A15 need updating.
          else if (!UpperAddr)  NextState = Active2;  //Only when Lower order bits change.
	//else NextState = UpperAddr ? Active1: Active2;
        end
      endcase
    end
//------------------------------------------------------------------------Output Logic----------------------------------------------------------------------
  always_comb begin
    {HRQ,DACK,ADSTB,AEN} = 4'b0;
     case (State)
      Inactive0 : begin
                  HRQ = 1'b1;
                  AEN = 1'b0;
                  end

      Active0   : begin

                  end // doubts.

      Active1   : begin
                  ADSTB = (!EOPn ? 1'b0 : 1'b1);
                  AEN = (!EOPn ? 1'b0 : 1'b1);
                  ldUpperAddr = (!EOPn ? 1'b0 : 1'b1);
                  DACK = (!EOPn ? 1'b0 : 1'b1);
                  end //Assert ADSTB inorder to output high order address bits to external latch U2.(ref diagram)

      Active2   : begin
                  ADSTB = 1'b0;
                  ldUpperAddr = 1'b0;
                  end

      Active4   : begin
                  DmaRead = (!EOPn || TerminalCount) ? 1'b0 : (Isread ? 1'b1 : 1'b0);
                  DmaWrite = (!EOPn || TerminalCount) ? 1'b0 : (!Isread ? 1'b1 : 1'b0);
                  EOP = (TerminalCount ? 1'b0 : 1'b1); //EOPn is active low s/g.
        AEN = (!EOPn || TerminalCount) ? 1'b0 : 1'b1;




                 end
    endcase
  end


endmodule
