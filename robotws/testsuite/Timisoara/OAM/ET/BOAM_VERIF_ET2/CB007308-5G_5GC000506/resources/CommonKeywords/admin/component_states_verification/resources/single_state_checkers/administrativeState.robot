*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Resource  ../core_checker.robot

*** Keywords ***
Check administrativeState locked
    [Arguments]  ${states}
    Check Status Value    ${states}    administrativeState    Locked

Check administrativeState unlocked
    [Arguments]  ${states}
    Check Status Value    ${states}    administrativeState    Unlocked
