*** Settings ***
Documentation
...    Author: valentyna.mykhaylets@nokia.com
...    Maintainer: valentyna.mykhaylets@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Resource  ../StatusGetters/GetComponentStates.robot

Resource  ../resources/single_state_checkers/administrativeState.robot
Resource  ../resources/single_state_checkers/operationalState.robot

Resource  ../OnAirCheckers/CheckOnAir.robot
Resource  ../resources/CommonCheckers/LockedCommon.robot


*** Keywords ***
Check Administrative & Operational States On Locked COAM BTS
    ${states}    Get cOAM BTS Statuses
    Check administrativeState locked            ${states}
    Check operationalState enabled              ${states}

Check Administrative & Operational States On Unlocked COAM BTS
    ${states}    Get cOAM BTS Statuses
    Check administrativeState unlocked          ${states}
    Check operationalState enabled              ${states}

Check SMOD while COAM BTS locked
    [Arguments]  ${component_index}
    Check SMOD while OnAir              ${component_index}

Check BBMOD while COAM BTS locked
    [Arguments]  ${component_index}
    Check BBMOD while OnAir             ${component_index}

Check GNSS while COAM BTS locked
    Check GNSS while OnAir

Check RU while COAM BTS locked
    [Arguments]  ${component_index}
    Check RU while OnAir                ${component_index}

Check Cell while COAM BTS locked
    [Arguments]  ${component_index}
    ${states}   Get Cell Statuses       ${component_index}
    Check Cell while superior unit is Locked    ${states}
