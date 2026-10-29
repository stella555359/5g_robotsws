*** Settings ***
Documentation
...   feature keywords

Library       ute_admin_infomodel
Library       ute_admin

Library    ute_ue
Library       ../../../resources/rrm_fixture.py
Library       ../../../resources/webui/interface.py
Library       ta5g_cell_operations

Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py
Variables    ../../5GC002640/resources/variables_2640.py

*** Variables ***
${PCELL_ID}          100
${CA_UE}=     UE_1
${NON_CA_UE}=     UE_2

*** Keywords ***
Set Initial Attenuation For A1 measurement
    Initialise Attenuator
    Log To Console    ${ATTENUATOR}
    Set Attenuation    30    ${ATTENUATOR['NRCELL_100']['ports']}  confirm=${TRUE}
#    Set Attenuation  ${ATTENUATOR['NRCELL_100']['attenuation']}  ${ATTENUATOR['NRCELL_100']['ports']}  confirm=${TRUE}
    Set Attenuation  ${ATTENUATOR['NRCELL_101']['attenuation']}  ${ATTENUATOR['NRCELL_101']['ports']}  confirm=${TRUE}
    Set Attenuation  ${ATTENUATOR['NRCELL_103']['attenuation']}  ${ATTENUATOR['NRCELL_103']['ports']}  confirm=${TRUE}
    Set Attenuation  ${ATTENUATOR['NRCELL_104']['attenuation']}  ${ATTENUATOR['NRCELL_104']['ports']}  confirm=${TRUE}
    Set Attenuation  ${ATTENUATOR['NRCELL_105']['attenuation']}  ${ATTENUATOR['NRCELL_105']['ports']}  confirm=${TRUE}
    Set Attenuation  ${ATTENUATOR['NRCELL_106']['attenuation']}  ${ATTENUATOR['NRCELL_106']['ports']}  confirm=${TRUE}

Trigger Scell Addition Based On A1
    [Arguments]    ${pcell_id}=100
    Initialise Attenuator
    Log To Console    ${ATTENUATOR}
    Set Attenuation    0    ${ATTENUATOR['NRCELL_${pcell_id}']['ports']}  confirm=${TRUE}

Trigger Scell Release
    [Arguments]     ${cell_id}
    Set Attenuation    90    ${ATTENUATOR['NRCELL_${cell_id}']['ports']}  confirm=${TRUE}

Trigger Handover
    [Arguments]  ${pcell_id}
    Gradually Increase Attenuation    port=${ATTENUATOR['NRCELL_${pcell_id}']['ports']}    step=2    interval=1
    ...    init_value=0
    ...    max_value=60
    BuiltIn.Sleep    15    Wait for HO

Clear Attenuation On Cell
    [Arguments]    ${cell_id}
    Set Attenuation  ${ATTENUATOR['NRCELL_${cell_id}']['attenuation']}  ${ATTENUATOR['NRCELL_${cell_id}']['ports']}  confirm=${TRUE}
