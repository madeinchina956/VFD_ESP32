#ifndef CONTROL_SOURCE_H
#define CONTROL_SOURCE_H

#include <stdbool.h>

typedef enum
{
    CONTROL_SOURCE_LOCAL = 0,
    CONTROL_SOURCE_REMOTE

} control_source_t;


// Set control source
void control_source_set(control_source_t source);

// Get current control source
control_source_t control_source_get(void);

// Check who is allowed to control the motor
bool control_source_local_allowed(void);
bool control_source_remote_allowed(void);

#endif