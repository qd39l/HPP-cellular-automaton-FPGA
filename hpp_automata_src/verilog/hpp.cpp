//----------------------------------
// hpp.cpp
//
// Description:
// This is for running on a PC and see how much speedup we can get on the FPGA.
// 
//----------------------------------

#include <iostream>

const unsigned LATTICE_WIDTH = 640;
const unsigned LATTICE_HEIGHT = 480;
const unsigned iterations = 6000;

short a1[LATTICE_WIDTH][LATTICE_HEIGHT];
short b1[LATTICE_WIDTH][LATTICE_HEIGHT];
short c1[LATTICE_WIDTH][LATTICE_HEIGHT];
short d1[LATTICE_WIDTH][LATTICE_HEIGHT];

short a2[LATTICE_WIDTH][LATTICE_HEIGHT];
short b2[LATTICE_WIDTH][LATTICE_HEIGHT];
short c2[LATTICE_WIDTH][LATTICE_HEIGHT];
short d2[LATTICE_WIDTH][LATTICE_HEIGHT];

short LAST = 1;

int main () {
    int x, y;
    short change;

    // init grids
    // Resolve Collisions
    for (x = 0; x < LATTICE_WIDTH; x++) {
        for (y = 0; y < LATTICE_HEIGHT; y++) {
            a1[x][y] = 1;
            b1[x][y] = 2;
            c1[x][y] = 3;
            d1[x][y] = 4;
        }
    }

    for (int turn = 0; turn < iterations; turn++){
        // Resolve Collisions
        for (x = 0; x < LATTICE_WIDTH; x++) {
            for (y = 0; y < LATTICE_HEIGHT; y++) {
                change = (a1[x][y] & c1[x][y] & ~(b1[x][y] | d1[x][y])) |
                        (b1[x][y] & d1[x][y] & ~(a1[x][y] | c1[x][y]));

                a2[x][y] = a1[x][y] ^ change;
                b2[x][y] = b1[x][y] ^ change;
                c2[x][y] = c1[x][y] ^ change;
                d2[x][y] = d1[x][y] ^ change;
            }
        }
        // Propagate
        for (x = 1; x < LATTICE_WIDTH - 1; x++) {
            for (y = 1; y < LATTICE_HEIGHT - 1; y += 2) {
                a1[x][y] = (a2[x][y - 1] >> 1) + (a2[x - 1][y - 1] << LAST);
                b1[x][y] = b2[x][y - 1];
                c1[x][y] = c2[x][y + 1];
                d1[x][y] = (d2[x][y + 1] >> 1) + (d2[x - 1][y + 1] << LAST);

                a1[x][y + 1] = a2[x][y];
                b1[x][y + 1] = (b2[x][y] << 1) + (b2[x + 1][y] >> LAST);
                c1[x][y + 1] = (c2[x][y + 2] << 1) + (c2[x + 1][y + 2] >> LAST);
                d1[x][y + 1] = d2[x - 1][y + 2];
            }
        }
    }

    return 0;
}

