#ifndef UI_SETTINGS_H
#define UI_SETTINGS_H

#include <stdbool.h>

// Draw complete Settings screen
void ui_settings_draw(
    int selected_item
);

// Update highlighted Settings item
void ui_settings_update_selection(
    int old_item,
    int new_item
);

// Redraw Control Source after changing it
void ui_settings_update_source(
    bool selected
);

#endif