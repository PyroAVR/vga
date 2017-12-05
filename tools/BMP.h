#ifndef __BMP_H__
#define __BMP_H__
#include <stdint.h>
typedef struct  {
    uint8_t magic[2];
    uint8_t size[4];
    uint8_t reserved[4];
    uint32_t array_offset;
} bmp_header;

// NT-, OS/2 DIB header
typedef struct  {
    uint32_t size;
    uint16_t array_width;
    uint16_t array_height;
    uint16_t color_planes;
    uint16_t bpp;
} bitmap_core_header;

//NT + DIB header
typedef struct   {
    uint32_t size;
    uint32_t array_width;
    uint32_t array_height;
    uint16_t color_planes;
    uint16_t bpp;
    uint32_t compression;
    uint32_t image_size;
    uint32_t width_px_per_meter;
    uint32_t height_px_per_meter;
    uint32_t palette_colors;
    uint32_t significant_colors;
} bitmap_info_header;


bitmap_core_header *read_bmp(void *ptr);

int bmp_width(bitmap_core_header *b);
int bmp_height(bitmap_core_header *b);
uint32_t bmp_array(bitmap_core_header *b);

#ifdef __OS
bitmap_core_header *bmp_hdr_from_file(char *filename);
void bmp_summarize(bitmap_core_header *b);
#endif
#endif
