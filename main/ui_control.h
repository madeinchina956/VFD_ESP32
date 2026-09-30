#ifndef UI_CONTROL_H
#define UI_CONTROL_H

#include <stdbool.h>

// Draw complete Control screen
void ui_control_draw(
    int selected_item,
    int rpm,
    bool forward,
    bool running,
    bool editing
);


// Update selection without redrawing screen
void ui_control_update_selection(
    int old_item,
    int new_item,
    int rpm,
    bool forward,
    bool running,
    bool editing
);


// Redraw one Control item
void ui_control_update_item(
    int item,
    bool selected,
    int rpm,
    bool forward,
    bool running,
    bool editing
);

#endif