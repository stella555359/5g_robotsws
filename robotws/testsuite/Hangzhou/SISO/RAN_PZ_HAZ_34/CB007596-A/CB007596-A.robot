# *** Settings ***
# Documentation     author: zhao nana
# ...               contact: nana.zhao@nokia-sbell.com
# ...               squad group: MMW_02
# Suite Setup        robot_common_operations.Common Suite Setup
# Suite Teardown    Suite_CB007596_Teardown
# Force Tags                5G_RAN    5G_RAN_TDD    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_ANDROID_ASOD_AEUB_ENB    master_pDU
# ...    PY36
# ...               RAN_5G    RAN_5G_TDD
# 
# Resource          ./resources/CB007596_A_resource.robot
# 
# 
# 
# 
# *** Variables ***
# ${du_scf_name}    SCF_SBTS22R4.xml
# ${ultp}    100M
# ${dltp}    50M
# ${exp_ul}    10
# ${exp_dl}    10
# ${fail_count}    0
# ${loop_num}    10
# 
# ${UE_NUMBER}    1
# *** Test Cases ***
# [1]CB007596_A_1_CB007596_A_01_gNB_comissioned_to_On_air_restricted
#     [Documentation]    check commission scf success
#     [Tags]    CIT_20B    CRT_UTE    21B_pDU
#     [Setup]    Case Common Setup
#     Commission_DU    du_scf_name=${du_scf_name}
#     [Teardown]    Case Common Teardown
# 
# [1]CB007596_A_09_KPI_L3_call_restricted
#     [Documentation]    check attach successfully 8 out of 10 
#     [Tags]    CIT_20B    CRT_UTE    21B_pDU
#     [Setup]    Case Common Setup
#     
#     FOR    ${count}    IN RANGE    ${loop_num}
#         Run Keyword And Ignore Error    step1: Prepare UE    ue_index=${0}
#         ${status}    ${error}    Run Keyword And Ignore Error    Step2: UE Attach    ue_index=${0}
#         Run Keyword If    '${status}'!='PASS'
#         ...    interger calculate coam    input_number=${fail_count}
#         Run Keyword And Ignore Error    Step7: UE Detach    ue_index=${0}
#         exit for loop if    ${fail_count} >= 2
#     log    ${fail_count}
#     END
#     Should Be True    ${fail_count} < 2
#     [Teardown]    Case Common Teardown
# 
# [1]CB007596_A_5_CB007596_A_05_stability_KPI_testing_restricted
#     [Documentation]    check l3 call stability in 15 min
#     [Tags]    CIT_20B    CRT_UTE    21B_pDU
#     [Setup]    Case Common Setup
#     ${list_of_cell_ids0}    Create List    2162697
#     FOR    ${ue_index}    IN RANGE    ${UE_NUMBER}
#         step1: Prepare UE    ue_index=${0}
#         Step2: UE Attach    ue_index=${0}
#         Step3: Start traffic    ue_index=${0}
#         #${all_tp}    Step4: Check throughput    traffic_time=300s
#         ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=15m
#         ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids${ue_index}}
#         ...    ultarget_throughput=${exp_ul}    dltarget_throughput=${exp_dl}    actCarrierAggregation=${True}
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
#         
#     END
#     [Teardown]    Case_Teardown    ue_number=${UE_NUMBER}
# 
# *** Keywords ***
# Suite_CB007596_Teardown
#     Run Keyword And Ignore Error     Logout via Web
#     robot_common_operations.Common Suite Teardown
