*** Settings ***
Force Tags    CLOUD_5G_I_BOO_AP_LOO    SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC   CONFIGURED    RAN_5G_TDD    RAN_5G
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Marcin Plawny, Andrei Maria, Dan Moldovan
...              :maintainer: marcin.plawny@nokia.com

Library    testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/dcap/utf_installer.py
Library    CB008225_Keywords.py
Resource    CB008225_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_B08_2.json    skip_relation_errors=False
...            AND             Set VM IP
...            AND             Install Latest UTF
...            AND             Check Radios Availability
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../scfc_after_delta.xml
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs
...               AND            Dcap Teardown
...               AND            Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/../initial_commissioning.xml
...                              delta_scf_filename=delta_B08_2.json

*** Test Cases ***
USCB008225_J_B08_2_PCMD_records_from_gNB_DU_during_RRC_Inactive_to_RRC_Connected_transition_Admission_Control_fail_in_gNB_CU_CP
    [Documentation]    This user scenario validates the PCMD records reported by gNB-DU when UE moves from
    ...                RRC_Inactive to RRC_Connected state and AC fails in gNB-CU-CP.

    [Setup]    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...        AND             Get Vm IP and Replace    delta_scf=delta_Cell_Trace_PCMD_DU_Configuration.json    suite_path=${CURDIR}
    ...        AND             Find Scfc And Send Delta Commissioning
    ...                        scfc_filename=delta_Cell_Trace_PCMD_DU_Configuration.json    skip_relation_errors=False
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup.cfg
    ...        AND             Setup Dcap
    ...        AND             Sleep    10s
    ...        AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../scfc_after_delta1.xml

    ${dcap_id}=    Dcap Start New Trace
    Sleep    15s

    Set Core Network Assistance Information For RRC Inactive State In Initial Context Setup Request    ue_id=5
    Set Parameters For UE RRC Resume Request    ue_id=5    gnb_id=2    cell_nr=6    msg=resume_request_1    cause=mo_Data
    Attach UE    ue_id=5
    Establish PDU Session    ue_id=5    gw_id=5    pdu_id=1
    Wait For Release RRC Inactive Conditions Met
    Verify Traces For Successful Transition To RRC INACTIVE
    Send UE RRC Resume Request    ue_id=5
    Sleep    5s

    Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Verify Tcpdump Log    packet_filter=${RRC_REJECT}
    Prepare Emil Logs As Json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    Merge Json Files

    ${B08_2_messages}    Create List    "InitialULRRCMessageTransfer": \{    "rrcResumeRequest1": \{    "F1AP: UEContextReleaseCommand"
    ...    "DU: UeCtxSetupTraceRecord"    "result": "miscFailure",    "ueCtxSetupRecord": \{    "rrcReject": \{
    ...    "F1AP: InitialULRRCMessageTransfer"    "ssbSubcarrierSpacing": "kHz30"
    Verify Messages In Json    ${B08_2_messages}    UTF_logs_all.json    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs

    [Teardown]    Run Keywords    Deregister UE Without Confirmation    ue_id=all
    ...           AND             Add Scout Scf Id To Test Data
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...           AND             Remove Vm IP from delta    delta_scf=delta_Cell_Trace_PCMD_DU_Configuration.json    suite_path=${CURDIR}
    ...           AND             Roll Delta Back    initial_scf_filename=${OUTPUT_DIR}/../scfc_after_delta.xml
    ...                           delta_scf_filename=delta_Cell_Trace_PCMD_DU_Configuration.json
    ...           AND             Run Keyword If Test Failed
    ...                           Run Keyword And Ignore Error
    ...                           Dcap Stop Trace And Download Logs    ${dcap_id}    ${OUTPUT_DIR}/${TEST_NAME}_UTF_logs
    ...           AND             Run Keyword If Test Passed    Find Suspicious Logs
