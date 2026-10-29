*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Library    Collections

*** Keywords ***
Check Status Value
    [Arguments]    ${statuses_container}    ${status}    ${value}
    ${actual_value}=    get from dictionary    ${statuses_container}    ${status}
    run keyword and continue on failure    should be equal    ${actual_value}    ${value}
