//Priority Assertions


//[1]If it is fixed priority then check if the channels are getting fixed priority values
property FixedPriority_p;
@(posedge IF.clk)
priority1==1'b1|->channels = 8'b11100100;
endproperty

FixedPriority_a:assert property FixedPriority_p;



//[2]If DREQ is 4'b0001 then DACK should be 4'b0001
property DREQ1_p;
@(posedge IF.clk)
IF1.DREQFinal==4'b0001|->IF1.DACK=4'b0001;
endproperty

DREQ1_a:assert property DREQ1_p;



//[3]If DREQ is 4'b0011 then DACK should be 4'b0001
property DREQ2_p;
@(posedge IF.clk)
IF1.DREQFinal==4'b0011|->IF1.DACK=4'b0001;
endproperty

DREQ2_a: assert property DREQ2_p;



//[4]If DREQ id 4'b1000 then DACK should be 4'b1000
property DREQ3_p;
@(posedge IF.clk)
IF1.DREQFinal==4'b1000|->IF1.DACK=4'b1000;
endproperty

DREQ2_a: assert property DREQ2_p;


//[5]If DREQ id 4'b1100 then DACK should be 4'b0100
property DREQ4_p;
@(posedge IF.clk)
IF1.DREQFinal==4'b1100|->IF1.DACK=4'b0100;
endproperty

DREQ2_a:assert property DREQ2_p;


//[6]check if only one channel is getting DACK at a time
property onlyOneDACK_p;
@(posedge IF.clk)
(!IF1.DREQ)|->$onehot(IF1.DACK);                     
endproperty

onlyOneDACK_a:assert property onlyOneDACK_p;


//[7]Check if hardware requests and software requests are considered
property allRequests_p;
@(posedge IF.clk)
IF1.DREQFinal = IF1.DREQ | 4'b1 << requestRegister[1:0];
endproperty

allRequests_a:assert property allRequests_p;




