*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Resource  ../StatusGetters/GetComponentStates.robot

Resource  ../resources/CommonCheckers/ResetCommon.robot
Resource  ../OnAirCheckers/CheckOnAir.robot


*** Keywords ***
Check SMOD while GNSS reset
    [Arguments]  ${component_id}
    Check SMOD while OnAir              ${component_id}

Check BBMOD while GNSS reset
    [Arguments]  ${component_id}
    Check BBMOD while OnAir             ${component_id}

Check GNSS while GNSS reset
    ${states}   Get GNSS Statuses
    Check availability & operational & administrative while Reset   ${states}

Check RU while GNSS reset
    [Arguments]  ${component_id}
    Check RU while OnAir                ${component_id}

Check Cell while GNSS reset
    [Arguments]  ${component_id}
    Check Cell while OnAir              ${component_id}
