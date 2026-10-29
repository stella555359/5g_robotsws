# *** Settings ***
# Resource   ../Resources/5GC001726_keywords.robot
# 
# Documentation    Suite description
# ...   author: Ding Binmei
# ...   contact: binmei.ding@nokia-sbell.com
# ...   squad group: mmW1
# ...   Feature 1726 in 5G19B program
# 
# Force Tags    5G_RRM
# ...    PY36
# 
# Suite Setup    run keywords   Import NIDD variables    AND
# ...    Suite preparation    is_need_to_perform_commision=${True}    1726_scf_parameter=${MODIFY_SCF_COMMON}
# Suite Teardown    Run keyword and ignore error    5GC001726_keywords.Common Suite Teardown
# 
# *** Variables ***
# ${DL_TPUT_HIGN_IPERF}    200M   # Need to be updated based on manual testing
# ${DL_TPUT_MID_IPERF}    150M    # Need to be updated based on manual testing: for case 503
# ${DL_TPUT_LOW_IPERF}    20M   # Need to be updated based on manual testing
# ${UL_TPUT_IPERF}    20M
# ${REPEAT_TIME_FOR_VERIFICATION}    2
# ${UL_TPUT_EXPECT}       19
# 
# *** Test Cases ***
# [1][1.0]5GC001726_GE_502_GNB-8CCDL_2CCUL_maxScell7DL1UL_non-contiguous_UE8DL2UL_1UE_LowThroughput_HighThroughput_LowThroughput
#     [Tags]    CIT_20B    CIT_21A    CIT_21B    CIT_22R1    CRT_22R1    CIT_22R3    CIT_22R4    CDRT_22R3
#     [Documentation]  Author: Ding Binmei
#     ...              Case Description: low ==> high ==> low
#     ...              uplink freq is noncontiguous, thus only one cell is for ul.
#     [Setup]    Test preparation    is_log_required=${True}
#     Switch pcell for attach based on cell index    cell_index_for_attach=${1}
#     Connect to gnb coam via ssl
#     run keyword and continue on failure   Start X2 log capture from eNB    log_name=GE_502
#     Wait until keyword succeeds    2X    10 s    Power ue attach
#     run keyword and continue on failure
#     ...    Start data transfer with high or low throughput and verify behaviours    dl_tput_iperf=20M    expected_dl_tput=${19}
#     Sleep    2s
#     run keyword and continue on failure
#     ...    Start data transfer with high or low throughput and verify behaviours    dl_tput_iperf=200M    expected_dl_tput=${200}
#     Sleep    2s
#     run keyword and continue on failure
#     ...    Start data transfer with high or low throughput and verify behaviours    dl_tput_iperf=20M    expected_dl_tput=${19}
# 
#     [Teardown]    Run keyword and ignore error    Test Case Teardown GE502
# 
# *** Keywords ***
# Test preparation
#     [Documentation]  Author: Ding Binmei
#     ...              Description: Case preparation for updating paremeters based on case level
#     [Arguments]     ${name}=btslog    ${btslog_path}=/opt/btslog/btslog    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
#     ...    ${log_storage_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}    ${is_log_required}=${True}
#     robot_common_operations.Common Case Setup
#     COAM Create log directory
#     _capture log in case setup    is_log_required=${is_log_required}
#     ...    name=${name}    btslog_path=${btslog_path}
#     ...    btslog_launcher_path=${btslog_launcher_path}
#     ...    log_storage_dir=${log_storage_dir}    host=${host}
#     Connect to Common Unit Master    alias=ASIK Master
# #    Connect to Capacity Unit Loner case    alias=ABIL Loner_1
#     Connect to Capacity Unit Slave case
#     Connect to gnb coam via ssl
# 
# Test Case Teardown GE502
#     [Arguments]     ${is_log_required}=${True}
#     run keyword and continue on failure    Stop X2 log capture from eNB    log_name=GE_502
#     Test Case Teardown    is_log_required=${is_log_required}
