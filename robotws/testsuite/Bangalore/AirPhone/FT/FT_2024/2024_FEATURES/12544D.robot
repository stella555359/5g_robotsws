*** Settings ***
Documentation  Script for feature 12544D
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
    [Setup]     Prepare for test Case_12544D
    wtsrunner.amf_ue_ics_param    id=${UE1}     ue=all     core_network_assistance_info=on
    ...     ue_identity_index_value=1    ue_specific_drx=256    periodic_registration_update_timer=1:10min
    ...         plmn_id=311:489    tac_id=200      nr_paging_edrx_cycle=hf1
    Log to Console      Registering UE\n
    UE Register should be Successful for SA     ${UE1}
    sleep    65s
    Read WTS Output For Pattern And Print matching Lines    ${12544_ueinactive}    ${Timeout_SA}
    Start and Validate Traffic For SA       UE_ID=${UE1}
    Read WTS Output For Pattern And Print matching Lines    ${12544_resumecomplete}     ${Timeout_SA}
    Log to Console     Starting log collection\n
##    Collect Logs For The Test   ${Log_Path}
    Log to Console      \n Starting Tear Down for Test Case
#   [Teardown]      Run Keyword And Ignore Error       Common test case tear down
