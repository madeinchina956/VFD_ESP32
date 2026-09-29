#include "ui_faults.h"

#include "ui_common.h"
#include "tft_graphics.h"
#include "tft_font.h"


void ui_faults_draw(void)
{
    tft_fill_screen(
        COLOR_DARK_BLUE
    );

    ui_draw_header(
        "FAULTS"
    );


    // Fault status box
    tft_draw_rectangle(
        10,
        75,
        220,
        90,
        COLOR_GREEN
    );

    tft_draw_text(
        "STATUS",
        20,
        90,
        2,
        COLOR_WHITE
    );

    tft_draw_text(
        "NO FAULT",
        55,
        125,
        2,
        COLOR_GREEN
    );


    // Fault code
    tft_draw_rectangle(
        10,
        185,
        220,
        70,
        COLOR_WHITE
    );

    tft_draw_text(
        "FAULT CODE",
        20,
        200,
        2,
        COLOR_WHITE
    );

    tft_draw_text(
        "0",
        20,
        230,
        2,
        COLOR_YELLOW
    );


    ui_draw_footer(
        "PRESS:BACK"
    );
}