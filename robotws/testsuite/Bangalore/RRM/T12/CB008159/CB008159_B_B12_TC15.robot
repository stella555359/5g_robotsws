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
