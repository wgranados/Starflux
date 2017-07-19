module movement_handler(clock, right, left, x_val);
    input clock; // 50mhz clock from de2 board
    input right, left; // left, right movement from KEY[3] and KEY[0]
    output reg [7:0] x_val; // output values 
		 
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
		  if(left & right)
		      x_val <= x_val;
        else if(left)
            x_val <= (x_val > 8'b0000_0000)  ? x_val - 1'b1 : 8'b0000_0000;
        else if(right)
            x_val <= (x_val < 8'b1111_1111) ? x_val + 1'b1: 8'b1111_1111;
    end

endmodule
