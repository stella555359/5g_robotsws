*** Settings ***
Documentation     author: Wu Pengliang
...               contact: pengliang.wu@nokia.com

Suite Setup       CB014474_168_Suit_Setup
Suite Teardown    robot_common_operations.Common Suite Teardown

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ./resources/CB014474_FDD_common_keywords.robot



*** Test Cases ***
[1]CB014474-SR-A_27_Switching 1 BWP1 user to dynamically RAT0 and 1 BWP1 user RAT1 with 3 dedicated BWPs FDD
    [Documentation]    This case verify Dynamic UE switch dynamic RAT0 in large BWP in case 3 dedicated BWPs for FDD
    [Tags]    26R2    Trunk
    [Setup]    Common Case Setup    allowed_faults_ids=7311
    Set Suite Variable    ${case_log}    ${OUTPUT_DIR}/CB014474-SR-A_27_check_large_BWP_with_3_dedicated_BWP
    Create Directory    ${case_log}/
    MTP Dyn UE L3 Call and Start Traffic    dl_tput=300Mbits/sec
    Spark Non-Dyn UE L3 Call and Start Traffic    ue1_dl_tput=10Mbits/sec    ue2_dl_tput=50Mbits/sec
    Check DL Throught From Asslog    dl_tp=365
    ${csv_file_path}    Capture TTI log    tti_log=${case_log}    filter=${EMPTY}    log_time=3
    Check TTI Trace    dl_tti_path=${csv_file_path}[DL]    target_prb_count=${106}    prb_ratio=${0.89}
    [Teardown]    Run Keywords    All UE Stop traffic and detach    if_M90=${False}
    ...           AND             CB014474_168_Case_Teardown


[1]CB014474-SR-A_45_Check different BWP dynamic Ues with full buffer load status with multiple dedicated BWPs FDD
    [Documentation]    This case verify Dynamic UE switch dynamic RAT0 in small BWP in case 3 dedicated BWPs for FDD
    [Tags]    26R2    Trunk
    [Setup]    Common Case Setup    allowed_faults_ids=7311
    Set Suite Variable    ${case_log}    ${OUTPUT_DIR}/CB014474-SR-A_45_check_small_BWP_with_3_dedicated_BWP
    Create Directory    ${case_log}/
    M90 Dyn 10M UE L3 Call and Start Traffic    dl_tput=180Mbits/sec
    Spark Non-Dyn UE L3 Call and Start Traffic    ue1_dl_tput=10Mbits/sec    ue2_dl_tput=200Mbits/sec
    Check DL Throught From Asslog    dl_tp=365
    ${csv_file_path}    Capture TTI log    tti_log=${case_log}    filter=${EMPTY}    log_time=3
    Check TTI Trace    dl_tti_path=${csv_file_path}[DL]    target_prb_count=${106}    prb_ratio=${0.87}
    [Teardown]    Run Keywords    All UE Stop traffic and detach    if_MTP=${False}
    ...           AND             CB014474_168_Case_Teardown