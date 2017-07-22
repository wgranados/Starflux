module health_handler(ship_health, clk, health_update);
	input clk; // default 50mhz clock on de2 board
	input health_update; // prompts us to decrement ship's health
	output reg [3:0] ship_health; // four bit register we're storing ship's health on 
	
	always@(posedge clk) begin
		if(health_update) begin
				ship_health <= ship_health - 1'b1;
		end
   end
	 
endmodule
