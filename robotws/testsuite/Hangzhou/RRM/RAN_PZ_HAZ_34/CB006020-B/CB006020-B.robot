# *** Settings ***
# Documentation
# ...    author: Jiang Hongyu
# ...    contact: hongyu.jiang@nokia-sbell.com
# ...    squad group: MMW_SG_04
# ...    feature : CB006020-B
# 
# Force Tags  STATE_SW_UPLOADED
# 
# Library     taf.sbts.oam.coam.admin       WITH NAME    coam
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# 
# Suite Setup    Case Suit Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# 
# *** Variables ***
# ${gnb_ip}                  ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${gNB_username}            ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${gNB_password}            ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${default_scf_path}        ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T7422/
# @{cell_list1}              ${5}    ${6}    ${7}    ${8}
# @{cell_list2}              ${1}    ${2}    ${3}    ${4}
# @{ue_index_list}           ${2}
# ${ul_throughput}           50M
# ${dl_throughput}           200M
# ${duration}                6000
# @{nr_cell_list1}           16385    16386    16387    16388
# @{nr_cell_list2}           16389    16390    16391    16392
# ${exp_ul}                  ${50}
# ${exp_dl}                  ${200}
# ${ul_power_port_list}      ${tl.ues[0].iperf_details.ports[0:4]}
# ${dl_power_port_list}      ${tl.ues[0].iperf_details.ports[4:8]}
# ${enb_bts_id}              ${tl.enbs[1].instance_id}
# ${4G_NR_BTS}               ${tl.enbs[1].global_bts_id}
# ${enb_ip}                  ${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
# 
# *** Test Cases ***
# [1]CB006020-B_021_28G_Main_39G_Ext_Call_setup_UL_DL_traffic_with_beamSetFR2_16_8_8_1P_N45_45_N0_20_on_main_Sector
#     [Tags]  CRT_23R1    CRT_22R4    CRT_TRUNK
#     [Setup]    robot_common_operations.Common case Setup
#     Lock Cell And Check is Locked    cell_list=${cell_list1}    cell_group_idx=${1}
#     Check GNB on air
#     Modify Parameter Value On ENB    bts_host=${enb_ip}    value=5
#     Start Traffic And Check Throughput    if_ul=${True}    if_dl=${True}    ul_list=${nr_cell_list1}    dl_list=${nr_cell_list1}
#     [Teardown]  Unlock Cell And Check is Unlocked    cell_list=${cell_list1}    cell_group_idx=${1}
# 
# 
# [1]CB006020-B_025_28G_Main_39G_Ext_Call_setup_UL_DL_traffic_with_beamSetFR2_16_8_8_1P_N45_45_N0_20_on_extension_Sector
#     [Tags]  CRT_23R1    CRT_22R4    CRT_TRUNK
#     [Setup]    robot_common_operations.Common case Setup
#     Lock Cell And Check is Locked    cell_list=${cell_list2}    cell_group_idx=${0}
#     Check GNB on air
#     Modify Parameter Value On ENB    bts_host=${enb_ip}    value=9
#     Start Traffic And Check Throughput    if_ul=${True}    if_dl=${True}    ul_list=${nr_cell_list2}    dl_list=${nr_cell_list2}
#     [Teardown]  Unlock Cell And Check is Unlocked    cell_list=${cell_list2}    cell_group_idx=${0}
# 
# 
# 
# *** Keywords ***
# Input default SCF
#     [Arguments]      ${bts_host}    ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    separator=_
#     ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
#     ${version_scf}    set variable if    ${if_common_load}    SBTS00    ${version_list[0]}
#     ${default_scf_path1}    set variable    ${default_scf_path}SCF_${version_scf}
#     [Return]     ${default_scf_path1}
#     [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Case Suit Setup
#     CI_interface.Common Suite Setup
#     robot_common_operations.Common Suite Setup
#     ${default_gnb_scf_path}    Input default SCF    bts_host=${gnb_ip}
#     ${default_enb_scf_path}    Input default SCF    bts_host=${enb_ip}
#     log to console    ${default_gnb_scf_path}_beamSet.xml
#     log to console    ${default_enb_scf_path}_4G.xml
#     Setup Commission SCF    scf_path=${default_gnb_scf_path}_beamSet.xml
#     Setup Commission SCF    scf_path=${default_enb_scf_path}_4G.xml    bts_host=${enb_ip}
#     Check GNB on air    bts_host=${gnb_ip}
#     Check GNB on air    bts_host=${enb_ip}
# 
# Get Cells Info
#     [Arguments]  ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${gnb_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#     ${c_info}    coam.get cells info    cell_type=nr    connection=${connection}
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Check GNB on air
#     [Timeout]    20 min
#     [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#     Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air    connection=${connection}
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Setup Commission SCF
#     [Arguments]  ${scf_path}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#     COAM Commission with scf file    scf_file_path=${scf_path}    connection=${connection}
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Lock Cell And Check is Locked
#     [Arguments]  ${cell_list}    ${cell_group_idx}=${0}    ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${gnb_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#     FOR    ${cell_index}    IN    @{cell_list}
#         Perform cell lock via rest api    cell_idx=${cell_index}    connection=${connection}   timeout=60
#         Wait Until Keyword Succeeds    90 sec    3 sec    Cell Should Be Locked    cell_idx=${cell_index}    cell_group_idx=${cell_group_idx}
#         ...    connection=${connection}
#     END
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Unlock Cell And Check is Unlocked
#     [Arguments]  ${cell_list}    ${cell_group_idx}=${0}    ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${gnb_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#     FOR    ${cell_index}    IN    @{cell_list}
#         Perform cell unlock via rest api    cell_idx=${cell_index}    connection=${connection}   timeout=60
#         Wait Until Keyword Succeeds    120 sec    3 sec    Cell Should Be Unlocked    cell_idx=${cell_index}    cell_group_idx=${cell_group_idx}
#         ...    connection=${connection}
#     END
#     change 4G configuration
#     robot_common_operations.Common case Teardown
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Modify Parameter Value On ENB
#     [Arguments]    ${bts_host}    ${value}    ${cell_id}=1    ${connection}=coam_admin
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#     coam.Perform parameter recommissioning    dist_name=MRBTS-${enb_bts_id}/LNBTS-${enb_bts_id}/LNCEL-${cell_id}
#     ...                                       parameter=defaultLnRelGnbCellId
#     ...                                       operation=update
#     ...                                       value=${value}
#     ...                                       skip_parameter_relation_errors=${True}
#     ...                                       should_activate=${True}
#     ...                                       connection=${connection}
#      Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air    connection=${connection}
#      [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# ###################### UE Relevant #########################
# attach multi power ue
#     [Arguments]    ${ue_index_list}
#     log to console       Prepare UE
#     FOR    ${item}    IN    @{ue_index_list}
#         power_ue.Prepare UE    ue_index=${item}    ue_type=samsung    ui_version=S21UI3.1
#         ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${item}    ue_type=samsung    log_type=Aasyslog
#         power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False
#     END
# 
# start multi power ue traffic ul and dl
#     [Arguments]    ${ue_index_list}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
#     ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
#     log to console      Start traffic    console=yes
#     FOR    ${item}    IN    @{ue_index_list}
#         run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
#         ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
#         ...    iperf_port=@{ul_power_port_list}[${item}]
#         sleep    1s
#         run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
#         ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung    protocol=${protocol}
#         ...    iperf_port=@{dl_power_port_list}[${item}]
#     END
# 
# stop multi power ue traffic ul and dl
#     [Arguments]    ${ue_index_list}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
#     log to console     Stop traffic    console=yes
#     FOR    ${item}    IN    @{ue_index_list}
#         run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
#         ...    protocol=${protocol}    iperf_port=@{ul_power_port_list}[${item}]
#         run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=samsung    protocol=${protocol}
#         ...    iperf_port=@{dl_power_port_list}[${item}]
#     END
# 
# detach multi power ue
#     [Arguments]    ${ue_index_list}
#     log to console      UE Detach    console=yes
#     FOR    ${item}    IN    @{ue_index_list}
#          power_ue.UE Detach    ue_index=${item}    ue_type=samsung
#     END
# 
# ###################### Aasyslog check TP #########################
# Start Traffic And Check Throughput
#     [Arguments]  ${if_ul}    ${if_dl}    ${ul_list}    ${dl_list}    ${ue_index_list}=${ue_index_list}    ${exp_ul_tp}=${exp_ul}
#     ...    ${exp_dl_tp}=${exp_dl}    ${log_time}=3m    ${ue_type}=samsung
#     attach multi power ue    ue_index_list=${ue_index_list}
#     start multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
#     ...        ul_duration=${duration}    dl_duration=${duration}    protocol=tcp    if_ul=${if_ul}    if_dl=${if_dl}
#     ${log_path}    power_ue.Collect Tput   ue_type=${ue_type}    duration=${log_time}    ignore_time=10s
#     run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
#     ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${exp_ul_tp}    target_avg_percent=0.3
#     ...    min_percent=0    actCarrierAggregation=${True}
#     run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
#     ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${exp_dl_tp}    target_avg_percent=0.5
#     ...    min_percent=0    actCarrierAggregation=${True}
#     stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    protocol=tcp    if_ul=${if_ul}    if_dl=${if_dl}
#     [Teardown]  Run keyword and ignore error    detach multi power ue    ue_index_list=${ue_index_list}
# 
# change 4G configuration
#     [Arguments]      ${value}=${5}
#     Connect to gnb coam via ssl    bts_host=${enb_ip}    username=${gNB_username}    password=${gNB_password}    connection=4G_admin
#     coam.Perform Parameter Recommissioning
#     ...    dist_name=MRBTS-${enb_bts_id}/LNBTS-${4G_NR_BTS}/LNCEL-1
#     ...    parameter=defaultLnRelGnbCellId
#     ...    value=${value}
#     ...    operation=update
#     ...    connection=4G_admin
#     ...    should_activate=${True}
#     COAM Teardown gnb connections     connection=4G_admin
# 
# 
# 
# 
# 
# 
# 
# 
