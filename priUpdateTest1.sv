class weightedPriority;
  randc var [3:0] dreq;

  constraint c {
    dreq dist {3:= 50, [0:2]:= 50};}
endclass

module top();

  logic [3:0] dreq,requestRegister,dreqFinal;
  logic [3:0] dack;
  logic priority1;
  prioritylogic uut (.*);
  initial begin
   requestRegister = 4'b1000;
   priority1 = 1'b1;
    /*for( bit[4:0] i=0; i<16;i++)
      begin
        dreq = i;
        #5;
      end*/
  end
    weightedPriority prioritise ;
initial begin


  prioritise = new();
  repeat(15)
    begin
  		assert (prioritise.randomize());
  		dreq = prioritise.dreq;
      #5;
    end
    end




    endmodule
