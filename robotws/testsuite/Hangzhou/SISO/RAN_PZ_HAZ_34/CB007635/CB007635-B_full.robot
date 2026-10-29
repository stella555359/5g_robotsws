# *** Settings ***
# Documentation     author: yan meng
# ...               contact: meng.yan@nokia-sbell.com
# ...               squad group: MMW_02
# Suite Setup       SISO Coam Suite Setup for CLOUD UTE    enb_flag=${False}
# Suite Teardown    SISO Coam Suite Teardown
# Force Tags                5G_RAN    5G_RAN_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASOE_2xAEWD_ENB    master_pDU
# ...   PY39
# ...               RAN_5G    RAN_5G_TDD
# 
# Resource          ./resources/CB007635_B_resource.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# 
# 
# 
# 
# *** Variables ***
# ${du_scf_name}    SCF_SBTS00.xml
# ${ultp}    120M
# ${dltp}    600M
# ${fail_count1}    0
# ${fail_count2}    0
# ${loop_num}    10
# ${MAX_START_TIME}    390
# ${MAX_BBMOD_START_TIME}    240
# ${UE_NUMBER}    2
# ${exp_ul}    103.5
# ${exp_dl}    537.3
# 
# *** Test Cases ***
# [1][1.0]CB007635_B_01_gNB_comissioned_to_On_Air_full
#     [Documentation]    check commission scf success
#     [Tags]    CIT_20B    CRT   21B_pDU
#     [Setup]    SISO Coam Test Setup
#     sleep    10s
#     [Teardown]    SISO Coam Test Teardown
# 
# [1][1.0]CB007635_B_06_KPI_site_Reset_full
#     [Documentation]    check the time from site reset to on air status
#     [Tags]    CIT_20B    CRT    21B_pDU
#     [Setup]      SISO Coam Test Setup
#     Login via Web
#     selenium_coam.reset_site
#     ${time1}=    Get Time    epoch
#     #sleep    1min
#     #Wait_all_Cells_onair_cloud_Coam
#     Wait Until Keyword Succeeds    10min    20s    Verify all cells should be onair
#     ${time2}=    Get Time    epoch
#     should be true    ${time2}-${time1} < ${MAX_START_TIME}
#     sleep    600s
#     [Teardown]    SISO Coam Test Teardown
# 
# 
# [1][1.0]CB007635_B_03_stability_KPI_testing_full
#     [Documentation]    check l3 call stability in 15 min
#     [Tags]    CIT_20B    CRT    21B_pDU
#     [Setup]    SISO Coam Test Setup
#     ${list_of_cell_ids0}    Create List    2605058
# 	${list_of_cell_ids1}    Create List    2605057
#     FOR    ${ue_index}    IN RANGE    ${UE_NUMBER}
#         step1: Prepare UE    ue_index=${ue_index}
#         Step2: UE Attach    ue_index=${ue_index}
#         Step3: Start traffic    ul_throughput=${ultp}    dl_throughput=${dltp}    ue_index=${ue_index}
#         ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=15m
#         ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids${ue_index}}
#         ...    ultarget_throughput=${exp_ul}    dltarget_throughput=${exp_dl}
#         ...    target_avg_percent=1
#         Set Test Variable    ${all_tp}    ${all_tp}
#         Run keyword and continue on failure    should be true    ${all_tp[1][0]['average']}>=${exp_dl}
#         Run keyword and continue on failure    should be true    ${all_tp[0][0]['average']}>=${exp_ul}
#         Run Keyword And Ignore Error    BOTH TPUT Upload
#         ...             exp_dl=${dltp} Mbits/sec
#         ...             dl_avg=${all_tp[1][0]['average']} Mbits/sec
#         ...             dl_max=${all_tp[1][0]['peak']} Mbits/sec
#         ...             dl_min=${all_tp[1][0]['minimum']} Mbits/sec
#         ...             exp_ul=${ultp} Mbits/sec
#         ...             ul_avg=${all_tp[0][0]['average']} Mbits/sec
#         ...             ul_max=${all_tp[0][0]['peak']} Mbits/sec
#         ...             ul_min=${all_tp[0][0]['minimum']} Mbits/sec
#         ...             protocol=udp
#         ...             deviation=0%
#     END
#     [Teardown]    Common Test Teardown
# 
# [1][1.0]CB007635_B_05_KPI_L3_call_full
#     [Documentation]    check attach successfully 8 out of 10
#     [Tags]    CIT_20B    CRT    21B_pDU
#     [Setup]    SISO Coam Test Setup
# 
#     FOR    ${count}    IN RANGE    ${loop_num}
#         Run Keyword And Ignore Error    step1: Prepare UE    ue_index=${0}
#         ${status}    ${error}    Run Keyword And Ignore Error    Step2: UE Attach    ue_index=${0}
#         Run Keyword If    '${status}'!='PASS'
#         ...    interger calculate coam    input_number=${fail_count1}
#         Run Keyword And Ignore Error    Step7: UE Detach    ue_index=${0}
#         exit for loop if    ${fail_count1} > 2
#     END
#     log    ${fail_count1}
# 
#     FOR    ${count}    IN RANGE    ${loop_num}
#         Run Keyword And Ignore Error    step1: Prepare UE    ue_index=${1}
#         ${status}    ${error}    Run Keyword And Ignore Error    Step2: UE Attach    ue_index=${1}
#         Run Keyword If    '${status}'!='PASS'
#         ...    interger calculate coam    input_number=${fail_count2}
#         Run Keyword And Ignore Error    Step7: UE Detach    ue_index=${1}
#         exit for loop if    ${fail_count2} > 2
#     END
#     log    ${fail_count2}
#     Should Be True    ${fail_count1} < 2
#     Should Be True    ${fail_count2} < 2
#     [Teardown]    SISO Coam Test Teardown
# 
# 
# *** Keywords ***
# Common Test Teardown
#     Case_Teardown    ue_number=${UE_NUMBER}
#     SISO Coam Test Teardown
