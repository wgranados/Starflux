module current_score_handler(current_highscore, clk, current_score_update);
	input clk; // default 50mhz clock on de2 board
	input current_score_update; // enable signal prompting us to increment the current score
	output reg [7:0] current_highscore; // 8 bit register which stores the user's current highscore
	
	always@(posedge clk) begin
		if(current_score_update) begin	
			current_highscore <= current_highscore + 1'b1;
		end
   end

endmodule
