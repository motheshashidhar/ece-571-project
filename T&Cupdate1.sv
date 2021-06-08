// Code your design here
module TimingAndControl(input logic clk,reset,chipSelectN,carry,TC, HLDA,DREQ,EOP,output logic HRQ,DACK,AEN,ADSTB,ALE);
  logic dmaRead; // Data is written from memory to Peripheral device.
  logic dmaWrite; // Data is read from Peripheral device into the memory.
  logic ldUpperAddr; //should be one internal signal. in state Active1 to load temp addr. connecting to data bus.
  logic isRead; // internal signal coming from mode reg to inform if dma has to  perform read/write
  logic EOPn;

  /*enum  {SIbit = 0, //Index of individual states in state register.
         S0bit = 1,
         S1bit = 3,
         S2bit = 4,
         S4bit = 5}

  Shift a 1 to the bit that represents each state.
  enum logic [4:0] {Inactive0 = 5'b00001 << SIbit,
                    Active0 = 5'b00001 << S0bit,
                    Active1 = 5'b00001 << S1bit,
                    Active2 = 5'b00001 << S2bit,
                    Active4 = 5'b00001 << S4bit,
                    }State,NextState;

  always_comb begin
    NextState = State;  //The default for each branch below.
    unique case(1'b1)   // reverse case statement
      State[SIbit] : if (ChipSelN && DREQ) NextState = Active0; //if chip is selected and there is a request on the channel,transition to Active0 state takes place.
                     else NextState = Inactive0;

  end */



  enum logic[4:0]{Inactive0=5'b00001,
                  Active0=5'b00010,
                  Active1=5'b00100,
                  Active2=5'b01000,
                  Active4=5'b10000}State,NextState; //explicit enum definition.

  assign MEMWn = AEN ? (dmaWrite ?  1'b0 : 1'b1) : 1'bz; //if it is a dma write operation, this s/g will be low i.e. activated.
  assign IORn  = AEN ? (dmaWrite ?  1'b0 : 1'b1) : 1'bz; //if it is a dma write operation, this s/g will be low i.e. activated.
  assign MEMRn = AEN ? (dmaRead ?  1'b0 : 1'b1) : 1'bz; //if it is a dma read operation, this s/g will be low i.e. activated.
  assign IOWn  = AEN ? (dmaRead ?  1'b0 : 1'b1) : 1'bz; //if it is a dma read operation, this s/g will be low i.e. activated.
  assign EOPn  = EOP ? 1'b0 : 1'b1;


  always_ff @ (posedge clk)
    begin

      if (reset)  State <= Inactive0;
      else  State <= NextState;
    end
//--------------------------------------------------------------------------Next State Logic.-----------------------------------------------------------------------------
  always_comb
    begin
      NextState = State;

      unique case (State)
        Inactive0: begin
          if (chipSelN && DREQ) NextState = Active0; //if chip is selected and there is a request on the channel,transition to Active0 state takes place.
          else NextState = Inactive0;
        end

        Active0: begin
          if  (!EOPn || !DREQ) NextState = Inactive0;
          else if (HLDA) NextState  = Active1;
          else   NextState = Active0;
        end

        Active1: begin
          if (!EOPn) NextState = InActive0;
          else NextState = Active2
        end

        Active2: begin
          if (!EOPn) NextState = Inactive0;
          else NextState = Active4;
        end

        Active4: begin
          if(!EOP || TC) NextState = Inactive0;
          else NextState = carryPresent ? Active1: Active2;  //if higher order bits changes, transition to S1 or after every byte transfer transition to s2.
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
                  DmaRead = (!EOPn || TC) ? 1'b0 : (isread ? 1'b1 : 1'b0);
                  DmaWrite = (!EOPn || TC) ? 1'b0 : (!isread ? 1'b1 : 1'b0);
                  EOP = (TC ? 1'b0 : 1'b1); //EOPn is active low s/g.
                  AEN = (!EOPn || TC) ? 1'b0 : 1'b1;
                 end
    endcase
  end


endmodule
