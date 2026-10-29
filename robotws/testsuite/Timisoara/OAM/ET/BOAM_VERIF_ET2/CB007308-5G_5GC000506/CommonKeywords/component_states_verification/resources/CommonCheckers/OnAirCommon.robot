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
Check availability & operational & administrative & procedural while OnAir
    [Arguments]  ${states}
    Check availabilityStatus online         ${states}
    Check operationalState enabled          ${states}
    Check administrativeState unlocked      ${states}
    Check proceduralStatus configured       ${states}

Check availability & operational & administrative while OnAir
    [Documentation]  For GNSS use currently
    [Arguments]  ${states}  ${checkAdministrativeState}=${TRUE}
    Check availabilityStatus online         ${states}
    Check operationalState enabled          ${states}
    Run Keyword If  ${checkAdministrativeState}==${TRUE}
    ...   Check administrativeState unlocked      ${states}
