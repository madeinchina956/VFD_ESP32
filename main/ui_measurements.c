#include "ui_measurements.h"

#include "ui_common.h"
#include "tft_graphics.h"
#include "tft_font.h"


void ui_measurements_draw(void)
{
    tft_fill_screen(
        COLOR_DARK_BLUE
    );

    ui_draw_header(
        "MEASUREMENTS"
    );


    // Actual motor speed
    tft_draw_text(
        "ACTUAL RPM",
        20,
        75,
        2,
        COLOR_WHITE
    );

    tft_draw_text(
        "0 RPM",
        20,
        100,
        2,
        COLOR_GREEN
    );


    // Motor current
    tft_draw_text(
        "CURRENT",
        20,
        140,
        2,
        COLOR_WHITE
    );

    tft_draw_text(
        "0.0 A",
        20,
        165,
        2,
        COLOR_YELLOW
    );


    // Estimated torque
    tft_draw_text(
        "TORQUE",
        20,
        205,
        2,
        COLOR_WHITE
    );

    tft_draw_text(
        "0.0",
        20,
        230,
        2,
        COLOR_YELLOW
    );


    // DC-link voltage
    tft_draw_text(
        "DC LINK",
        130,
        205,
        1,
        COLOR_WHITE
    );

    tft_draw_text(
        "0 V",
        130,
        230,
        2,
        COLOR_GREEN
    );


    ui_draw_footer(
        "PRESS:BACK"
    );
}