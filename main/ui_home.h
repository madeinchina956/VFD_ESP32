#ifndef UI_HOME_H
#define UI_HOME_H
#include "ui_home.h"
// Draw complete home menu
void ui_home_draw(
    int selected_item
);

// Update only changed menu items
void ui_home_update_selection(
    int old_item,
    int new_item
);

#endif