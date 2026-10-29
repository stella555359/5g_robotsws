*** Settings ***
Documentation
...   Test suite for regression testing of feature  CNI-130230
...   author: Julia Luszcz
...   author/contact: julia.luszcz@nokia.com


Resource    ../resources/robot/common.robot
Resource    ./resources/resources.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/variables_config1.py


Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms


*** Test Cases ***
[1]CNI_130230_01_Lane_blocking_using_FR_5GC000955_in_a_loop
    [Setup]     Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    No connection to unit
    ...         AND
    ...         Common Preconditions With Watching Alarms
    Lane_blocking_using_FR_5GC000955_in_a_loop      ${lanes}


[1]CNI_130230_03_Changing_linkspeed_in_loops
    [Setup]     Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    BTS configuration error (not enough HW for LCR)
    ...         AND
    ...         Common Preconditions With Watching Alarms
    Modify Linkspeed in Loop        ${linkspeed_parameters}      ${max_linkspeed}


[1]CNI_130230_02_Configuration_with_a_redundant_link_and_switching_between_them_in_a_loop
    [Setup]     Run Keywords   Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    No connection to unit
    ...         AND
    ...         Common Preconditions With Watching Alarms
    Configure Redundant Link and Switch between Two links in Loop    ${cablink_parameters}
