#ifndef ENCODER_H
#define ENCODER_H

#include <stdbool.h>

// Initialize KY-040 encoder
void encoder_init(void);

// Returns encoder position in DETENTS,
// not every individual quadrature transition
int encoder_get_value(void);

// Returns true once for each encoder button press
bool encoder_button_pressed(void);

#endif