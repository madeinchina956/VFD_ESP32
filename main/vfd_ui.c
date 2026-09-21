#include "vfd_ui.h"
#include "tft_graphics.h"
#include "tft_font.h"

void vfd_ui_show_home(void)
{
    tft_fill_screen(COLOR_DARK_BLUE);

    // Title
    tft_draw_rectangle(5, 5, 230, 45, COLOR_WHITE);
    tft_draw_text("VFD", 90, 15, 3, COLOR_WHITE);

    // Speed
    tft_draw_rectangle(10, 65, 220, 60, COLOR_GREEN);
    tft_draw_text("SPEED", 20, 75, 2, COLOR_WHITE);
    tft_draw_text("0 RPM", 20, 100, 2, COLOR_YELLOW);

    // Direction
    tft_draw_rectangle(10, 140, 220, 50, COLOR_WHITE);
    tft_draw_text("DIRECTION", 20, 150, 2, COLOR_WHITE);
    tft_draw_text("FORWARD", 20, 170, 2, COLOR_GREEN);

    // Mode
    tft_draw_rectangle(10, 205, 220, 50, COLOR_WHITE);
    tft_draw_text("MODE", 20, 215, 2, COLOR_WHITE);
    tft_draw_text("MANUAL", 20, 235, 2, COLOR_YELLOW);

    // Status
    tft_draw_rectangle(10, 270, 220, 40, COLOR_RED);
    tft_draw_text("STOPPED", 70, 282, 2, COLOR_WHITE);
}