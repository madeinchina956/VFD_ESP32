#include "control_source.h"

#include <stdint.h>
#include <string.h>

#include "esp_random.h"
#include "esp_timer.h"

#include "freertos/FreeRTOS.h"
#include "freertos/portmacro.h"

// Session timeout: 5 seconds
#define SESSION_TIMEOUT_US 5000000LL

// Shared state protection
static portMUX_TYPE lock = portMUX_INITIALIZER_UNLOCKED;

// Default control source
static control_source_t current_source =
    CONTROL_SOURCE_LOCAL;

// Wireless session state
static char owner_token[SESSION_TOKEN_SIZE] = {0};
static int64_t expires_at = 0;

// Clear session while holding the lock
static void clear_session(void)
{
    owner_token[0] = '\0';
    expires_at = 0;
}

// Check session expiration
static void expire_session(void)
{
    if (owner_token[0] != '\0' &&
        esp_timer_get_time() >= expires_at)
    {
        clear_session();
    }
}

// Generate a random session token
static void generate_token(char *token)
{
    uint8_t random_bytes[16];

    const char hex[] = "0123456789abcdef";

    esp_fill_random(random_bytes, sizeof(random_bytes));

    for (int i = 0; i < 16; i++)
    {
        token[i * 2] = hex[random_bytes[i] >> 4];
        token[i * 2 + 1] = hex[random_bytes[i] & 0x0F];
    }

    token[32] = '\0';
}

// Set control source
void control_source_set(control_source_t source)
{
    if (source != CONTROL_SOURCE_LOCAL &&
        source != CONTROL_SOURCE_REMOTE)
    {
        return;
    }

    portENTER_CRITICAL(&lock);

    if (current_source != source)
    {
        current_source = source;

        // Changing source revokes wireless ownership
        clear_session();
    }

    portEXIT_CRITICAL(&lock);
}

// Get control source
control_source_t control_source_get(void)
{
    portENTER_CRITICAL(&lock);

    control_source_t source = current_source;

    portEXIT_CRITICAL(&lock);

    return source;
}

bool control_source_local_allowed(void)
{
    return control_source_get() == CONTROL_SOURCE_LOCAL;
}

bool control_source_remote_allowed(void)
{
    return control_source_get() == CONTROL_SOURCE_REMOTE;
}

// Get current session availability
session_state_t session_get_state(void)
{
    portENTER_CRITICAL(&lock);

    expire_session();

    session_state_t state;

    if (current_source == CONTROL_SOURCE_LOCAL)
    {
        state = SESSION_LOCAL;
    }
    else if (owner_token[0] != '\0')
    {
        state = SESSION_BUSY;
    }
    else
    {
        state = SESSION_AVAILABLE;
    }

    portEXIT_CRITICAL(&lock);

    return state;
}

// Request exclusive wireless access
session_state_t session_acquire(
    char token[SESSION_TOKEN_SIZE])
{
    char candidate[SESSION_TOKEN_SIZE];

    generate_token(candidate);

    portENTER_CRITICAL(&lock);

    expire_session();

    session_state_t state;

    if (current_source == CONTROL_SOURCE_LOCAL)
    {
        state = SESSION_LOCAL;
    }
    else if (owner_token[0] != '\0')
    {
        state = SESSION_BUSY;
    }
    else
    {
        memcpy(owner_token, candidate, SESSION_TOKEN_SIZE);
        memcpy(token, candidate, SESSION_TOKEN_SIZE);

        expires_at =
            esp_timer_get_time() + SESSION_TIMEOUT_US;

        state = SESSION_AUTHORIZED;
    }

    portEXIT_CRITICAL(&lock);

    return state;
}

// Verify or release an existing session
session_state_t session_verify(
    const char *token,
    bool release)
{
    portENTER_CRITICAL(&lock);

    expire_session();

    session_state_t state;

    if (current_source == CONTROL_SOURCE_LOCAL)
    {
        state = SESSION_LOCAL;
    }
    else if (owner_token[0] == '\0')
    {
        state = SESSION_AVAILABLE;
    }
    else if (token == NULL ||
             strcmp(token, owner_token) != 0)
    {
        state = SESSION_BUSY;
    }
    else
    {
        state = SESSION_AUTHORIZED;

        if (release)
        {
            clear_session();
        }
        else
        {
            // Renew authorized session
            expires_at =
                esp_timer_get_time() + SESSION_TIMEOUT_US;
        }
    }

    portEXIT_CRITICAL(&lock);

    return state;
}