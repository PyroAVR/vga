#ifndef __COLOR_H__
#define __COLOR_H__


typedef struct  {
    int red:3;
    int green:3;
    int blue:2;
} color;


const color color_squares = {
           { 0, 0, 3 }, { 0, 0, 3 }, { 0, 0, 3 },
           { 0, 7, 0 }, { 0, 7, 0 }, { 0, 7, 0 },
           { 7, 0, 0 }, { 7, 0, 0 }, { 7, 0, 0 }
           };

#endif
