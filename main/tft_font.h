#ifndef TFT_FONT_H
#define TFT_FONT_H

#include <stdint.h>


void tft_draw_character(
    char character,
    uint16_t x,
    uint16_t y,
    uint16_t scale,
    uint16_t color
);


void tft_draw_text(
    const char *text,
    uint16_t x,
    uint16_t y,
    uint16_t scale,
    uint16_t color
);

#endif