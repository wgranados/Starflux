module all_time(current_highscore,alltime_highscore, resetn, clk);
	input [7:0] current_highscore;
	output reg [7:0] alltime_highscore;
	input resetn;
	input clk;
	always@(posedge clk) begin
	        if(current_highscore > alltime_highscore)
							alltime_highscore <= current_highscore;
    	end
endmodule
