*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Jenish
...             :contact  : jenish.valan@nokia.com
...             The aim of the feature is to validate the counters introduced in CB008159
...             for analysing network performance.

Resource    resources/Keywords/8159_keyword.robot

Suite Setup       Run Keywords       Updated Suite Setup
...     AND       GNB Delta Commission     ${DELTA_DIR}/Delta_SRB_Inactivity.json
...     AND       Update BSR Package For RJIO
Suite Teardown    Common Suite Teardown


*** Variables ***
${DELTA_DIR}          ${CURDIR}/config/scf
${SAUE_ID}            1
${UE_ID}              1
${TOPOLOGY}           CLOUD_5G_O_E_AP_LOOO


*** Test Cases ***
[1][1.0] CB008159_C_31_Verify_counter_for_no_of_InSession_QoSFlows_release_by_AMF_via_UEContextReleaseCommand_cause_RN_radio_connnection_with_UE_lost
    [Documentation]    CB008159 TC C_B12_TC31
    [Tags]    QC_28284   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable     CB008159_C_TC31
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}        Create Log Directory    ${Test_CaseNumber}
    Log To Console     Starting the test.....
    Start UTE WTS      basic_setup_rjio.cfg
    NG Link Should Be UP
    Sleep   60s
    slog.Start Syslog  ${Log_Path}     SysLogCapC31.LOG
    Wait For Next Full Pm Interval
    Make SA Call    ${SAUE_ID}    ${gw_ID}
    Traffic Should Be Successful For SA    5    2    ${SAUE_ID}
    Radio Connection Ue Lost By AMF    ${SAUE_ID}
    UE Deregister Should Be Successful For SA
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55125C09027   1     NG_FLOW_REL_AMF_UE_LOST_INSESN
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Run Keyword And Ignore Error    Common Test Teardown For 8159

[1][1.0] CB008159_D_45_Verify_counter_for_VoNR_QoS_flow_setup_timer_measurement_when_VoNR_is_setup_via_NGAP_PDU_RESOURCE_MODIFY_REQUEST
    [Documentation]      This testcase is used to make VoNR  call using  NGAP: PDU RESOURCE MODIFY REQUEST
    ...                  and verify the counters for Time to setup 5QI1 QosFlow in a measurement period
    ...                  and Maximum time to setup 5QI1 QosFlow in a measurement period.
    [Tags]    QC_28283   QCD_MN_RAN    QCP_RAN_VRF
    Link SCOUT SCF to Configuration ID for Reporting
    Start UTE WTS      basic_setup_rjio.cfg
    ${Test_CaseNumber}     Set Variable     CB008159_D_B1_TC45
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log To Console          Starting the test.....
    NG Link Should Be UP
    Sleep   60s
    slog.Start Syslog  ${Log_Path}     SysLogCapD45.LOG
    Wait For Next Full Pm Interval
    Register And Establish GBR And Non-GBR Calls
    Stop Data Traffic For SA    ${UE_ID}
    UE Deregister Should Be Successful For SA
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55125C09030    >0     NG_FLOW_SETUP_TIME_5QI1
    ...     M55125C09031    >0     NG_FLOW_SETUP_TIME_MAX_5QI1
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Run Keywords     Common Test Teardown For 8159

[1][1.0] CB008159_E_46_Verify_counter_no_of_time_RA_is_successful_and_contention_is_resolved_for_UE_performing_CBRA_for_initial_access_during_SA_call
    [Documentation]    the TestCase is to validate the counters introduced in CB008159
    [Tags]    QC_28286   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable    CB008159_E_TC46
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log To Console          Starting the test.....
    Start UTE WTS      basic_setup_rjio.cfg
    NG Link Should Be UP
    Sleep   60s
    slog.Start Syslog  ${Log_Path}     SysLogCapE46.LOG
    Wait For Next Full Pm Interval
    Make SA Call    ${UE_ID}    ${gw_ID}
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55306C09015   1     RA_CB_CONT_RESOLVED_ALL
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Run Keyword And Ignore Error    Common Test Teardown For 8159
