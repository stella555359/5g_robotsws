*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation   :copyright: Nokia
...             :author   : rfch37
...             :contact  : anandapriya.mani@nokia.com
...             The aim of the feature is to validate the counters introduced in CB008159
...             for analysing network performance.

Resource    resources/Keywords/8159_keyword.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Test Cases ***
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
