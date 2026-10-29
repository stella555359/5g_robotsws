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
${TOPOLOGY}           CLOUD_5G_I_LOO_AP_LOOO


*** Test Cases ***
[1][1.0] CB008159_B_15_Verify_counter_for_number_of_ERABs_release_initiated_by_SgNB_with_cause_Radionetwork_tDCoverall_expiry
    [Documentation]      This testcase is used to verify counters for Number SgNB-initiated NSA ERABs released
    ...                  due to TDCoverall guard timer expiration in the SgNB for an X2 message.
    [Tags]    QC_28281   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable    CB008159_B_B12_TC15
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log To Console          Starting the test.....
    Start UTE WTS      basic_setup_tmo.cfg
    Basic Bring Up
    slog.Start Syslog  ${Log_Path}     SysLogCapB15.LOG
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

[1][1.0] CB008159_G_55_Verify_counters_current_no_of_PSCell_UEs_with_0_configured_SCell_in_DL_and_UL_update_when_sgNB_addition_happen_without_Scell
    [Documentation]    the Testcase is to validate the counters introduced in CB008159
    [Tags]    QC_28287   QCD_MN_RAN    QCP_RAN_VRF
    ${Test_CaseNumber}     Set Variable    CB008159_G_TC55
    Link SCOUT SCF to Configuration ID for Reporting
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Log To Console          Starting the test.....
    slog.Start Syslog       ${Log_Path}     SysLogCapG55.LOG
    Wait Coam Site To Be Ready
    Start UTE WTS      basic_setup_tmo.cfg
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

[1][1.0] CB008159_F_50_Verify_counter_for_number_of_ERABs_that_are_failed_to_setup_in_SgNB_via_SgNB_Addition_due_to_cause_Radionetwork_unspecified
    [Documentation]      This testcase is used to verify counters for Number of NSA E-RABs setup fails
    ...                  due to radio network unspecified.
    [Tags]    QC_28288   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Run Keywords     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND     GNB Delta Commission    ${DELTA_DIR}/Delta_Configuration_CB008159_F_B12_B22_TC50_TC52_TC54.json
    ...     AND     Start UTE WTS           basic_setup_tmo.cfg
    ${Log_Path}     Create Log Directory    CB008159_F50
    Log To Console       Starting the test.....
    Basic Bring Up
    slog.Start Syslog    ${Log_Path}     SysLogCapF50.LOG
    Wait For Next Full Pm Interval
    LTE Attach Should Be Successful For NSA     101
    wtsrunner.ENB UE DC Start       target_gnb=2        target_cells=1      ue=101
    ...      bearer=2,3     type=split_scg
    Sleep   5s
    UE Detach Should Be Successful For NSA      101
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55112C06024   2     NX2CC_RAB_SETUP_FL_RN_UNSPC
    ...     M55112C06029   2     NX2CC_RAB_SETUP_FL_TOT
    ...     M55112C06030   2     NX2CC_RAB_SETUP_FL_INIT
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    GNB Delta Commission    ${DELTA_DIR}/Delta_Configuration_CB008159_F_B12_B22_TC50_TC52_TC54_reverse.json
    [Teardown]    Run Keyword And Ignore Error    Common Test Teardown For 8159
