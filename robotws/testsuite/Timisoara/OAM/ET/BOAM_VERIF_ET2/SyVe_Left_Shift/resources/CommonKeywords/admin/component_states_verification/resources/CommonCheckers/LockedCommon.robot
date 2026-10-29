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
Check availability & operational & administrative & procedural while Locked
    [Arguments]  ${states}
    Check availabilityStatus online         ${states}
    Check operationalState enabled          ${states}
    Check administrativeState locked        ${states}
    Check proceduralStatus configured       ${states}

Check Cell while superior unit is Locked
    [Documentation]  Check status of Cell when ABIL or Radio or whole BTS is locked. Cell is dependent on those units.
    [Arguments]  ${states}
    Check availabilityStatus dependency     ${states}
    Check operationalState disabled         ${states}
    Check administrativeState unlocked      ${states}
    Check proceduralStatus configured       ${states}
