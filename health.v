module health(ship_health, clk, resetn, health_update);
	input clk;
	input resetn;
	input health_update;
	output reg [3:0] ship_health;
	
	always@(posedge clk) begin
		if(health_update)
				ship_health <= ship_health - 1'b1;
    end
endmodule
