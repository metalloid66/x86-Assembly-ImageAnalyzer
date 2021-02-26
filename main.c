#include <stdio.h>
#include <stdlib.h>
#define MAX_SHAPES 50
#define BYTES_PER_PIXEL 3

// ------------------------------Data Section------------------------------------

// ----- STRINGS
const char* fname = "intensive_tests.bmp";

// ----- CONSTANTS
const int header_size = 54;

// ------------------------------End Data Section--------------------------------

// ------------------------------Functions---------------------------------------

// reads the bitmap width from the header
int get_width(unsigned char* bitmap);

// reads the bitmap height from the header
int get_height(unsigned char* bitmap);

// returns the number of bytes per bitmap row
int bytes_per_row(unsigned char* bitmap);

// gets the pixel
unsigned int get_pixel(unsigned char* bitmap, int x, int y);

// reads the bmp from the disk
unsigned char* read_bmp(const char* path) {
	FILE* stream = NULL;
	unsigned char* image = NULL;

	if ((stream = fopen(path, "rb")) != NULL) {
		image = (unsigned char*)malloc(header_size);

		if (fread(image, header_size, 1, stream) == 1) {
			int image_size = bytes_per_row(image) * get_height(image);
			int new_size = image_size + header_size;

			image = (unsigned char*)realloc(image, new_size);

			if (fread(image + header_size, image_size, 1, stream) == 1) {
				return image;
			}
			else printf("Error: failed to read pixel data... ");
		}
		else printf("Error: failed to read header data... ");
	}
	else printf("Error: failed to open... ");

	free(image);

	printf("File Error!\n");
	return NULL;
}

// ------------------------------End Of Functions-----------------------------------

// ------------------------------Main Program Execution--------------------------

int measure_marker(unsigned char* bitmap, int x, int y, int sw, int sh, int thicc);
int find_markers(unsigned char* bitmap, unsigned int* x_pos, unsigned int* y_pos);

int main(int argc, char** argv) {

	unsigned char* bitmap = 0;
	if (argc != 2) {
		bitmap = read_bmp(fname);
	}
	else {
		bitmap = read_bmp(argv[1]);
	}

	if (bitmap != NULL) {
		unsigned int x[MAX_SHAPES];
		unsigned int y[MAX_SHAPES];
		int found = find_markers(bitmap, x, y);

		while (--found >= 0) {
			printf("%i. P at coordinates: x = %i, y = %i\n",found, x[found], y[found]);
		}
	}

	return 0;
}