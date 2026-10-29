# *** Settings ***
# Documentation
# Resource   ./../Resources/CB009787_keywords.robot
# 
# Suite Setup        9787 Suite preparation
# Suite Teardown     run keyword and ignore error    Common suite recovery
# 
# *** Variables ***
# ${DURATION_OF_TRAFFIC}        3000
# ${DURATION_OF_TPUT_CHECK}     1min
# ${PERCENT_TARGET_AVG}         0.95
# ${PERCENT_TARGET_MIN}         0.85
# 
# *** Test Cases ***
# General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Documentation]    Author: Cui Lingxue
#     [Setup]    9787 Case Setup    if_commission_needed=${False}
#     set test variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
#     General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Teardown]    run keyword and ignore error    Common case teardown    detach_ue=${False}    is_btslog_required=${false}
# 
# General_SiSo_E2E_system_setup_with_data_transfer_conducted_NROnly
#     [Documentation]    Author: Cui Lingxue
#     [Setup]    9787 Case Setup    if_commission_needed=${False}
#     Step 1: UE attach, start UL traffic and verify
#     Step 2: Stop UL traffic, start DL traffic and verify
#     Step 3: Start UL traffic and verify bi-direction traffic
#     [Teardown]   run keyword and ignore error    Common case teardown    detach_ue=${True}    is_btslog_required=${false}
# 
# *** Keywords ***
# Step 1: UE attach, start UL traffic and verify
#     [Arguments]    ${prepare_ue_needed}=${True}    ${4G_check}=${False}    ${iperf_ul_tput}=200M    ${exp_ul}=100
#     ...    ${customized_log_name}=9787_NR_Only_peak    ${cell_index}=1
# 
#     log to console    Step 1: UE attach, start UL traffic and verify
#     Retry commercial ue attach if failed
#     ...    prepare_ue_needed=${prepare_ue_needed}    4G_check=${4G_check}
#     Start data transfer based on direction    data_transfer_direction=ul    ul_tput=${iperf_ul_tput}    duration=${DURATION_OF_TRAFFIC}
#     ...    dl_tput=1M
#     ${tput_log_path}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    filter=L2Lo    check_source=Aasyslog
#     run keyword and continue on failure    check tput via power ue optimized
#     ...    cell_index=${cell_index}    direction=ul
#     ...    tput_log_path=${tput_log_path}
#     ...    exp_ul=${exp_ul}    target_avg_percent=${PERCENT_TARGET_AVG}    min_percent=${PERCENT_TARGET_MIN}
#     ...    customized_log_name=${customized_log_name}_ul
# 
# Step 2: Stop UL traffic, start DL traffic and verify
#     [Arguments]    ${iperf_dl_tput}=500M    ${exp_dl}=400
#     ...    ${customized_log_name}=9787_NR_Only_peak    ${cell_index}=1
#     log to console    Step 2: Stop UL traffic, start DL traffic and verify
#     Stop data transfer based on direction    data_transfer_direction=ul
# 
#     start data transfer based on direction    data_transfer_direction=dl    dl_tput=${iperf_dl_tput}    duration=${DURATION_OF_TRAFFIC}
#     ...    ul_tput=1M
#     ${tput_log_path}    power_ue.collect tput    ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    filter=L2Lo    check_source=Aasyslog
#     run keyword and continue on failure    check tput via power ue optimized
#     ...    cell_index=${cell_index}    direction=dl
#     ...    tput_log_path=${tput_log_path}
#     ...    exp_dl=${exp_dl}    target_avg_percent=${PERCENT_TARGET_AVG}    min_percent=${PERCENT_TARGET_MIN}
#     ...    customized_log_name=${customized_log_name}_dl
# 
# Step 3: Start UL traffic and verify bi-direction traffic
#     [Arguments]    ${iperf_ul_tput}=200M    ${exp_ul}=100    ${exp_dl}=400
#     ...    ${customized_log_name}=9787_NR_Only_peak    ${cell_index}=1
#     log to console    Step 3: Start UL traffic and verify bi-direction traffic
#     start data transfer based on direction    data_transfer_direction=ul    ul_tput=${iperf_ul_tput}    duration=${DURATION_OF_TRAFFIC}
#     ...    dl_tput=1M
#     ${tput_log_path}    power_ue.collect tput     ue_type=${UE_TYPE}    duration=${DURATION_OF_TPUT_CHECK}    filter=L2Lo    check_source=Aasyslog
#     run keyword and continue on failure    check tput via power ue optimized
#     ...    cell_index=${cell_index}    direction=both
#     ...    tput_log_path=${tput_log_path}
#     ...    exp_ul=${exp_ul}    exp_dl=${exp_dl}    target_avg_percent=${PERCENT_TARGET_AVG}    min_percent=${PERCENT_TARGET_MIN}
#     ...    customized_log_name=${customized_log_name}_both
