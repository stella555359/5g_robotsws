*** Settings ***
Documentation
...   Test suite for regression testing of feature xxxxxx
...   author: Name Surname
...   contact: name.surname@nokia.com


Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
#...               prefix_tag=4CC
#...               swconfig_from_path=testsuite/..../custom_swconf.txt
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms and Restore Configuration If Test Failed


*** Variables ***
#@{CUSTOM_ALLOWED_ALARMS}    Fault Name 1    # Variable to add additional allowed alarms, specific for TL conofguration
#...                         Fault Name 2
${some_var}    some_value


*** Test Cases ***
Sample Test Case
    [Timeout]    20h

    Log to Console    ${some_var}
