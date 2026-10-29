# *** Settings ***
# Documentation     author: Bijiajian
# ...               contact: Jiajian.bi@nokia-sbell.com
# ...               squad group: SG_02
# Suite Setup       Common Suite Setup for COAM 
# Suite Teardown    Common Suite Teardown
# Force Tags        5G_RRM    QCD_MN_RAN    QCP_RAN_ST
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
# ${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs
# ${scf_path_23R1}       /home/ute/Downloads/SCF/23R1
# ${scf_path_23R2}       /home/ute/Downloads/SCF/23R2
# ${scf_path_23R3}       /home/ute/Downloads/SCF/23R3
# ${scf_path_23R4}       /home/ute/Downloads/SCF/23R4
# @{beam_set_5_1_horizontal}    -33    -33    -16    -16    0    0    16    16    33    33    0    0    -33    -33    -16    -16
# @{beam_set_5_1_vertical}    96    96    96    96    96    96    96    96    96    96    102    102    96    96    96    96
# @{pm_path}    ${CURDIR}/Resources/NR_5054a.txt    ${CURDIR}/Resources/NR_5055b.txt    ${CURDIR}/Resources/NR_5056b.txt
#     ...    ${CURDIR}/Resources/NR_5057c.txt   ${CURDIR}/Resources/NR_5108d.txt    ${CURDIR}/Resources/NR_5109d.txt
# 
# 
# *** Test Cases ***
# TEST1
#     [Setup]    Case Setup
#     MCS Set PA common
#     MCS Set angle    horizontal_set=${beam_set_5_1_horizontal}    vertical_set=${beam_set_5_1_vertical}
#     Reload Case SCF and Commission    scf_file=${scf_path}/KPI.xml
#     Multi UE Attach And Send Traffic
#     sleep    15min
#     Calcu kpi from pm    pm_path=${pm_path}
#     #excel path：/home/ute/Downloads/KPI.xlsx
#     Put value to excel
#     Run keyword and ignore error    Multi UE Check Tput
#     [Teardown]    Case Teardown
# 
# *** Keywords ***
# Common Suite Setup for COAM
#     robot_common_operations.Common Suite Setup
# 
# Common Suite Teardown
#     robot_common_operations.Common Suite Teardown
# 
# Case Setup
#     COAM Create log directory
#     Connect to gnb coam via ssl
#     ${build}    Coam Get Active SW Version
# 	Set Test Variable    ${build}    ${build}  
#     ${result}    String.split string    string=${build}    separator=_
#     Run keyword if    'SBTS23R3' in ${result}    set test variable    ${scf_path}    ${scf_path_23R3}
#     ...    ELSE IF    'SBTS23R1' in ${result}    set test variable    ${scf_path}    ${scf_path_23R1}
#     ...    ELSE IF    'SBTS23R2' in ${result}    set test variable    ${scf_path}    ${scf_path_23R2}
#     ...    ELSE IF    'SBTS23R4' in ${result}    set test variable    ${scf_path}    ${scf_path_23R4}
#     robot_common_operations.Common Case Setup
# 
# Case Teardown
#     Run keyword and ignore error    COAM Teardown gnb connections
#     Run keyword and ignore error    MCS Set PA common
# 
# Download pm file From ASIK To TestPC
#     [Arguments]    ${path}    ${log_path}=${TS_CASE_LOG_PATH}   ${connection}=ASIK Master
#     @{pm_names1}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
#     ...    file_indicator=PM.*.*0000.ANY.xml.gz
# 	@{pm_names2}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
#     ...    file_indicator=PM.*.*1500.ANY.xml.gz
# 	@{pm_names3}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
#     ...    file_indicator=PM.*.*3000.ANY.xml.gz
# 	@{pm_names4}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${connection}
#     ...    file_indicator=PM.*.*4500.ANY.xml.gz
# 	@{list_log_names}    Create list    @{pm_names1}    @{pm_names2}    @{pm_names3}    @{pm_names4}
# 	Sort List    ${list_log_names}
#     log    ${list_log_names}
#     @{list_log_path_local}    Create list
#     @{list_size}    Create list
#     FOR  ${log_name}  IN  @{list_log_names}
#         Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
#         ...   remote_path=${path}/${log_name}
#         ...   local_path=${log_path}/${log_name}
#         ...   connection=${connection}
#         Append to list    ${list_log_path_local}    ${log_path}/${log_name}
#     END
#     Sort List    ${list_log_path_local}
#     ${result}    String.split string    string=${list_log_names}[-1]    separator=.gz
#     [Return]    ${list_log_path_local}[-1]    ${result}[0]
# 
# Download PM File
#     [Arguments]    ${path}=/ffs/run/uri/PERFMON_FILES
#     Connect to Common Unit Master
#     run    rm -r ${TS_CASE_LOG_PATH}/*
#     ${pm_file}    ${PM_name}    Download pm file From ASIK To TestPC    path=${path}
#     should not be empty    ${pm_file}
#     Run    gzip -d ${pm_file}
#     #run    rm -r ${TS_CASE_LOG_PATH}/PM.*.gz
#     [Return]    ${TS_CASE_LOG_PATH}/${PM_name}
# 
# Calcu kpi from pm
#     [Arguments]    ${pm_path}
#     ${pm_file_path}    Download PM File
#     @{values}    Create list
#     Set Test Variable    ${values}    ${values}
#     ${time}    Evaluate    datetime.datetime.now().strftime("%Y%m%d")    datetime
#     ${time}    Evaluate    ${time}
#     Append to list    ${values}    ${time}
#     Append to list    ${values}    ${build}
#     FOR   ${pm}   IN   @{pm_path}
# 	    ${value}    calcu_kpi_from_pmfile    file_name=${pm_file_path}    pm_name=${pm}
#         Append to list    ${values}    ${value}
#     END
# 	[Return]    ${values}
# 
# Put value to excel
#     put value to xlsx    values=${values}
# 
# Reload Case SCF and Commission
#     [Arguments]    ${scf_file}
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    scf_file_path=${scf_file}
#     COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'
# 
# Multi UE Detach And Stop Traffic
#     : FOR    ${ue_no}    IN RANGE    ${ue_num}
#     \    Run Keyword And Continue On Failure    Common Stop traffic    direction=dl    ue_index=${ue_no}
#     \    Run Keyword And Continue On Failure    Common Stop traffic    direction=ul    ue_index=${ue_no}
#     \    Run Keyword And Continue On Failure    Common UE Detach    ue_index=${ue_no}    power_reset=true
# 
# Multi UE Attach And Send Traffic
#     [Arguments]    ${send_traffic_ul}=100MKbits/sec    ${send_traffic_dl}=1000MKbits/sec    ${send_duration}=3600    ${num}=2
#     : FOR    ${ue_no}    IN RANGE    ${num}
#     \    Common UE Attach    ue_index=${ue_no}    power_reset=true
#     \    sleep    3s
#     \    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_ul}
#     \    ...    send_duration=${send_duration}
#     \    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_dl}
#     \    ...    send_duration=${send_duration}
# 
# Check DL UL Throughput On Site
#     ${cells}    get_item_from_scf    scf_file_path=${scf_path}/common.xml    ref=<p name="nrCellIdentity">([\\w\\W]*?)</p>
#     ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
#     power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cells}    target_throughput=100
#     power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cells}    target_throughput=0
# 
# Multi UE Check DL Tput
#     [Arguments]    ${check_traffic_dl}=100    ${num}=1
#     : FOR    ${ue_no}    IN RANGE    ${num}
#     \    Run Keyword And Continue On Failure    Common UE Check DL Tput    ue_index=${ue_no}    
#     \    ...    check_traffic=${check_traffic_dl}
# 
# Multi UE Check Tput
#     [Arguments]    ${check_traffic_ul}=60    ${check_traffic_dl}=600    ${num}=2
#     : FOR    ${ue_no}    IN RANGE    ${num}
#     \    Run Keyword And Continue On Failure    Common UE Check UL And DL Tput    ue_index=${ue_no}    
#     \    ...    check_traffic_ul=${check_traffic_ul}    check_traffic_dl=${check_traffic_dl}
# 
# MCS Set Odd Attenuations
#     [Arguments]    ${attenuation}    ${begin_input_port}    ${end_input_port}    ${output_port}
#     [Documentation]    for example:
#     ...    ${attenuation} =${90.0}
#     ...    ${begin_input_port}=${1}
#     ...    ${end_input_port}=${64}
#     ...    ${output_port}=${1}
#     mcs.set_odd_attenuations    attenuation=${attenuation}    begin_input_port=${begin_input_port}    
#     ...    end_input_port=${end_input_port}    output_port=${output_port}
# 
# MCS Set Even Attenuations
#     [Arguments]    ${attenuation}    ${begin_input_port}    ${end_input_port}    ${output_port}
#     mcs.set_even_attenuations    attenuation=${attenuation}    begin_input_port=${begin_input_port}    
#     ...    end_input_port=${end_input_port}    output_port=${output_port}
# 
# Set Odd By Output_port
#     [Arguments]    ${begin_output_port}    ${end_output_port}    ${attenuation}    ${B_Odd}=True
#     :FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
#     \    Run keyword if    ${num}%2 and '${B_Odd}'=='True'    MCS Set Odd Attenuations    attenuation=${${attenuation}}    
#     \    ...    begin_input_port=${1}    end_input_port=${64}    output_port=${${num}}
#     \    Run keyword if    ${num}%2==0 and '${B_Odd}'=='False'    MCS Set Odd Attenuations    attenuation=${${attenuation}}    
#     \    ...    begin_input_port=${1}    end_input_port=${64}    output_port=${${num}}
# 
# Set Even By Output_port
#     [Arguments]    ${begin_output_port}    ${end_output_port}    ${attenuation}    ${B_Odd}=True
#     :FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
#     \    Run keyword if    ${num}%2 and '${B_Odd}'=='True'    MCS Set Even Attenuations    attenuation=${${attenuation}}    
#     \    ...    begin_input_port=${1}    end_input_port=${64}    output_port=${${num}}
#     \    Run keyword if    ${num}%2==0 and '${B_Odd}'=='False'    MCS Set Even Attenuations    attenuation=${${attenuation}}    
#     \    ...    begin_input_port=${1}    end_input_port=${64}    output_port=${${num}}
# 
# MCS Set PA common
#     MCS Setup    ip=${mcs_ip}    model=${mcs_model}    vendor=hbte
#     Set Odd By Output_port    begin_output_port=1    end_output_port=16    attenuation=0    B_Odd=True
#     Set Odd By Output_port    begin_output_port=1    end_output_port=16    attenuation=90    B_Odd=False
#     Set Even By Output_port    begin_output_port=1    end_output_port=16    attenuation=90    B_Odd=True
#     Set Even By Output_port    begin_output_port=1    end_output_port=16    attenuation=0    B_Odd=False
#     MCS Teardown
# 	
# MCS Set PA 20
#     MCS Setup    ip=${mcs_ip}    model=${mcs_model}    vendor=hbte
#     Set Odd By Output_port    begin_output_port=1    end_output_port=16    attenuation=20    B_Odd=True
#     Set Odd By Output_port    begin_output_port=1    end_output_port=16    attenuation=90    B_Odd=False
#     Set Even By Output_port    begin_output_port=1    end_output_port=16    attenuation=90    B_Odd=True
#     Set Even By Output_port    begin_output_port=1    end_output_port=16    attenuation=20    B_Odd=False
#     MCS Teardown
