//----------------------------------
// pe_collision.v
//
// Author: Kunpeng Huang (kh537), Owen Deng (qd39), Siqi Qian (sq85)
//
//----------------------------------

module pe_collision (input [4:0] state,
                     input artist_mode,
                     output [4:0] state_next);
    wire obstacle, a_top, b_left, c_bottom, d_right, change;
    assign obstacle = state[4];
    assign a_top = state[3];
    assign b_left = state[2];
    assign c_bottom = state[1];
    assign d_right = state[0];

    // resolve collisions
    assign change = (a_top & c_bottom & ~(b_left | d_right)) | (b_left & d_right & ~(a_top | c_bottom));

    wire K_a, K_b, K_c, K_d;
    assign K_a = a_top ^ change;
    assign K_b = b_left ^ change;
    assign K_c = c_bottom ^ change;
    assign K_d = d_right ^ change;

    wire a_out, b_out, c_out, d_out;
    
    /***
        Resolving obstacles is tricky. We need the particle to bounce back. 
        If a particle is at A position and this grid is an obstacle, then a should be set to 0 and C (the oppsite of A) should be set to 1.
    ***/
    assign a_out = (obstacle && K_c) ? K_c 
                 : (obstacle && K_a && ~artist_mode) ? 1'b0
                 : K_a; // this is when artist mode is active. This is a bug but will create artistic effects

    assign b_out = (obstacle && K_d) ? K_d 
                 : (obstacle && K_b && ~artist_mode) ? 1'b0
                 : K_b;

    assign c_out = (obstacle && K_a) ? K_a
                 : (obstacle && K_c && ~artist_mode) ? 1'b0
                 : K_c;

    assign d_out = (obstacle && K_b) ? K_b
                 : (obstacle && K_d && ~artist_mode) ? 1'b0
                 : K_d;
    
    assign state_next = {obstacle, a_out, b_out, c_out, d_out};
endmodule
