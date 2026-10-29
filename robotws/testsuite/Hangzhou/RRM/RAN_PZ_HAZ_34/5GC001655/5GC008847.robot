# *** Settings ***
# Documentation     author: Bijiajian
# ...               contact: Jiajian.bi@nokia-sbell.com
# ...               squad group: SG_02
# Force Tags        5G_RRM    QCD_MN_RAN    QCP_RAN_ST
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Library           OperatingSystem
# Library           Collections
# Library           BuiltIn
# Library           String
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/Resource_common_keywords.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource          Resources/1347_common_keyword.robot
# 
# *** Variables ***
# ${tmp_swconfig_dir}    /home/ute/Downloads/SCF/swconfig.txt
# ${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs
# ${scf_path_24R3}       /home/ute/Downloads/SCF/24R3
# ${scf_path_23R4}       /home/ute/Downloads/SCF/23R4
# ${scf_path_24R1}       /home/ute/Downloads/SCF/24R1
# ${scf_path_24R2}       /home/ute/Downloads/SCF/24R2
# @{beam_set_5_1_horizontal}    -33    -33    -16    -16    0    0    16    16    33    33    0    0    -33    -33    -16    -16
# @{beam_set_5_1_vertical}    96    96    96    96    96    96    96    96    96    96    102    102    96    96    96    96
# @{num}    0   1  2   3   4   5   6   7   24   25   26   27   28   29   30   31
# 
# *** Test Cases ***
# 5GC008847_Single_UE_UL_peak
#     [Tags]    CRT    5GC008847
#     [Setup]    Case Setup
#     Run Keyword And Ignore Error    MCS Set angle    horizontal_set=${beam_set_5_1_horizontal}
#     ...    vertical_set=${beam_set_5_1_vertical}
#     Recover swconfig file
#     Reload Case SCF and Commission    scf_file=${scf_path}/8847.xml
#     Single UE Attach And Send ul Traffic
# 	sleep    10s
#     Run Keyword And Ignore Error    Check DL UL Throughput On Site    dl_target=0    ul_target=120
#     Single UE Attach And Send dl Traffic
# 	sleep    10s
#     Run Keyword And Ignore Error    Check DL UL Throughput On Site    dl_target=1380    ul_target=0
#     [Teardown]    Case Teardown
# 
# [1.0] CB008847_5G_E_3_Max_scheduled_UEs_per_slot_change_Capacity_L1Pool
#     [Tags]    CRT    5GC008847
#     [Setup]    Case Setup
#     Reload Case SCF and Commission    scf_file=${scf_path}/8847.xml
#     Run Keyword And Ignore Error    Multi UE Attach And Send Traffic
#     Run Keyword And Ignore Error    Check DL UL Throughput On Site
#     Common Capture BIP log and download
#     Run Keyword And Ignore Error    Multi UE Check Tput
#     sleep    5min
#     ${counter1}    Check BTS Counters via webUI    counter_id=M55308C17002
#     ${counter2}    Check BTS Counters via webUI    counter_id=M55308C18002
# 	Run Keyword And Ignore Error    Should Contain any    ${counter1}    14    15    16
# 	Run Keyword And Ignore Error    Should Contain any    ${counter2}    14    15    16
#     [Teardown]    Case Teardown
# 
# *** Keywords ***
# Common Suite Setup
#     robot_common_operations.Common Suite Setup
# 
# Common Suite Teardown
#     robot_common_operations.Common Suite Teardown
# 
# Case Setup
#     COAM Create log directory
#     Connect to gnb coam via ssl
#     ${build}    Coam Get Active SW Version
#     ${result}    String.split string    string=${build}    separator=_
#     Run keyword if    'SBTS24R3' in ${result}    set test variable    ${scf_path}    ${scf_path_24R3}
#     ...    ELSE IF    'SBTS23R4' in ${result}    set test variable    ${scf_path}    ${scf_path_23R4}
#     ...    ELSE IF    'SBTS24R1' in ${result}    set test variable    ${scf_path}    ${scf_path_24R1}
#     ...    ELSE IF    'SBTS24R2' in ${result}    set test variable    ${scf_path}    ${scf_path_24R2}
#     robot_common_operations.Common Case Setup
# 
# Case Teardown
#     #Run keyword and ignore error    Multi UE Detach And Stop Traffic
#     Run keyword and ignore error    COAM Teardown gnb connections
#     Run keyword and ignore error    CI_interface.Common Case Teardown
#     robot_common_operations.Common Case Teardown
# 
# Update swconfig file
#     [Arguments]    ${swconfig_dir}
#     Connect to Common Unit Master
#     Upload_swConfig_file_to_asik_and_crasign    localFilePath=${swconfig_dir}    asik_alias=ASIK Master
#     Csn.Disconnect    connection=ASIK Master
# 
# Reload Case SCF and Commission
#     [Arguments]    ${scf_file}
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    scf_file_path=${scf_file}
#     COAM Wait for gnb ready and cell setup
# 
# Multi UE Detach And Stop Traffic
#     : FOR    ${ue_no}    IN RANGE    ${ue_num}
#     \    Run Keyword And Continue On Failure    Common Stop traffic    direction=dl    ue_index=${ue_no}
#     \    Run Keyword And Continue On Failure    Common Stop traffic    direction=ul    ue_index=${ue_no}
#     \    Run Keyword And Continue On Failure    Common UE Detach    ue_index=${ue_no}    power_reset=true
# 
# Single UE Attach And Send ul Traffic
#     [Arguments]    ${send_traffic_ul}=200MKbits/sec    ${send_duration}=1800    ${ue_no}=1
#     Common UE Attach    ue_index=${ue_no}    power_reset=true
#     sleep    3s
#     Common UE Send UL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_ul}    send_duration=${send_duration}
# 
# Single UE Attach And Send dl Traffic
#     [Arguments]    ${send_traffic_dl}=2000MKbits/sec    ${send_duration}=1800    ${ue_no}=1
#     Common UE Attach    ue_index=${ue_no}    power_reset=true
#     sleep    3s
#     Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_dl}    send_duration=${send_duration}
# 
# Multi UE Attach And Send Traffic
#     [Arguments]    ${send_traffic_ul}=20MKbits/sec    ${send_traffic_dl}=200MKbits/sec    ${send_duration}=3600
#     : FOR    ${ue_no}    IN    @{num}
#     \    Run Keyword And Continue On Failure    Common UE Attach    ue_index=${ue_no}    power_reset=true
#     \    sleep    3s
#     \    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_ul}
#     \    ...    send_duration=${send_duration}
#     \    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_dl}
#     \    ...    send_duration=${send_duration}
# 
# Check DL UL Throughput On Site
#     [Arguments]    ${dl_target}=1300    ${ul_target}=130
#     ${cells}    Get NRcellid list
#     @{cell}    Create list    @{cells}[0]
#     ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
#     power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cell}    target_throughput=${dl_target}
#     power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cell}    target_throughput=${ul_target}
# 
# Multi UE Check DL Tput
#     [Arguments]    ${check_traffic_dl}=50    ${num}=1
#     : FOR    ${ue_no}    IN RANGE    ${num}
#     \    Run Keyword And Continue On Failure    Common UE Check DL Tput    ue_index=${ue_no}    
#     \    ...    check_traffic=${check_traffic_dl}
# 
# Multi UE Check Tput
#     [Arguments]    ${check_traffic_ul}=8    ${check_traffic_dl}=80
#     : FOR    ${ue_no}    IN    @{num}
#     \    Run Keyword And Continue On Failure    Common UE Check UL And DL Tput    ue_index=${ue_no}    
#     \    ...    check_traffic_ul=${check_traffic_ul}    check_traffic_dl=${check_traffic_dl}
