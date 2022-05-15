//////////////////////////////////////////////////////////
// 16-bit parallel random number generator ///////////////
//////////////////////////////////////////////////////////
// Algorithm is based on:
// A special-purpose processor for the Monte Carlo simulation of ising spin systems
// A. Hoogland, J. Spaa, B. Selman and A. Compagner
// Journal of Computational Physics
// Volume 51, Issue 2, August 1983, Pages 250-260
// but modified to use a 63 bit shift register 
// with feedback from positions 63 and 62
// 
// Owen: This is Bruce's code. We got it from https://people.ece.cornell.edu/land/courses/ece5760/Chemical_Simulation/Two_reaction_per_step/VGA_320x240_chem_sim_2_MM_rand63bit.v
//////////////////////////////////////////////////////////

module rand63(rand_out, seed_in, clk, reset);
	// 16-bit random number on every cycle
	output wire [15:0] rand_out ;
	// the clocks and stuff
	input wire clk, reset ;
	input wire [63:1] seed_in; // 128 bits is 32 hex digits 0xffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff

	reg [4:1] sr1, sr2, sr3, sr4, sr5, sr6, sr7, sr8, 
				sr9, sr10, sr11, sr12, sr13, sr14, sr15, sr16;
	
	// state names
	parameter react_start=4'd0 ;

	// generate random numbers	
	assign rand_out = {sr1[3], sr2[3], sr3[3], sr4[3],
							sr5[3], sr6[3], sr7[3], sr8[3],
							sr9[3], sr10[3], sr11[3], sr12[3],
							sr13[3], sr14[3], sr15[3], sr16[3]} ;
							
	always @ (posedge clk) //
	begin
		
		if (!reset)
		begin	
			//init random number generator 
			sr1 <= seed_in[4:1] ;
			sr2 <= seed_in[8:5] ;
			sr3 <= seed_in[12:9] ;
			sr4 <= seed_in[16:13] ;
			sr5 <= seed_in[20:17] ;
			sr6 <= seed_in[24:21] ;
			sr7 <= seed_in[28:25] ;
			sr8 <= seed_in[32:29] ;
			sr9 <= seed_in[36:33] ;
			sr10 <= seed_in[40:37] ;
			sr11 <= seed_in[44:41] ;
			sr12 <= seed_in[48:45] ;
			sr13 <= seed_in[52:49] ;
			sr14 <= seed_in[56:53] ;
			sr15 <= seed_in[60:57] ;
			sr16 <= {1'b0,seed_in[63:61]} ;
		end
		
		// update 63-bit shift register
		// 16 times in parallel
		else 
		begin
				sr1 <= {sr1[3:1], sr16[3]^sr15[3]} ;
				sr2 <= {sr2[3:1], sr16[3]^sr1[4]}  ;
				sr3 <= {sr3[3:1], sr1[4]^sr2[4]}  ;
				sr4 <= {sr4[3:1], sr2[4]^sr3[4]}  ;
				sr5 <= {sr5[3:1], sr3[4]^sr4[4]}  ;
				sr6 <= {sr6[3:1], sr4[4]^sr5[4]}  ;
				sr7 <= {sr7[3:1], sr5[4]^sr6[4]}  ;
				sr8 <= {sr8[3:1], sr6[4]^sr7[4]}  ;
				sr9 <= {sr9[3:1], sr7[4]^sr8[4]}  ;
				sr10 <= {sr10[3:1], sr8[4]^sr9[4]}  ;
				sr11 <= {sr11[3:1], sr9[4]^sr10[4]}  ;
				sr12 <= {sr12[3:1], sr10[4]^sr11[4]}  ;
				sr13 <= {sr13[3:1], sr11[4]^sr12[4]}  ;
				sr14 <= {sr14[3:1], sr12[4]^sr13[4]}  ;
				sr15 <= {sr15[3:1], sr13[4]^sr14[4]}  ;
				sr16 <= {sr16[3:1], sr14[4]^sr15[4]}  ;
		end
	end
endmodule

