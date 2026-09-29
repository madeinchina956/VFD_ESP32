#include "ui_settings.h"

#include "ui_common.h"
#include "tft_graphics.h"
#include "tft_font.h"


void ui_settings_draw(void)
{
    tft_fill_screen(
        COLOR_DARK_BLUE
    );

    ui_draw_header(
        "SETTINGS"
    );


    // Wi-Fi
    tft_draw_rectangle(
        10,
        70,
        220,
        50,
        COLOR_WHITE
    );

    tft_draw_text(
        "WIFI",
        20,
        85,
        2,
        COLOR_WHITE
    );


    // ESP32 controller address
    tft_draw_rectangle(
        10,
        140,
        220,
        70,
        COLOR_WHITE);

    tft_draw_text(
        "CONTROLLER IP",
        20,
        150,
        1,
        COLOR_WHITE);

    tft_draw_text(
        "192.168.4.1",
        20,
        180,
        2,
        COLOR_YELLOW);

    // Controller type
    tft_draw_rectangle(
        10,
        230,
        220,
        45,
        COLOR_WHITE);
    tft_draw_text(
        "ESP32 WROOM",
        45,
        245,
        2,
        COLOR_GREEN);
    ui_draw_footer(
        "PRESS:BACK");
}