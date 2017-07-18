module display(clk, reset, user_x, enemy_x, grid, x, y, colour);
	input clk; // default 50Mhz clock on de2 board 
	input reset; // reset signal 
	input [7:0]user_x;
	input [7:0]enemy_x;
	input [160*120-1:0] grid;
	output reg[7:0] x; 
	output reg[6:0] y;
	output reg[2:0] colour;

	
	reg [10:0]counter = 11'b0;
	wire [6:0]user_y = 7'd0;
	wire [6:0]enemy_y = 7'd160;
	
	// colours we'll be using for the grid stuff
	wire [2:0]red = 3'b100;
	wire [2:0]green = 3'b010;
	wire [2:0]blue = 3'001;
	
	always@(posedge clk) begin
		if(!reset)
			begin
				counter <= 11'b0;
			end
		else 
			begin
			   // draw user ship in red
				if(count == 11'd1) begin
					x <= user_x;
				   y <= user_y;	
					colour <= red; 
				end
				// draw enemy ship in blue
				if(count == 11'd2) begin
					x <= enemy_x;
				   y <= enemy_y;	
					colour <= blue; 
				end
				// draw bullets in green
				if(count > 11'd2 && count < 11'd19199) begin
					x <= grid[(counter-11'd2)%160];
					y <= grid[1]; // some calculation
					colour <= green;
				end
				counter <= counter + 1'b1;
			end
	end
	
	
	
endmodule
