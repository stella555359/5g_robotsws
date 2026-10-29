# *** Settings ***
# Documentation
# ...         author: Lixia.tang
# ...         contact: lixia.tang@nokia-sbell.com
# ...         squad group: 5G_PZ_MMW_HZ_3_SG
# ...         CB007425-5G-AA60 4CC DL 2CC UL CA test
# 
# Force Tags
# 
# Library     taf.sbts.oam.coam.admin   WITH NAME   admin_cli
# Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
# Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    Suite setup
# Suite Teardown    Suite teardown
# 
# *** Variables ***
# ${scf_name}    SCF_SBTS_239_CA.xml
# ${data_amount}    2M
# ${process_num}    1
# ${protocol}  TCP
# ${ue_type}    ${tl.ues[0].capabilities[1]}
# ${4cc_duration}    7m
# ${4cc_ul_exp_tcp}    230
# ${4cc_dl_exp_tcp}    1950
# @{list_of_cell_4CC}     15024133    15024134    15024135    15024136
# ${SCF_TEMPLATE_PATH}          ${commissionings_path}/HGZ/${testline_name}/
# 
# *** Test Cases ***
# [1]CB007425_AA_5GC001831_TC001_4CC_DL_2CC_UL_Contiguous_AsymmetricCA_Buffer_Based_Scell_Activation_Deactivation_TCP
#     [Documentation]
#     ...    The purpose of this test case is to test 5GC001831 asymmetric CA 4CCs in DL and 2CCss in UL, Single UE intra band
#     ...    mmW with buffer based scell activation and deactivation on ASIM platform.All CCs frequency are contiguous.
#     [Tags]
#     [Setup]    robot_common_operations.Common Suite Setup
#     [Timeout]    15min
#     Run Keyword And Ignore Error    robot_common_operations.Common case setup
#     Wait Until Keyword Succeeds    10min    20s    COAM Check All Cells Onair
#     step2: Prepare UE
#     Step3: UE Attach
#     Start traffic and check result    tp_direction=both
#     Step7: UE Detach
#     [Teardown]    Run Keywords    CaseTeardown
#     ...    AND    robot_common_operations.Common Suite Teardown
# 
# 
# *** Keywords ***
# Scf commission until on-air
#     log to console      step2: Scf commission and wait for on-air
#     Scf commission and wait for on-air    scf_name=${scf_name}
# 
# step2: Prepare UE
#     log to console      step3: Prepare UE
#     power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
# 
# Step3: UE Attach
#     log to console      Step4: UE Attach
#     ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
#     power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
# 
# Step4: Start traffic
#     [Arguments]  ${tp_direction}=both
#     log to console      Step4:Start traffic
#     Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
#     ...    direction=ul    throughput=140M    duration=1400    ue_type=${ue_type}    iperf_type=via_command
#     ...    protocol=tcp    data_amount=2M
#     sleep    1s
#     Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
#     ...     direction=dl    throughput=2100M    duration=1400    ue_type=${ue_type}     protocol=tcp
#     ...     process_num=${process_num}    window=13M
#     sleep    20s
# 
# Step5: Check throughput
#     [Arguments]  ${tp_direction}=both
#     ${log}    Run keyword and continue on failure    power_ue.Collect Tput
# 	...    ue_type=${ue_type}    duration=${4cc_duration}    filter=L2Lo
# 	Set Suite Variable     ${log}
#     Run keyword if    '${tp_direction}'=='both'    Check throughput for Bi-direction
# 
# Check throughput for Bi-direction
# 	${all_tp}    Run keyword and continue on failure    power_ue.Check Bi Tput
# 	...    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_4CC}
#     ...    ultarget_throughput=${4cc_ul_exp_tcp}    dltarget_throughput=${4cc_dl_exp_tcp}    actCarrierAggregation=${True}
#     ...    target_avg_percent=0.95    min_percent=0.75
# 
# Step6: Stop traffic
#     [Arguments]  ${tp_direction}=both
#     log to console      Step6: Stop traffic
#     Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
#     ...    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command    protocol=tcp
#     Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'      power_ue.Stop traffic    direction=dl
#     ...     ue_index=${0}    ue_type=${ue_type}    protocol=tcp
# 
# Step7: UE Detach
#     log to console      Step8: UE Detach
#     power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}
# 
# Start traffic and check result
#     [Arguments]  ${tp_direction}=both    ${sleep_time}=2m
#     Step4: Start traffic    tp_direction=${tp_direction}
#     Run keyword and continue on failure    Step5: Check throughput    tp_direction=${tp_direction}
#     Run Keyword And Ignore Error    Step6: Stop traffic    tp_direction=${tp_direction}
# 
# Scf commission and wait for on-air
#     [Arguments]   ${scf_name}   ${connection}=COAM
#     admin_cli.perform_commissioning
#     ...   scf_file=${SCF_TEMPLATE_PATH}/${scf_name}
#     ...   skip_parameter_relation_errors=${true}
#     ...   should_activate=${true}
#     ...   timeout=${600}
#     ...   connection=${connection}
#     Wait Until Keyword Succeeds    20min    20s    COAM Check All Cells Onair
# 
# Suite setup
#     Connect to gnb coam via ssl    connection=COAM
#     ...    gnb_index=${0}
#     ...    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
#     ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#     ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
# 
# Suite teardown
#     Run Keyword And Ignore Error    admin_cli.teardown    connection=COAM
# 
# CaseTeardown
#     Log To Console    \n *** Case teardown
#     Run Keyword And Ignore Error    Teardown the Aasyslog save progress
# 	Run Keyword And Ignore Error    CI_interface.Common Case Teardown
