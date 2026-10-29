*** Settings ***
Documentation    Test suite for FR2 TDD CB012261
...              authors: Aleksandra Faliszek
...              contact: aleksandra.faliszek@nokia.com

Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     ./resources/CB012261_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup    Common Suite Setup With OnAir Test Line Preparation
Suite Teardown  Common Suite Teardown

*** Test Cases ***
CB012261_SR_A_05_B1-Enable_and_disable_FDAGC_PRACH_algorithm_FR2_TDD_Loki
    [Setup]      Common Preconditions With Watching Alarms
    Log To Console  \n===Verify attach and tput with CB012261 feature disabled===
    Disable feature CB012261    1    2    5    6
    Prepare Ue for L3 Call
    Verify NSA L3 call
    Log To Console  \n===Verify attach and tput with CB012261 feature enabled===
    Enable feature CB012261     1    2    5    6
    Verify NSA L3 call
    [Teardown]   Common Postconditions With Watching Alarms
