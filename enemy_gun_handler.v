module enemy_gun_handler(clock,x_val_ship, x_val_bullet, y_val_bullet, reset);
    input clock; // 50mhz clock from de2 board
	 input [7:0] x_val_ship;
    output reg [7:0] x_val_bullet; // output values
	 output reg [7:0] y_val_bullet;
	 input reset;
    reg shot; // true if the bullet has been shot already  
	 wire [27:0]rd_2hz_out; 
	 rate_divider rd_2hz(
			.enable(1'b1),
			.countdown_start(28'd24_999_999), // 24,999,99 in dec
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