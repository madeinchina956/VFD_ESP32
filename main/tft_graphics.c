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

void tft_fill_rectangle(
    uint16_t x,
    uint16_t y,
    uint16_t width,
    uint16_t height,
    uint16_t color
)
{
    if (width == 0 || height == 0)
        return;

    if (x >= TFT_WIDTH || y >= TFT_HEIGHT)
        return;

    if (x + width > TFT_WIDTH)
        width = TFT_WIDTH - x;

    if (y + height > TFT_HEIGHT)
        height = TFT_HEIGHT - y;

    tft_set_window(
        x,
        y,
        x + width - 1,
        y + height - 1
    );

    uint8_t pixel[2] = {
        color >> 8,
        color & 0xFF
    };

    for (uint32_t i = 0; i < width * height; i++)
    {
        tft_display_write_data(pixel, 2);
    }
}
void tft_draw_rectangle(
    uint16_t x,
    uint16_t y,
    uint16_t width,
    uint16_t height,
    uint16_t color
)
{
    // Top
    tft_fill_rectangle(
        x,
        y,
        width,
        1,
        color
    );

    // Bottom
    tft_fill_rectangle(
        x,
        y + height - 1,
        width,
        1,
        color
    );

    // Left
    tft_fill_rectangle(
        x,
        y,
        1,
        height,
        color
    );

    // Right
    tft_fill_rectangle(
        x + width - 1,
        y,
        1,
        height,
        color
    );
}
// Seven-segment patterns for digits 0-9
static const uint8_t digit_segments[10] =
{
    0x3F, // 0
    0x06, // 1
    0x5B, // 2
    0x4F, // 3
    0x66, // 4
    0x6D, // 5
    0x7D, // 6
    0x07, // 7
    0x7F, // 8
    0x6F  // 9
};

// Draw one digit
static void tft_draw_digit(
    uint16_t x,
    uint16_t y,
    int digit,
    uint16_t color
)
{
    if (digit < 0 || digit > 9)
        return;

    uint8_t segments = digit_segments[digit];

    int width = 24;
    int height = 40;
    int thick = 4;

    // Top
    if (segments & 0x01)
        tft_fill_rectangle(
            x + thick,
            y,
            width - (2 * thick),
            thick,
            color
        );

    // Upper right
    if (segments & 0x02)
        tft_fill_rectangle(
            x + width - thick,
            y + thick,
            thick,
            height / 2 - thick,
            color
        );

    // Lower right
    if (segments & 0x04)
        tft_fill_rectangle(
            x + width - thick,
            y + height / 2,
            thick,
            height / 2 - thick,
            color
        );

    // Bottom
    if (segments & 0x08)
        tft_fill_rectangle(
            x + thick,
            y + height - thick,
            width - (2 * thick),
            thick,
            color
        );

    // Lower left
    if (segments & 0x10)
        tft_fill_rectangle(
            x,
            y + height / 2,
            thick,
            height / 2 - thick,
            color
        );

    // Upper left
    if (segments & 0x20)
        tft_fill_rectangle(
            x,
            y + thick,
            thick,
            height / 2 - thick,
            color
        );

    // Middle
    if (segments & 0x40)
        tft_fill_rectangle(
            x + thick,
            y + height / 2 - 2,
            width - (2 * thick),
            thick,
            color
        );
}
// Draw an integer on the screen
void tft_draw_number(
    uint16_t x,
    uint16_t y,
    int value,
    uint16_t color,
    uint16_t background
)
{
    // Clear old number
    tft_fill_rectangle(
        x,
        y,
        150,
        50,
        background
    );

    // Draw negative sign
    if (value < 0)
    {
        tft_fill_rectangle(
            x,
            y + 18,
            16,
            4,
            color
        );

        x += 22;
        value = -value;
    }

    // Display zero
    if (value == 0)
    {
        tft_draw_digit(
            x,
            y,
            0,
            color
        );

        return;
    }

    int digits[10];
    int count = 0;

    // Break number into digits
    while (value > 0 && count < 10)
    {
        digits[count] = value % 10;
        value /= 10;
        count++;
    }

    // Draw digits left to right
    for (int i = count - 1; i >= 0; i--)
    {
        tft_draw_digit(
            x,
            y,
            digits[i],
            color
        );

        x += 32;
    }
}