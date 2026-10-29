# *** Settings ***
# Documentation
# ...     TL Target:
# ...         gNB type: 1xABIL+1xASIK+AMIA
# ...         Classical configuration
# ...         AWEWA/B n260 BW 100MHz, pMAx : 19dBm
# ...         UE type : QCT
# ...         4G Real (Real eNB)
# ...         Core Network type : Real
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
# #Resource    ./Resources/test_var.robot
# 
# Test Setup     robot_common_operations.Common Case Setup
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# Force Tags    RAN_5G_TDD    5G_RAN_TDD
# 
# *** Variables ***
# ${ue_type}              ${tl.ues[0].capabilities[1]}
# ${ul_exp_tp}            120
# ${dl_exp_tp}            530
# ${tp_duration}          15m
# @{list_of_cell}         34078721
# ${scf_path}    ${commissionings_path}/HGZ/${testline_name}
# ${scf_name}    1477_scf.xml
# 
# *** Test Cases ***
# [1]5GC001477-A_019_Call setup DL traffic with beamSetFR2_6_6_4_2P
#     [Documentation]  The purpose of this test case is to check Beamtracking procedure UE reporting the 2 best beams.
#     ...             and beam change.
#     ...             Beam change Offset parameter is configured to non zero value
#     ...             Post condition Checks:
#     ...             SCF (setting 1720 params + 1127), check in the log ASIK/startup
#     ...             that the 1720 & 1127 parameters are taken into account.
#     ...             Test Step
#     ...                 1. Set BeamSetFR2_16_8_8
#     ...                 2. Perform UE attach with traffic
#     ...                 3. Move RRH positioner to perform beam switching
#     ...                 4. Capture gNB L1/L2 traces.
#     [Tags]          QC_623899
# 	Scf commition and wair for on-air    scf_name=${scf_path}/${scf_name}
#     Prepare UE
#     UE Attach
#     Start traffic
# 	Check throughput
#     [Teardown]    Teardown
# 
# *** Keywords ***
# Prepare UE
#     log to console      Prepare UE
#     power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
# 
# UE Attach
#     log to console      UE Attach
#     ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}   log_type=Aasyslog
#     power_ue.Verify attach    ue_type=${ue_type}  5Grach_ed=${5Grach_ed_0}    4G_check=False
# 
# Start traffic
#     log to console      Start traffic
#     power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=150M    duration=1400
#     ...    ue_type=${ue_type}   iperf_type=via_command
#     sleep    1s
#     power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=600M    duration=1400
#     ...    ue_type=${ue_type}   process_num=1
#     sleep    20s
# 
# Check throughput
#     log to console      Check throughput
#     ${log}    Run keyword and continue on failure    power_ue.Collect Tput
# 	...    ue_type=${ue_type}    duration=${tp_duration}    filter=L2Lo
# 	${all_tp}    Run keyword and continue on failure    power_ue.Check Bi Tput
# 	...    ue_type=${ue_type}    log=${log}    cells=${list_of_cell}
#     ...    ultarget_throughput=${ul_exp_tp}    dltarget_throughput=${dl_exp_tp}
#     ...    target_avg_percent=0.95    min_percent=0.5
# 	Set Test Variable    ${all_tp}    ${all_tp}
# 
# Stop traffic
#     log to console      Stop traffic
#     power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}   iperf_type=via_command
#     power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}
# 
# UE Detach
#     log to console      UE Detach
#     power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}
# 
# Teardown
#     Run Keyword and Ignore Error    Stop traffic
#     Run Keyword and Ignore Error    UE Detach
# 
# Scf commition and wair for on-air
#     [Arguments]    ${scf_name}    ${is_pdl_checking_needed}=${True}
#     log to console    Scf commition and wair for on-air
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    scf_file_path=${scf_name}    is_pdl_checking_needed=${is_pdl_checking_needed}    connection=GNB_OAM
#     Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
#     Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
