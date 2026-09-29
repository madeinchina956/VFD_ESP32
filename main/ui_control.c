#include "ui_control.h"

#include <stdio.h>

#include "ui_common.h"
#include "tft_graphics.h"
#include "tft_font.h"


static const uint16_t item_y[] =
{
    60,
    120,
    180,
    240
};


// Draw one Control option
static void draw_item(
    int item,
    bool selected,
    int rpm,
    bool forward,
    bool running,
    bool editing
)
{
    char text[20];

    uint16_t background =
        selected ? COLOR_BLUE : COLOR_DARK_BLUE;

    uint16_t border =
        selected ? COLOR_YELLOW : COLOR_WHITE;


    // Green border indicates active editing
    if (item == 0 && editing)
        border = COLOR_GREEN;


    tft_fill_rectangle(
        10,
        item_y[item],
        220,
        45,
        background
    );

    tft_draw_rectangle(
        10,
        item_y[item],
        220,
        45,
        border
    );


    if (selected)
    {
        tft_draw_text(
            ">",
            20,
            item_y[item] + 15,
            1,
            COLOR_YELLOW
        );
    }


    // Speed
    if (item == 0)
    {
        tft_draw_text(
            "SPEED",
            40,
            item_y[item] + 8,
            1,
            COLOR_WHITE
        );

        snprintf(
            text,
            sizeof(text),
            "%d RPM",
            rpm
        );

        tft_draw_text(
            text,
            105,
            item_y[item] + 8,
            1,
            COLOR_YELLOW
        );
    }


    // Direction
    else if (item == 1)
    {
        tft_draw_text(
            "DIRECTION",
            40,
            item_y[item] + 15,
            1,
            COLOR_WHITE
        );

        tft_draw_text(
            forward ? "FWD" : "REV",
            140,
            item_y[item] + 15,
            1,
            COLOR_GREEN
        );
    }


    // Run / Stop
    else if (item == 2)
    {
        tft_draw_text(
            "MOTOR",
            40,
            item_y[item] + 15,
            1,
            COLOR_WHITE
        );

        tft_draw_text(
            running ? "RUN" : "STOP",
            140,
            item_y[item] + 15,
            1,
            running ? COLOR_GREEN : COLOR_RED
        );
    }


    // Back
    else
    {
        tft_draw_text(
            "BACK",
            90,
            item_y[item] + 15,
            1,
            COLOR_WHITE
        );
    }
}


// Draw complete Control screen
void ui_control_draw(
    int selected_item,
    int rpm,
    bool forward,
    bool running,
    bool editing
)
{
    tft_fill_screen(
        COLOR_DARK_BLUE
    );

    ui_draw_header(
        "CONTROL"
    );


    for (int i = 0; i < 4; i++)
    {
        draw_item(
            i,
            i == selected_item,
            rpm,
            forward,
            running,
            editing
        );
    }


    ui_draw_footer(
        "ROTATE:MOVE PRESS:SET"
    );
}


// Update only old and new selections
void ui_control_update_selection(
    int old_item,
    int new_item,
    int rpm,
    bool forward,
    bool running,
    bool editing
)
{
    draw_item(
        old_item,
        false,
        rpm,
        forward,
        running,
        editing
    );

    draw_item(
        new_item,
        true,
        rpm,
        forward,
        running,
        editing
    );
}


// Redraw one item after its value changes
void ui_control_update_item(
    int item,
    bool selected,
    int rpm,
    bool forward,
    bool running,
    bool editing
)
{
    draw_item(
        item,
        selected,
        rpm,
        forward,
        running,
        editing
    );
}