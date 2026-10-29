*** Settings ***
Documentation
...   feature keywords

Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords_1167.py    WITH NAME   python_1167

*** Variables ***
${IDLE_TIMER}    60

*** Keywords ***
Set Default Values On Attenuator
    Log To Console     ${ATTENUATOR}
    Set Attenuation    ${ATTENUATOR['NRCELL_10']['attenuation']}   ${ATTENUATOR['NRCELL_10']['ports']}
    Set Attenuation    ${ATTENUATOR['NRCELL_11']['attenuation']}   ${ATTENUATOR['NRCELL_11']['ports']}
    Set Attenuation    ${ATTENUATOR['NRCELL_20']['attenuation']}  ${ATTENUATOR['NRCELL_20']['ports']}
    Set Attenuation    ${ATTENUATOR['NRCELL_22']['attenuation']}  ${ATTENUATOR['NRCELL_22']['ports']}
    Set Attenuation    ${ATTENUATOR['NRCELL_30']['attenuation']}  ${ATTENUATOR['NRCELL_30']['ports']}
    Set Attenuation    ${ATTENUATOR['NRCELL_40']['attenuation']}  ${ATTENUATOR['NRCELL_40']['ports']}

Set Default Values On Attenuator for TDD
    Log To Console     ${ATTENUATOR}
    Set Attenuation    ${ATTENUATOR['NRCELL_10']['attenuation']}   ${ATTENUATOR['NRCELL_10']['ports']}
    Set Attenuation    ${ATTENUATOR['NRCELL_20']['attenuation']}  ${ATTENUATOR['NRCELL_20']['ports']}
    Set Attenuation    ${ATTENUATOR['NRCELL_22']['attenuation']}   ${ATTENUATOR['NRCELL_22']['ports']}
    Set Attenuation        10      ${ATTENUATOR['NRCELL_30']['ports']}
    Set Attenuation        20      ${ATTENUATOR['NRCELL_40']['ports']}

Set Default Values On Attenuator for Test 35MHz
    Log To Console     ${ATTENUATOR}
    Set Attenuation    ${ATTENUATOR['NRCELL_8']['attenuation']}  ${ATTENUATOR['NRCELL_8']['ports']}
    Set Attenuation    127   ${ATTENUATOR['NRCELL_10']['ports']}
    Set Attenuation        20      ${ATTENUATOR['NRCELL_30']['ports']}
    Set Attenuation        15      ${ATTENUATOR['NRCELL_40']['ports']}

Set Att For Cell With Id
    [Arguments]    ${cell_id}    ${attenuation}=90dB
    Set Attenuation    ${attenuation}    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}

Trigger Scell Addition Based On A1
    [Arguments]    ${cell_id}    ${attenuation}=0dB
    Set Att For Cell With Id    ${cell_id}    ${attenuation}
    BuiltIn.Sleep    2    Wait for scell addition

Trigger Scell Release
    [Arguments]    ${cell_id}    ${attenuation}=90dB
    Set Att For Cell With Id    ${cell_id}    ${attenuation}
    BuiltIn.Sleep    2    Wait for scell release

Perform Scell Swap
    [Arguments]    ${src_cell_id}    ${dst_cell_id}    ${att_value}=10dB
    Set Att For Cell With Id   ${src_cell_id}   ${att_value}
    Set Att For Cell With Id   ${dst_cell_id}    ${ATTENUATOR['NRCELL_${dst_cell_id}']['attenuation']}
    BuiltIn.Sleep    2    Wait for scell swap

Clear Attenuation On Cell
    [Arguments]    ${cell_id}
    Set Att For Cell With Id   ${cell_id}    0dB
