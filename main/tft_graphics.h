#ifndef TFT_GRAPHICS_H
#define TFT_GRAPHICS_H

#include <stdint.h>

#define TFT_WIDTH       240
#define TFT_HEIGHT      320

/*
 * RGB565 colors
 */
#define COLOR_BLACK         0x0000
#define COLOR_WHITE         0xFFFF
#define COLOR_BLUE          0x001F
#define COLOR_GREEN         0x07E0
#define COLOR_RED           0xF800
#define COLOR_YELLOW        0xFFE0
#define COLOR_DARK_BLUE     0x0010


void tft_fill_screen(
    uint16_t color
);


void tft_draw_pixel(
    uint16_t x,
    uint16_t y,
    uint16_t color
);


void tft_draw_rectangle(
    uint16_t x,
    uint16_t y,
    uint16_t width,
    uint16_t height,
    uint16_t color
);

#endif