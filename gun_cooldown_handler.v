module gun_cooldown_handler(clock, shoot, gun_cooldown_counter, startGameEn);
	input clock; // Default 50Mhz clock passed by de2 board
	input shoot; // Enable signal to increase our heat, from SW[0]
	input startGameEn; // signal when the game is started to change gun cooldown to 0
	output reg [3:0] gun_cooldown_counter; // 8 bit value we're counting to FF
	

	//  rate divider for our firing of the gun
   //  the expected behaviour is that we will create 
	//  an enable signal every 1s for our counter to increment to FF
	wire [27:0]rd_1hz_out, rd_050hz_out; 
	rate_divider rd_1hz(
		.enable(1'b1),
		.countdown_start(28'd49_999_999),
		.clock(clock),
		.reset(startGameEn),
		.q(rd_1hz_out)
	);

	//  rate divider for our refreshing of the gun
   //  the expected behaviour is that we will create 
	//  an enable signal every 2s for our counter to decrement to 0
   rate_divider rd_050hz(
      .enable(1'b1),
      .countdown_start(28'd99_999_999),
      .clock(clock),
      .reset(startGameEn),
      .q(rd_050hz_out)
    );

	wire gun_firing_enable   = (rd_1hz_out == 28'b0) ? 1'b1 : 1'b0;
	wire gun_cooldown_enable = (rd_050hz_out == 28'b0) ? 1'b1 : 1'b0;

	always@(posedge clock)
	begin
		if(startGameEn)
			gun_cooldown_counter = 4'b0000;
		if(gun_firing_enable & shoot)
            gun_cooldown_counter = (gun_cooldown_counter < 4'b1111) ? gun_cooldown_counter + 1'b1 : 4'b1111;
		if(gun_cooldown_enable & !shoot)
            gun_cooldown_counter = (gun_cooldown_counter > 4'b0000) ? gun_cooldown_counter - 1'b1 : 4'b0000;
	end

endmodule
