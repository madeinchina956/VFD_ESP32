#include "ui_common.h"

#include "tft_graphics.h"
#include "tft_font.h"


// Draw title area used by all screens
void ui_draw_header(const char *title)
{
    tft_fill_rectangle(
        0,
        0,
        TFT_WIDTH,
        50,
        COLOR_DARK_BLUE);

    tft_draw_rectangle(
        5,
        5,
        230,
        40,
        COLOR_WHITE);
    tft_draw_text(
        title,
        20,
        17,
        2,
        COLOR_WHITE);
}
// Draw instructions at the bottom
void ui_draw_footer(const char *text)
{
    tft_fill_rectangle(
        0,
        290,
        TFT_WIDTH,
        30,
        COLOR_DARK_BLUE);
    tft_draw_text(
        text,
        10,
        300,
        1,
        COLOR_WHITE);
}