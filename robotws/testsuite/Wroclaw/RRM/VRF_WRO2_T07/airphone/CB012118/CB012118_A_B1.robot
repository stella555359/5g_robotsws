*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT    PY310
...           CONFIGURED    5G_RAN_TDD    5G_RAN    SBTS00    RAN_5G    RAN_5G_TDD    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Piotr Gudas
...              :contact: piotr.gudas@nokia.com

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_delta
Library     ta5g_enb
Library     ta5g_testline_management

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Vm Ethernet Interfaces
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=CB012118_A.json
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_2c_tdd_sansa_interrat_ho_vonr.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=CB012118_A.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging And Mark New Test    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
[2]CB012118-A_B1_Triggering_of_Blind_Redirect_towards_LTE
    [Documentation]    Test purpose:
    ...                    This user scenario describes the gNB behaviour on reception of NGAP message
    ...                    requesting setup of 5QI-1. This scenario assumes the case where the condition
    ...                    for configuring B1 measurement is NOT satisfied.
    ...
    ...                Test case covers requirement: 5G_RAN_USR_RRM_22670

    Attach UE And Establish PDU Session
    Set UE To Send B1 Measurement In Response To RRCReconfiguration
    Setup fiveQI-1    pass_regexp=E-UTRA redirectedCarrierInfo=2200; redirect to eNB-3 cell 1

    Verify Traces For IMS Voice EPS Fallback And UE Context Release

[1]CB012118-A_B1_Triggering_of_Blind_Redirect_towards_LTE
    [Documentation]    Test purpose:
    ...                    This user scenario describes the gNB behaviour on reception of NGAP message
    ...                    requesting setup of 5QI-1. This scenario assumes the case where
    ...                    B1 measurement is NOT configured
    ...
    ...                Test case covers requirement: 5G_RAN_USR_RRM_22670

    Find Scfc and Send Delta Commissioning    scfc_filename=actVoFallBackLteB1MeaBaRedir_false.json

    Attach UE And Establish PDU Session    ue_id=2    gw_id=2
    Setup fiveQI-1    ue_id=2    pass_regexp=E-UTRA redirectedCarrierInfo=2200; redirect to eNB-3 cell 1

    Verify Traces For IMS Voice EPS Fallback And UE Context Release


*** Keywords ***
Attach UE And Establish PDU Session
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    Wait Until Keyword Succeeds    2x    100ms    Attach Ue    ue_id=${ue_id}
    Establish Pdu Session With Traffic    ue_id=${ue_id}    pdu_id=1    gw_id=${gw_id}    throughput='168mbps'

Setup fiveQI-1
    [Arguments]    ${ue_id}=1    ${pass_regexp}=None
    Modify PDU Session    ue_id=${ue_id}    pdu_id=1    qos_to_add=2    pass_regexp=${pass_regexp}

Set UE To Send B1 Measurement In Response To RRCReconfiguration
    [Arguments]    ${ue_id}=1
    ${b1_meas_hex}    Set Variable    004100004002001FCF1E00
    ${ue_nr_rrc_reconf_param_to_send_B1_meas} =    catenate    SEPARATOR=
    ...    ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=send_complete_and_hex
    ...    \ hex=${b1_meas_hex} nth=1
    Execute Egate Command    cmd=${ue_nr_rrc_reconf_param_to_send_B1_meas}

Verify Traces For IMS Voice EPS Fallback And UE Context Release
    Verify Ngap Messages    packet_filter=${PDU_SESS_RES_MOD_REQ_TO_SETUP_5QI_1}
    Verify Ngap Messages    packet_filter=${5QI_1_BERER_IS_REJECTED_WITH_CAUSE}
    Verify Ngap Messages    packet_filter=${UE_CTXT_REL_REQ_WITH_CAUSE}
    Verify Ngap Messages    packet_filter=${UE_CTXT_REL_REL_WITH_CAUSE}
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:eNB1_X2    ip_with_mask=10.0.1.138/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:eNB1_X2    ip_with_mask=10.0.1.138/24

*** Variables ***
${REDIRECTION} =    ngap.radioNetwork == 41
${PDU_SESS_RES_MOD_REQ_TO_SETUP_5QI_1} =    ngap.PDUSessionResourceModifyRequest_element && ngap.fiveQI == 1
${5QI_1_BERER_IS_REJECTED_WITH_CAUSE} =    ngap.PDUSessionResourceModifyResponse_element && ${VOICE_FALLBACK_TRIGGERED}
${UE_CTXT_REL_REQ_WITH_CAUSE} =    ${NGAP_UE_CONTEXT_RELEASE_REQUEST} && ${REDIRECTION}
${UE_CTXT_REL_REL_WITH_CAUSE} =    ${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${REDIRECTION}
