*** Settings ***
Documentation  Script for 12544C
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CRT   RAN_5G_TDD   RAN_5G    SBTS00     CONFIGURED

Resource    resources/Keywords/common_keywords.robot
Resource    resources/Keywords/Testcase_KW.robot
Resource    resources/ute/sosReport.robot

Suite Setup        Updated Suite Setup
#Suite Teardown    Common Suite Teardown

*** Variables  ***
${UE1}        1
${UE2}        2
${Log_Path}   /home/ute/logs
${profile_id}   3


*** Test Cases ***
Make L3 SA call
    Log to Console      Starting the test case\n
    [Setup]     Prepare for test Case_12544C
    Log to Console      Registering UE\n
    UE Register should be Successful for SA     ${UE1}
    wtsrunner.ue_ng_ctx_release     id=${UE1}      cause=NAS_normal_release
    Read WTS Output For Pattern And Print matching Lines    ${12544_ueidle}    ${Timeout_SA}
    wtsrunner.amf_paging_start     id=${UE1}     ueid=${UE1}      nr_paging_edrx_cycle_value=hf1
    sleep    30s
    wtsrunner.ue_disp
    Read WTS Output For Pattern And Print matching Lines    ${12544_ueactive}    ${Timeout_SA}
    Log to Console     Starting log collection\n
##    Collect Logs For The Test   ${Log_Path}
    Log to Console      \n Starting Tear Down for Test Case
#   [Teardown]      Run Keyword And Ignore Error       Common test case tear down




