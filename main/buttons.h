#ifndef BUTTONS_H
#define BUTTONS_H

#include <stdbool.h>

// Initialize the Start and Stop button GPIOs
void buttons_init(void);

// Returns true when Start is pressed
bool start_button_pressed(void);

// Returns true when Stop is pressed
bool stop_button_pressed(void);

#endif