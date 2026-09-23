#ifndef TFT_DISPLAY_H
#define TFT_DISPLAY_H

#include <stdint.h>

void tft_display_init(void);
void tft_display_write_command(
    uint8_t command
);

void tft_display_write_data(
    const uint8_t *data,
    int length
);

#endif