module movement_handler(clock, right, down, up, left, x_val, y_val);
    input clock; // 50mhz clock from de2 board
    input right, left; // left, right movement from KEY[3] and KEY[0]
    input up, down; // currently ignore this for now
    output reg [7:0] x_val, y_val; // output values 

    always@(posedge clock)
    begin
        if(left)
            x_val <= (x_val > 8'b0000_0000)  ? x_val - 1'b1 : 8'b0000_0000;
        if(right)
            x_val <= (x_val < 8'b1111_1111) ? x_val + 1'b1: 8'b1111_1111;
    end

endmodule
