module current_score(current_highscore, resetn, clk, current_score_update);
	input resetn;
	input clk;
	output reg [7:0] current_highscore;
	input current_score_update;
	
	always@(posedge clk) begin
	        if(current_score_update)
					current_highscore <= current_highscore + 1'b1;
    	end
endmodule
