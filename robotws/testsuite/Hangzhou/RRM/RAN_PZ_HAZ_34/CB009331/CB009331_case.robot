# *** Settings ***
# Documentation     author: Wang Ming
# ...               contact: ming.5.wang@nokia-sbell.com
# ...               squad group: SG_02
# Suite Setup    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# Force Tags        5G_RRM
# ...    PY36
# Library           OperatingSystem
# Library           Collections
# Library           BuiltIn
# Library           String
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource          ../5GC001655/Resources/1347_common_keyword.robot
# Resource          ../5GC001655/Resources/5GC001116_MTK_common_keyword.robot
# Resource          ../5GC000534_EB/Resources/MCS.robot
# Resource          ../5GC002538/Resources/2538_keyword.robot
# 
# 
# *** Variables ***
# ${tl_path}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
# ${scf_path}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
# ${_scf_file_path}    ${scf_path}/commom_9331.xml
# ${tmp_swconfig_dir}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt
# @{beamset_horizontal}    -26    -26    0    0    26    26    0    0    -26    -26    0    0    26    26    0    0
# @{beamset_vertical}    96    96    96    96    96    96    96    96    96    96    96    96    96    96    102    102
# ${pa_value}    25
# @{pa_port}    1    2    3    4    5    6    7    8    9    10    11    12    13    14    15    16    17    18
# ...    19    20    21    22    23    24    25    27    28    29    30    31    32
# 
# 
# *** Test Cases ***
# CB009331_case
#     [Tags]    5GC001086    CIT_TRUNK
#     [Setup]    Case Setup
#     Reload Case SCF and Commission    scf_file=${_scf_file_path}
#     COAM Wait for gnb ready and cell setup    gnb_type='SA'
# 	${cellid}    Get NRcellid list
# 	Remove Values From List    ${cellid}    ${cellid}[1]
# 	Set Test Variable    ${cellid}
# 	CPE Attach And Check Tput
#     Capture BIP Log and Download By Web
#     [Teardown]    Case Teardown
# 
# 
# *** Keywords ***
# Case Setup
#     COAM Create log directory
#     Connect to gnb coam via ssl
#     robot_common_operations.Common Case Setup
# 
# 
# Case Teardown
#     Comment    Run Keyword And Ignore Error    Recover swconfig file
#     Comment    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${_scf_file_path}
#     Run Keyword And Ignore Error    COAM Teardown gnb connections
#     robot_common_operations.Common Case Teardown
# 	
# 
# MCS Set Beam
#     [Arguments]    ${begin_output_port}    ${end_output_port}    ${vertical_angle}    ${horizontal_angle}
#     MCS Setup    ip=${tl.mcses.ip_addr}    vendor=hbte
#     FOR    ${num}    IN RANGE    ${${begin_output_port}}    ${${end_output_port}}+1
#         ${index}    evaluate    ${num}-1
#         MCS Set Phases According to Angles    vertical_angle=${${vertical_angle}[${index}]}
#         ...    horizontal_angle=${${horizontal_angle}[${index}]}    vertical_distance=${2.1}
#         ...    horizontal_distance=${0.5}    output_group_id=${num}
#     END
#     MCS Teardown
# 
# UE Attach For MTU
#     [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_SA
#     ${ue_type}    Get UE type    ue_index=${ue_index}
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    get_spark_license=${false}    power_reset=False
#     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}    power_reset=False
#     power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
#     [Teardown]
# 
# UE Send DL Traffic
#     [Arguments]    ${ue_index}=${0}    ${send_traffic}=1500M/sec    ${send_duration}=3600   ${ue_mode}=NSA
#     ${ue_type}    Get UE type    ue_index=${ue_index}
#     power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
#     ...    throughput=${send_traffic}    duration=${send_duration}    ue_mode=${ue_mode}
# 
# UE Send UL Traffic
#     [Arguments]    ${ue_index}=${0}    ${send_traffic}=50M/sec    ${send_duration}=3600   ${ue_mode}=NSA
#     ${ue_type}    Get UE type    ue_index=${ue_index}
#     power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
#     ...    throughput=${send_traffic}    duration=${send_duration}    ue_mode=${ue_mode}
# 
# UE Check DL Traffic
#     [Arguments]    ${ue_index}=${0}    ${direction}=dl
#     ${output}    spark.check_throughput_on_ue    ue_alias=UE_${ue_index}
#     ${tput}    run keyword if    '${direction}'=='ul'    Evaluate    ${output[0]} / 1024 / 1024
#     ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${output[1]} / 1024 / 1024
#     [return]    ${tput}
# 
# UE Check UL Traffic
#     [Arguments]    ${ue_index}=${0}    ${direction}=ul
#     ${output}    spark.check_throughput_on_ue    ue_alias=UE_${ue_index}
#     ${tput}    run keyword if    '${direction}'=='ul'    Evaluate    ${output[0]} / 1024 / 1024
#     ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${output[1]} / 1024 / 1024
#     [return]    ${tput}
# 
# MTU Stop traffic
#     [Arguments]    ${ue_index}=${0}    ${direction}=dl    ${ue_mode}=SA    ${apn_address}=ims
#     ${ue_type}    Get UE type    ue_index=${ue_index}
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_mode=${ue_mode}
#     ...    ue_index=${ue_index}    apn_address=${apn_address}
# 
# MTU Stop Ul traffic
#     [Arguments]    ${ue_index}=${0}    ${direction}=ul    ${ue_mode}=SA    ${apn_address}=ims
#     ${ue_type}    Get UE type    ue_index=${ue_index}
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_mode=${ue_mode}
#     ...    ue_index=${ue_index}    apn_address=${apn_address}
# 
# Multi UE Attach And Send Traffic
#     [Arguments]    ${send_dl}=1500M/sec    ${send_ul}=200M/sec    ${send_duration}=3600    ${num}=1
#     FOR    ${ue_no}    IN RANGE    ${num}
#         UE Attach For MTU    ue_index=${ue_no}
#         sleep    2s
#         Run Keyword And Continue On Failure    UE Send DL Traffic    ue_index=${ue_no}
#         ...    send_traffic=${send_dl}    send_duration=${send_duration}
# 		Run Keyword And Continue On Failure    UE Send UL Traffic    ue_index=${ue_no}
#         ...    send_traffic=${send_ul}    send_duration=${send_duration}
#     END
# 
# Multi UE Check Tput
#     [Arguments]    ${num}=1    ${check_dl}=1400    ${check_ul}=200
#     FOR    ${ue_no}    IN RANGE    ${num}
#         ${dl_tput}    UE Check DL Traffic    ue_index=${ue_no}
#         Run Keyword And Continue On Failure    Should Be True    ${dl_tput}>${check_dl}
# 		${ul_tput}    UE Check UL Traffic    ue_index=${ue_no}
# 		Run Keyword And Continue On Failure    Should Be True    ${ul_tput}>${check_ul}
#     END
# 
# Multi UE Attach And Send UL Traffic
#     [Arguments]    ${send_traffic}=260M/sec    ${send_duration}=3600    ${num}=1
#     FOR    ${ue_no}    IN RANGE    ${num}
#         UE Attach For MTU    ue_index=${ue_no}
#         sleep    2s
#         Run Keyword And Continue On Failure    UE Send UL Traffic    ue_index=${ue_no}
#         ...    send_traffic=${send_traffic}    send_duration=${send_duration}
#         sleep    120s
#     END
# 
# Multi UE Check UL Tput
#     [Arguments]    ${num}=1    ${check_tput}=1
#     FOR    ${ue_no}    IN RANGE    ${num}
#         ${tput}    UE Check UL Traffic    ue_index=${ue_no}
#         Run Keyword And Continue On Failure    Should Be True    ${tput}>${check_tput}
#     END
# 
# Multi UE Stop traffic
#     [Arguments]    ${num}=1
#     FOR    ${ue_no}    IN RANGE    ${num}
#         MTU Stop traffic    ue_index=${ue_no}
#     END
# 
# Multi UE Stop UL traffic
#     [Arguments]    ${num}=1
#     FOR    ${ue_no}    IN RANGE    ${num}
#         MTU Stop Ul traffic    ue_index=${ue_no}
#         UE Detach For MTU    ue_index=${ue_no}
#     END
# 
# UE Detach For MTU
#     [Arguments]    ${ue_index}=${0}
#     ${ue_type}    Get UE type    ue_index=${ue_index}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=False
# 
# Reload Case SCF and Commission
#     [Arguments]    ${scf_file}
#     Connect to gnb coam via ssl
#     Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${scf_file}
#     COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'
# 
# 
# UE Attach For CPE
#     [Arguments]    ${ue_index}=${0}
#     ${ue_type}    Get UE type    ue_index=${ue_index}
# 	power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
# 	${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
# 	power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
#     [Teardown]
# 
# UE Send Traffic
#     [Arguments]    ${ue_index}=${0}    ${dl_traffic}=1500M/sec    ${ul_traffic}=200M/sec    ${send_duration}=900    
# 	...    ${iperf_port}=${tl.appserver.iperf_details.port}
# 	${ue_type}    Get UE type    ue_index=${ue_index}
# 	power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
# 	...    throughput=${dl_traffic}    duration=${send_duration}    iperf_port=${iperf_port}
# 	power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
# 	...    throughput=${ul_traffic}    duration=${send_duration}    iperf_port=${iperf_port}
# 
# UE Check Traffic
#     [Arguments]    ${ue_index}=${0}    ${dl_target}=${1200}    ${ul_target}=${100}
# 	${ue_type}    Get UE type    ue_index=${ue_index}
# 	${full_log_path}    power_ue.Collect Tput    ue_type=${ue_type}    ue_index=${ue_index}
# 	power_ue.Check Tput    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    
# 	...    target_throughput=${dl_target}    log=${full_log_path}    cells=${cellid}
# 	power_ue.Check Tput    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    
# 	...    target_throughput=${ul_target}    log=${full_log_path}    cells=${cellid}
# 
# UE Detach For CPE
#     [Arguments]    ${ue_index}=${0}
# 	${ue_type}    Get UE type    ue_index=${ue_index}
# 	Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    
# 	...    direction=dl    iperf_port=${tl.appserver.iperf_details.port}
# 	Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    
# 	...    direction=ul    iperf_port=${tl.appserver.iperf_details.port}
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
# 
# CPE Attach And Check Tput
#     [Arguments]
# 	UE Attach For CPE
# 	UE Send Traffic
# 	UE Check Traffic
# 	[Teardown]    UE Detach For CPE