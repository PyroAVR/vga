#include "BMP.h"

int bmp_type(bitmap_core_header *ptr);

__attribute__((always_inline)) bitmap_core_header *read_bmp(void *ptr) {
   return (bitmap_core_header*)ptr; 
}


__attribute__((always_inline)) uint32_t bmp_array(bitmap_core_header *ptr) {
    return ptr + (uint32_t*)(ptr->array_offset);
}

uint32_t bmp_width(bitmap_core_header *ptr) {
    switch(bmp_type(ptr))   {
        case 0: //Windoge
             
            break;
        default: //OS/2

            break;
    }
}

uint32_t bmp_height(bitmap_core_header *ptr) {
    switch(bmp_type(ptr))   {
        case 0: //Windoge
             
            break;
        default: //OS/2

            break;
    }
}


#ifdef __OS
#include <stdio.h>
bitmap_core_header *bmp_hdr_from_file(char *filename)   {
    FILE *f = fopen(filename, "rb");
    if(f == NULL)   {
        perror("could not open file");
        return NULL;
    }
    bitmap_core_header *r = malloc(sizeof(bitmap_core_header));
    fclose(f);
    return r;
}

void bmp_summarize(bitmap_core_header *ptr) {
    printf();

}

#endif

__attribute__((always_inline)) int bmp_type(bmp_core_header *ptr)    {
    switch(b->magic)   {
        case "BM":
            return 0;
        case "BA":
            return 1;
        case "CI":
            return 2;
        case "CP":
            return 3;
        case "IC":
            return 4;
        case "PT":
            return 5;
        default:
            return 0;
    }
}
    
}
