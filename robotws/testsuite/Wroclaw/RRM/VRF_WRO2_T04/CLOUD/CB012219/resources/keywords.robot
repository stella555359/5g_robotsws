*** Settings ***
Documentation
...   feature keywords

Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py

*** Variables ***
${IDLE_TIMER}    60

*** Keywords ***
Set Default Values On Attenuator for TDD Scell Swap
    Log To Console     ${ATTENUATOR}
    Set Attenuation    ${ATTENUATOR['NRCELL_10']['attenuation']}   ${ATTENUATOR['NRCELL_10']['ports']}
    Set Attenuation    ${ATTENUATOR['NRCELL_20']['attenuation']}  ${ATTENUATOR['NRCELL_20']['ports']}
    Set Attenuation    90   ${ATTENUATOR['NRCELL_22']['ports']}
    Set Attenuation        10      ${ATTENUATOR['NRCELL_30']['ports']}
    Set Attenuation        20      ${ATTENUATOR['NRCELL_40']['ports']}
