#include "session_http.h"
#include "control_source.h"

#include <stdio.h>
#include <string.h>

#include "esp_http_server.h"

static httpd_handle_t server = NULL;

// Send JSON response
static esp_err_t send_json(
    httpd_req_t *req,
    const char *status,
    const char *body)
{
    httpd_resp_set_status(req, status);
    httpd_resp_set_type(req, "application/json");

    httpd_resp_set_hdr(
        req,
        "Cache-Control",
        "no-store"
    );

    return httpd_resp_sendstr(req, body);
}

// Return session denial response
static esp_err_t deny_access(
    httpd_req_t *req,
    session_state_t state)
{
    switch (state)
    {
        case SESSION_LOCAL:
            return send_json(
                req,
                "423 Locked",
                "{\"state\":\"local\"}"
            );

        case SESSION_BUSY:
            return send_json(
                req,
                "409 Conflict",
                "{\"state\":\"busy\"}"
            );

        default:
            return send_json(
                req,
                "401 Unauthorized",
                "{\"state\":\"disconnected\"}"
            );
    }
}

// Extract Bearer session token
static bool read_token(
    httpd_req_t *req,
    char token[SESSION_TOKEN_SIZE])
{
    char header[40];

    if (httpd_req_get_hdr_value_len(
            req, "Authorization") != 39)
    {
        return false;
    }

    if (httpd_req_get_hdr_value_str(
            req,
            "Authorization",
            header,
            sizeof(header)) != ESP_OK)
    {
        return false;
    }

    if (strncmp(header, "Bearer ", 7) != 0)
    {
        return false;
    }

    memcpy(token, header + 7, SESSION_TOKEN_SIZE);

    return true;
}

// GET /api/session
static esp_err_t get_session(httpd_req_t *req)
{
    switch (session_get_state())
    {
        case SESSION_LOCAL:
            return send_json(
                req, "200 OK",
                "{\"state\":\"local\"}"
            );

        case SESSION_BUSY:
            return send_json(
                req, "200 OK",
                "{\"state\":\"busy\"}"
            );

        default:
            return send_json(
                req, "200 OK",
                "{\"state\":\"available\"}"
            );
    }
}

// POST /api/session/acquire
static esp_err_t acquire_session(httpd_req_t *req)
{
    char token[SESSION_TOKEN_SIZE];

    session_state_t state = session_acquire(token);

    if (state != SESSION_AUTHORIZED)
    {
        return deny_access(req, state);
    }

    char response[100];

    snprintf(
        response,
        sizeof(response),
        "{\"state\":\"authorized\",\"token\":\"%s\"}",
        token
    );

    return send_json(req, "200 OK", response);
}

// POST /api/session/release
static esp_err_t release_session(httpd_req_t *req)
{
    char token[SESSION_TOKEN_SIZE];

    if (!read_token(req, token))
    {
        return deny_access(req, SESSION_AVAILABLE);
    }

    session_state_t state =
        session_verify(token, true);

    if (state != SESSION_AUTHORIZED)
    {
        return deny_access(req, state);
    }

    return send_json(
        req,
        "200 OK",
        "{\"released\":true}"
    );
}

// GET /api/status
// MOCK MEASUREMENTS ONLY
static esp_err_t get_status(httpd_req_t *req)
{
    char token[SESSION_TOKEN_SIZE];

    if (!read_token(req, token))
    {
        return deny_access(req, SESSION_AVAILABLE);
    }

    session_state_t state =
        session_verify(token, false);

    if (state != SESSION_AUTHORIZED)
    {
        return deny_access(req, state);
    }

    // Fixed simulated data.
    // No UART communication or motor commands.
    return send_json(
        req,
        "200 OK",
        "{"
        "\"session_authorized\":true,"
        "\"simulated\":true,"
        "\"running\":false,"
        "\"commanded_rpm\":0,"
        "\"actual_rpm\":0,"
        "\"motor_current\":0.0,"
        "\"dc_link_voltage\":0.0,"
        "\"estimated_torque\":0.0,"
        "\"direction\":\"forward\","
        "\"mode\":\"speed\","
        "\"fault_active\":false,"
        "\"fault_code\":0,"
        "\"fault_description\":\"Simulated data\""
        "}"
    );
}

// Register HTTP endpoints
esp_err_t session_http_start(void)
{
    if (server != NULL)
    {
        return ESP_OK;
    }

    httpd_config_t config = HTTPD_DEFAULT_CONFIG();

    esp_err_t result = httpd_start(&server, &config);

    if (result != ESP_OK)
    {
        server = NULL;
        return result;
    }

    const httpd_uri_t routes[] = {
        {
            .uri = "/api/session",
            .method = HTTP_GET,
            .handler = get_session
        },
        {
            .uri = "/api/session/acquire",
            .method = HTTP_POST,
            .handler = acquire_session
        },
        {
            .uri = "/api/session/release",
            .method = HTTP_POST,
            .handler = release_session
        },
        {
            .uri = "/api/status",
            .method = HTTP_GET,
            .handler = get_status
        }
    };

    for (int i = 0; i < 4; i++)
    {
        result = httpd_register_uri_handler(
            server,
            &routes[i]
        );

        if (result != ESP_OK)
        {
            httpd_stop(server);
            server = NULL;
            return result;
        }
    }

    return ESP_OK;
}