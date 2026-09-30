#include "ui_task.h"

#include <stdbool.h>
#include <stdio.h>

#include "control_source.h"
#include "encoder.h"
#include "buttons.h"
#include "vfd_ui.h"

#include "ui_home.h"
#include "ui_control.h"
#include "ui_measurements.h"
#include "ui_faults.h"
#include "ui_settings.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"


#define HOME_ITEMS      4
#define CONTROL_ITEMS   3
#define SETTINGS_ITEMS  2

#define RPM_MIN         0
#define RPM_MAX         3600
#define RPM_STEP        50


// UI state
static vfd_screen_t current_screen = VFD_SCREEN_HOME;

static int home_selection = 0;
static int control_selection = 0;
static int settings_selection = 0;

static int commanded_rpm = 0;
static bool forward = true;
static bool running = false;
static bool editing_speed = false;


// Wrap menu selection
static int wrap_selection(int value, int total)
{
    if (value >= total)
        return 0;

    if (value < 0)
        return total - 1;

    return value;
}


// Draw Control screen
static void draw_control(void)
{
    ui_control_draw(
        control_selection,
        commanded_rpm,
        forward,
        running,
        editing_speed
    );
}


// Return to Home screen
static void return_home(void)
{
    current_screen = VFD_SCREEN_HOME;
    editing_speed = false;

    ui_home_draw(home_selection);
}


// Open selected Home menu
static void open_home_item(void)
{
    switch (home_selection)
    {
        case 0:
            current_screen = VFD_SCREEN_CONTROL;
            control_selection = 0;
            editing_speed = false;
            draw_control();
            break;

        case 1:
            current_screen = VFD_SCREEN_MEASUREMENTS;
            ui_measurements_draw();
            break;

        case 2:
            current_screen = VFD_SCREEN_FAULTS;
            ui_faults_draw();
            break;

        case 3:
            current_screen = VFD_SCREEN_SETTINGS;
            settings_selection = 0;
            ui_settings_draw(settings_selection);
            break;
    }
}


// Rotate Home menu
static void rotate_home(int direction)
{
    int old_item = home_selection;

    home_selection =
        wrap_selection(
            home_selection + direction,
            HOME_ITEMS
        );

    ui_home_update_selection(
        old_item,
        home_selection
    );
}


// Rotate Control menu
static void rotate_control(int direction)
{
    // Change RPM only in LOCAL mode
    if (editing_speed &&
        control_selection == 0 &&
        control_source_local_allowed())
    {
        commanded_rpm += direction * RPM_STEP;

        if (commanded_rpm > RPM_MAX)
            commanded_rpm = RPM_MAX;

        if (commanded_rpm < RPM_MIN)
            commanded_rpm = RPM_MIN;

        ui_control_update_item(
            0,
            true,
            commanded_rpm,
            forward,
            running,
            editing_speed
        );

        return;
    }


    editing_speed = false;

    int old_item = control_selection;

    control_selection =
        wrap_selection(
            control_selection + direction,
            CONTROL_ITEMS
        );

    ui_control_update_selection(
        old_item,
        control_selection,
        commanded_rpm,
        forward,
        running,
        editing_speed
    );
}


// Press encoder on Control screen
static void press_control(void)
{
    switch (control_selection)
    {
        // Speed
        case 0:
            if (!control_source_local_allowed())
            {
                printf("Speed disabled in REMOTE mode\n");
                return;
            }

            editing_speed = !editing_speed;

            ui_control_update_item(
                0,
                true,
                commanded_rpm,
                forward,
                running,
                editing_speed
            );
            break;


        // Direction
        case 1:
            if (!control_source_local_allowed())
            {
                printf("Direction disabled in REMOTE mode\n");
                return;
            }

            forward = !forward;

            ui_control_update_item(
                1,
                true,
                commanded_rpm,
                forward,
                running,
                editing_speed
            );
            break;


        // Back
        case 2:
            return_home();
            break;
    }
}


// Rotate Settings menu
static void rotate_settings(int direction)
{
    int old_item = settings_selection;

    settings_selection =
        wrap_selection(
            settings_selection + direction,
            SETTINGS_ITEMS
        );

    ui_settings_update_selection(
        old_item,
        settings_selection
    );
}


// Press encoder on Settings screen
static void press_settings(void)
{
    // Control Source
    if (settings_selection == 0)
    {
        if (control_source_local_allowed())
        {
            control_source_set(
                CONTROL_SOURCE_REMOTE
            );

            editing_speed = false;

            printf("Control source: REMOTE\n");
        }
        else
        {
            control_source_set(
                CONTROL_SOURCE_LOCAL
            );

            printf("Control source: LOCAL\n");
        }

        ui_settings_update_source(true);
    }

    // Back
    else
    {
        return_home();
    }
}


// Check physical START / STOP buttons
static void check_motor_buttons(void)
{
    bool start_pressed = start_button_pressed();
    bool stop_pressed = stop_button_pressed();


    // STOP always works and has priority
    if (stop_pressed)
    {
        printf("STOP button pressed\n");

        // Temporary until dsPIC UART is implemented
        running = false;
    }

    // START only works in LOCAL mode
    else if (start_pressed)
    {
        if (!control_source_local_allowed())
        {
            printf("START disabled in REMOTE mode\n");
            return;
        }

        printf("START button pressed\n");

        // Temporary until dsPIC UART is implemented
        running = true;
    }

    else
    {
        return;
    }


    // Refresh status if Control screen is open
    if (current_screen == VFD_SCREEN_CONTROL)
        draw_control();
}


// Handle encoder rotation
static void handle_rotation(int direction)
{
    switch (current_screen)
    {
        case VFD_SCREEN_HOME:
            rotate_home(direction);
            break;

        case VFD_SCREEN_CONTROL:
            rotate_control(direction);
            break;

        case VFD_SCREEN_SETTINGS:
            rotate_settings(direction);
            break;

        default:
            break;
    }
}


// Handle encoder press
static void handle_encoder_press(void)
{
    switch (current_screen)
    {
        case VFD_SCREEN_HOME:
            open_home_item();
            break;

        case VFD_SCREEN_CONTROL:
            press_control();
            break;

        case VFD_SCREEN_SETTINGS:
            press_settings();
            break;

        default:
            return_home();
            break;
    }
}


// Main UI task
static void ui_task(void *arg)
{
    int last_encoder_value = encoder_get_value();

    ui_home_draw(home_selection);


    while (1)
    {
        int encoder_value = encoder_get_value();


        // Encoder rotation
        if (encoder_value != last_encoder_value)
        {
            int direction =
                (encoder_value > last_encoder_value)
                ? 1
                : -1;

            handle_rotation(direction);

            last_encoder_value = encoder_value;
        }


        // Encoder push button
        if (encoder_button_pressed())
        {
            handle_encoder_press();
        }


        // Physical START / STOP
        check_motor_buttons();


        vTaskDelay(
            pdMS_TO_TICKS(10)
        );
    }
}


// Start UI task
void ui_task_start(void)
{
    xTaskCreate(
        ui_task,
        "ui_task",
        4096,
        NULL,
        5,
        NULL
    );
}