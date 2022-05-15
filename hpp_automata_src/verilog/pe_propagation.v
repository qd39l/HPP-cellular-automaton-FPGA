//----------------------------------
// pe_propagation.v
//
// Author: Kunpeng Huang (kh537), Owen Deng (qd39), Siqi Qian (sq85)
//
// Description: The propagation module is responsible for resolving two grids. 
// This is nothing but careful wiring.
//
//----------------------------------

module pe_propagation (input clk, reset, // active low
                       input [9:0] right_state,
                       input ain, cin,
                       output aout, cout,
                       output [9:0] write_state);
    
    reg [9:0] prev_state;
    reg [9:0] prev_prev_state;

    always @(posedge clk) begin
        if (!reset) begin
            prev_state <= 10'd0;
            prev_prev_state <= 10'd0;
        end else begin
            prev_state <= right_state;
            prev_prev_state <= prev_state;
        end
    end

    wire [4:0] prev_top, prev_bottom, prev_prev_top, prev_prev_bottom;
    assign prev_top = prev_state[4:0];
    assign prev_bottom = prev_state[9:5];
    assign prev_prev_top = prev_prev_state[4:0];
    assign prev_prev_bottom = prev_prev_state[9:5];

    wire [4:0] write_state_top, write_state_bottom;
    assign write_state_top = {prev_top[4], ain, prev_prev_top[2], prev_bottom[1], right_state[0]};
    assign write_state_bottom = {prev_bottom[4], prev_top[3], prev_prev_bottom[2], cin, right_state[5]};

    assign write_state = {write_state_bottom, write_state_top};

    assign cout = prev_top[1];
    assign aout = prev_bottom[3];
endmodule
