module gun_cooldown_handler(clock, shoot, reset, gun_cooldown_counter);
	input clock; // Default 50Mhz clock passed by de2 board
	input shoot; // Enable signal to increase our heat, from SW[0]
	input reset; // Reset signal from SW[2]
	output reg [3:0] gun_cooldown_counter; // 8 bit value we're counting to FF

	//  rate divider for our firing of the gun
   //  the expected behaviour is that we will create 
	//  an enable signal every 1s for our counter to increment to FF
	wire [27:0]rd_1hz_out, rd_050hz_out; 
	rate_divider rd_1hz(
		.enable(1'b1),
		.countdown_start(28'b10111110101111000001111111), // 49,999,99 in dec
		.clock(clock),
		.reset(reset),
		.q(rd_1hz_out)
	);

	//  rate divider for our refreshing of the gun
   //  the expected behaviour is that we will create 
	//  an enable signal every 2s for our counter to decrement to 0
    rate_divider rd_050hz(
      .enable(1'b1),
      .countdown_start(28'b101111101011110000011111111), // 99,999,999 in decimal
      .clock(clock),
      .reset(reset),
      .q(rd_050hz_out)
    );

	wire gun_firing_enable   = (rd_1hz_out == 28'b0) ? 1:0;
	wire gun_cooldown_enable = (rd_050hz_out == 28'b0) ? 1:0;

	always@(posedge clock)
	begin
		if(reset)
			gun_cooldown_counter = 4'b0;
		if(gun_firing_enable & shoot)
            gun_cooldown_counter = (gun_cooldown_counter < 4'b1111_1111) ? gun_cooldown_counter + 1'b1 : 4'b1111;
		if(gun_cooldown_enable & !shoot)
            gun_cooldown_counter = (gun_cooldown_counter > 4'b0000_0000) ? gun_cooldown_counter - 1'b1 : 4'b0000;
	end

    assign gun_cooldown_out = gun_cooldown_counter;

endmodule
