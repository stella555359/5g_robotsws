*** Settings ***
Documentation
...    Author: przemyslaw.smolen@nokia.com
...    Maintainer: przemyslaw.smolen@nokia.com

...            [Example of execution]    pybot --variable CONFIGURATION:Wroclaw.IAV_WRO_TL1071 testsuite/WMP/OAM/LBT3366/startup.robot

Library    taf.hw.optical_switch

*** Variables ***
${SWITCH_HOST}
${SWITCH_MODEL}
${SWITCH_ALIAS}


*** Keywords ***

LEONI Setup Alias
    [Arguments]  ${SWITCH_HOST}
    ...     ${SWITCH_MODEL}
    ...     ${SWITCH_ALIAS}
    taf.hw.optical_switch.setup optical switch  addr=${SWITCH_HOST}  model=${SWITCH_MODEL}  alias=${SWITCH_ALIAS}   optical_switch=Leoni

LEONI Teardown Alias
    [Arguments]  ${SWITCH_ALIAS}
    taf.hw.optical_switch.teardown  optical_switch_device=${SWITCH_ALIAS}

LEONI Get Optical Switch Channels
    [Arguments]  ${SWITCH_ALIAS}
    ${settings}=  taf.hw.optical_switch.get optical switch channels       optical_switch_device=${SWITCH_ALIAS}
    [Return]    ${settings}

LEONI Set Optical Switch Channels
    [Arguments]  ${SWITCH_ALIAS}
    ...     ${SETTINGS_TO_BE_APPLIED}
    taf.hw.optical_switch.set optical switch channels  settings=${SETTINGS_TO_BE_APPLIED}  optical_switch_device=${SWITCH_ALIAS}