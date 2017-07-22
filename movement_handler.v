module movement_handler(clock, right, left, x_val, startGameEn);
    input clock; // 50mhz clock from de2 board
    input right, left; // left, right movement from KEY[3] and KEY[0]
	 input startGameEn;
    output reg [7:0] x_val; // output values 
		 
	 wire [27:0]rd_16hz_out; 
	 rate_divider rd_16hz(
			.enable(1'b1),
			.countdown_start(28'b1011111010111100001000), // 3,125,000 in dec
			.clock(clock),
			.reset(reset),
			.q(rd_16hz_out)
	 );
	 
	 wire movement_handler_clock   = (rd_16hz_out == 28'b0) ? 1:0;


    always@(posedge movement_handler_clock)
    begin
		  if(startGameEn)
		  begin
				x_val <= 8'b0;
		  end
		  else if(left & right)
		  begin
		      x_val <= x_val;
		  end
        else if(left)
		  begin
            x_val <= (x_val > 8'b0000_0000)  ? x_val - 1'b1 : 8'b0000_0000;
		  end
        else if(right)
		  begin
            x_val <= (x_val < 8'd120) ? x_val + 1'b1: 8'd120;
		  end
    end

endmodule
