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


*** Test Cases ***
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
