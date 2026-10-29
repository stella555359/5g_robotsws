*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    SBTS22R4    SBTS23R1
    ...    CLOUD_5G_I_BLLL_AP_LOO

Documentation    :copyright: Nokia

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource     feature_keywords.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      taf.ul.ettf.logging
Variables    testsuite/Wroclaw/RRM/resources/airphone/tshark_filters/ngap.py
Variables    testsuite/Wroclaw/RRM/resources/airphone/tshark_filters/f1ap.py
Variables    testsuite/Wroclaw/RRM/resources/airphone/tshark_filters/e1ap.py
Variables    feature_variables.py
Variables    ../resources/custom_policy.py

*** Variables ***
${LOGGING_POLICY}=    FULL_POLICY

${TS_CONFIG_DIR_GBR}=     ${CURDIR}/config/5GC001167-I/5GC001167_I_d_Non_GBR_as_default_bearer_for_3CC_CA_with_dedicated_GBR_added
${TS_CONFIG_DIR_NON_GBR}=      ${CURDIR}/config/5GC001167-I/5GC001167_I_d_Non_GBR_as_default_bearer_for_3CC_CA_with_dedicated_Non_GBR_added

${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}=                     f1ap.SCell_ToBeSetupMod_List == 2
${F1AP_SCELL_TO_ADD_MOD_LIST}=                          nr-rrc.sCellToAddModList == 2 && nr-rrc.physCellId == 50 && nr-rrc.physCellId == 52
${F1AP_UE_MODIFICATION_REQUEST_DRX}=                    f1ap.longDRXCycleLength == 7
${F1AP_UE_MODIFICATION_RESPONSE_DRX}=                   nr-rrc.milliSeconds == 7 && nr-rrc.drx_InactivityTimer == 11
${F1AP_CONTEXT_MODIFY_RESPONSE_QOSFLOW}=                f1ap.DRBs_SetupMod_List == 1
${F1AP_CONTEXT_MODIFY_REQUEST_PDU}=                     f1ap.dRBID == 5 && f1ap.id == 33
${F1AP_CONTEXT_MODIFY_RESPONSE_PDU}=                    nr-rrc.rlc_BearerToReleaseList == 2
${E1AP_BEARER_MODIFY_REQUEST_RESPONSE}=                 e1ap.qoS_Flow_Identifier == 2
${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE}=            ngap.pDUSessionResourceModifyResponseTransfer && ngap.qosFlowIdentifier == 2
${NGAP_PDU_SESSION_RELEASE_COMMAND}=                    ngap.PDUSessionResourceToReleaseListRelCmd == 1
${NGAP_PDU_SESSION_RELEASE_RESPONSE}=                   ngap.pDUSessionID == 1 && ngap.pDUSessionResourceReleaseResponseTransfer == 00

${NGAP_PDU_SESSION_RESOURCE_SETUP_REQUEST_5QI_1}=       ngap.qosFlowIdentifier == 2 && ngap.fiveQI == 1
${NGAP_PDU_SESSION_RESOURCE_SETUP_REQUEST_5QI_7}=       ngap.qosFlowIdentifier == 2 && ngap.fiveQI == 7
${F1AP_CONTEXT_MODIFY_REQUEST_QOSFLOW_5QI_1}=           f1ap.fiveQI == 1
${F1AP_CONTEXT_MODIFY_REQUEST_QOSFLOW_5QI_7}=           f1ap.fiveQI == 7

*** Test Cases ***
5GC001167-I_d_non_GBR_QoS_flow_as_a_default_for_3CC_CA_then_GBR_QoS_added
    [Setup]    Custom Prepare Test Environement And Reach Onair
    ...        iphy_xml=${TS_CONFIG_DIR_GBR}/ap/iphy_AHCA_n5_AHFIB_n66_AHFIB_n66.xml
    ...        scfc=fdd_3CC_n5_n66_n66_GBR.xml
    ...        egate_cfg=${TS_CONFIG_DIR_GBR}/basic_fs_sa_call_fdd_cmwv_3CC_1167_I_d.cfg
    ...        disablel1bypass=False

    Attach_UE_With_PDU_Session_Setup
    Verify_Successful_3CC_On_NGAP_And_F1AP_Messages
    Send_Data_Traffic_For_Ue_And_Display_Bearer_Statistic    ue_id=1
    Display_Qfi_Statistic_In_Egate_Console      ue_id=1    qfi=1
    Perform_GBR_Qosflow_Establishment
    Verify_GBR_Qosflow_Establishment_On_NGAP_And_F1AP_And_E1AP_Messages
    Start_Data_Traffic_For_Added_GBR_QosFlow    ue_id=1    qfi=2   pdu_id=1
    Detach_Ue_And_Verify_Detach_Procedure

5GC001167_I_d_Non_GBR_as_default_bearer_for_3CC_CA_with_dedicated_Non_GBR_added
    [Setup]    Custom Prepare Test Environement And Reach Onair
    ...				iphy_xml=${TS_CONFIG_DIR_NON_GBR}/ap/iphy_AHCA_n5_AHFIB_n66_AHFIB_n66.xml
    ...				scfc=fdd_3CC_n5_n66_n66_nonGBR.xml
    ...             egate_cfg=${TS_CONFIG_DIR_NON_GBR}/basic_fs_sa_call_fdd_cmwv_3CC_1167_I_d.cfg
    ...             disablel1bypass=False

    Attach_UE_With_PDU_Session_Setup
    Verify_Successful_3CC_On_NGAP_And_F1AP_Messages
    Send_Data_Traffic_For_Ue_And_Display_Bearer_Statistic    ue_id=1
    Display_Qfi_Statistic_In_Egate_Console    ue_id=1    qfi=1
    Perform_nonGBR_Qosflow_Establishment
    Verify_nonGBR_Qosflow_Establishment_On_NGAP_And_F1AP_And_E1AP_Messages
    Start_Data_Traffic_For_Added_nonGBR_QosFlow
    Detach_Ue_And_Verify_Detach_Procedure

*** Keywords ***
Attach_UE_With_PDU_Session_Setup
    Set Internal Traffic Type To UEs    ue_id=1
    Change UE Cell Location    ue_id=1    cell_id=2
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1

Verify_Successful_3CC_On_NGAP_And_F1AP_Messages
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}    continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_BE_SETUP_MOD_LIST}        continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_SCELL_TO_ADD_MOD_LIST}             number_of_messages=3   continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_UE_MODIFICATION_REQUEST_DRX}       continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_UE_MODIFICATION_RESPONSE_DRX}      number_of_messages=2    continue_on_failure=False

Release_Of_Established_PDU_Session
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    cmd=ue_pdu_session_release ue=${ue_id} pdu=${pdu_id}
    ...    pass_regexp=UE ID: ${ue_id}.*Successfully released PDU Session with ID ${pdu_id}    timeout=10

Detach_Ue_And_Verify_Detach_Procedure
    Release_Of_Established_PDU_Session    ue_id=1     pdu_id=1
    Verify Tcpdump Log       packet_filter=${NGAP_PDU_SESSION_RELEASE_COMMAND}
    Verify Tcpdump Log       packet_filter=${F1AP_CONTEXT_MODIFY_REQUEST_PDU}
    Verify Tcpdump Log       packet_filter=${F1AP_CONTEXT_MODIFY_RESPONSE_PDU}
    Verify Tcpdump Log       packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMMAND}
    Verify Tcpdump Log       packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMPLETE}
    Verify Tcpdump Log       packet_filter=${NGAP_PDU_SESSION_RELEASE_RESPONSE}
    Deregister Ue    ue_id=1
    Verify Tcpdump Log       packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}

Perform_Qosflow_Establishment
    [Arguments]     ${ue_id}=1     ${qosflows}=2
    Execute Egate Command     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${ue_id} qosflows_to_add=${qosflows} by=amf

Perform_GBR_Qosflow_Establishment
    Perform_Qosflow_Establishment

Perform_nonGBR_Qosflow_Establishment
    Perform_Qosflow_Establishment

Verify_GBR_Qosflow_Establishment_On_NGAP_And_F1AP_And_E1AP_Messages
    Verify Tcpdump Log      packet_filter=${NGAP_PDU_SESSION_RESOURCE_SETUP_REQUEST_5QI_1}
    Verify Tcpdump Log      packet_filter=${E1AP_BEARER_MODIFY_REQUEST_RESPONSE}    number_of_messages=2
    Verify Tcpdump Log      packet_filter=${F1AP_CONTEXT_MODIFY_REQUEST_QOSFLOW_5QI_1}
    Verify Tcpdump Log      packet_filter=${F1AP_CONTEXT_MODIFY_RESPONSE_QOSFLOW}
    Verify Tcpdump Log      packet_filter=${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE}

Verify_nonGBR_Qosflow_Establishment_On_NGAP_And_F1AP_And_E1AP_Messages
    Verify Tcpdump Log      packet_filter=${NGAP_PDU_SESSION_RESOURCE_SETUP_REQUEST_5QI_7}     continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${E1AP_BEARER_MODIFY_REQUEST_RESPONSE}         number_of_messages=2    continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_CONTEXT_MODIFY_REQUEST_QOSFLOW_5QI_7}         continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${F1AP_CONTEXT_MODIFY_RESPONSE_QOSFLOW}        continue_on_failure=False
    Verify Tcpdump Log      packet_filter=${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE}    continue_on_failure=False

Start_Data_Traffic_For_Added_GBR_QosFlow
    [Arguments]    ${ue_id}    ${qfi}  ${pdu_id}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl rtp_codec=amr_12_2
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=ul rtp_codec=amr_12_2
    Wait for Traffic to Stabilize
    Display_Qfi_Statistic_In_Egate_Console      ue_id=1    qfi=2
    Stop Data Traffics    ue_id=${ue_id}    qfi=${qfi}     dir=bi

Start_Data_Traffic_For_Added_nonGBR_QosFlow
    Start Dl Data Traffic    ue_id=1    qfi=2    trf_id=1
    Start Ul Data Traffic    ue_id=1    qfi=2    trf_id=1
    Wait for Traffic to Stabilize
    Display_Qfi_Statistic_In_Egate_Console      ue_id=1    qfi=2
    Stop Data Traffics    ue_id=1    qfi=2    dir=bi

Display_Qfi_Statistic_In_Egate_Console
    [Arguments]    ${ue_id}    ${qfi}
    Execute Egate Command    cmd=qfi_stats ue=${ue_id} pdu=${ue_id} qfi=${qfi} format=long
    Wait for Traffic to Stabilize
    Execute Egate Command    cmd=qfi_stats ue=${ue_id} pdu=${ue_id} qfi=${qfi} format=long
