module best_score_handler(clk, current_highscore, alltime_highscore, startGameEn);
	input clk; // default 50mhz clock on de2 board
	input startGameEn; // FSM reset signal to reset everything
	input [7:0] current_highscore; // 8 bit register containing user's current score
	output reg [7:0] alltime_highscore; // 8 bit register containing the best high score overall

	always@(posedge clk) begin
		if(current_highscore > alltime_highscore) begin
			alltime_highscore <= current_highscore;
		end
	end
	
endmodule
