module hex(ship_health, current_highscore, alltime_highscore, resetn, health_update, current_score_update, gameover_signal, CLOCK_50, LEDG, LEDR);
	output [3:0] ship_health;
	output [7:0] current_highscore;
	output [7:0] alltime_highscore;
	input resetn; // reset button
	input health_update; // 1 bit value to update health.
   input current_score_update; // 1 bit value to update the current score
   input gameover_signal; // 1 bit value to update the gameover score. 	
	input CLOCK_50;
	output [17:0] LEDR;
	output [8:0] LEDG;
	all_time a(.current_highscore(current_highscore),.alltime_highscore(alltime_highscore) , .resetn(resetn), .clk(CLOCK_50));
	current_score c(.current_highscore(current_highscore),.resetn(resetn), .clk(CLOCK_50));
	health h(.ship_health(ship_health), .clk(CLOCK_50), .resetn(resetn));
	gameover g(.ledr(LEDR), .ledg(LEDG), .clk(CLOCK_50), .resetn(resetn));
endmodule

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



module health(ship_health, clk, resetn, health_update);
	input clk;
	input resetn;
	input health_update;
	output reg [3:0] ship_health;
	
	always@(posedge clk) begin
		if(health_update)
				ship_health <= ship_health - 1'b1;
    end
endmodule

module gameover(ledr, ledg, clk, resetn);
	output [17:0]ledr;
	output [8:0] ledg;
	input clk;
	input resetn;
	reg [17:0] redout;
	reg [8:0] greenout;
	always@(posedge clk) begin
		if(!resetn) begin
			redout <= 18'b0;
			greenout <= 9'b0;
		end
		else begin
			case (redout)
				18'b0:
				begin
					redout <= 18'b101010101010101010;
					greenout <= 9'b101010101;
				end
				18'b101010101010101010:
				begin
					redout <= 18'b100010001000100010;
					greenout <= 9'b100010001;
				end
				18'b100010001000100010:
				begin
					redout <= 18'b100000001000000010;
					greenout <= 9'b100000001;
				end
				18'b10000000100000001:
				begin
					redout <= 18'b0;
					greenout <= 9'b0;
				end
				default: 
				begin 
					redout <= 18'b0;
					greenout <= 9'b0;
				end
			endcase
		end
	end
	assign ledr = redout;
	assign ledg = greenout;
endmodule
