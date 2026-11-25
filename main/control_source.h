#ifndef CONTROL_SOURCE_H
#define CONTROL_SOURCE_H

#include <stdbool.h>

#define SESSION_TOKEN_SIZE 33

typedef enum
{
    CONTROL_SOURCE_LOCAL = 0,
    CONTROL_SOURCE_REMOTE
} control_source_t;

typedef enum
{
    SESSION_LOCAL,
    SESSION_AVAILABLE,
    SESSION_BUSY,
    SESSION_AUTHORIZED
} session_state_t;

// Control source
void control_source_set(control_source_t source);
control_source_t control_source_get(void);

bool control_source_local_allowed(void);
bool control_source_remote_allowed(void);

// Wireless sessions
session_state_t session_get_state(void);

session_state_t session_acquire(
    char token[SESSION_TOKEN_SIZE]
);

session_state_t session_verify(
    const char *token,
    bool release
);

#endif