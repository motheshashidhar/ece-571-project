module prioritylogic(dreq,priority1,dack,requestRegister);
  input [3:0]requestRegister;
  input logic [3:0] dreq;
  logic [3:0] dreqFinal;
  input logic priority1;
  output logic [3:0]dack;
  bit [3:0] [1:0] channels = 8'b11100100; //an array with 4 elements where each element is 2 bit wide.

  assign dreqFinal = dreq | 4'b1 << requestRegister[1:0];
 // assign dreqFinal = dreq & (~(maskRegister[3:0]));

  always_comb begin


    if (dreqFinal[channels[0]]) begin

      dack[channels[0]] =1'b1;
      dack[channels[1]] = 1'b0;
      dack[channels[2]] = 1'b0;
      dack[channels[3]] = 1'b0;
      if (!priority1)  channels = 8'b11100100;
      else channels = {2'(channels[3] + 2'b01),2'(channels[2] + 2'b01),2'(channels[1] + 2'b01), 2'(channels[0]) + 2'b01};

    end
    else if (dreqFinal[channels[1]]) begin

      dack[channels[0]] =1'b0;
      dack[channels[1]] = 1'b1;
      dack[channels[2]] = 1'b0;
      dack[channels[3]] = 1'b0;
      if (!priority1)  channels = 8'b11100100;
      else channels = {2'(channels[3] + 2'b10),2'(channels[2] + 2'b10),2'(channels[1] + 2'b10), 2'(channels[0]) + 2'b10};

    end
    else if (dreqFinal[channels[2]]) begin

      dack[channels[0]] =1'b0;
      dack[channels[1]] = 1'b0;
      dack[channels[2]] = 1'b1;
      dack[channels[3]] = 1'b0;
      if (!priority1)  channels = 8'b11100100;
      else channels = {2'(channels[3] + 2'b11),2'(channels[2] + 2'b11),2'(channels[1] + 2'b11), 2'(channels[0]) + 2'b11};

    end
    else if (dreqFinal[channels[3]]) begin


      dack[channels[0]] =1'b0;
      dack[channels[1]] = 1'b0;
      dack[channels[2]] = 1'b0;
      dack[channels[3]] = 1'b1;
      if (!priority1)  channels = 8'b11100100;
      else channels = {2'(channels[3] + 2'b00),2'(channels[2] + 2'b00),2'(channels[1] + 2'b00), 2'(channels[0]) + 2'b00};
    end


  end
  initial begin
    $monitor ($time,"ns dreq = %b, dack = %b, channels= %b",dreq,dack,channels);
  end
endmodule
