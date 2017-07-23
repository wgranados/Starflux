module display(clk, startGameEn, user_x, enemy_x, grid, x, y, colour);
	input clk; // default 50Mhz clock on de2 board 
	input startGameEn; // reset signal 
	input [7:0]user_x;
	input [7:0]enemy_x;
	input [160*120-1:0] grid;
	output reg [7:0] x;
	output reg [6:0] y;
	output reg[2:0] colour;

	wire [6:0]user_y = 7'd1;
	wire [6:0]enemy_y = 7'd2;
	
	// colours we'll be using for the grid stuff
	wire [2:0]red = 3'b100;
	wire [2:0]green = 3'b010;
	wire [2:0]blue = 3'b001;
	wire [2:0]black = 3'b000;
	// use this var when we want to clear the screen to
   // by setting everything to black	
	reg clear = 1'b0;

	// count from 0 to 160*120-1=19200 and implictly calculate the x,y 
	// values from the counter. Since X changes every tick, and Y changes 
	// once every 160 ticks, which can be emulated using integer division
	
	
	always@(posedge clk) begin
		if(startGameEn)
			begin
				x <= 8'b0;
				y <= 7'b0;
				clear <= 1'b1;
			end
		else 
			begin
			   // draw user ship in red
				if(clear) begin
					colour <= black;
				end
				else if(x == user_x && y == user_y) begin	
					colour <= red; 
				end
				// draw enemy ship in blue
				else if(x == enemy_x && y == enemy_y) begin	
					colour <= blue; 
				end
				// draw bullets in green
				// but for now we'll just draw the other positions as black to reset the screen
				else begin
					colour <= black;
				end
				if(x < 8'd160) begin
					x <= x + 1'b1;
				end
				if(x == 8'd160 && y != 7'd120) begin
					x <= 0;
					y <= y + 1'b1;
				end
				else if(y == 7'd120 &&  x == 8'd160) begin
					x <= 8'b0;
					y <= 7'b0;
					clear <= 1'b0;
				end
			end
	end
endmodule
