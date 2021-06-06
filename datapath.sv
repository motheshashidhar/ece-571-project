module DataPath ( interface IF );
  logic [3:0][15:0]currentAddressRegister;
  logic [3:0][15:0]currentWordCountRegister;
  logic [3:0][15:0]baseAddressRegister;
  logic [3:0][15:0]baseWordCountRegister;
  logic [15:0]temporaryAddressRegister;
  logic [15:0]temporaryWordCountRegister;
  logic [7:0] temp;
  logic [7:0]commandRegister;
  logic [3:0]maskRegister;
  logic [3:0]requestRegister;
  logic [3:0][5:0]modeRegister;
  logic [7:0]statusRegister;
  bit bytePointerlow;

  bit ldCommandRegister;
  bit ldRequestRegister;
  bit ldSingleMaskbitRegister;
  bit ldModeRegister;
  bit enStatusRegister;
  bit enTemporaryRegister;
  bit clearBytePointerFF;
  bit masterClear;
  bit ldMaskRegister;
  bit clearMaskRegister;
  bit ldAddrReg;
  bit ldWordCountReg;
  bit enAddrReg;
  bit enWordCountReg;



  // signals to be written in interface//
  logic [7:0]dataBus;
  logic IOR_N;
  logic IOW_N;
  logic MEMR_N;
  logic MEMW_N;
  logic [7:0] address;
  logic  clk;
  logic rst;
  logic CS_N;




  assign channelNo =  (!CS_N) ? address[2:1] : 'bz;  // also little confusion over here                 // except this all signals over here goes to interface
  assign IF.RotatingPriority = commandRegister[4];
  assign IF.FixedPriority = !commandRegister[4];
  assign IF.transferMode = 2'b10;
  assign IF.requestRegister = requestRegister;
  assign IF.statusRegister = statusRegister;
  assign IF.maskRegister = maskRegister;

  always_comb
    begin

      // databus logic//
      if(CS_N) // transfer mode
        begin
          if(IF.ldUpperAddress)
            assign dataBus = temporaryAddressRegister[15:8];
          else assign dataBus = 'bz;
        end

      else if(!CS_N) // programing mode
        begin
          if(!IOR_N)
            begin
              if(enAddrReg)begin if(bytePointerlow) assign dataBus = currentAddressRegister[channelNo][7:0]; else assign dataBus = currentAddressRegister[channelNo][15:8]; end
              else if(!enAddrReg && enWordCountReg) begin if(bytePointerlow) assign dataBus = currentWordCountRegister[channelNo][7:0]; else assign dataBus= currentWordCountRegister[channelNo][15:8]; end
              else if(!enAddrReg && ! enWordCountReg) begin if(enStatusRegister) assign dataBus = statusRegister; else if (enTemporaryRegister) assign dataBus = temp; else assign dataBus = 'bz; end
              else assign dataBus = 'bz;
            end
        end


      // Address Bus logic

      if(CS_N && IF.ldLowerAddress) assign address = temporaryAddressRegister[7:0];
      else assign address = 'bz;

      //Terminal count logic
      if(temporaryWordCountRegister[channelNo] == '1) assign IF.TC = 1'b1;
      else assign IF.TC = 1'b0;


      // IF.isRead and isWrite logic
      if(modeRegister[channelNo][3:2] == 2'b10) assign IF.isRead = 1'b1;
      else if(modeRegister[channelNo][3:2] == 2'b01) assign IF.isRead = 1'b0;
      else begin assign IF.isRead = 1'bz;end



      //definations software commands and word count and adress register command codes


      if(!CS_N & !IOW_N & ((address[3:0] == 4'd0) || (address[3:0] == 4'd2) ||(address[3:0] == 4'd4) ||address[3:0] == 4'd6)) ldAddrReg =1;
      else if(!CS_N & !IOW_N & ((address[3:0] == 4'd1) || (address[3:0] == 4'd3) ||(address[3:0] == 4'd5) ||address[3:0] == 4'd7)) ldWordCountReg =1;
      else if(!CS_N & !IOR_N & ((address[3:0] == 4'd0) || (address[3:0] == 4'd2) ||(address[3:0] == 4'd4) ||address[3:0] == 4'd6)) enAddrReg = 1;
      else if(!CS_N & !IOR_N & ((address[3:0] == 4'd1) || (address[3:0] == 4'd3) ||(address[3:0] == 4'd5) ||address[3:0] == 4'd7)) enWordCountReg = 1;
      else if(!CS_N & !IOW_N & address[3:0] == 4'b1000) ldCommandRegister =1;
      else if(!CS_N & !IOW_N & address[3:0] == 4'b1001) ldRequestRegister = 1;
      else if(!CS_N & !IOW_N & address[3:0] == 4'b1010) ldSingleMaskbitRegister = 1;
      else if(!CS_N & !IOW_N & address[3:0] == 4'b1011) ldModeRegister =1;
      else if(!CS_N & !IOR_N & address[3:0] == 4'b1000) enStatusRegister =1;
      else if(!CS_N & !IOR_N & address[3:0] == 4'b1101) enTemporaryRegister =1;
      else if(!CS_N & !IOW_N & address[3:0] == 4'b1100) clearBytePointerFF =1;
      else if(!CS_N & !IOW_N & address[3:0] == 4'b1101) masterClear =1;
      else if(!CS_N & !IOW_N & address[3:0] == 4'b1111) ldMaskRegister =1;
      else if(!CS_N & !IOW_N & address[3:0] == 4'b1110) clearMaskRegister = 1;

    end

  // Register operations



  // operations
  always_ff@(posedge clk)
    begin
      if(masterClear| rst)  begin requestRegister <= '0; statusRegister <= '0; maskRegister <= '1; temporaryAddressRegister <= '0; temporaryWordCountRegister <= '0; currentAddressRegister <= baseAddressRegister; currentWordCountRegister <= baseWordCountRegister; end
      else begin

        statusRegister[7:4] <= IF.dmaReq;   // here IF.dmaReg is an intyerface signal
        statusRegister[channelNo] <= (temporaryWordCountRegister == '1) ? 1'b1 : statusRegister[channelNo];
        if(IF.ldTempRegister) temp <= dataBus; else temp <= temp;
        if(ldCommandRegister) commandRegister <= dataBus[7:0]; else commandRegister <= commandRegister;

        if(ldRequestRegister) requestRegister <= dataBus[3:0]; else requestRegister <= requestRegister;
        if(temporaryWordCountRegister == '1) statusRegister[channelNo] <= 1'b1; else statusRegister[channelNo] <= statusRegister[channelNo];
        if(clearMaskRegister) maskRegister <= '0; else  begin if(ldMaskRegister) maskRegister <= dataBus; else maskRegister<= maskRegister; end
        if(ldCommandRegister) commandRegister <= dataBus; else commandRegister <= commandRegister;
        //if(ldModeRegister) modeRegister <= dataBus; else modeRegister <= modeRegister; //  check this once
        if(ldModeRegister) modeRegister[channelNo] <= dataBus[7:2]; else modeRegister[channelNo] <= modeRegister[channelNo];

        temporaryAddressRegister 				<= CS_N ? (IF.AddrGen ? (modeRegister[channelNo][3] ? temporaryAddressRegister - 16'd1 : temporaryAddressRegister + 16'd1) : (IF.ldTempAddr ? currentAddressRegister[channelNo] : temporaryAddressRegister)) : '0;
        temporaryWordCountRegister				<= CS_N ? (IF.AddrGen ? (temporaryWordCountRegister != '1 ? temporaryWordCountRegister - 16'b1 : temporaryWordCountRegister) : (IF.ldTempAddr ? currentWordCountRegister[channelNo] : temporaryWordCountRegister)) : '0;
        baseAddressRegister[channelNo][7:0] 	<= ldAddrReg ? (bytePointerlow ? dataBus : baseAddressRegister[channelNo][7:0]) : baseAddressRegister[channelNo][7:0];
        baseAddressRegister[channelNo][15:8] 	<= ldAddrReg ? (!bytePointerlow ? dataBus : baseAddressRegister[channelNo][15:8]) : baseAddressRegister[channelNo][15:8];
        baseWordCountRegister[channelNo][7:0] 	<= ldWordCountReg ? (bytePointerlow ? dataBus : baseWordCountRegister[channelNo][7:0]) : baseWordCountRegister[channelNo][7:0];
        baseWordCountRegister[channelNo][15:8] <= ldWordCountReg ? (!bytePointerlow ? dataBus : baseWordCountRegister[channelNo][15:8]) : baseWordCountRegister[channelNo][15:8];



        //if(CS_N && modeRegister[5]  ) temporaryAddressRegister <= temporaryAddressRegister


        if(CS_N)

          begin
            if(IF.ldLowerAddress) currentAddressRegister[channelNo] <= temporaryAddressRegister;
            else if(!IF.ldLowerAddress && temporaryWordCountRegister == '1 && modeRegister[channelNo][4]) currentAddressRegister[channelNo] <= baseAddressRegister[channelNo];
            else if (!IF.ldLowerAddress && temporaryWordCountRegister == '1 && !modeRegister[channelNo][4]) currentAddressRegister[channelNo] <= currentAddressRegister[channelNo];
            else if(!IF.ldLowerAddress && temporaryAddressRegister != '1) currentAddressRegister[channelNo] <= currentAddressRegister[channelNo];

            if(IF.ldLowerAddress) currentWordCountRegister[channelNo] <= temporaryWordCountRegister;
            else if(!IF.ldLowerAddress && temporaryWordCountRegister == '1 && modeRegister[channelNo][4]) currentWordCountRegister[channelNo] <= baseWordCountRegister[channelNo];
            else if (!IF.ldLowerAddress && temporaryWordCountRegister == '1 && !modeRegister[channelNo][4]) currentWordCountRegister[channelNo] <= currentWordCountRegister[channelNo];
            else if(!IF.ldLowerAddress && temporaryAddressRegister != '1) currentWordCountRegister[channelNo] <= currentWordCountRegister[channelNo];

          end

        else
          begin
            if(ldAddrReg && bytePointerlow) currentAddressRegister[channelNo][7:0] <= dataBus;
            else currentAddressRegister[channelNo][7:0] <= currentAddressRegister[channelNo][7:0];

            if(ldAddrReg && !bytePointerlow) currentAddressRegister[channelNo][15:8] <= dataBus;
            else currentAddressRegister[channelNo][15:8] <= currentAddressRegister[channelNo][7:0];

            if(ldWordCountReg && bytePointerlow) currentWordCountRegister[channelNo][7:0] <= dataBus;
            else currentWordCountRegister[channelNo][7:0] <= currentWordCountRegister[channelNo][7:0];

            if(ldWordCountReg && !bytePointerlow) currentWordCountRegister[channelNo][15:8] <= dataBus;
            else currentWordCountRegister[channelNo][15:8] <= currentWordCountRegister[channelNo][15:8];

          end
      end
    end

  always_ff@(posedge clk)

    begin
      if (rst | masterClear | clearBytePointerFF)
        bytePointerlow <= '0;
      else if(!bytePointerlow)
        bytePointerlow <= ~bytePointerlow;
    end
  endmodule
