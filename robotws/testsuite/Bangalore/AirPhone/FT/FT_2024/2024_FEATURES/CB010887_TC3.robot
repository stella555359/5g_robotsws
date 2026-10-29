*** Settings ***
Documentation  Script for feature CB010887
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


*** Test Cases ***
Make L3 SA call
    Log to Console      Starting the test case\n
    [Setup]     Prepare for test Case CB010887
    wtsrunner.ul_mimo_srs_beam_pos_nr    profile_id=1    mode=fixed    init_quad_pos=1    init_sub_quad_pos=1
    ...   test_type=SRS multi_path_config=true    num_of_nlos_paths=1    azimuth=0    zenith=0
    ...      srs_transmit_power_per_port=-550,-550,-550,-550
    wtsrunner.ue_testmode_set_nr    id=1    testmode=ul_mimo_srs_beam_pos    action=activate profile_id=1
    Log to Console      Registering UE\n
    UE Register should be Successful for SA_CB010887_TC3     ${UE1}
    Start and Validate Traffic For SA       UE_ID=${UE1}
    Stop Data Traffic for SA    ${UE1}
    sleep    30s
    Log to Console     Starting log collection\n
    Collect Logs For The Test   ${Log_Path}
    Log to Console      \n Starting Tear Down for Test Case
#   [Teardown]      Run Keyword And Ignore Error       Common test case tear down




