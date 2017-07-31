module enemy_gun_handler(clock,gun_cooldown, startGameEn, enemy_shoot);
    input clock; // 50mhz clock from de2 board
	 input [3:0] gun_cooldown;
	 input startGameEn;
	 output reg enemy_shoot; 
	 
	 reg clear;


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
