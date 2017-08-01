module enemy_gun_handler(clock,gun_cooldown, startGameEn, enemy_shoot);
	input clock; // 50mhz clock from de2 board
	input [3:0] gun_cooldown; // 4 bit value keeping trck of the gun's cooldown, overheats when it reaches 4'b1111
	input startGameEn; // FSM reset signal to reset everything
	output reg enemy_shoot; // shoot signal sent from the enemy
	  
	reg clear; // Start cycling from F to 0 as the cooldown


	always@(posedge clock)
	begin
		if(startGameEn) begin
			enemy_shoot = 1'b0;
			clear <= 1'b0;
		end
		if(clear && gun_cooldown != 4'b0000) begin
			enemy_shoot = 1'b0;
		end
		else if (clear && gun_cooldown == 4'b0000) begin
			clear <= 1'b0;
		end
		else if(~clear && gun_cooldown < 4'b1111) begin
			enemy_shoot = 1'b1;
		end
		else if(~clear && gun_cooldown == 4'b1111) begin
			clear <= 1'b1;
			enemy_shoot = 1'b0;
		end
	end
	 
endmodule
