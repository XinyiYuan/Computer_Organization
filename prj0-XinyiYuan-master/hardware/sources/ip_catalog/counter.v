`timescale 1ns / 1ps

`define STATE_RESET 8'd0
`define STATE_RUN 8'd1
`define STATE_HALT 8'd2

module counter(
    input clk,
    input [31:0] interval,
    input [7:0] state,
    output reg [31:0] counter,
	  output reg [31:0] count_interval
	);

//	reg [31:0] count_interval;

    always @(posedge clk)
		begin
	 		if (state==`STATE_RESET) counter<=0;
			else if (state==`STATE_RUN)	
				begin			
					if (count_interval==interval) 
						counter<=counter+1;
				end
		end

		always @(posedge clk)
		begin
			if (state==`STATE_RESET || state==`STATE_HALT) 
				count_interval<=1;
			else if (state==`STATE_RUN)
				begin
					count_interval<=count_interval+1;
					if (count_interval>interval || count_interval==interval) 
						count_interval<=count_interval-interval+1;
				end
		end

	/*TODO: Add your logic code here*/
    
endmodule
