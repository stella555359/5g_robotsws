*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Library  ../../../CommonKeywords/utils.py

Resource  ../StatusGetters/GetComponentStates.robot
Resource  ../resources/CommonCheckers/OnAirCommon.robot

Resource  ../resources/single_state_checkers/administrativeState.robot
Resource  ../resources/single_state_checkers/availabilityStatus.robot
Resource  ../resources/single_state_checkers/operationalState.robot
Resource  ../resources/single_state_checkers/proceduralStatus.robot

*** Keywords ***
Check SMOD while OnAir
    [Arguments]  ${component_id}
    ${states}   Get SMOD Statuses       ${component_id}
    Check availability & operational & administrative & procedural while OnAir      ${states}

Check BBMOD while OnAir
    [Arguments]  ${component_id}
    ${states}   Get BBMOD Statuses      ${component_id}
    Check availability & operational & administrative & procedural while OnAir      ${states}

Check GNSS while OnAir
    ${states}   Get GNSS Statuses
    Check availabilityStatus is either online or degraded         ${states}
    Check operationalState enabled          ${states}
    Check administrativeState unlocked      ${states}

Check RU while OnAir
    [Arguments]  ${component_id}
    ${states}   Get RU Statuses         ${component_id}
    Check availability & operational & administrative & procedural while OnAir      ${states}

Check Cell while OnAir
    [Arguments]  ${component_id}
    ${states}   Get Cell Statuses       ${component_id}
    Run Keyword If  '${trunk_flag}' == '${9999}'  Run Keywords
    ...     Check operationalState enabled SBTS00         ${states}
    ...     AND  Check administrativeState unlocked     ${states}
    ...     AND  Check proceduralStatus configured     ${states}
    ...         ELSE    Run Keywords
    ...     Check availabilityStatus is either online or degraded     ${states}
    ...     AND  Check operationalState enabled Branch        ${states}
    ...     AND  Check administrativeState unlocked    ${states}
    ...     AND  Check proceduralStatus configured      ${states}

Check availabilityStatus is either online or degraded
    [Arguments]  ${states}
    ${success}  run keyword and return status       Check availabilityStatus online         ${states}
    run keyword if  ${success}==False   Check availabilityStatus degraded       ${states}

