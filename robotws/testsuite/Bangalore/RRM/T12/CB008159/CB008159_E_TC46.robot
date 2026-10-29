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


*** Variables ***
${SA_UEID}        1


*** Test Cases ***
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


*** Keywords ***
Make SA Call
    [Documentation]    This Keyword is for L3 call for specific to this TestCase.
    [Arguments]    ${SAUE_ID}=${SAUE_ID}    ${gw_ID}=${gw_ID}
    Enable Internal TG   1  1
    Sleep   20s
    wtsrunner.Ue Register   id=${SAUE_ID}
    Sleep   30s
    wtsrunner.Ue Pdu Session Setup    pdu=${Pdu_session_ID}    ue=${UE_ID}
    ...       nwslice=${nwslice_ID}    gw=${gw_ID}
    Sleep   30s
