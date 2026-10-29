*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Resource  ../StatusGetters/GetComponentStates.robot

Resource  ../resources/CommonCheckers/ResetCommon.robot
Resource  ../OnAirCheckers/CheckOnAir.robot


*** Keywords ***
Check SMOD while BBMOD reset
    [Arguments]  ${component_index}
    Check SMOD while OnAir                  ${component_index}

Check BBMOD while BBMOD reset
    [Arguments]  ${component_index}
    ${states}   Get BBMOD Statuses          ${component_index}
    Check availability & operational & administrative & procedural while Reset  ${states}

Check GNSS while BBMOD reset
    Check GNSS while OnAir

Check RU while BBMOD reset
    [Arguments]  ${component_index}
    ${states}   Get RU Statuses             ${component_index}
    Check availability & operational & administrative & procedural while Reset  ${states}

Check Cell while BBMOD reset
    [Arguments]  ${component_index}
    ${states}   Get Cell Statuses           ${component_index}
    Check Cell while superior unit Resets   ${states}
