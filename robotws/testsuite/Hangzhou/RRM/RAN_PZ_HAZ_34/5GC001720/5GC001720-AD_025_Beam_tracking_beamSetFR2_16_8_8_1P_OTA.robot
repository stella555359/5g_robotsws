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
# #Suite Setup    Case Suite Setup
# 
# Library     taf.ul.parser.pcap    WITH NAME    pcap
# Library     ../CB007306_OTA/Resources/hbtePositioner/positionerDemo.py
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
# ${ASIB_IP}                         ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# ${ASIB_SSH_USERNAME}               ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
# ${ASIB_SSH_PASSWORD}               ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
# 
# ${ue_type}              ${tl.ues[0].capabilities[1]}
# ${ul_exp_tp}            115
# ${dl_exp_tp}            530
# ${tp_duration}          1m
# ${bip_log_path}         /home/ute/test
# ${bip_log_name}         biplog.pcap
# @{list_of_cell}         34078721
# ${PositionMotion}       10.71.207.75
# ${BIP_remote_path}      /tmp/tcpdump_L2L1_bip_filtering_off.pcap0
# ${gnbMirroring_path}    /ffs/run/config/scripts/gnbMirroring.sh
# ${scf_path}    ${commissionings_path}/HGZ/${testline_name}
# ${scf_name}    1720_scf.xml
# 
# *** Test Cases ***
# [1]5GC001720-AD_025_Beam_tracking_beamSetFR2_16_8_8_1P_OTA
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
#     ${beams_id}    Create List
#     FOR    ${i}    IN RANGE    ${3}
#         ${start_position}    Evaluate    ${i}*10
#         ${i}    Evaluate    ${i}+1
#         ${end_position}    Evaluate    ${i}*10
#         Capture BIP Logs    delay=${5}
#         ${beam_id}    Analysis The Wireshark Log And return Beamid
#         Append To List   ${beams_id}    ${beam_id}
#         run keyword if    ${i}!=${3}    Restart and check TP    X=${start_position}    Y=${end_position}
#     END
#     Log To Console    ${beams_id}
#     should not be equal as integers  @{beams_id}[0]    @{beams_id}[1]
#     should not be equal as integers  @{beams_id}[1]    @{beams_id}[2]
#     [Teardown]    Teardown
# 
# *** Keywords ***
# Set X and Y PositionMotion
#     [Arguments]   ${ip}=${PositionMotion}     ${if_X}=${False}    ${if_Y}=${True}      ${exceed}=${90}
#     ...    ${start_X}=${0}     ${end_X}=${0}     ${speed_X}=${2}    ${loopCount_X}=${1}
#     ...    ${start_Y}=${0}     ${end_Y}=${0}     ${speed_Y}=${2}    ${loopCount_Y}=${1}
#     Log To Console    start to move position
#     Run keyword if     ${if_X}     positionerDemo.setXPositionMotion     ip=${ip}      start=${start_X}
#     ...     end=${end_X}    speed=${speed_X}    loopCount=${loopCount_X}    exceed=${exceed}
#     Run keyword if     ${if_Y}     positionerDemo.setYPositionMotion     ip=${ip}      start=${start_Y}
#     ...     end=${end_Y}    speed=${speed_Y}    loopCount=${loopCount_Y}    exceed=${exceed}
# 
# Capture BIP Logs
#     [Arguments]   ${delay}=${20}
#     Log To Console    prepare for capture bip
#     ${connection}    ssh.Connect to    hostname=${ASIB_IP}    username=${ASIB_SSH_USERNAME}
#     ...    password=${ASIB_SSH_PASSWORD}    alias=DU
#     run keyword and continue on failure    Clear Tmp Bip Logs
#     Log To Console    Capture BIP Logs
#     ssh.send_command   command=sh ${gnbMirroring_path} --capturing_time_seconds=${delay} > /dev/null    connection=${connection}
#     sleep    ${delay}s
#     sleep    30s
#     Log To Console    Copy BIP Logs To Test PC
#     ${current_time}     Get Current Date        result_format=%Y%m%d_%H%M%S
#     set suite variable    ${current_time}
#     run    command=mkdir ${bip_log_path}/${current_time}
#     run    sshpass -p ${ASIB_SSH_PASSWORD} scp toor4nsn@${ASIB_IP}:${BIP_remote_path} ${bip_log_path}/${current_time}/${bip_log_name}
#     [Teardown]    ssh.Disconnect    connection=${connection}
# 
# Clear Tmp Bip Logs
#     ssh.send_command    command=cd /tmp && rm -rf tcpdump_L2L1_bip*    connection=DU
# 
# Analysis The Wireshark Log And return Beamid
#     Log To Console    Wireshark analyzing...
#     ${pdml_list}    PCAP.Load Pcap File    pcap_file=${bip_log_path}/${current_time}/biplog.pcap
#     sleep    30s
#     ${Beam_id}    PCAP.Get Field Value By Name    pdml_list=${pdml_list}
#     ...    field_name=DlData_PdcchSendReq_t.beamId
#     sleep    30s
#     BuiltIn.Log    ${Beam_id}
#     [Return]    ${Beam_id}[0]
# 
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
# Restart and check TP
#     [Arguments]   ${X}    ${Y}
#     Stop traffic
#     UE Detach
#     UE Attach
#     Start traffic
#     Check throughput
#     Set X and Y PositionMotion    start_Y=${X}   end_Y=${Y}
#     sleep    60s
#     Check throughput
# 
# Teardown
#     Run Keyword and Ignore Error    Stop traffic
#     Run Keyword and Ignore Error    UE Detach
#     Set X and Y PositionMotion
# 
# Scf commition and wair for on-air
#     [Arguments]    ${scf_name}    ${is_pdl_checking_needed}=${True}
#     log to console    Scf commition and wair for on-air
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    scf_file_path=${scf_name}    is_pdl_checking_needed=${is_pdl_checking_needed}    connection=GNB_OAM
#     Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air
#     Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
