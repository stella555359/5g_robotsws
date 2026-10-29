*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           RAN_5G_TDD   RAN_5G     CONFIGURED

Documentation   :copyright: Nokia
...             :author   : Amitha
...             :contact  : amitha.kadambi@nokia.com
...             The aim of the feature is to validate the counters introduced in CB008033
...             as part of enhancing Handover related counters.

Resource    resources/Keywords/8033_KW.robot

Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${NSA_UEID_11}        11
${A3MEAS_ID}           1


*** Test Cases ***
[1][1.0] CB008033_C#5 Verify counters for a successful intra-gNB Intra DU Pscell change via MeNB for NSA user
    [Documentation]    This is Testcase testing Handover related counters.
    [Tags]    QC_28267   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare For Testcase CB008033 TC5
    Basic Bring Up
    Wait For Next Full Pm Interval
    Make ENDC Call
    Traffic Should Be Successful For NSA    ${NSA_UEID_11}  5   2
    Sleep    30s
    Trigger A3 Measurement For NSA   ${NSA_UEID_11}    ${A3MEAS_ID}            51
    Sleep   30s
    Stop Traffic          ${NSA_UEID_11}            1
    UE 5GDetach Should Be Successful For NSA        11
    UE Detach Should Be Successful For NSA          11
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55179C00001   1     PC_PR_ATT_NSA_NNNRL
    ...     M55179C00002   1     PC_EX_ATT_NSA_NNNRL
    ...     M55179C00003   1     PC_EX_SUC_NSA_NNNRL
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    [Teardown]      Run Keyword And Ignore Error    Teardown For TestCase CB008033 TC5


*** Keywords ***
Make ENDC Call
    [Documentation]     This keyword is TestCase specific Keyword for UE attach.
    LTE Attach Should Be Successful For NSA     11
    UE Attach Should Be Successful For NSA      11   1
