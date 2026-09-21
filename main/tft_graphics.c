#include "tft_graphics.h"
#include "tft_display.h"

static void tft_set_window(
    uint16_t x1,
    uint16_t y1,
    uint16_t x2,
    uint16_t y2
)
{
    uint8_t data[4];

    // X coordinates
    tft_display_write_command(0x2A);

    data[0] = x1 >> 8;
    data[1] = x1 & 0xFF;
    data[2] = x2 >> 8;
    data[3] = x2 & 0xFF;

    tft_display_write_data(data, 4);

    // Y coordinates
    tft_display_write_command(0x2B);

    data[0] = y1 >> 8;
    data[1] = y1 & 0xFF;
    data[2] = y2 >> 8;
    data[3] = y2 & 0xFF;

    tft_display_write_data(data, 4);

    // Memory write
    tft_display_write_command(0x2C);
}

void tft_fill_screen(uint16_t color)
{
    uint8_t row[TFT_WIDTH * 2];

    for (int x = 0; x < TFT_WIDTH; x++)
    {
        row[x * 2] = color >> 8;
        row[x * 2 + 1] = color & 0xFF;
    }

    tft_set_window(
        0,
        0,
        TFT_WIDTH - 1,
        TFT_HEIGHT - 1
    );

    for (int y = 0; y < TFT_HEIGHT; y++)
    {
        tft_display_write_data(row, sizeof(row));
    }
}

void tft_draw_pixel(
    uint16_t x,
    uint16_t y,
    uint16_t color
)
{
    if (x >= TFT_WIDTH || y >= TFT_HEIGHT)
        return;

    uint8_t pixel[2] = {
        color >> 8,
        color & 0xFF
    };

    tft_set_window(x, y, x, y);
    tft_display_write_data(pixel, 2);
}

void tft_draw_rectangle(
    uint16_t x,
    uint16_t y,
    uint16_t width,
    uint16_t height,
    uint16_t color
)
{
    if (width == 0 || height == 0)
        return;

    for (uint16_t i = x; i < x + width; i++)
    {
        tft_draw_pixel(i, y, color);
        tft_draw_pixel(i, y + height - 1, color);
    }

    for (uint16_t i = y; i < y + height; i++)
    {
        tft_draw_pixel(x, i, color);
        tft_draw_pixel(x + width - 1, i, color);
    }
}