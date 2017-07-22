module enemy(clock, x_val, startGameEn);
    input clock; // 50mhz clock from de2 board
	 input startGameEn;
    output reg [7:0] x_val; // output values
    reg left; // true if the enemy is moving towards left side of the screen
	 wire [27:0]rd_2hz_out; 
	 rate_divider rd_2hz(
			.enable(1'b1),
			.countdown_start(28'd2499999), // 24,999,99 in dec
			.clock(clock),
			.reset(reset),
			.q(rd_2hz_out)
	 );
	 
	 wire movement_handler_clock   = (rd_2hz_out == 28'b0) ? 1:0;

    always@(posedge movement_handler_clock)
    begin
		if(startGameEn)
			begin
				x_val <= 8'b0;// If the reset button is clicked then reset the x value and make it go right
				left <= 1'b0;
			end
      else if(!left)
			begin
		    	x_val <= x_val + 1'b1;// increase the x value of enemy when moving to the right
		    	if(x_val == 8'd120)
				begin
					left = 1'b1; // if the enemy reaches the rightmost position of the screen then make it move to the left
				end		
			end
      else if(left)
			begin
				x_val <= x_val - 1'b1; 
				if(x_val == 8'b0) // if the enemy reaches the leftmost position of the screen then make it move to the right.
					begin
						left = 1'b0;
					end
			end
    end
endmodule


module shoot(clock,x_val_ship, x_val_bullet, y_val_bullet, reset);
    input clock; // 50mhz clock from de2 board
	 input [7:0] x_val_ship;
    output reg [7:0] x_val_bullet; // output values
	 output reg [7:0] y_val_bullet;
	 input reset;
    reg shot; // true if the bullet has been shot already  
	 wire [27:0]rd_2hz_out; 
	 rate_divider rd_2hz(
			.enable(1'b1),
			.countdown_start(28'b1011111010111100000111111), // 24,999,99 in dec
			.clock(clock),
			.reset(reset),
			.q(rd_2hz_out)
	 );
	 
	 wire movement_handler_clock   = (rd_2hz_out == 28'b0) ? 1:0;

    always@(posedge movement_handler_clock)
    begin
		if(reset)
			begin
				x_val_bullet <= 8'b0;
				shot <= 1'b0;
			end
      else if(!shot)
			begin
		    	x_val_bullet <= x_val_ship;
				y_val_bullet<= 8'b0;
				shot = 1'b1;
			end
      else if(shot)
				y_val_bullet <= y_val_bullet + 1'b1;
    end
endmodule
