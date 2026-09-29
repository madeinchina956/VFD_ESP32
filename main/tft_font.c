#include "tft_font.h"
#include "tft_graphics.h"
#include <stddef.h>
// 5x7 bitmap data for digits 0-9
static const uint8_t digits[10][5] =
{
    {0x3E,0x51,0x49,0x45,0x3E},
    {0x00,0x42,0x7F,0x40,0x00},
    {0x42,0x61,0x51,0x49,0x46},
    {0x21,0x41,0x45,0x4B,0x31},
    {0x18,0x14,0x12,0x7F,0x10},
    {0x27,0x45,0x45,0x45,0x39},
    {0x3C,0x4A,0x49,0x49,0x30},
    {0x01,0x71,0x09,0x05,0x03},
    {0x36,0x49,0x49,0x49,0x36},
    {0x06,0x49,0x49,0x29,0x1E}
};

// 5x7 bitmap data for letters A-Z
static const uint8_t letters[26][5] =
{
    {0x7E,0x11,0x11,0x11,0x7E},
    {0x7F,0x49,0x49,0x49,0x36},
    {0x3E,0x41,0x41,0x41,0x22},
    {0x7F,0x41,0x41,0x22,0x1C},
    {0x7F,0x49,0x49,0x49,0x41},
    {0x7F,0x09,0x09,0x09,0x01},
    {0x3E,0x41,0x49,0x49,0x7A},
    {0x7F,0x08,0x08,0x08,0x7F},
    {0x00,0x41,0x7F,0x41,0x00},
    {0x20,0x40,0x41,0x3F,0x01},
    {0x7F,0x08,0x14,0x22,0x41},
    {0x7F,0x40,0x40,0x40,0x40},
    {0x7F,0x02,0x04,0x02,0x7F},
    {0x7F,0x04,0x08,0x10,0x7F},
    {0x3E,0x41,0x41,0x41,0x3E},
    {0x7F,0x09,0x09,0x09,0x06},
    {0x3E,0x41,0x51,0x21,0x5E},
    {0x7F,0x09,0x19,0x29,0x46},
    {0x46,0x49,0x49,0x49,0x31},
    {0x01,0x01,0x7F,0x01,0x01},
    {0x3F,0x40,0x40,0x40,0x3F},
    {0x1F,0x20,0x40,0x20,0x1F},
    {0x3F,0x40,0x38,0x40,0x3F},
    {0x63,0x14,0x08,0x14,0x63},
    {0x07,0x08,0x70,0x08,0x07},
    {0x61,0x51,0x49,0x45,0x43}
};

// Return bitmap data for a character
static const uint8_t *get_character_data(char character)
{
    static const uint8_t colon[5]   = {0x00,0x36,0x36,0x00,0x00};
    static const uint8_t period[5]  = {0x00,0x60,0x60,0x00,0x00};
    static const uint8_t dash[5]    = {0x08,0x08,0x08,0x08,0x08};
    static const uint8_t greater[5] = {0x00,0x41,0x22,0x14,0x08};
    static const uint8_t less[5]    = {0x08,0x14,0x22,0x41,0x00};
    static const uint8_t slash[5]   = {0x20,0x10,0x08,0x04,0x02};
    static const uint8_t plus[5]    = {0x08,0x08,0x3E,0x08,0x08};

    if (character >= 'a' && character <= 'z')
        character -= 32;

    if (character >= '0' && character <= '9')
        return digits[character - '0'];

    if (character >= 'A' && character <= 'Z')
        return letters[character - 'A'];

    switch (character)
    {
        case ':': return colon;
        case '.': return period;
        case '-': return dash;
        case '>': return greater;
        case '<': return less;
        case '/': return slash;
        case '+': return plus;
        default:  return NULL;
    }
}


// Draw one character with transparent background
void tft_draw_character(
    char character,
    uint16_t x,
    uint16_t y,
    uint16_t scale,
    uint16_t color
)
{
    const uint8_t *data =
        get_character_data(character);

    if (data == NULL)
        return;

    // Draw active pixels only
    for (int column = 0; column < 5; column++)
    {
        for (int row = 0; row < 7; row++)
        {
            if (data[column] & (1 << row))
            {
                tft_fill_rectangle(
                    x + column * scale,
                    y + row * scale,
                    scale,
                    scale,
                    color
                );
            }
        }
    }
}


// Draw one character with a background color
void tft_draw_character_bg(
    char character,
    uint16_t x,
    uint16_t y,
    uint16_t scale,
    uint16_t color,
    uint16_t background
)
{
    // Clear full character area first
    tft_fill_rectangle(
        x,
        y,
        6 * scale,
        7 * scale,
        background
    );

    if (character != ' ')
    {
        tft_draw_character(
            character,
            x,
            y,
            scale,
            color
        );
    }
}


// Draw text with transparent background
void tft_draw_text(
    const char *text,
    uint16_t x,
    uint16_t y,
    uint16_t scale,
    uint16_t color
)
{
    while (*text)
    {
        if (*text != ' ')
        {
            tft_draw_character(
                *text,
                x,
                y,
                scale,
                color
            );
        }

        x += 6 * scale;
        text++;
    }
}


// Draw text with foreground and background colors
void tft_draw_text_bg(
    const char *text,
    uint16_t x,
    uint16_t y,
    uint16_t scale,
    uint16_t color,
    uint16_t background
)
{
    while (*text)
    {
        tft_draw_character_bg(
            *text,
            x,
            y,
            scale,
            color,
            background
        );

        x += 6 * scale;
        text++;
    }
}