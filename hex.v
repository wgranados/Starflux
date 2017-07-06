module hex_control(HEX0, HEX1, HEX2, HEX3, KEY, SW, load_all_time, load_score);
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
	input [1:0] KEY;
	input [7:0] load_all_time; // all time score.
	input [7:0] load_score;
	input [3:0] SW;	
	all_time a(HEX0, HEX1, load_all_time, KEY[0], ~KEY[1]);
	
endmodule

module all_time(hex0, hex1, load_all_time, resetn, enable);
	output [6:0]hex0;
	output [6:0]hex1;
	output reg [7:0] out;
	
	always@(posedge enable) begin
	        if(!resetn) begin
	            out <= 8'b0; 
	        end
	        else begin
			out <= load_all_time; // storing the all time score.
	        end
    	end
	hex hex1(out[7:4], hex1); // displaying it on the hexes.
	hex hex0(out[3:0], hex0);	
endmodule

module current_score(hex2, hex3, clear_score, enable);
	output [6:0]hex2;
	output [6:0]hex3;
	output reg [7:0] out;
	
	always@(posedge enable) begin
	        if(!resetn) begin
	            out <= 8'b0; 
	        end
	        else begin
			out <= out + 1; // increasing the current score.
	        end
    	end
	hex hex3(out[7:4], hex3); // displaying it on the hexes.
	hex hex2(out[3:0], hex2);
endmodule

module rateDiv(clk, out);
	output pulse;
	input clock, clear_b;
	reg [24:0] count;

	always @(posedge clock, negedge clear_b)
		if (clear_b == 1'b0)
			count <= 25'b00000_00000_00000_00000_00000;
		else
			begin
				if (count == 25'b00000_00000_00000_00000_00000)
					count <= (25'd25_000_000 - 1);
				else
					count <= count - 1'b1;
			end

	assign pulse = (count == 25'b00000_00000_00000_00000_00000) ? 1 : 0;

endmodule
	
module cool_down_timer(hex4, hex5, heat, cool);
	output [6:0]hex4;
	output [6:0]hex5;
	output reg [7:0] out;
	
	always@(posedge cool, negedge heat) begin
	        if(!resetn) begin
	            out <= 8'b0; // setting health to F.
	        end
	        else begin
			if(heat == 1'b0)
				out <= out - 1'b1; // heating or cooling the timer.
			else(cool)
				out <= out + 1'b1;
							
	        end
    	end
	hex hex5(out[7:4], hex5); // displaying it on the hexes.
	hex hex4(out[3:0], hex4);
endmodule

module health(hex6, hex7, enable, resetn);
	output [6:0]hex6;
	output [6:0]hex7;
	output reg [7:0] out;
	
	always@(posedge enable) begin
		if(!resetn) begin
	            out <= 8'b1111_1111; // setting health to F.
	        end
	        else begin
			out <= out - 1'b1; // increasing the current score.
	        end
    	end
	hex hex7(out[7:4], hex7); // displaying it on the hexes.
	hex hex6(out[3:0], hex6);
endmodule

module hex(a, out);
	input [3:0] a;
	output reg [6:0] out; 
	always
	begin
		case(a)
			4'h0: out = ~7'b0111111;
			4'h1: out = ~7'b0000110;
			4'h2: out = ~7'b1011011;
			4'h3: out = ~7'b1001111;
			4'h4: out = ~7'b1100110;
			4'h5: out = ~7'b1101101;
			4'h6: out = ~7'b1111101;
			4'h7: out = ~7'b0000111;
			4'h8: out = ~7'b1111111;
			4'h9: out = ~7'b1100111;
			4'hA: out = ~7'b1110111;
			4'hB: out = ~7'b1111100;
			4'hC: out = ~7'b0111001;
			4'hD: out = ~7'b1011110;
			4'hE: out = ~7'b1111001;
			4'hF: out = ~7'b1110001;
			default: out = ~7'b0111111;
		endcase
	end
endmodule
	
	

