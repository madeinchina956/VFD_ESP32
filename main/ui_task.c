#include "ui_task.h"

#include <stdbool.h>
#include <stdio.h>

#include "encoder.h"
#include "vfd_ui.h"

#include "ui_home.h"
#include "ui_control.h"
#include "ui_measurements.h"
#include "ui_faults.h"
#include "ui_settings.h"

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"


#define HOME_ITEMS     4
#define CONTROL_ITEMS  4

#define RPM_MIN        0
#define RPM_MAX        3600
#define RPM_STEP       50


// Current UI screen
static vfd_screen_t current_screen =
    VFD_SCREEN_HOME;


// Current selections
static int home_selection = 0;
static int control_selection = 0;


// Control values
static int commanded_rpm = 0;
static bool forward = true;
static bool running = false;
static bool editing_speed = false;


// Wrap menu selection around
static int wrap_selection(
    int value,
    int total
)
{
    if (value >= total)
        return 0;

    if (value < 0)
        return total - 1;

    return value;
}


// Return to main menu
static void return_home(void)
{
    current_screen =
        VFD_SCREEN_HOME;

    editing_speed = false;

    ui_home_draw(
        home_selection
    );
}


// Open selected home screen
static void open_home_item(void)
{
    switch (home_selection)
    {
        case 0:
            current_screen =
                VFD_SCREEN_CONTROL;

            control_selection = 0;
            editing_speed = false;

            ui_control_draw(
                control_selection,
                commanded_rpm,
                forward,
                running,
                editing_speed
            );
            break;


        case 1:
            current_screen =
                VFD_SCREEN_MEASUREMENTS;

            ui_measurements_draw();
            break;


        case 2:
            current_screen =
                VFD_SCREEN_FAULTS;

            ui_faults_draw();
            break;


        case 3:
            current_screen =
                VFD_SCREEN_SETTINGS;

            ui_settings_draw();
            break;
    }
}


// Handle encoder rotation on home screen
static void rotate_home(
    int direction
)
{
    int old_item =
        home_selection;

    home_selection += direction;

    home_selection =
        wrap_selection(
            home_selection,
            HOME_ITEMS
        );

    ui_home_update_selection(
        old_item,
        home_selection
    );
}


// Handle encoder rotation on Control screen
static void rotate_control(
    int direction
)
{
    // Change RPM while speed is being edited
    if (editing_speed &&
        control_selection == 0)
    {
        commanded_rpm +=
            direction * RPM_STEP;

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


    // Otherwise move between Control options
    int old_item =
        control_selection;

    control_selection += direction;

    control_selection =
        wrap_selection(
            control_selection,
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


// Handle Control screen button press
static void press_control(void)
{
    // Speed
    if (control_selection == 0)
    {
        editing_speed =
            !editing_speed;

        ui_control_update_item(
            0,
            true,
            commanded_rpm,
            forward,
            running,
            editing_speed
        );
    }


    // Direction
    else if (control_selection == 1)
    {
        forward =
            !forward;

        ui_control_update_item(
            1,
            true,
            commanded_rpm,
            forward,
            running,
            editing_speed
        );
    }


    // Run / Stop
    else if (control_selection == 2)
    {
        running =
            !running;

        ui_control_update_item(
            2,
            true,
            commanded_rpm,
            forward,
            running,
            editing_speed
        );
    }


    // Back
    else if (control_selection == 3)
    {
        return_home();
    }
}


// Main UI task
static void ui_task(void *arg)
{
    int last_encoder_value =
        encoder_get_value();


    // Show home menu at startup
    ui_home_draw(
        home_selection
    );


    while (1)
    {
        int encoder_value =
            encoder_get_value();


        // Check encoder rotation
        if (encoder_value !=
            last_encoder_value)
        {
            int direction;

            if (encoder_value >
                last_encoder_value)
            {
                direction = 1;
            }
            else
            {
                direction = -1;
            }


            if (current_screen ==
                VFD_SCREEN_HOME)
            {
                rotate_home(
                    direction
                );
            }

            else if (current_screen ==
                     VFD_SCREEN_CONTROL)
            {
                rotate_control(
                    direction
                );
            }


            last_encoder_value =
                encoder_value;
        }


        // Check encoder button
        if (encoder_button_pressed())
        {
            if (current_screen ==
                VFD_SCREEN_HOME)
            {
                open_home_item();
            }

            else if (current_screen ==
                     VFD_SCREEN_CONTROL)
            {
                press_control();
            }

            else
            {
                return_home();
            }
        }


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