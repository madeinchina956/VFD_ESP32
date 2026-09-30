#include "ui_control.h"

#include <stdio.h>

#include "ui_common.h"
#include "tft_graphics.h"
#include "tft_font.h"


// Selectable Control menu positions
static const uint16_t item_y[] =
{
    60,     // Speed
    120,    // Direction
    180     // Back
};


// Draw one selectable Control option
static void draw_item(
    int item,
    bool selected,
    int rpm,
    bool forward,
    bool editing
)
{
    char text[20];

    uint16_t background =
        selected ? COLOR_BLUE : COLOR_DARK_BLUE;

    uint16_t border =
        selected ? COLOR_YELLOW : COLOR_WHITE;


    // Green border means RPM is being edited
    if (item == 0 && editing)
    {
        border = COLOR_GREEN;
    }


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


    // Show selection arrow
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


    /*
     * -------------------------
     * Speed
     * -------------------------
     */
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


    /*
     * -------------------------
     * Direction
     * -------------------------
     */
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


    /*
     * -------------------------
     * Back
     * -------------------------
     */
    else if (item == 2)
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


// Draw read-only motor status
static void draw_motor_status(
    bool running
)
{
    // Status box is NOT selectable by encoder
    tft_fill_rectangle(
        10,
        240,
        220,
        40,
        COLOR_DARK_BLUE
    );

    tft_draw_rectangle(
        10,
        240,
        220,
        40,
        COLOR_WHITE
    );


    tft_draw_text(
        "STATUS",
        25,
        255,
        1,
        COLOR_WHITE
    );


    tft_draw_text(
        running ? "RUN" : "STOP",
        140,
        255,
        1,
        running ? COLOR_GREEN : COLOR_RED
    );
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


    // Only 3 selectable encoder items
    for (int i = 0; i < 3; i++)
    {
        draw_item(
            i,
            i == selected_item,
            rpm,
            forward,
            editing
        );
    }


    // Motor state is display-only
    draw_motor_status(
        running
    );


    ui_draw_footer(
        "ROTATE:MOVE PRESS:SET"
    );
}


// Update old and new encoder selections
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
        editing
    );

    draw_item(
        new_item,
        true,
        rpm,
        forward,
        editing
    );
}


// Redraw one Control item
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
        editing
    );
}