*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO  VARIANT_SA_FS_ECPRI_MMWV_TDD    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Kamila Bialczyk,Alok Shastri
...              :contact: kamila.bialczyk@nokia.com,alok.shastri@nokia.com


Resource     ../resources/5G_SW_WRO_Keywords.robot

Library      ta5g_tshark
Library      ta5g_egate
Library      ta5g_file_system

Variables    ta5g_global_var


Suite Setup       Run Keywords    Start Default Logging And Reach Onair
...                               lua_cfg_filepath=${CURDIR}/config/egate_2cc_865.lua
...                               output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...               AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_change_nullFallback_true.json
...               AND             Set Suite Variable    ${pdu_id}    1
...               AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Test Setup        Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown     Run Keywords    Increment PDU ID
...               AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_default_values.json
...               AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${ICS_FAILURE_DUE_TO_ENCRYPTION_OR_INTEGRITY_PROTECTION_ALGO_NOT_SUPPORTED} =
...    ${NGAP_INITIAL_CONTEX_SETUP_FAILURE} && ${ENCRYPTION_AND_OR_INTEGRITY_PROTECTION_ALGORITHMS_NOT_SUPPORTED}

${ICS_FAILURE_DUE_TO_FAILURE_IN_RADIO_INTERFACE_PROCEDURE} =
...    ${NGAP_INITIAL_CONTEX_SETUP_FAILURE} && ${FAILURE_IN_RADIO_INTERFACE_PROCEDURE}

${NR_RRC_SECURITY_MODE_COMMAND_IN_F1AP_UE_CONTEXT_SETUP} =
...    ${F1AP_UE_CONTEXT_SETUP_REQUEST} && ${SECURITY_MODE_COMMAND}

*** Test Cases ***
5GC000865_E_1_5GC000866_E_1_Security_Mode_Failure_During_Initial_As_Security_Activation
    [Tags]    GQC:FEATURE:5GC000865-G    GQC:FEATURE:5GC000866-G
    Set Suite Variable    ${ue_id}    3
    Execute Initial Procedure From 5GC000752-C Message Flow    ue_id=${ue_id}    initial_pdu_id=${ue_id}
    Configure Rule For SecurityModeCommand Messages    ue_id=${ue_id}    rule=failure
    Perform Action And Wait For Given Tshark Message Number
    ...    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
    ...    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
    ...    action=Exit Idle Mode Without Confirmation   ue_id=${ue_id}
    Verify Messages Occurance For Failure During Initial As Security Activation
    Verify Tcpdump Log    packet_filter=${SECURITY_MODE_FAILURE}    relation_symbol= >=

*** Keywords ***
Execute Initial Procedure From 5GC000752-C Message Flow
    [Arguments]    ${ue_id}    ${initial_pdu_id}
    ${next_pdu_id} =    Evaluate    ${initial_pdu_id} + 1
    Turn On Off Inclusion Of Ue Capabilities    turn_on_off=on
    Attach Ue    ue_id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE from UE with RAN UE NGAP ID \\d+ and AMF UE NGAP ID \\d+
    Establish Pdu Session    ue_id=${ue_id}     pdu_id=${initial_pdu_id}    gw_id=${initial_pdu_id}
    Establish Pdu Session    ue_id=${ue_id}     pdu_id=${next_pdu_id}    gw_id=${next_pdu_id}
    ...    pass_regexp=PDUSessionId:${next_pdu_id}
    Release Ue Ctx    ue_id=${ue_id}    pass_regexp=IS IDLE

Trigger Error Scenario Of 5GC000865-G Feature
    [Arguments]    ${scfc_filename}    ${ue_id}
    Find Scfc And Send Delta Commissioning    scfc_filename=${scfc_filename}
    Exit Idle Mode    ue_id=${ue_id}    pass_regexp=UE${ue_id}: RrcState: NR CONNECTED    timeout=60

Verify Messages Occurance For Triggered Error Scenario
    [Arguments]    ${ue_id}
    Verify Tcpdump Log    packet_filter=${SECURITY_MODE_COMMAND}    relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${SECURITY_MODE_COMPLETE}    relation_symbol= >=
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ngap.AMF_UE_NGAP_ID == ${pdu_id}
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST} && ngap.AMF_UE_NGAP_ID == ${${pdu_id}+1}
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ngap.AMF_UE_NGAP_ID == ${pdu_id}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND}    number_of_messages=2
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}    number_of_messages=2
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ngap.AMF_UE_NGAP_ID == ${pdu_id}
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ngap.AMF_UE_NGAP_ID == ${${pdu_id}+1}
    Verify Ngap Messages    packet_filter=${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION}

Execute Core Test Case
    [Arguments]    ${scfc_filename}    ${ue_id}    ${initial_pdu_id}
    Execute Initial Procedure From 5GC000752-C Message Flow    ue_id=${ue_id}    initial_pdu_id=${initial_pdu_id}
    Trigger Error Scenario Of 5GC000865-G Feature    scfc_filename=${scfc_filename}    ue_id=${ue_id}
    Verify Messages Occurance For Triggered Error Scenario    ue_id=${ue_id}
    Verify Ngap Messages
    ...   packet_filter=${ICS_FAILURE_DUE_TO_ENCRYPTION_OR_INTEGRITY_PROTECTION_ALGO_NOT_SUPPORTED} && ngap.AMF_UE_NGAP_ID == ${${pdu_id}+1}

Verify Messages Occurance For Failure During Initial As Security Activation
    Verify Ngap Messages
    ...    packet_filter=${ICS_FAILURE_DUE_TO_FAILURE_IN_RADIO_INTERFACE_PROCEDURE} && ngap.AMF_UE_NGAP_ID == ${${pdu_id}+1}
    Verify Ngap Messages    packet_filter=${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION}
    Verify Tcpdump Log    packet_filter=${SECURITY_MODE_COMMAND}    number_of_messages=2    relation_symbol= >=

Increment PDU ID
    ${new_pdu_id} =    Evaluate    ${pdu_id} + 2
    Set Suite Variable     ${pdu_id}   ${new_pdu_id}
