*** Settings ***
Documentation
...    Author: Adelina Gordan
...    Maintainer: Adelina Gordan (adelina.gordan@nokia.com)
...    Group in charge: VERIF_TIM_3_ET_GMS
...    References: DOORS
...    Feature Description: CB007406-J
...    Sample execution: robot -v cranName:cran2 -L TRACE -b debug.log -d results/CB007406-J general.robot

Resource   ./resources/CB007406-J.robot
Resource   ./resources/xpath_7406-J.robot

Suite Setup  Run Keyword  Login vCU
Suite Teardown  Run Keyword And Ignore Error  Logout vCU

*** Test Cases ***
[1]6. Check if counters under measurement 51325 TCP UDP Statistics update correctly
    [Tags]     CRT
    Select counters to display TCP UDP
    Check selected counters
    Clear selection

[1]7. Check if counters under measurement 51326 SCTP Statistics update correctly
    [Tags]     CRT
    Select counters to display SCTP
    Check selected counters
