*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
...  Description: This robot file is uploaded to remote UEPC in order to steer the positioner.
...  Make sure that remote positioner PC has its firewall disabled and that the GUI's mode is not switched to `local`.

Library     Orbis.py

*** Test Cases ***
Moving Positioner
    log to console    \nPositioner at ${positioner_address}:${positioner_api_port}
    log to console    Setting azimuth to ${azimuth_angle} degrees at speed ${azimuth_speed} deg/s
    log to console    Setting tilting to ${tilting_angle} degress at speed ${tilting_speed} deg/s
    log to console    Starting movement
    set_properties    ${positioner_address}:${positioner_api_port}
    ...    azimuth=${azimuth_speed}    elevation=${tilting_speed}
    log to console    Waiting for movement to finish
    set_dut_position    ${positioner_address}:${positioner_api_port}
    ...    azimuth=${azimuth_angle}    elevation=${tilting_angle}
    wait_for_dut_movement_to_stop   ${positioner_address}:${positioner_api_port}    timeout=300
    log to console    Movement finished
