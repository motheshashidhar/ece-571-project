module top();
  logic [3:0] dreq;
  logic [3:0] dack;
  logic priority1;
  prioritylogic uut (.*);
  initial begin
   priority1 = 1'b0;
    for( bit[4:0] i=0; i<16;i++)
      begin
        dreq = i;
        #5;
      end
  end

endmodule

/*class randomPriority;
  randc [3:0] channels;
  constraint c {
    channels dist 3:=50, [0:2]: = 50};
endclass

initial begin
  randomPriority prioritise ;
  prioritise new();
  assert (prioritise.randomize())
    end*/
