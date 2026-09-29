#ifndef TFT_DISPLAY_H
#define TFT_DISPLAY_H

#include <stdint.h>

// Initialize the TFT display
void tft_display_init(void);

// Send one command byte to the TFT
void tft_display_write_command(
    uint8_t command
);

// Send data bytes to the TFT
void tft_display_write_data(
    const uint8_t *data,
    int length
);

// Send the same RGB565 color
// to multiple pixels
void tft_display_write_color_repeat(
    uint16_t color,
    int count
);

#endif