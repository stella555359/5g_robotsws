*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    RAN_5G_TDD    RAN_5G
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristina Burtea, Dan Moldovan, Andrei Maria, Elena Sabau, Radu Turcu
...              :maintainer: marcin.plawny@nokia.com

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/dcap/utf_installer.py
Library    CB008225_Keywords.py
Resource    CB008225_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_8225_no_ran_sharing.json    skip_relation_errors=False
...            AND             Set VM IP
...            AND             Install Latest UTF
...            AND             Check Radios Availability
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_non_ran_sharing.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Setup Dcap

Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs
...               AND            Dcap Teardown
...               AND            Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/../initial_commissioning.xml
...                              delta_scf_filename=delta_8225_no_ran_sharing.json

*** Test Cases ***
USCB008225_J_9757_1_Active_UEs_configured_per_cell_with_periodic_measurements_during_end_of_periodic_measurements_for_SA
    [Documentation]    This test case tests the gNB behavior for UE in RRC_CONNECTED state that is successfully
    ...                transitioned to RRC_INACTIVE state based on the UE inactivity after Initial Context Setup.
    ...                Successful suspend procedure. Second UE has no CNAI for RRC Inactive - it is released to IDLE.
    ...                5G_CP_ARC_ARG_9757

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Vm IP and Replace    delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration9757.json    suite_path=${CURDIR}
    ...        AND             Find Scfc And Send Delta Commissioning
    ...                        scfc_filename=delta_Cell_Trace_MDT_PCMD_Configuration9757.json    skip_relation_errors=False
    ...        AND             Remove Vm IP from delta    delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration9757.json    suite_path=${CURDIR}
    ...        AND             Sleep    60s    reason=Wait for delta

    ${dcap_id}=    Dcap Start New Trace
    Sleep    5s

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=1
    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1    gw_id=1
    Attach UE    ue_id=10
    Establish PDU Session    ue_id=10    gw_id=10
    Wait For Release RRC Inactive Conditions Met
    Sleep    5s

    Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs

    ${MDT_list1}   set variable      UEs with MDT enabled is 1
    ${MDT_list2}   set variable      UEs with MDT enabled is 2
    Syslog should contain MDT List message    ${MDT_list1}
    Syslog should NOT contain MDT List message   ${MDT_list2}

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/scfc_after_delta.xml
    ...                           delta_scf_filename=delta_Cell_Trace_MDT_PCMD_Configuration9757.json
    ...           AND             Run Keyword If Test Failed
    ...                           Run Keyword And Ignore Error
    ...                           Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

USCB008225_J_B01_B_B1_1_gNB_CU_UeDuConnectivity_Record_from_gNB_CU_CP_during_RRC_Connected_to_RRC_Inactive_transition
    [Documentation]    This test case tests the gNB behavior for UE in RRC_CONNECTED state that is successfully
    ...                transitioned to RRC_INACTIVE state based on the UE inactivity after Initial Context Setup.
    ...                Successful suspend procedure. Second UE has no CNAI for RRC Inactive - it is released to IDLE.
    ...                5G_CP_ARC_ARG_9757

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Vm IP and Replace    delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration9757.json    suite_path=${CURDIR}
    ...        AND             Find Scfc And Send Delta Commissioning
    ...                        scfc_filename=delta_Cell_Trace_MDT_PCMD_Configuration9757.json    skip_relation_errors=False
    ...        AND             Remove Vm IP from delta    delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration9757.json    suite_path=${CURDIR}
    ...        AND             Sleep    60s    reason=Wait for delta

    ${dcap_id}=    Dcap Start New Trace
    Sleep    5s

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=1
    Attach UE    ue_id=1
    Establish PDU Session    ue_id=1    gw_id=1
    Attach UE    ue_id=10
    Establish PDU Session    ue_id=10    gw_id=10
    Wait For Release RRC Inactive Conditions Met
    Sleep    5s

    Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Prepare Emil Logs As Json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Merge Json Files
    ${MDT_list1}   set variable      UEs with MDT enabled is 1
    ${MDT_list2}   set variable      UEs with MDT enabled is 2
    Syslog should contain MDT List message    ${MDT_list1}
    Syslog should NOT contain MDT List message   ${MDT_list2}

    ${B01_messages}    Create List    "rrcRelease": \{    "suspendConfig": \{    "UEContextReleaseComplete": \{
    ...    "BearerContextStatusChange": "suspend"    "BearerContextModificationResponse": \{    "radioNetwork": "normal-release"
    ...    "CoreNetworkAssistanceInformationForInactive": \{    "measurementReport": \{    "ueDuConnectivityRecord": \{
    ...    "ueCtxReleaseCmdSndTime": \{    "ueCtxReleaseCmplRcvTime": \{    "gnb-du-Ids": \{    "releaseData": \[
    Verify Messages In Json    ${B01_messages}    UTF_logs_all.json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/scfc_after_delta.xml
    ...                           delta_scf_filename=delta_Cell_Trace_MDT_PCMD_Configuration9757.json
    ...           AND             Run Keyword If Test Failed
    ...                           Run Keyword And Ignore Error
    ...                           Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

USCB008225_J_B02_D_B1_1_ROBUSTNESS_PCMD_Cell_Trace_Records_and_MDT_measurements_from_gNB_CU_CP_during_RRC_Inactive_to_RRC_Connected_transition
    [Documentation]    This test case validates the PCMD, Cell trace records and MDT measurements reported by
    ...                gNB-CU-CP when UE moves from RRC_Inactive to RRC_Connected state.
    ...                5G_RAN_USR_RRM_188806

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Vm IP and Replace    delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration.json    suite_path=${CURDIR}
    ...        AND             Find Scfc And Send Delta Commissioning
    ...                        scfc_filename=delta_Cell_Trace_MDT_PCMD_Configuration.json    skip_relation_errors=False
    ...        AND             Remove Vm IP from delta    delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration.json    suite_path=${CURDIR}
    ...        AND             Sleep    45s    reason=Wait for delta

    ${dcap_id}=    Dcap Start New Trace
    Sleep    5s

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=2
    Set PDU Param Internal Traffic    ue_id=2    pdu_id=1
    Set PDU Param Internal Traffic    ue_id=2    pdu_id=2
    Set Parameters For UE RRC Resume Request    ue_id=2    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mo_Signalling
    Attach UE    ue_id=2
    Establish PDU Session    ue_id=2    gw_id=1    pdu_id=1
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE

    Establish PDU Session    ue_id=2    gw_id=2    pdu_id=2
    Sleep    5s

    Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Prepare Emil Logs As Json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Merge Json Files

    ${B02_messages}    Create List    "rrcResumeComplete": \{    "dedicatedNAS-Message":    "c1": \{    "rrcResumeRequest1": \{
    ...    "ueCtxSetupReqSndTime": \{    "rrcResume": \{    "trigger": "rrcResume",    "measurementReport": \{
    ...    rrcConnEstablishmentCmplRcvTime": \{
    Verify Messages In Json    ${B02_messages}    UTF_logs_all.json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/scfc_after_delta.xml
    ...                           delta_scf_filename=delta_Cell_Trace_MDT_PCMD_Configuration.json
    ...           AND             Run Keyword If Test Failed
    ...                           Run Keyword And Ignore Error
    ...                           Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

USCB008225_J_B06_D_B01_1_Subscriber_and_Equipment_trace_during_RRC_Inactive_to_RRC_Connected_transition
    [Documentation]    This test case validates the subscriber and equipment trace
    ...                when UE moves from RRC_Inactive to RRC_Connected state.

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Vm IP and Replace    delta_scf=delta_8225_Subscriber_Trace.json    suite_path=${CURDIR}
    ...        AND             Find Scfc And Send Delta Commissioning
    ...                        scfc_filename=delta_8225_Subscriber_Trace.json    skip_relation_errors=False
    ...        AND             Remove Vm IP from delta    delta_scf=delta_8225_Subscriber_Trace.json    suite_path=${CURDIR}
    ...        AND             Sleep    45s    reason=Wait for delta

    ${dcap_id}=    Dcap Start New Trace
    Sleep    5s

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=6
    Set PDU Param Internal Traffic    ue_id=6    pdu_id=1
    Set PDU Param Internal Traffic    ue_id=6    pdu_id=2
    Start Subscriber Trace
    Set Parameters For UE RRC Resume Request    ue_id=6    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mo_Signalling
    Attach UE    ue_id=6
    Establish PDU Session    ue_id=6    gw_id=1    pdu_id=1
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE

    Establish PDU Session    ue_id=6    gw_id=2    pdu_id=2
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_COMPLETE}
    Sleep    5s

    Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Prepare Emil Logs As Json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Merge Json Files

    ${B06_messages}    Create List    "InitialContextSetupRequest": \{    "CoreNetworkAssistanceInformationForInactive": \{
    ...    "UEContextReleaseComplete": \{    "BearerContextStatusChange": "suspend"    "radioNetwork": "normal-release"    "suspendConfig": \{
    ...    "rrcResumeRequest1": \{    "rrcResume": \{    "subscriberTraceActivationFlag": true,
    Verify Messages In Json    ${B06_messages}    UTF_logs_all.json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/scfc_after_delta.xml
    ...                           delta_scf_filename=delta_8225_Subscriber_Trace.json
    ...           AND             Run Keyword If Test Failed
    ...                           Run Keyword And Ignore Error
    ...                           Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

USCB008225_J_B09_1_Activation_of_MBA_functionality_Cell_Trace_and_PCMD
    [Documentation]    This test case checking the gNB behaviour for UE in RRC_INACTIVE state that is successfully
    ...                transitioned to RRC_CONNECTED state. Successful Resume procedure.
    ...                5G_RAN_USR_RRM_18085, 5G_PM_982

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Vm IP and Replace    delta_scf=delta_Cell_Trace_PCMD_Configuration.json    suite_path=${CURDIR}
    ...        AND             Find Scfc And Send Delta Commissioning
    ...                        scfc_filename=delta_Cell_Trace_PCMD_Configuration.json    skip_relation_errors=False
    ...        AND             Remove Vm IP from delta    delta_scf=delta_Cell_Trace_PCMD_Configuration.json    suite_path=${CURDIR}
    ...        AND             Sleep    45s    reason=Wait for delta

    ${dcap_id}=    Dcap Start New Trace
    Sleep    5s

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=9
    Set PDU Param Internal Traffic    ue_id=9    pdu_id=1
    Set Parameters For UE RRC Resume Request    ue_id=9    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mo_SMS
    Attach UE    ue_id=9
    Establish PDU Session    ue_id=9    gw_id=9    pdu_id=1
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE

    Send UE RRC Resume Request    ue_id=9
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_COMPLETE}
    Sleep    5s

    Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Prepare Emil Logs As Json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Merge Json Files

    ${B09_messages}    Create List    "rrcResumeComplete": \{    "rrcResumeRequest1": \{
    Verify Messages In Json    ${B09_messages}    UTF_logs_all.json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/scfc_after_delta.xml
    ...                           delta_scf_filename=delta_Cell_Trace_PCMD_Configuration.json
    ...           AND             Run Keyword If Test Failed
    ...                           Run Keyword And Ignore Error
    ...                           Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

USCB008225_J_B11_3_Activation_of_SBA_functionality
    [Documentation]    This test case validates trace recording session for selected UE call for Subscriber Trace
    ...                content is started in gNB (via AMF, e.g. by message NGAP: TRACE START).

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Vm IP and Replace    delta_scf=delta_8225_Subscriber_Trace.json    suite_path=${CURDIR}
    ...        AND             Find Scfc And Send Delta Commissioning
    ...                        scfc_filename=delta_8225_Subscriber_Trace.json    skip_relation_errors=False
    ...        AND             Remove Vm IP from delta    delta_scf=delta_8225_Subscriber_Trace.json    suite_path=${CURDIR}
    ...        AND             Sleep    45s    reason=Wait for delta

    ${dcap_id}=    Dcap Start New Trace
    Sleep    5s

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=4
    Set PDU Param Internal Traffic    ue_id=4    pdu_id=1
    Set PDU Param Internal Traffic    ue_id=4    pdu_id=2
    Set Parameters For UE RRC Resume Request    ue_id=4    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mo_Signalling
    Attach UE    ue_id=4
    Establish PDU Session    ue_id=4    gw_id=1    pdu_id=1
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE

    Establish PDU Session    ue_id=4   gw_id=2    pdu_id=2
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_COMPLETE}
    Sleep    5s

    Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Prepare Emil Logs As Json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Merge Json Files

    ${B11_messages}    Create List    "InitialContextSetupRequest": \{    "CoreNetworkAssistanceInformationForInactive": \{
    ...    "UEContextReleaseComplete": \{    "BearerContextStatusChange": "suspend"    "radioNetwork": "normal-release"    "suspendConfig": \{
    ...    "System-BearerContextModificationResponse": \{
    Verify Messages In Json    ${B11_messages}    UTF_logs_all.json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/scfc_after_delta.xml
    ...                           delta_scf_filename=delta_8225_Subscriber_Trace.json
    ...           AND             Run Keyword If Test Failed
    ...                           Run Keyword And Ignore Error
    ...                           Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

USCB008225_J_B13_Activation_of_MBA_functionality_with_MDT_content
    [Documentation]    This test case checking the gNB behaviour for UE in RRC_INACTIVE state that is successfully
    ...                transitioned to RRC_CONNECTED state. Successful Resume procedure.
    ...                5G_RAN_USR_RRM_18085, 5G_PM_982

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Vm IP and Replace    delta_scf=Cell_Trace_MDT_Configuration.json    suite_path=${CURDIR}
    ...        AND             Find Scfc And Send Delta Commissioning
    ...                        scfc_filename=Cell_Trace_MDT_Configuration.json    skip_relation_errors=False
    ...        AND             Remove Vm IP from delta    delta_scf=Cell_Trace_MDT_Configuration.json    suite_path=${CURDIR}
    ...        AND             Sleep    45s    reason=Wait for delta

    ${dcap_id}=    Dcap Start New Trace
    Sleep    5s

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=11
    Set PDU Param Internal Traffic    ue_id=11    pdu_id=1
    Set PDU Param Internal Traffic    ue_id=11    pdu_id=2
    Set Parameters For UE RRC Resume Request    ue_id=11    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mo_Signalling
    Attach UE    ue_id=11
    Establish PDU Session    ue_id=11    gw_id=1    pdu_id=1
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE

    Establish PDU Session    ue_id=11    gw_id=2    pdu_id=2
    Verify Tcpdump Log    packet_filter=${RRC_RESUME_COMPLETE}
    Sleep    5s

    Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Prepare Emil Logs As Json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Merge Json Files

    ${B13_messages}    Create List    "rrcResumeComplete": \{    "rrcResumeRequest1": \{
    Verify Messages In Json    ${B13_messages}    UTF_logs_all.json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/scfc_after_delta.xml
    ...                           delta_scf_filename=Cell_Trace_MDT_Configuration.json
    ...           AND             Run Keyword If Test Failed
    ...                           Run Keyword And Ignore Error
    ...                           Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

USCB008225_J_B05_D_B02_1_PCMD_and_Cell_trace_records_during_RNA_Update_in_same_gNB
    [Documentation]    This test case validates the PCMD records reported by gNB-CU-CP and gNB-DU during RNA Update.

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Vm IP and Replace    delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration9757.json    suite_path=${CURDIR}
    ...        AND             Find Scfc And Send Delta Commissioning
    ...                        scfc_filename=delta_Cell_Trace_MDT_PCMD_Configuration9757.json    skip_relation_errors=False
    ...        AND             Remove Vm IP from delta    delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration9757.json    suite_path=${CURDIR}
    ...        AND             Sleep    45s    reason=Wait for delta

    ${dcap_id}=    Dcap Start New Trace
    Sleep    5s

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=5
    Attach UE    ue_id=5
    Establish PDU Session    ue_id=5    gw_id=5
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE
    Perform Parameter Commissioning    parameter=ranAC    value=3    dist_name=MRBTS-1/NRBTS-1/NRCELL-1

    Wait For Timer T380 To Expire
    Verify Traces For Successful RNA Update
    Sleep    5s

    Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Prepare Emil Logs As Json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Merge Json Files

    ${B05_messages}    Create List    "rrcRelease": \{    "suspendConfig": \{    "UEContextReleaseComplete": \{
    ...    "ueDuConnectivityRecord": \{    "gnb-cu-ue-f1ap-Id":    "gnb-du-ue-f1ap-Id":    "NRRRC: RRCResumeRequest1"
    ...    "ueCtxReleaseCmdSndTime": \{    "ueCtxReleaseCmplRcvTime": \{    "ueSetupRecord": \{
    Verify Messages In Json    ${B05_messages}    UTF_logs_all.json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/scfc_after_delta.xml
    ...                           delta_scf_filename=delta_Cell_Trace_MDT_PCMD_Configuration9757.json
    ...           AND             Run Keyword If Test Failed
    ...                           Run Keyword And Ignore Error
    ...                           Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

USCB008225_J_B03_D_E5_1_PCMD_CellTraceRecords_and_MDT_from_gNBCUCP_during_RRC_Inactive_to_RRC_Connected_transition_Fallback_to_RRC_Setup
    [Documentation]    This test case checking the gNB behaviour for handling RRCResumeRequest1 from UE in RRC_INACTIVE state,
    ...                for which the UE Context was not found, or resumeMAC-I not verified, and this leads to fallback to RRCSetup.
    ...                5G_RAN_USR_RRM_18098, 5G_PM_973

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Vm IP and Replace    delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration9757.json    suite_path=${CURDIR}
    ...        AND             Find Scfc And Send Delta Commissioning
    ...                        scfc_filename=delta_Cell_Trace_MDT_PCMD_Configuration9757.json    skip_relation_errors=False
    ...        AND             Remove Vm IP from delta    delta_scf=delta_Cell_Trace_MDT_PCMD_Configuration9757.json    suite_path=${CURDIR}
    ...        AND             Sleep    45s    reason=Wait for delta

    ${dcap_id}=    Dcap Start New Trace
    Sleep    5s

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=3
    Set PDU Param Internal Traffic    ue_id=3
    Attach UE    ue_id=3
    Establish PDU Session    ue_id=3    gw_id=3
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE

    Set Parameters For UE RRC Resume Request With Action    ue_id=3    gnb_id=2    cell_nr=1    msg=resume_request_1
    ...                                                     cause=mt_Access    action=invalid_short_mac_i
    Start Data Traffic    ues=3    direction=dl    pdu=1    throughput=10kbps
    Verify Traces For RRC Setup After Resuming UE
    Sleep    5s

    Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Prepare Emil Logs As Json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Merge Json Files

    ${B03_messages}    Create List    "rrcResumeRequest1": \{
    Verify Messages In Json    ${B03_messages}    UTF_logs_all.json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/scfc_after_delta.xml
    ...                           delta_scf_filename=delta_Cell_Trace_MDT_PCMD_Configuration9757.json
    ...           AND             Run Keyword If Test Failed
    ...                           Run Keyword And Ignore Error
    ...                           Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

USCB008225_J_B07_D_E5_1_PCMD_records_from_gNB_DU_during_RRC_Inactive_to_RRC_Connected_transition_Fallback_to_RRC_Setup
    [Documentation]    This test case validates the PCMD records reported by gNB-DU during RRC_Inactive to
    ...                RRC_Connected transition (Fallback to RRC Setup).

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Vm IP and Replace    delta_scf=delta_Cell_Trace_PCMD_Configuration.json    suite_path=${CURDIR}
    ...        AND             Find Scfc And Send Delta Commissioning
    ...                        scfc_filename=delta_Cell_Trace_PCMD_Configuration.json    skip_relation_errors=False
    ...        AND             Remove Vm IP from delta    delta_scf=delta_Cell_Trace_PCMD_Configuration.json    suite_path=${CURDIR}
    ...        AND             Sleep    45s    reason=Wait for delta

    ${dcap_id}=    Dcap Start New Trace
    Sleep    5s

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=7
    Set PDU Param Internal Traffic    ue_id=7
    Attach UE    ue_id=7
    Establish PDU Session    ue_id=7    gw_id=7
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE

    Set Parameters For UE RRC Resume Request With Action    ue_id=7    gnb_id=2    cell_nr=1    msg=resume_request_1
    ...                                                     cause=mt_Access    action=invalid_short_mac_i
    Start Data Traffic    ues=7    direction=dl    pdu=1    throughput=10kbps
    Verify Traces For RRC Setup After Resuming UE
    Sleep    5s

    Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Prepare Emil Logs As Json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Merge Json Files

    ${B07_messages}    Create List    "rrcResumeRequest1": \{    "rrcSetup": \{    "rrcSetupComplete": \{
    Verify Messages In Json    ${B07_messages}    UTF_logs_all.json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/scfc_after_delta.xml
    ...                           delta_scf_filename=delta_Cell_Trace_PCMD_Configuration.json
    ...           AND             Run Keyword If Test Failed
    ...                           Run Keyword And Ignore Error
    ...                           Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

USCB008225_J_B08_1_PCMD_records_from_gNB_DU_during_RRC_Inactive_to_RRC_Connected_transition_AC_fails_in_gNB_DU
    [Documentation]    This user scenario validates the PCMD records reported by gNB-DU when UE moves from
    ...                RRC_Inactive to RRC_Connected state and AC fails in gNB-DU.

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Vm IP and Replace    delta_scf=delta_Cell_Trace_PCMD_DU_Configuration.json    suite_path=${CURDIR}
    ...        AND             Find Scfc And Send Delta Commissioning
    ...                        scfc_filename=delta_Cell_Trace_PCMD_DU_Configuration.json    skip_relation_errors=False
    ...        AND             Remove Vm IP from delta    delta_scf=delta_Cell_Trace_PCMD_DU_Configuration.json    suite_path=${CURDIR}
    ...        AND             Sleep    45s    reason=Wait for delta

    ${dcap_id}=    Dcap Start New Trace
    Sleep    5s

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=8
    Set Parameters For UE RRC Resume Request    ue_id=8    gnb_id=2    cell_nr=1    msg=resume_request_1    cause=mt_Access
    Set PDU Param Internal Traffic    ue_id=8
    Attach UE    ue_id=8
    Establish PDU Session    ue_id=8    gw_id=8   pdu_id=1
    Wait For Release RRC Inactive Conditions Met
    Perform Parameter Commissioning    parameter=maxNumOfRrcSA    value=0    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    Verify Traces For Successful Transition To RRC INACTIVE
    Sleep    15s

    Start Data Traffic    ues=8    direction=dl    pdu=1    throughput=10kbps
    Verify Tcpdump Log    packet_filter=${RRC_REJECT}
    Sleep    5s

    Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Prepare Emil Logs As Json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Merge Json Files

    ${B08_1_messages}    Create List    "InitialULRRCMessageTransfer": \{    "rrcResumeRequest1": \{    "F1AP: UEContextReleaseCommand"
    ...    "DU: UeCtxSetupTraceRecord"    "result": "miscFailure",    "ueCtxSetupRecord": \{    "rrcReject": \{
    ...    "F1AP: InitialULRRCMessageTransfer"    "gnb-cu-ue-f1ap-Id":    "gnb-du-ue-f1ap-Id":
    Verify Messages In Json    ${B08_1_messages}    UTF_logs_all.json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs

    [Teardown]    Run Keywords    Perform Parameter Commissioning    parameter=maxNumOfRrcSA    value=250    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...           AND             Deregister UE Without Confirmation    ue_id=all
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/scfc_after_delta.xml
    ...                           delta_scf_filename=delta_Cell_Trace_PCMD_DU_Configuration.json
    ...           AND             Run Keyword If Test Failed
    ...                           Run Keyword And Ignore Error
    ...                           Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs

*** Variables ***
${trace_start}=    ng_ue_trace_start id=1 trace_plmn=311:489 trace_ref_id=1 trace_rec_session_ref_id=1
...                ifaces_to_trace=NG-C,Uu,Xn-C,F1-C tce_ip=0.0.0.0 trace_depth=minimum

*** Keywords ***
Start Subscriber Trace
    Execute Egate Command    cmd=${trace_start}

Syslog should contain MDT List message
    [Arguments]      ${MDT_List_string}
    log to console     Verifying MDT List messages in syslog
    ${status}=   run    command=sudo cat ${OUTPUT DIR}/${TEST_NAME}/enb/default_syslog_enbNone.log | grep "${MDT_List_string}"
    Should Contain   ${status}  ${MDT_List_string}

Syslog should NOT contain MDT List message
    [Arguments]      ${MDT_List_string}
    log to console     Verifying MDT List messages in syslog
    ${status}=   run    command=sudo cat ${OUTPUT DIR}/${TEST_NAME}/enb/default_syslog_enbNone.log | grep "${MDT_List_string}"
    Should Not Contain   ${status}  ${MDT_List_string}
