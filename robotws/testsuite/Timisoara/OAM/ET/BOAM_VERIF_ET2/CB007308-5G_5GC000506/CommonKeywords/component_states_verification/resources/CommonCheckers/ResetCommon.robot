*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Resource  ../single_state_checkers/administrativeState.robot
Resource  ../single_state_checkers/availabilityStatus.robot
Resource  ../single_state_checkers/operationalState.robot
Resource  ../single_state_checkers/proceduralStatus.robot

*** Keywords ***
Check availability & operational & administrative & procedural while Reset
    [Arguments]  ${states}
    Check availabilityStatus offline            ${states}
    Check operationalState disabled             ${states}
    Check administrativeState unlocked          ${states}
    Check proceduralStatus not initialized      ${states}

Check availability & operational & administrative while Reset
    [Arguments]  ${states}
    Check availabilityStatus offline        ${states}
    Check operationalState disabled         ${states}
    Check administrativeState unlocked      ${states}

Check Cell while superior unit Resets
    [Documentation]  Check status of Cell when ABIL or Radio resets. Cell is dependent on those units.
    [Arguments]  ${states}
    Check availabilityStatus failed             ${states}
    Check operationalState disabled             ${states}
    Check administrativeState unlocked          ${states}
    Check proceduralStatus not initialized      ${states}
