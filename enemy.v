module enemy(health, CLOCK_50, LEDR, x, resetn);
	output [17:0] LEDR;
	input CLOCK_50;
	input resetn;
        output [7:0] x;
	movement_handler(.clock(CLOCK_50),.x_val(x), .reset(resetn));
endmodule

module movement_handler(clock, x_val, reset);
    input clock; // 50mhz clock from de2 board
    output reg [7:0] x_val; // output values
    reg left; // true if the enemy is moving towards left side of the screen
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
	if(!reset)
		begin
			x_val <= 8'b0;
			left <= 1'b0;
		end
        else if(!left)
		begin
		    	x_val <= x_val + 1'b1;
		    	if(x_val == 8'b10100000)
				begin
					left = 1'b1;
				end		
		end
        else if(left)
		begin
            		x_val <= x_val - 1'b1;
			if(x_val == 8'b0)
				begin
					left = 1'b0;
				end
	
		end
    end

endmodule


module shoot(clock, x_val, reset);
    input clock; // 50mhz clock from de2 board
    output reg [7:0] x_val; // output values
    reg left; // true if the enemy is moving towards left side of the screen
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
	if(!reset)
		begin
			x_val <= 8'b0;
			left <= 1'b0;
		end
        else if(!left)
		begin
		    	x_val <= x_val + 1'b1;
		    	if(x_val == 8'b10100000)
				begin
					left = 1'b1;
				end		
		end
        else if(left)
		begin
            		x_val <= x_val - 1'b1;
			if(x_val == 8'b0)
				begin
					left = 1'b0;
				end
	
		end
    end

endmodule
