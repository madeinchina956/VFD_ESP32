#include "control_source.h"


// Default to local control
static control_source_t current_source =
    CONTROL_SOURCE_LOCAL;


void control_source_set(control_source_t source)
{
    current_source = source;
}


control_source_t control_source_get(void)
{
    return current_source;
}


bool control_source_local_allowed(void)
{
    return current_source ==
           CONTROL_SOURCE_LOCAL;
}


bool control_source_remote_allowed(void)
{
    return current_source ==
           CONTROL_SOURCE_REMOTE;
}