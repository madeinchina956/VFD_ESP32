#include "ui_home.h"

#include <stdbool.h>

#include "ui_common.h"
#include "tft_graphics.h"
#include "tft_font.h"


// Home menu labels
static const char *menu_items[] =
{
    "CONTROL",
    "MEASURE",
    "FAULTS",
    "SETTINGS"
};


// Vertical position of each option
static const uint16_t menu_y[] =
{
    65,
    120,
    175,
    230
};


// Draw one menu option
static void draw_menu_item(
    int item,
    bool selected
)
{
    uint16_t background =
        selected ? COLOR_BLUE : COLOR_DARK_BLUE;

    uint16_t border =
        selected ? COLOR_YELLOW : COLOR_WHITE;


    // Clear and redraw only this menu item
    tft_fill_rectangle(
        15,
        menu_y[item],
        210,
        40,
        background
    );

    tft_draw_rectangle(
        15,
        menu_y[item],
        210,
        40,
        border
    );


    // Show selection arrow
    if (selected)
    {
        tft_draw_text(
            ">",
            25,
            menu_y[item] + 13,
            2,
            COLOR_YELLOW
        );
    }


    tft_draw_text(
        menu_items[item],
        55,
        menu_y[item] + 13,
        2,
        COLOR_WHITE
    );
}


// Draw complete home screen
void ui_home_draw(
    int selected_item
)
{
    tft_fill_screen(
        COLOR_DARK_BLUE
    );

    ui_draw_header(
        "VFD CONTROLLER"
    );


    for (int i = 0; i < 4; i++)
    {
        draw_menu_item(
            i,
            i == selected_item
        );
    }


    ui_draw_footer(
        "ROTATE:MOVE PRESS:SELECT"
    );
}


// Redraw only old and new selections
void ui_home_update_selection(
    int old_item,
    int new_item
)
{
    draw_menu_item(
        old_item,
        false);
    draw_menu_item(
        new_item,
        true);
}