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

// reads a raw 32-bit int from the bitmap
unsigned int read_dword(unsigned char* bitmap, int offset) {
	return bitmap[offset + 0]
		| (bitmap[offset + 1] << 8)
		| (bitmap[offset + 2] << 16)
		| (bitmap[offset + 3] << 24);
}

// reads the bitmap width from the header
int get_width(unsigned char* bitmap) {
	return read_dword(bitmap, 18);
}

// reads the bitmap height from the header
int get_height(unsigned char* bitmap) {
	return read_dword(bitmap, 22);
}

// returns the number of bytes per bitmap row (stride)
int bytes_per_row(unsigned char* bitmap) {
	int result = BYTES_PER_PIXEL * get_width(bitmap);
	int remain = result % 4;
	if (remain != 0) {
		result += 4 - remain;
	}
	return result;
}

// gets the pixel
unsigned int get_pixel(unsigned char* bitmap, int x, int y) {
	int offset = bytes_per_row(bitmap) * y + BYTES_PER_PIXEL * x;
	unsigned char* pixels = bitmap + 54U;
	return pixels[offset + 2]
		| (pixels[offset + 1] << 8)
		| (pixels[offset + 0] << 16);
}

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

// ------------------------------End Functions-----------------------------------

// ------------------------------Main Program Execution--------------------------

int measure_marker(unsigned char* bitmap, int x, int y, int sw, int sh, int thicc) {
	const unsigned int black = 0x00000000;

	int i = 0;
	int j = 0;
	int ci = 0;
	int cj = 0;

	if (get_pixel(bitmap, x, y) == black) {
		for (i = x; i < x + sw && get_pixel(bitmap, i, y) == black; ++i) ++ci;
		for (j = y; j > y - sh && get_pixel(bitmap, x, j) == black; --j) ++cj;

		if (ci == cj && ci == sw && cj == sh) {
			return measure_marker(bitmap, x + 1, y - 1, sw - 1, sh - 1, thicc + 1);
		}
		else {
			return -1;
		}
	}
	else {
		for (i = x; i < x + sw && get_pixel(bitmap, i, y) != black; ++i) ++ci;
		for (j = y; j > y - sh && get_pixel(bitmap, x, j) != black; --j) ++cj;

		if (ci == cj && ci == sw && cj == sh) {
			return thicc - 1;
		}
		else {
			return -1;
		}
	}
}

// finds the markers
int find_markers(unsigned char* bitmap, unsigned int* x_pos, unsigned int* y_pos) {
	const unsigned int black = 0x00000000;

	int px = -1;
	int py = -1;
	int sw = -1;
	int sh = -1;

	int i = 0;
	int j = 0;
	int x = 0;
	int y = 0;
	int found = 0;

	int w = get_width(bitmap);
	int h = get_height(bitmap);

	for (y = 0; y < h; ++y) {
		for (x = 0; x < w; ++x) {

			unsigned int pixel = get_pixel(bitmap, x, y);
			if (pixel == black) {

				// if a black pixel is underneath, we ditch it
				if (get_pixel(bitmap, x, y - 1) == black) continue;

				// measure shape height (sh)
				for (i = y, sh = 0; i < h && get_pixel(bitmap, x, i) == black; ++i) ++sh;

				// measure whites on the left
				for (j = y; j < h && get_pixel(bitmap, x - 1, j) != black; ++j);

				// if there's some blackboi touching us on the left, we blow the rape whistle
				if (i > j) continue;

				// save Py
				py = i - 1;
				// save Px
				px = x;

				// measure shape width (sw)
				for (i = x, sw = 0; i < w && get_pixel(bitmap, i, py) == black; ++i) ++sw;

				// if there's some blackboi touching us ontop, we blow the rape whistle
				for (j = x; j < w && get_pixel(bitmap, j, py + 1) != black; ++j);
				if (i > j) continue;

				// if width != height, we ditch it
				if (sw != sh) continue;

				// now apply measuring
				int thickness = measure_marker(bitmap, px + 1, py - 1, sw - 1, sh - 1, 1);

				if (thickness == -1 || thickness >= sw - 1) {
					continue;
				}
				else {
					x_pos[found] = px;
					y_pos[found] = py;
					found = found + 1;
				}
			}
		}
	}

	return found;
}

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
			printf("Marker at coordinates: x = %i, y = %i\n", x[found], y[found]);
		}
	}

	return 0;
}