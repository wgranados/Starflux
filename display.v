module display(clk, reset, user_x, enemy_x, grid, x, y, colour);
	input clk; // default 50Mhz clock on de2 board 
	input reset; // reset signal 
	input [7:0]user_x;
	input [7:0]enemy_x;
	input [160*120-1:0] grid;
	output [7:0] x; 
	output [6:0] y;
	output reg[2:0] colour;

	
	reg [7:0]counter = 11'b0;
	wire [6:0]user_y = 7'd0;
	wire [6:0]enemy_y = 7'd160;
	
	// colours we'll be using for the grid stuff
	wire [2:0]red = 3'b100;
	wire [2:0]green = 3'b010;
	wire [2:0]blue = 3'b001;
	wire [2:0]black = 3'b000;

	
	assign x = counter%160; 
	assign y = counter/120;
	
	always@(posedge clk) begin
		if(reset)
			begin
				counter <= 8'b0;
			end
		else 
			begin
			   // draw user ship in red
				if(x == user_x & y == user_y) begin	
					colour <= red; 
				end
				// draw enemy ship in blue
				else if(x == enemy_x & y == enemy_y) begin	
					colour <= blue; 
				end
				// draw bullets in green
				else begin
					colour <= black;
				end
				if(counter == 11'd19200)begin
					counter <= 11'd0;
				end
				counter <= counter + 1'b1;
			end
	end
	
	
	
endmodule
