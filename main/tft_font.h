#ifndef TFT_FONT_H
#define TFT_FONT_H

#include <stdint.h>


// Draw one character with transparent background
void tft_draw_character(
    char character,
    uint16_t x,
    uint16_t y,
    uint16_t scale,
    uint16_t color
);


// Draw one character with foreground
// and background colors
void tft_draw_character_bg(
    char character,
    uint16_t x,
    uint16_t y,
    uint16_t scale,
    uint16_t color,
    uint16_t background
);


// Draw text with transparent background
void tft_draw_text(
    const char *text,
    uint16_t x,
    uint16_t y,
    uint16_t scale,
    uint16_t color
);


// Draw text with foreground
// and background colors
void tft_draw_text_bg(
    const char *text,
    uint16_t x,
    uint16_t y,
    uint16_t scale,
    uint16_t color,
    uint16_t background
);

#endif