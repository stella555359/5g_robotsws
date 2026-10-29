# *** Settings ***
# Documentation    Suite description
# 
# Resource    ../../../SISO/RAN_PZ_HAZ_34/CB007750_A/resources/comm_7750A.robot
# Resource    ../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    ./Resource/sleepcell_keyword.robot
# Resource    ./Resource/sleepingcell_cases.robot
# Library     DateTime
# 
# *** Variables ***
# ${ue0_dl_power_port_list}    ${tl.ues[0].iperf_details.ports[0]}
# ${ue1_dl_power_port_list}    ${tl.ues[1].iperf_details.ports[1]}
# ${ue_type}    ${tl.ues[0].capabilities[-1]}
# ${throughput}     500M
# ${dltarget_tp}    100
# ${tp_during}    9m
# ${check_traffic_time}    ${4000}
# ${ue_index}    ${0}
# ${sync_total_times}    ${3}
# ${round_time}    ${2}
# 
# *** Test Cases ***
# [1]CB007835-5G-A_04_Separately_Capture_snapshot during tracffic
#     [Tags]    Sleep_Cell
#     Run Keyword And Ignore Error    Detach All Ues in Init
#     Check BTS Should Be Normal
#     ${cell_list}    get cell nrCellIdentity
#     ${status}    set variable    ${False}
#     ue attach
#     sleep    20s
#     FOR    ${item}    IN RANGE    ${round_time}
#         Log To Console    Start ${item} times Traffic
#         Separately Capture snapshot during tracffic     cell_list=${cell_list}
#     END
# #    should be true    ${status}
#     [Teardown]    run keywords    run keyword if test failed    collect snapshot    AND    ue teardown
# 
# [1]CB007835-5G-A_05_Separately_switch_sync_master_then_L3call
#     [Tags]    Sleep_Cell
#     Run Keyword And Ignore Error    Detach All Ues in Init
#     FOR    ${item}    IN RANGE    ${sync_total_times}
#         Log to console    start ${item} sync
#         ${status}    run keyword and return status    SYNC_SOURCE_SWITCH_AND_L3call
#         ${cell_list}    get cell nrCellIdentity
#         power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${throughput}    ue_index=${ue_index}
#         ...    duration=500    ue_mode=SA    iperf_port=${ue0_dl_power_port_list}    iperf_type=via_command    process_num=${3}
#         ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    ignore_time=10s
#         ${status1}    run keyword and return status    check all cell tp     log_path=${log_path}    nr_cell_list=${cell_list}
#         run keyword and continue on failure    should be true    ${status}
#         run keyword and continue on failure    should be true    ${status1}
#         run keyword and continue on failure    run keyword if    not ${status}    collect snapshot
#     END
#     [Teardown]    run keywords    run keyword if test failed    collect snapshot    AND    ue teardown
# 
# *** Keywords ***
# ue attach
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
#     Log To Console    UE Attach
#     ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_SA    ue_index=${ue_index}
#     Log To Console    Verify attach
#     power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    5Grach_ed=${5Grach_ed_0}    4G_check=False
# 
# ue teardown
#     Log To Console    Stop traffic
#     run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
#     ...    iperf_port=${ue${ue_index}_dl_power_port_list}    ue_mode=SA
#     Log To Console    UE Detach
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
#     CI_interface.Common Case Teardown
# 
# get cell nrCellIdentity
#     Connect to gnb coam via ssl
#     ${nrcell_info}     get_relation_mapping_between_cell_index_and_nrCellIdentity
#     ${nrcell_id_list}    create list
#     ${dic_value}    get dictionary values    ${nrcell_info}
#     FOR    ${item}    IN    @{dic_value}
#         ${nr_cell}    get from dictionary    ${item}    nrCellIdentity
#         append to list      ${nrcell_id_list}    ${nr_cell}
#     END
#     [Teardown]    COAM Teardown gnb connections
#     [Return]    ${nrcell_id_list}
# 
# check all cell tp
#     [Arguments]     ${log_path}    ${nr_cell_list}
#     ${all_cell_tp_status_list}    create list
#     ${tp_status_flag}    set variable    ${False}
#     FOR    ${item}    IN    @{nr_cell_list}
#         ${item_list}    create list    ${item}
#         ${tp_status_flag}    run keyword and return status    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
#         ...    cells=${item_list}    target_throughput=${dltarget_tp}    min_percent=0.6
#         Exit for loop if    ${tp_status_flag}
#     END
#     should be true    ${tp_status_flag}
# 
# collect snapshot
#     Connect to gnb coam via ssl
#     COAM Save snapshot via rest api    log_path=${output_dir}     timeout=${1200}
#     [Teardown]    COAM Teardown gnb connections
# 
# retry attach and retry traffic
#     [Arguments]    ${cell_list}
#     ue attach
#     sleep    10s
#     Log To Console    Start Traffic
#     power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${throughput}    ue_index=${ue_index}
#     ...    duration=4000    ue_mode=SA    iperf_port=${ue0_dl_power_port_list}    iperf_type=via_command    process_num=${3}
#     sleep    10s
#     Log To Console    Check Throughput
#     ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${tp_during}    ignore_time=10s
#     ${status}    run keyword and return status    check all cell tp     log_path=${log_path}    nr_cell_list=${cell_list}
# 
# 
# SYNC_SOURCE_SWITCH
#     [Tags]    Sleep_Cell
#     ${active_sync}    ${passive_sync}    Syncsource switch pre-condition
#     Syncsource status check in gnb
#     start syncsource switch    active_sync=${active_sync}    passive_sync=${passive_sync}
#     Syncsource status check in gnb after sync switch
#     [Teardown]    teardown with sync failed
# 
# SYNC_SOURCE_SWITCH_AND_L3call
#     SYNC_SOURCE_SWITCH
#     ue attach verify
# 
# Separately Capture snapshot during tracffic
#     [Arguments]    ${cell_list}
#     power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${throughput}    ue_index=${ue_index}
#     ...    duration=5000    ue_mode=SA    iperf_port=${ue0_dl_power_port_list}    iperf_type=via_command    process_num=${3}
#     ${time1}    DateTime.get current date
#     ${time1_stamp}    convert Date    ${time1}    epoch
#     FOR    ${i}    IN RANGE    ${7}
#         sleep    10s
#         Log To Console    Check Throughput
#         ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${tp_during}    ignore_time=10s
#         ${status}    run keyword and return status    check all cell tp     log_path=${log_path}    nr_cell_list=${cell_list}
#         ${time2}    DateTime.get current date
#         ${time2_stamp}    convert Date    ${time2}    epoch
#         ${time_diff}     evaluate    int(${time2_stamp})-int(${time1_stamp})
#         run keyword and continue on failure    collect snapshot
#         run keyword unless      ${status}     retry attach and retry traffic    cell_list=${cell_list}
#         Exit for loop if    ${time_diff}>${check_traffic_time}
#     END
#     run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
#     ...    iperf_port=${ue${ue_index}_dl_power_port_list}    ue_mode=SA
