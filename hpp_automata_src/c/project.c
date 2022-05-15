//----------------------------------
// project.c
//
// Author: Siqi Qian (sq85), Kunpeng Huang (kh537), Owen Deng (qd39)
//
// To compile run $ gcc project.c -o main
//
// Description: HPS code for mouse control and PIO communication. To be
// used with the HPP cellular automaton project.
//
//----------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <dirent.h>
#include <linux/input.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/select.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <math.h>
#include <termios.h>
#include <signal.h>

// main bus; scratch RAM
#define FPGA_ONCHIP_BASE 0xC8000000
#define FPGA_ONCHIP_SPAN 0x00001000

// main bus; FIFO write address
#define FIFO_BASE 0xC0000000
#define FIFO_SPAN 0x00001000

/// lw_bus; FIFO status address
#define HW_REGS_BASE 0xff200000
#define HW_REGS_SPAN 0x00005000

// input/output offsets from the LW bus base addr
// FIXME change base addr
#define PTR_X_LO_BASE 0x00000010
#define PTR_X_HI_BASE 0x00000020
#define PTR_Y_LO_BASE 0x00000030
#define PTR_Y_HI_BASE 0x00000040
#define MOUSE_ACTION_BASE 0x00000050
#define MOUSE_TRIGGER_BASE 0x00000060

// Light weight bus base and PIO ports' base address
// FIXME change variable name
void *h2p_lw_virtual_base;
volatile int *ptr_x_lo_virtual_base;
volatile int *ptr_x_hi_virtual_base;
volatile int *ptr_y_lo_virtual_base;
volatile int *ptr_y_hi_virtual_base;
volatile int *mouse_action_virtual_base;
volatile int *mouse_trigger_virtual_base;

// HPS_to_FPGA FIFO status address = 0
volatile unsigned int *FIFO_status_ptr = NULL;

// HPS_to_FPGA FIFO write address
// main bus addess 0x0000_0000
void *h2p_virtual_base;
volatile unsigned int *FIFO_write_ptr = NULL;

// /dev/mem file id
int fd;

// buffer for command-line interface
char input_buffer[64];

void handler(int sig)
{
	printf("nexiting...(%d)\n", sig);
	exit(0);
}

void perror_exit(char *error)
{
	perror(error);
	handler(9);
}

int main(int argc, char *argv[])
{

	// Declare volatile pointers to I/O registers (volatile
	// means that IO load and store instructions will be used
	// to access these pointer locations,
	// instead of regular memory loads and stores)

	// === need to mmap: =======================
	// FPGA_CHAR_BASE
	// FPGA_ONCHIP_BASE
	// HW_REGS_BASE

	// === get FPGA addresses ==================
	// Open /dev/mem
	if ((fd = open("/dev/mem", (O_RDWR | O_SYNC))) == -1)
	{
		printf("ERROR: could not open \"/dev/mem\"...\n");
		return (1);
	}

	//============================================
	// get virtual addr that maps to physical
	// for light weight bus
	// FIFO status registers
	h2p_lw_virtual_base = mmap(NULL, HW_REGS_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, HW_REGS_BASE);
	if (h2p_lw_virtual_base == MAP_FAILED)
	{
		printf("ERROR: mmap1() failed...\n");
		close(fd);
		return (1);
	}
	FIFO_status_ptr = (unsigned int *)(h2p_lw_virtual_base);

	// ===========================================

	// FIFO write addr
	h2p_virtual_base = mmap(NULL, FIFO_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, fd, FIFO_BASE);

	if (h2p_virtual_base == MAP_FAILED)
	{
		printf("ERROR: mmap3() failed...\n");
		close(fd);
		return (1);
	}
	// Get the address that maps to the FIFO
	FIFO_write_ptr = (unsigned int *)(h2p_virtual_base);

	//============================================

	// get the addresses for input/output regs from the FPGA
	// FIXME change var name
	ptr_x_lo_virtual_base = (int *)(h2p_lw_virtual_base + PTR_X_LO_BASE);
	ptr_x_hi_virtual_base = (int *)(h2p_lw_virtual_base + PTR_X_HI_BASE);
	ptr_y_lo_virtual_base = (int *)(h2p_lw_virtual_base + PTR_Y_LO_BASE);
	ptr_y_hi_virtual_base = (int *)(h2p_lw_virtual_base + PTR_Y_HI_BASE);
	mouse_action_virtual_base = (int *)(h2p_lw_virtual_base + MOUSE_ACTION_BASE);
	mouse_trigger_virtual_base = (int *)(h2p_lw_virtual_base + MOUSE_TRIGGER_BASE);

	const unsigned int VGA_W = 640;
	const unsigned int VGA_H = 480;

	// default square position
	// FIXME from this and on you'll need to add a lot of things...
	int ptr_x_lo = 310 - 1;
	int ptr_x_hi = 360 - 1;
	int ptr_y_lo = 210 - 1;
	int ptr_y_hi = 260 - 1;
	int mouse_action = 0;
	int mouse_trigger = 0;

	*ptr_x_lo_virtual_base = ptr_x_lo;
	*ptr_x_hi_virtual_base = ptr_x_hi;
	*ptr_y_lo_virtual_base = ptr_y_lo;
	*ptr_y_hi_virtual_base = ptr_y_hi;
	*mouse_action_virtual_base = mouse_action;
	*mouse_trigger_virtual_base = mouse_trigger;

	printf("Use mouse to move around...");

	// mouse setup
	int fdmouse, bytes;
	unsigned char data[3];

	const char *pDevice = "/dev/input/mice";

	// Open Mouse
	fdmouse = open(pDevice, O_RDWR);
	if (fdmouse == -1)
	{
		printf("ERROR Opening %s\n", pDevice);
		return -1;
	}

	int left, middle, right;
	signed char x, y;

	// // keyboard setup
	// struct input_event ev[64];
	// int fd_keyboard, rd_keyboard, value_keyboard, size_keyboard = sizeof (struct input_event);
	// char name_keyboard[256] = "Unknown";
	// char *device = NULL;

	// //Setup check
	// if (argv[1] == NULL){
	// 	printf("Please specify (on the command line) the path to the dev event interface device\n");
	// 	exit (0);
	// 	}

	// if ((getuid ()) != 0)
	// 	printf ("You are not root! This may not work...\n");

	// if (argc > 1)
	// 	device = argv[1];

	// //Open Device
	// if ((fd_keyboard = open (device, O_RDONLY)) == -1)
	// 	printf ("%s is not a vaild device.\n", device);

	// //Print Device Name
	// ioctl (fd_keyboard, EVIOCGNAME (sizeof (name_keyboard)), name_keyboard);
	// printf ("Reading From : %s (%s)\n", device, name_keyboard);
	while (1)
	{
		// Read Mouse
		bytes = read(fdmouse, data, sizeof(data));

		if (bytes > 0)
		{
			left = data[0] & 0x1;
			right = data[0] & 0x2;
			middle = data[0] & 0x4;

			x = data[1];
			y = data[2];

			if (!(ptr_x_hi + x > 639 || ptr_x_lo + x < 0))
			{
				ptr_x_hi += x;
				ptr_x_lo += x;
			}

			if (!(ptr_y_hi - y > 479 || ptr_y_lo - y < 0))
			{
				ptr_y_hi -= y;
				ptr_y_lo -= y;
			}
			printf("x=%d, y=%d, left=%d, middle=%d, right=%d, ptr_x_hi=%d, ptr_x_lo=%d, ptr_y_hi=%d, ptr_y_lo=%d\n", x, y, left, middle, right, ptr_x_hi, ptr_x_lo, ptr_y_hi, ptr_y_lo);

			if (left != 0)
			{
				*mouse_action_virtual_base = 1;
				*mouse_trigger_virtual_base = 1;
			}
			else if (right != 0)
			{
				*mouse_action_virtual_base = 2;
				*mouse_trigger_virtual_base = 1;
			}
			else if (middle != 0)
			{
				*mouse_action_virtual_base = 3;
				*mouse_trigger_virtual_base = 1;
			}
			else
			{
				*mouse_action_virtual_base = 0;
				*mouse_trigger_virtual_base = 0;
			}

			if (left != 0 && right != 0 && middle == 0)
			{
				ptr_x_hi += 3;
				ptr_y_hi += 3;
			}
			else if (left != 0 && right == 0 && middle != 0)
			{
				ptr_x_hi -= 3;
				ptr_y_hi -= 3;
			}
		}

		// if ((rd_keyboard = read (fd_keyboard, ev, size_keyboard * 64)) < size_keyboard)
		// 	perror_exit ("read()\n");

		// value_keyboard = ev[0].value;

		// if (value_keyboard != ' ' && ev[1].value == 1 && ev[1].type == 1){ // Only read the key press event
		// 	if (ev[1].code == 13){
		// 		ptr_x_hi += 2;
		// 		ptr_y_hi += 2;
		// 		printf("enlarge\n");
		// 	} else if (ev[1].code == 12) {
		// 		ptr_x_hi -= 2;
		// 		ptr_y_hi -= 2;
		// 		printf("shrink\n");
		// 	}
		// }
		// update parameters into design via PIO
		*ptr_x_lo_virtual_base = ptr_x_lo;
		*ptr_x_hi_virtual_base = ptr_x_hi;
		*ptr_y_lo_virtual_base = ptr_y_lo;
		*ptr_y_hi_virtual_base = ptr_y_hi;
	}
}
