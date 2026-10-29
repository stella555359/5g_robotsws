*** Settings ***
Documentation
...   feature keywords

Library       ute_admin_infomodel
Library       ute_admin
Library       ute_ue
Library       SSHLibrary
Library       ../../../resources/rrm_fixture.py
Library       ../../../resources/webui/interface.py
Library       ../../../resources/etws_cmas/counters.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library      ../../5GC001167/resources/delta_keywords.py
Library      ../../5GC001167/resources/keywords_1167.py    WITH NAME    python_1167
Library       ta5g_cell_operations
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/common_keywords.robot

Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py

*** Variables ***
${PCELL_ID}          1
${MTK_UE}=     MTK_UE


*** Keywords ***
Attach UE To Pcell
    [Arguments]    ${ue}    ${alias}=attach
    Set Test Variable    ${log_index}    ${alias}
    ${reserved}    Is Ue Reserved    ${ue}
    Run Keyword If    not ${reserved}    Require Ue    ${ue}    capabilities=${ue}
    Start Tracing On Smod    filter master=${EMPTY}
    Attach UE    ${ue}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds  3x  5s  Log UE Info  ${ue}  IP
    BuiltIn.Sleep    30    Wait for logs
    ${pcap_file}=    Stop tracing and download logs from SMOD
    Check Cell And Signal Strength For Ue    ${ue}
    Ue Attached    ${pcap_file}
    [Return]    ${pcap_file}
    [Teardown]    Run Keywords    Stop Tracing On Smod    AND
    ...    Set Test Variable    ${log_index}    ${EMPTY}   AND
    ...    Set Test Variable    ${${ue}_reserved}    ${True}

Set Full Attenuation For All Cells
    Initialise Attenuator
    Set Attenuation  90dB  confirm=${TRUE}    attenuator_id=1
    Set Attenuation  90dB  confirm=${TRUE}    attenuator_id=2

Clear Attenuation
    Set Attenuation  0dB  confirm=${TRUE}

Trigger A4 Event
    [Arguments]  ${neigh_cell}
    Gradually Decrease Attenuation For Cell    cell_id=${neigh_cell}
    ...    init_value=${ATTENUATOR['NRCELL_${neigh_cell}']['attenuation']}    min_value=0
    BuiltIn.Sleep    15    Wait for HO

Gradually Decrease Attenuation For Cell
    [Arguments]    ${cell_id}    ${init_value}=90    ${min_value}=0
    Initialise Attenuator
    Gradually Decrease Attenuation    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}    step=10    interval=1
    ...    init_value=${init_value}
    ...    min_value=${min_value}
    ...    attenuator_id=${ATTENUATOR['NRCELL_${cell_id}']['att_id']}

Gradually Increase Attenuation For Cell
    [Arguments]    ${cell_id}    ${max_value}=90    ${init_value}=${NONE}
    Initialise Attenuator
    ${init_val} =	Set Variable If	${init_value} != ${NONE}	${init_value}
    ...   ${ATTENUATOR['NRCELL_${cell_id}']['attenuation']}
    Gradually Increase Attenuation    port=${ATTENUATOR['NRCELL_${cell_id}']['ports']}    step=6    interval=1
    ...    init_value=${init_val}
    ...    max_value=${max_value}
    ...    attenuator_id=${ATTENUATOR['NRCELL_${cell_id}']['att_id']}

Enable HO Over Xn
    [Arguments]    ${from_cell}    ${to_cell}
    ${nrrel_id}    Find Nrrel Id    ${from_cell}    ${to_cell}
    Log To Console    Enabling HO over Xn
    Update Parameter    param=handoverAllowedSA    value=allowed
    ...    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${from_cell}/NRREL-${nrrel_id}
    [Return]    XN


Disable HO Over Xn
    [Arguments]    ${from_cell}    ${to_cell}
    ${nrrel_id}    Find Nrrel Id    ${from_cell}    ${to_cell}
    Log To Console    Disabling HO over Xn - only NG ho is possible
    Update Parameter    param=handoverAllowedSA    value=XnHoNotAllowed
    ...    distname=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${from_cell}/NRREL-${nrrel_id}
    [Return]    NG


Set Entry Attenuation 2 cells
    Initialise Attenuator
    Set Full Attenuation For All Cells
    Set Attenuation  ${ATTENUATOR['NRCELL_1_1']['attenuation']}  ${ATTENUATOR['NRCELL_1_1']['ports']}  confirm=${TRUE}
    ...   attenuator_id=${ATTENUATOR['NRCELL_1_1']['att_id']}
    Set Attenuation  ${ATTENUATOR['NRCELL_2_106']['attenuation']}  ${ATTENUATOR['NRCELL_2_106']['ports']}  confirm=${TRUE}
    ...   attenuator_id=${ATTENUATOR['NRCELL_2_106']['att_id']}

Prepare Attenuation Cell 1 Preferred
    Initialise Attenuator
    Set Full Attenuation For All Cells
    Set Attenuation  ${ATTENUATOR['NRCELL_1_1']['attenuation']}  ${ATTENUATOR['NRCELL_1_1']['ports']}  confirm=${TRUE}
    ...   attenuator_id=${ATTENUATOR['NRCELL_1_1']['att_id']}

Attenuate Cell
    [Arguments]    ${cell_id}
    Set Attenuation On Cell    ${cell_id}    90

Clear Attenuation On Cell
    [Arguments]    ${cell_id}
    Set Attenuation On Cell    ${cell_id}    0

Set Attenuation On Cell
    [Arguments]    ${cell_id}    ${attenuation}
    Initialise Attenuator
    Set Attenuation  ${attenuation}  ${ATTENUATOR['NRCELL_${cell_id}']['ports']}  confirm=${TRUE}
    ...   attenuator_id=${ATTENUATOR['NRCELL_${cell_id}']['att_id']}
