*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    SBTS23R1
...           CONFIGURED    CRT    RAN_5G_FDD    RAN_5G    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Michal Fluder (too many authors of particular testcases to mention)
...              :contact: michal.fluder@nokia.com

Variables    ta5g_global_var
Variables    config/754_B_variables.py

Resource     ../../resources/5G_SW_WRO_Keywords.robot

Library      ta5g_testline_management
Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      ta5g_iperf_traffic
Library      ta5g_enb


Suite Setup    Setup Inactivity Timer Variable And Reach OnAir
Suite Teardown    Run Keywords    Stop All Traffics
...               AND    Stop Default Processes And Gather Logs And Compress Logs


Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
Test Teardown    Run Keywords    Deregister Ue Without Confirmation    ue_id=1-3
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Variables ***
${ADD_OR_MODIFY_REQUEST_FOR_MULTI_PDU} =    ngap.pDUSessionID == 1 && ngap.pDUSessionID == 2 && ngap.qosFlowIdentifier == 3 &&
...                                         ngap.qosFlowIdentifier == 2 && ngap.radioNetwork == 0 && ngap.QosFlowListWithCause == 1 &&
...                                         ngap.QosFlowAddOrModifyRequestList == 1

${ADD_OR_MODIFY_RESPONSE_FOR_MULTI_PDU} =    ngap.pDUSessionID == 1 && ngap.pDUSessionID == 2 && ngap.PDUSessionResourceModifyListModRes == 2 &&
...                                          ngap.qosFlowIdentifier == 3

${UE_PDU_SESSION_MODIFY_REQUEST_QOS_2_AND_3} =    ${NGAP_PDU_SESSION_RESOURCE_MODIFY_REQUEST} && ngap.qosFlowIdentifier == 2 &&
...                                               ngap.qosFlowIdentifier == 3

${PDU_SESSION_MOD_REQUEST_TC6} =    ${NGAP_PDU_SESSION_RESOURCE_MODIFY_REQUEST} && (ngap.id == 64 && ngap.PDUSessionResourceModifyListModReq == 2) &&
...                                 ngap.id == 137

${PDU_SESSION_MOD_RESPONSE_TC6} =    ${NGAP_PDU_SESSION_RESOURCE_MODIFY_RESPONSE} && ngap.PDUSessionResourceFailedToModifyListModRes == 2 &&
...                                  ${MULTIPLE_PDU_SESSION_ID_INSTANCES}

*** Test Cases ***
5GC000754_B_02_PDU_Session_Mod_Success_Simultaneous_Add_and_Delete_one_or_more_nonGBR_5QI_QoS_Flows_in_a_single_message_multiPDU_session
    [Documentation]  Successful PDU Session Resource Modification procedure requested by the AMF to simultaneously
    ...              add and delete one or more non-GBR QoS Flows from one or more PDU sessions. The gNB uses
    ...              this procedure for the modification of the PDU session, adding/deleting DRB(s) and SDAP configuration.
    ...              OPTIMIZATION: Contains TC 5GC000876-A_PDU_Session_Resource_Setup_For_Subsequent_PDU_Session

    Attach UE    ue_id=1
    Establish Multiple PDU Sessions    pdu_ids_list=@{PDU_LIST_B2}    ue_id=1
    Modify Multiple PDU Sessions   pdu_ids_list=@{PDU_LIST_B2}    ue_id=1    qos_to_add=2
    Wait For Pdu Session Modify To Complete
    Verify Ngap Messages    packet_filter=${NGAP_PDU_SESSION_RESOURCE_MODIFY_REQUEST} && ngap.qosFlowIdentifier == 2    number_of_messages=2
    Verify Ngap Messages    packet_filter=${NGAP_PDU_SESSION_RESOURCE_MODIFY_RESPONSE} && ngap.qosFlowIdentifier == 2    number_of_messages=2
    Modify PDU Session Multi PDU    pdu_matrix=@{PDU_MATRIX_B2}      ue_id=1
    Wait For Pdu Session Modify To Complete
    Start Traffic And Check If Average Throughput Is Reached    pdu_gw_id=2    duration=${srbInactivityTimer}s
    Verify Ngap Messages    packet_filter=${ADD_OR_MODIFY_REQUEST_FOR_MULTI_PDU}
    Verify Ngap Messages    packet_filter=${ADD_OR_MODIFY_RESPONSE_FOR_MULTI_PDU}

5GC000754_B_04_PDU_Session_Modification_Success_Delete_one_or_more_nonGBR_5QI_QoS_Flows_in_one_ore_more_PDU_Sessions_ONE_PDU
    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/setup_logs
    ...        AND             Attach UE    ue_id=2
    ...        AND             Establish PDU Session    ue_id=2   pdu_id=1    gw_id=3
    ...        AND             Modify PDU Session    ue_id=2    qos_to_add=2,3
    ...        AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}/setup_logs
    ...        AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    Modify PDU Session    ue_id=2    qos_to_del=2,3
    Wait For Pdu Session Modify To Complete
    Start Traffic And Check If Average Throughput Is Reached    pdu_gw_id=3    duration=40s    margin=10%
    Verify Ngap Messages    packet_filter=${UE_PDU_SESSION_MODIFY_REQUEST_QOS_2_AND_3}
    Verify Ngap Messages    packet_filter=${NGAP_PDU_SESSION_RESOURCE_MODIFY_RESPONSE}

5GC000754_B_06_PDU_Session_Mod_Fail_for_QoS_Flow_Del_Invalid_IEs_in_NGAP_PDU_Session_Resource_Modify_Request_msg_with_QoS_Flow_Del_TC2
    Attach UE    ue_id=3
    Establish Multiple PDU Sessions    ue_id=3    pdu_ids_list=${PDU_LIST_B6}
    Modify PDU Session Multi PDU    ue_id=3   validation=on   pdu_matrix=${PDU_MATRIX_B6_SUCCESS}
    Wait For Pdu Session Modify To Complete
    Modify Multi PDU Session and Expect Failure   ue_id=3   pdu_matrix=${PDU_MATRIX_B6_FAILURE}
    Verify NGAP Messages        packet_filter=${PDU_SESSION_MOD_REQUEST_TC6}
    Verify NGAP Messages        packet_filter=${PDU_SESSION_MOD_RESPONSE_TC6}

*** Keywords ***
Setup Inactivity Timer Variable And Reach OnAir
    Start Default Logging And Reach Onair    lua_cfg_filepath=${CURDIR}/config/egate_754B.lua
    ...                                      output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
    Set Srb Inactivity Timer Variable
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Set Srb Inactivity Timer Variable
    ${srbInactivityTimer}=    Get Admin Object Parameter Value    parameter_name=srbInactivityTimerSA
    Set Suite Variable    ${srbInactivityTimer}

Wait For Pdu Session Modify To Complete
    Sleep    5    reason=Waiting for pdu session modification to complete.

Modify Multi PDU Session and Expect Failure
    [Arguments]    ${ue_id}    ${pdu_matrix}
    Modify PDU Session Multi PDU    ue_id=${ue_id}    validation=off   pdu_matrix=${pdu_matrix}
    ...                             pass_regexp=PDU Session Resource Modify Unsuccessful Transfer
    Wait For Pdu Session Modify To Complete
