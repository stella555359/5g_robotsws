*** Settings ***
Force Tags    CONFIGURED    RAN_5G_FDD   RAN_5G    CRT
...           CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Kamila Bialczyk
...              :contact: kamila.bialczyk@nokia.com

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Resource     5GC000752_F_Variables.robot
Library      ta5g_egate
Library      ta5g_pm_counters
Library      ta5g_ue_mobility

Suite Setup     Run Keywords    Start Default Logging And Reach Onair
...                             output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...                             lua_cfg_filepath=${CURDIR}/../../resources/egate_2c_tdd_2c_fdd_sansa.lua
...             AND             Set Counter Collecting Interval To Five Minutes
...             AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup     Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
@{pdu_ids_list} =    3    4
${AMF_NGAP_UE_CONTEXT_RELEASE_COMPLETE} =    ${NGAP_UE_CONTEXT_RELEASE_COMPLETE} && ${NGAP_UE_AMF_ID}
${RAN_NGAP_UE_CONTEXT_RELEASE_COMPLETE} =    ${NGAP_UE_CONTEXT_RELEASE_COMPLETE} && ${NGAP_UE_RAN_ID}

*** Test Cases ***
5GC000752-F_9_USBasicCall-F_EC18_1A_Unsuccessful_Initial_Context_Setup_with_PDU_Session_with_UE_Radio_Capabilities_lack_of_RRC_Sec_Mode_Complete
    [Documentation]   Correct handling of unsuccessful Initial Context Setup with PDU Session
    ...    with UE Radio Capabilities when gNB-CU-CP rejects NGAP Initial Context Setup Request

    Attach Ue    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Verify Ngap Messages    packet_filter=ngap.PDUSessionResourceSetupListCxtRes == 1 && ngap.pDUSessionID == 1
    Release Ue Ctx    ue_id=1
    Turn On Off Inclusion Of Ue Capabilities
    Configure Rule For Securitymodecommand Messages    ue_id=1    rule=drop
    Exit Idle Mode Without Confirmation    ue_id=1
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEX_SETUP_FAILURE}
    Verify Number Of Ngap Messages    packet_filter=${RAN_NGAP_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=2
    Verify Number Of Ngap Messages    packet_filter=${AMF_NGAP_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=2
    Verify ICS And Ue Context Release Failure Cause

5GC000752-F_11_USBasicCall-F_EC21_Unsuccessful_Initial_Context_Setup_with_PDU_Session_with_UE_Radio_Capabilities_lack_of_RRC_Reconf_Complete
    [Documentation]   Correct handling of unsuccessful Initial Context Setup with PDU Session
    ...    wihout UE Radio Capabilities when gNB-CU-CP rejects NGAP Initial Context Setup Request
    ...    due to lack of RRC: RRC Reconfiguration Complete - 5G UE no response

    Attach Ue    ue_id=2
    Establish PDU Session    ue_id=2    pdu_id=2    gw_id=2
    Verify Ngap Messages    packet_filter=ngap.PDUSessionResourceSetupListCxtRes == 1 && ngap.pDUSessionID == 2
    Release Ue Ctx    ue_id=2
    Turn On Off Inclusion Of Ue Capabilities
    UE NR RRC Reconf Param    ue_id=2    if_contains=any    action=drop
    Exit Idle Mode Without Confirmation    ue_id=2
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEX_SETUP_FAILURE}
    Verify Number Of Ngap Messages    packet_filter=${RAN_NGAP_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=2
    Verify Number Of Ngap Messages    packet_filter=${AMF_NGAP_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=2
    Verify ICS And Ue Context Release Failure Cause

*** Keywords ***
Verify Number Of Ngap Messages
    [Arguments]     ${packet_filter}    ${number_of_messages}
    Verify Tshark For Given Number Of Messages    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
    ...    packet_filter=${packet_filter}    number_of_messages=${number_of_messages}

Verify ICS And Ue Context Release Failure Cause
    Verify Ngap Messages    packet_filter=${ICS_RADIO_NETWORK_FAILURE_IN_RADIO_INTERFACE_PROCEDURE}
    Verify Ngap Messages    packet_filter=${UECONTEXTRELEASE_RADIO_NETWORK_FAILURE_IN_RADIO_INTERFACE_PROCEDURE}

