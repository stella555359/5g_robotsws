*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Resource  ../StatusGetters/GetComponentStates.robot

Resource  ../resources/single_state_checkers/administrativeState.robot
Resource  ../resources/single_state_checkers/availabilityStatus.robot
Resource  ../resources/single_state_checkers/operationalState.robot
Resource  ../resources/single_state_checkers/proceduralStatus.robot

Resource  ../OnAirCheckers/CheckOnAir.robot


*** Keywords ***
Check SMOD while Cell locked
    [Arguments]  ${component_index}
    Check SMOD while OnAir              ${component_index}

Check BBMOD while Cell locked
    [Arguments]  ${component_index}
    Check BBMOD while OnAir             ${component_index}

Check GNSS while Cell locked
    Check GNSS while OnAir

Check RU while Cell locked
    [Arguments]  ${component_index}
    Check RU while OnAir                ${component_index}

Check Cell while Cell locked
    [Arguments]  ${component_index}
    ${states}   Get Cell Statuses       ${component_index}
    Check availabilityStatus offline                        ${states}
    Check operationalState disabled                         ${states}
    Check administrativeState locked                        ${states}
    Check proceduralStatus initialization required          ${states}
