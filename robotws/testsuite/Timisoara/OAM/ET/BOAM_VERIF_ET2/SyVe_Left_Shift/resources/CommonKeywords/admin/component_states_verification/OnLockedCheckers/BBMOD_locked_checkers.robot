*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Resource  ../StatusGetters/GetComponentStates.robot

Resource  ../OnAirCheckers/CheckOnAir.robot
Resource  ../resources/CommonCheckers/LockedCommon.robot


*** Keywords ***
Check BBMOD while BBMOD locked
    [Arguments]  ${component_index}
    ${states}   Get BBMOD Statuses      ${component_index}
    Check availability & operational & administrative & procedural while Locked     ${states}

Check RU while BBMOD locked
    [Arguments]  ${component_index}
    ${states}   Get RU Statuses         ${component_index}
    Check RU while OnAir                        ${states}

Check Cell while BBMOD locked
    [Arguments]  ${component_index}
    ${states}   Get Cell Statuses       ${component_index}
    Check Cell while superior unit is Locked    ${states}

Check SMOD while BBMOD locked
    [Arguments]  ${component_index}
    Check SMOD while OnAir              ${component_index}

Check GNSS while BBMOD locked
    Check GNSS while OnAir
