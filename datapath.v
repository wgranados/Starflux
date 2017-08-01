module datapath(clk, startGameEn, user_x, user_y, enemy_x, enemy_y, enem_grid, x, y, colour);
	input clk; // default 50Mhz clock on de2 board 
	input startGameEn; // FSM reset signal to reset everything
	input [7:0]user_x; // 8 bit value keeping track of the user's x position on the vga
	input [6:0]user_y; // 7 bit value keeping track of the user's y position on the vga
	input [7:0]enemy_x; // 8 bit value keeping track of the enemy's x position on the vga
	input [6:0]enemy_y; // 7 bit value keeping track of the enemy's y position on the vga
	input [160*120-1:0] enem_grid; // 2D grid reprsentation for our 160x120 pixel screen, where each grid[y*120+x] represents an active bullet 
	
	output reg [7:0] x; // 8 bit x coordinate on VGA screen
	output reg [6:0] y; // 7 bit y coordinate on VGA screen
	output reg[2:0] colour; // 3 bit RGB value on VGA screen
	
	
	// colours we'll be using for the grid stuff
	wire [2:0]black 	= 3'b000;
	wire [2:0]white   = 3'b111;
	wire [2:0]red		= 3'b100;
	wire [2:0]green 	= 3'b010;
	wire [2:0]blue 	= 3'b001;
	
	// use this var when we want to clear the screen to
	// by setting everything to black	
	reg clear = 1'b0;
	
	always@(posedge clk) begin
		if(startGameEn) begin
			x <= 8'b0;
			y <= 7'b0;
			clear <= 1'b1;
		end
		else begin
			// note that if clear is set this cycles from (0,0) up to (159, 119)
			// setting everything to black until it reaches the lat pixel and
			// it resets
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
			else if(enem_grid[120*x+y] == 1'b1) begin
				colour <= green;
			end
			// draw bullets in green
			// but for now we'll just draw the other positions as black to reset the screen
			else begin
				colour <= black;
			end
	
			// enumerate the tuples (X,Y) s.t 0 <= X,Y < 160
			if(x < 8'd160) begin
				x <= x + 1'b1;
			end
			else if(x == 8'd160 && y != 7'd120) begin
				x <= 8'b0;
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
