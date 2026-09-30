#include "ui_settings.h"

#include "control_source.h"
#include "ui_common.h"
#include "tft_graphics.h"
#include "tft_font.h"


// Draw Control Source option
static void draw_control_source(bool selected)
{
    uint16_t background =
        selected ? COLOR_BLUE : COLOR_DARK_BLUE;

    uint16_t border =
        selected ? COLOR_YELLOW : COLOR_WHITE;


    tft_fill_rectangle(
        10,
        65,
        220,
        50,
        background
    );

    tft_draw_rectangle(
        10,
        65,
        220,
        50,
        border
    );


    if (selected)
    {
        tft_draw_text(
            ">",
            20,
            82,
            1,
            COLOR_YELLOW
        );
    }


    tft_draw_text(
        "SOURCE",
        40,
        80,
        1,
        COLOR_WHITE
    );


    // Show current control source
    if (control_source_local_allowed())
    {
        tft_draw_text(
            "LOCAL",
            140,
            80,
            1,
            COLOR_GREEN
        );
    }
    else
    {
        tft_draw_text(
            "REMOTE",
            140,
            80,
            1,
            COLOR_YELLOW
        );
    }
}


// Draw Back option
static void draw_back(bool selected)
{
    uint16_t background =
        selected ? COLOR_BLUE : COLOR_DARK_BLUE;

    uint16_t border =
        selected ? COLOR_YELLOW : COLOR_WHITE;


    tft_fill_rectangle(
        10,
        230,
        220,
        40,
        background
    );

    tft_draw_rectangle(
        10,
        230,
        220,
        40,
        border
    );


    if (selected)
    {
        tft_draw_text(
            ">",
            20,
            245,
            1,
            COLOR_YELLOW
        );
    }


    tft_draw_text(
        "BACK",
        90,
        245,
        1,
        COLOR_WHITE
    );
}


// Draw complete Settings screen
void ui_settings_draw(int selected_item)
{
    tft_fill_screen(
        COLOR_DARK_BLUE
    );

    ui_draw_header(
        "SETTINGS"
    );


    // Control source
    draw_control_source(
        selected_item == 0
    );


    // Wi-Fi information
    tft_draw_text(
        "WIFI",
        20,
        130,
        1,
        COLOR_WHITE
    );

    tft_draw_text(
        "ESP32 AP",
        120,
        130,
        1,
        COLOR_GREEN
    );


    // Controller IP
    tft_draw_text(
        "CONTROLLER IP",
        20,
        165,
        1,
        COLOR_WHITE
    );

    tft_draw_text(
        "192.168.4.1",
        20,
        190,
        2,
        COLOR_YELLOW
    );


    // Back
    draw_back(
        selected_item == 1
    );


    ui_draw_footer(
        "ROTATE:MOVE PRESS:SET"
    );
}


// Update highlighted Settings item
void ui_settings_update_selection(
    int old_item,
    int new_item
)
{
    if (old_item == 0)
    {
        draw_control_source(false);
    }
    else
    {
        draw_back(false);
    }


    if (new_item == 0)
    {
        draw_control_source(true);
    }
    else
    {
        draw_back(true);
    }
}


// Refresh Control Source value
void ui_settings_update_source(bool selected)
{
    draw_control_source(selected);
}