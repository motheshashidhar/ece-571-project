// Code your design here
module TimingAndControl(interface IF, IF1);
  logic dmaRead; // Data is written from memory to Peripheral device.
  logic dmaWrite; // Data is read from Peripheral device into the memory.
  //logic IF.ldUpperAddress; //should be one internal signal. in state Active1 to load temp addr. connecting to data bus.
  //logic IF.isRead; 
logic EOPn = 1;// internal signal coming from mode reg to inform if dma has to  perform read/write
  

   
  enum logic[4:0]{Inactive0=5'b00001,
                  Active0=5'b00010,
                  Active1=5'b00100,
                  Active2=5'b01000,
                  Active4=5'b10000}State,NextState; //explicit enum definition.

  assign MEMW_N = IF1.AEN ? (dmaWrite ?  1'b0 : 1'b1) : 1'bz; //.
  assign IOR_N  = IF1.AEN ? (dmaWrite ?  1'b0 : 1'b1) : 1'bz;
  assign MEMR_N= IF1.AEN ? (dmaRead ?  1'b0 : 1'b1) : 1'bz;
  assign IOW_N = IF1.AEN ? (dmaRead ?  1'b0 : 1'b1) : 1'bz;
  assign EOP_N=IF.TC ? 1'b0 :1'b1;
 


  always_ff @ (posedge IF.clk)
    begin

      if (IF.rst)  State <= Inactive0;
      else  State <= NextState;
    end
//--------------------------------------------------------------------------Next State Logic.-----------------------------------------------------------------------------
  always_comb
    begin
	//EOP=1'b0;
	//IF.isRead=1'b0;
      NextState = State;

        unique case (State)
        Inactive0: begin
          if (IF1.CS_N && IF1.DREQ) NextState = Active0; //if chip is selected and there is a request on the channel,transition to Active0 state takes place.
          else NextState = Inactive0;
        end

        Active0: begin
          if  (!EOPn || !IF1.DREQ) NextState = Inactive0;
          else if (IF1.HLDA) NextState  = Active1;
          else   NextState = Active0;
        end

        Active1: begin
          if (!EOPn) NextState = Inactive0; //EOPn=0 then go to Inactive0
          else NextState = Active2;
       end

        Active2: begin
          if (!EOPn) NextState = Inactive0;
          else NextState = Active4;
        end

        Active4: begin
          if(!EOPn || IF.TC) NextState = Inactive0;
          else if(IF.carrypresent) NextState = Active1; //Active1 state will occur when A8-A15 need updating.
          else if (!IF.carrypresent)  NextState = Active2;  //Only when Lower order bits change.
        end
      endcase
    end
//------------------------------------------------------------------------Output Logic----------------------------------------------------------------------
  always_comb begin
    {IF1.HRQ,IF1.DACK,IF1.ADSTB,IF1.AEN} = 4'b0;
     unique case (State)
      Inactive0 : begin
                  IF1.HRQ = 1'b1;
                  IF1.AEN = 1'b0;
                  end

      /*Active0   : begin
                  end // doubts.*/

      Active1   : begin
                  IF1.ADSTB = (!EOPn ? 1'b0 : 1'b1);
                  IF1.AEN = (!EOPn ? 1'b0 : 1'b1);
                  IF.ldUpperAddress = (!EOPn ? 1'b0 : 1'b1);
                  IF1.DACK = (!EOPn ? 1'b0 : 1'b1);
                  end //Assert IF1.ADSTB inorder to output high order address bits to external latch U2.(ref diagram)

      Active2   : begin
                  IF1.ADSTB = 1'b0;
                  IF.ldUpperAddress = 1'b0;
                  end

      Active4   : begin
                  dmaRead = (!EOPn || IF.TC) ? 1'b0 : (IF.isRead ? 1'b1 : 1'b0);
                  dmaWrite = (!EOPn || IF.TC) ? 1'b0 : (!IF.isRead ? 1'b1 : 1'b0);
                  IF1.AEN = (!EOPn || IF.TC) ? 1'b0 : 1'b1;

                 end
    endcase
  end


endmodule
