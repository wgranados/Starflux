module hex(HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, load_score, resetn, health, current_score, gameover, CLOCK_50, LEDG, LEDR);
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	input resetn;
	input [3:0] SW;
	output [17:0] LEDR;
	output [8:0] LEDG;
   input [7:0] load_score;
	input CLOCK_50;
	all_time a(.hex0(HEX0), .hex1(HEX1), .load_current_score(load_score) , .resetn(resetn), .clk(~KEY[1]));
	current_score c(.hex2(HEX2), .hex3(HEX3),.resetn(resetn), .clk(current_score));
	health h(.hex5(HEX5), .clk(health), .resetn(resetn));
	gameover g(.ledr(LEDR), .ledg(LEDG), .clk(gameover), .resetn(resetn));
endmodule

module all_time(hex0, hex1, load_current_score, resetn, clk);
	input [7:0] load_current_score;
	input resetn;
	input clk;
	output [6:0]hex0;
	output [6:0]hex1;
	reg [7:0] all_time;
	
	always@(posedge clk) begin
	        if(!resetn) begin
	            all_time <= 8'b0; 
	        end
	        else begin
					if(load_current_score > all_time)
						all_time <= load_current_score; // storing the all time score.
	        end
    	end
		hex_decoder h1(.hex_digit(all_time[7:4]), .segments(hex1)); // displaying it on the hexes.
		hex_decoder h0(.hex_digit(all_time[3:0]), .segments(hex0));
endmodule

module current_score(hex2, hex3, resetn, clk);
	output [6:0]hex2;
	output [6:0]hex3;
	input resetn;
	input clk;
	reg [7:0] current_score;
	
	always@(posedge clk) begin
	        if(!resetn) begin
	            current_score <= 8'b0; 
	        end
	        else begin
				current_score <= current_score + 1; // increasing the current score.
	        end
    	end
	hex_decoder h3(.hex_digit(current_score[7:4]), .segments(hex3)); // displaying it on the hexes.
	hex_decoder h2(.hex_digit(current_score[3:0]), .segments(hex2));
endmodule



module health(hex5, clk, resetn);
	output [6:0]hex5;
	input clk;
	input resetn;
	reg [3:0] health;
	
	always@(posedge clk) begin
		if(!resetn) 
	            health <= 4'b1111; // setting health to F.
	   else begin
			casez(health)
				 4'b0: health <= 4'b1111; // increasing the current score.
				 4'b????:health <= health - 1;
		       default: health <= 4'b1111;
			endcase
	   end
    end
	hex_decoder h5(.hex_digit(health[3:0]), .segments(hex5));
endmodule

module gameover(ledr, ledg, clk, resetn);
	output [17:0]ledr;
	output [8:0] ledg;
	input clk;
	input resetn;
	reg [17:0] redout;
	reg [8:0] greenout;
	always@(posedge clk) begin
		if(!resetn) begin
			redout <= 18'b0;
			greenout <= 9'b0;
		end
		else begin
			case (redout)
				18'b0:
				begin
					redout <= 18'b101010101010101010;
					greenout <= 9'b101010101;
				end
				18'b101010101010101010:
				begin
					redout <= 18'b100010001000100010;
					greenout <= 9'b100010001;
				end
				18'b100010001000100010:
				begin
					redout <= 18'b100000001000000010;
					greenout <= 9'b100000001;
				end
				18'b10000000100000001:
				begin
					redout <= 18'b0;
					greenout <= 9'b0;
				end
				default: 
				begin 
					redout <= 18'b0;
					greenout <= 9'b0;
				end
			endcase
		end
	end
	assign ledr = redout;
	assign ledg = greenout;
endmodule



module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
	

