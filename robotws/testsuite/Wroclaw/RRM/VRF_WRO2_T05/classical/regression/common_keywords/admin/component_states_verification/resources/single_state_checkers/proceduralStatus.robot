*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Resource  ../core_checker.robot

*** Keywords ***
Check proceduralStatus configured
    [Arguments]  ${states}
    Check Status Value    ${states}    proceduralStatus     configured

Check proceduralStatus not initialized
    [Arguments]  ${states}
    Check Status Value    ${states}    proceduralStatus     not initialized

Check proceduralStatus initialization required
    [Arguments]  ${states}
    Check Status Value    ${states}    proceduralStatus     initialization required
