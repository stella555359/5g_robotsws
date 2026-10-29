*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Jenish
...             :contact  : jenish.valan@nokia.com
...             The aim of the feature is to validate the counters introduced in CB008159
...             for analysing network performance.

Resource    resources/Keywords/8159_keyword.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${DELTA_DIR}          ${CURDIR}/config/scf
${SAUE_ID}            1
${UE_ID}              1

*** Test Cases ***
[1][1.0] CB008159_B_15_Verify_counter_for_number_of_ERABs_release_initiated_by_SgNB_with_cause_Radionetwork_tDCoverall_expiry
    [Documentation]      This testcase is used to verify counters for Number SgNB-initiated NSA ERABs released
    ...                  due to TDCoverall guard timer expiration in the SgNB for an X2 message.
    [Tags]    QC_28281   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable    CB008159_B_B12_TC15
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log To Console          Starting the test.....
    Start UTE WTS      basic_setup.cfg
    Basic Bring Up
    Wait For Next Full Pm Interval
    LTE Attach Should Be Successful For NSA     101
    Force MeNB To Not Send SGNBReconfigurationComplete Upon Receiving SGNBAdditionRequestAcknowledge From SGNB    1
    Verify SGnb Addition Failed With Cause TDCoverallexpiry      101   1
    UE Detach Should Be Successful For NSA      101
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55112C06020   1     NX2CC_RAB_REL_TDCOV_EXP_SGNB
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Run Keyword And Ignore Error    Common Test Teardown For 8159

[1][1.0] CB008159_C_31_Verify_counter_for_no_of_InSession_QoSFlows_release_by_AMF_via_UEContextReleaseCommand_cause_RN_radio_connnection_with_UE_lost
    [Documentation]    CB008159 TC C_B12_TC31
    [Tags]    QC_28284   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable     CB008159_C_TC31
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}        Create Log Directory    ${Test_CaseNumber}
    Log To Console     Starting the test.....
    Start UTE WTS      basic_setup.cfg
    Basic Bring Up
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
    [Setup]      Run Keywords     Create Basic Interface On UTE
    ...     AND     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND     GNB Delta Commission     ${DELTA_DIR}/Delta_Configuration_CB008159_D_B1_TC45.json
    ...     AND     Start UTE WTS      basic_setup_CB008159_D_B1_TC45.cfg
    ${Test_CaseNumber}     Set Variable     CB008159_D_B1_TC45
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log To Console          Starting the test.....
    Basic Bring Up
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
    ...     AND     GNB Delta Commission     ${DELTA_DIR}/Delta_Configuration_CB008159_D_B1_TC45_reverse.json

[1][1.0] CB008159_E_46_Verify_counter_no_of_time_RA_is_successful_and_contention_is_resolved_for_UE_performing_CBRA_for_initial_access_during_SA_call
    [Documentation]    the TestCase is to validate the counters introduced in CB008159
    [Tags]    QC_28286   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable    CB008159_E_TC46
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log To Console          Starting the test.....
    Start UTE WTS      basic_setup.cfg
    Basic Bring Up
    Wait For Next Full Pm Interval
    Make SA Call    ${UE_ID}    ${gw_ID}
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55306C09015   1     RA_CB_CONT_RESOLVED_ALL
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Run Keyword And Ignore Error    Common Test Teardown For 8159

[1][1.0] CB008159_F_50_Verify_counter_for_number_of_ERABs_that_are_failed_to_setup_in_SgNB_via_SgNB_Addition_due_to_cause_Radionetwork_unspecified
    [Documentation]      This testcase is used to verify counters for Number of NSA E-RABs setup fails
    ...                  due to radio network unspecified.
    [Tags]    QC_28288   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]         Run Keywords    Link SCOUT SCF to Configuration ID for Reporting
    ...     AND     GNB Delta Commission    ${DELTA_DIR}/Delta_Configuration_CB008159_F_B12_B22_TC50_TC52_TC54.json
    ...     AND     Start UTE WTS      basic_setup_CB008159_F_B12_B22_TC50_TC52_TC54.cfg
    Log To Console          Starting the test.....
    Basic Bring Up
    Wait For Next Full Pm Interval
    LTE Attach Should Be Successful For NSA     101
    Trigger ENDC Connection For Multiple Non-GBR Bearers And Verify SgNB Rejecting It With Cause RadioNetwork Unspecified      101   1
    UE Detach Should Be Successful For NSA      101
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55112C06024   2     NX2CC_RAB_SETUP_FL_RN_UNSPC
    ...     M55112C06029   2     NX2CC_RAB_SETUP_FL_TOT
    ...     M55112C06030   2     NX2CC_RAB_SETUP_FL_INIT
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

[1][1.0] CB008159_F_52_Verify_counter_for_number_of_ERABs_that_are_failed_to_setup_in_SgNB_due_to_any_cause_ERABs_setup_attempted_via_SgNB_Addition
    [Documentation]      This testcase is used to verify counters for total number of NSA E-RABs
    ...                  that failed to set updue to any failure.
    Log To Console          Starting the test.....
    Link SCOUT SCF to Configuration ID for Reporting
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55112C06029   2     NX2CC_RAB_SETUP_FL_TOT
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

[1][1.0] CB008159_F_54_Verify_counter_for_number_of_Initial_ERABs_failed_to_setup_in_SgNB_due_to_any_cause_ERABs_setup_attempted_via_SgNB_Addition
    [Documentation]      This testcase is used to verify counters for total number of initial
    ...                  NSA E-RABs that failed to set up due to any failure.
    ${Test_CaseNumber}     Set Variable    CB008159_F_B22_TC50_TC52_TC54
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log To Console          Starting the test.....
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55112C06030   2     NX2CC_RAB_SETUP_FL_INIT
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Run Keyword And Ignore Error    Common Test Teardown For 8159

[1][1.0] CB008159_G_55_Verify_counters_current_no_of_PSCell_UEs_with_0_configured_SCell_in_DL_and_UL_update_when_sgNB_addition_happen_without_Scell
    [Documentation]    the Testcase is to validate the counters introduced in CB008159
    [Tags]    QC_28287   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable    CB008159_G_TC55
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log To Console          Starting the test.....
    Wait Coam Site To Be Ready
    Start UTE WTS      basic_setup.cfg
    Basic Bring Up
    Wait For Next Full Pm Interval
    LTE Attach Should Be Successful For NSA     101
    UE Attach Should Be Successful For NSA      101    1
    Sleep    30s
    UE Detach Should Be Successful For NSA      101
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55118C04014   >0     UE_PSCELL_0_CONF_SCELL_DL
    ...     M55118C04015   >0     UE_PSCELL_0_CONF_SCELL_UL
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Run Keyword And Ignore Error    Common Test Teardown For 8159
