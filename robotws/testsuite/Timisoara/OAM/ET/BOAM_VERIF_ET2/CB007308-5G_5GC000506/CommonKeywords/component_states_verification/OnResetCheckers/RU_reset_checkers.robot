*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Resource  ../StatusGetters/GetComponentStates.robot

Resource  ../resources/CommonCheckers/ResetCommon.robot
Resource  ../OnAirCheckers/CheckOnAir.robot

Resource  ../resources/single_state_checkers/administrativeState.robot
Resource  ../resources/single_state_checkers/availabilityStatus.robot
Resource  ../resources/single_state_checkers/operationalState.robot
Resource  ../resources/single_state_checkers/proceduralStatus.robot

*** Keywords ***
Check SMOD while RU reset
    [Arguments]  ${component_id}
    Check SMOD while OnAir              ${component_id}

Check BBMOD while RU reset
    [Arguments]  ${component_id}
    Check BBMOD while OnAir             ${component_id}

Check GNSS while RU reset
    Check GNSS while OnAir

Check RU while RU reset
    [Arguments]  ${component_id}
    ${states}   Get RU Statuses         ${component_id}
    Check availabilityStatus notinstalled       ${states}
    Check operationalState disabled             ${states}
    Check administrativeState unlocked          ${states}
    Check proceduralStatus not initialized      ${states}

Check Cell while RU reset
    [Arguments]  ${component_id}
    ${states}   Get Cell Statuses       ${component_id}
    Check Cell while superior unit Resets       ${states}
