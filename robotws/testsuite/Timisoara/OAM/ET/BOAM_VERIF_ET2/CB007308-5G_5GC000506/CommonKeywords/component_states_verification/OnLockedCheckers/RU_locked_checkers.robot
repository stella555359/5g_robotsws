*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Resource  ../StatusGetters/GetComponentStates.robot

Resource  ../OnAirCheckers/CheckOnAir.robot
Resource  ../resources/CommonCheckers/LockedCommon.robot


*** Keywords ***
Check RU while RU locked
    [Arguments]  ${component_id}
    ${states}   Get RU Statuses         ${component_id}
    Check availability & operational & administrative & procedural while Locked     ${states}

Check Cell while RU locked
    [Arguments]  ${component_id}
    ${states}   Get Cell Statuses       ${component_id}
    Check Cell while superior unit is Locked    ${states}

Check SMOD while RU locked
    [Arguments]  ${component_id}
    Check SMOD while OnAir              ${component_id}

Check BBMOD while RU locked
    [Arguments]  ${component_id}
    Check BBMOD while OnAir             ${component_id}

Check GNSS while RU locked
    Check GNSS while OnAir
