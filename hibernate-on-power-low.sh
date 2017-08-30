#!/bin/bash
#
#   Author: Rohit Sharma
#
#   Script to check battery status and hibernate machine if battery is 
#   critically low.
#
#   Put it in cron and run it every 2 to 5 minutes depending on how quickly
#   the battery drains and also the type of tasks which are regularly performed
#   on the machine.
#
#   NOTE: This script uses systemd for hibernation.
#

DISPLAY_NUMBER=:0
WAIT_SECS_BEFORE_HIBERNATION=30
CRITICAL_BATTERY_PERCENTAGE=8


hibernate_machine()
{    
    # Showing hibernation warning to the default display
    warning_msg="The machine is going to hibernate after ${WAIT_SECS_BEFORE_HIBERNATION} seconds."
    zenity --display "${DISPLAY_NUMBER}" --title "Battery Low" \
           --text "${warning_msg}" --timeout 5 --warning 2> /dev/null

    echo "Waiting for hibernation to start..."
    sleep ${WAIT_SECS_BEFORE_HIBERNATION}

    # Don't hibernate if charger got connected
    if machine_is_discharging;
    then
        echo "Hibernating Machine..."
        systemctl hibernate
    fi
}


machine_is_discharging()
{ 
    echo "Checking discharging status..."

    # Checking current battery level
    current_battery_level_if_discharging=$(acpi -b  \
                                          | grep -i discharging \
                                          | cut -d " " -f4 \
                                          | egrep -o [[:digit:]]+)

    [ -n "${current_battery_level_if_discharging}" ] 
}


battery_is_low()
{
    echo "Checking if battery is low..."
    [ "${current_battery_level_if_discharging}" -le "${CRITICAL_BATTERY_PERCENTAGE}" ]
}


main()
{
    if machine_is_discharging && battery_is_low;
    then 
        hibernate_machine
    fi
}


main
