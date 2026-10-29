# *** Settings ***
# Documentation     author: zhangqingqing
# ...                 contact: qingqing.zhang@nokia-sbell.com
# ...                 squad group: SG_03
# ...                 feature : 5GC000784
# 
# 
# Force Tags    CA_5G_RRM
# ...    PY36
# Resource    ./../../5GC000710/Resources/5GC000710_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
# Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000784/5GC000784-A/Resources/5GC00784_A_variables.py
# 
# Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup    AND
# ...    Common Suite Setup for COAM    AND
# ...    Precondition for cell on air    gnb_index=${0}    tl_scf_file_name=${tl_scf_file_name}    AND
# ...    Get release info    AND
# ...    prepare UE AND PA    value1=${3}    value2=${127}    value3=${127}
# 
# 
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND
# ...               Run Keyword If Any Tests Failed    Run Keyword And Ignore Error
# ...               Common Suite Teardown for COAM    gnb_index=${0}
# 
# *** Variables ***
# ${gnb_path}    /tmp
# ${enb_path}    /tmp/
# #${tl_scf_file_name}    2056_786_D_03_gNB1.xml
# ${tl_scf_file_name}    gNB1_Golden_SCF.xml
# ${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
# ${scf_file_enb}    784_AB_eNB.xml
# ${interface1}    any
# ${interface_s1ap}    br1
# ${nglogname1_1st}    784A01_1st.pcap
# ${nglogname1_2nd}    784A01_2nd.pcap
# 
# ${dxdata2_apn}    95 943
# 
# *** Test Cases ***
# [1]5GC000784_A_01_Verify_successful_EC_setup_UE_in_connected_state_with_ongoing_data_service_via_different_NGAP_procedure
#     [Documentation]
#     [Tags]    CRT_TRUNK    CRT_22R2    5GC000784-A    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
#     [Setup]
#     robot_common_operations.Common Case Setup
#     Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_A01_pre}
#     Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_COUNTER}
#     Power UE Attach and Verify attach
#     Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_A01}
#     Make a EC and check successful procedure    nglogname=${nglogname1_1st}
#     sleep    20s
#     Prepare with PM counter time to caculate    period=start
#     Make a EC and check successful procedure    nglogname=${nglogname1_2nd}
#     Prepare with PM counter time to caculate    period=end
#     Check the PM counter shuould be specific value    value=${1}
#     ...    counter_id=${counter_id_A27_should_be_1}    dic_path=${counter_dic_path_A27_should_be_1}    timeout=${600}
#     run keyword    Check the PM counter shuould not zero    counter_id=${counter_id_A27_not_zero}
#     ...    dic_path=${counter_dic_path_A27_not_zero}    value=${1}    timeout=${600}
#     run keyword    Check the PM counter shuould not zero for counter2    counter_id=${counter_id_A27_not_zero_2}
#     ...    dic_path=${counter_dic_path_A27_not_zero_2}    value=${1}    timeout=${600}
#     [Teardown]    run keywords
#     ...           robot_common_operations.Common Case Teardown
#     ...           AND    Online modify parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_A01_recover}
#     ...           AND    Run Keyword And Ignore Error    Tear down wireshark log and detach
# 
# *** Keywords ***
# Precondition for power UE
#     [Arguments]    ${ue_type}    ${ui_version}=S20UI2.5    ${ue_index}=${0}
#     power_ue.Prepare UE    ue_type=${ue_type}    ui_version=${ui_version}    ue_index=${ue_index}    reset_sol=pc_reset
# 
# Power UE Attach and Verify attach
# #    Run Keyword if    '${release}' != 'SBTS21B_ENB_0000'
# #    ...    Start Capture Wireshark Logs on gNB   nglogname=${logname}    gnb_index=${gnb_index}
# #    ...    ELSE    Start Capture Wireshark Logs on gNB Slave     gnb_index=${gnb_index}    logname=${logname}
#     Precondition for power UE    ue_type=${ue_type}    ui_version=default
#     set apn to wap2    usedapn=${dxdata2_apn}
#     make WA with Samsung S21
#     5GC000710_common_keyword.Attach and check power UE    ue_type=${ue_type}
# 
# prepare UE AND PA
#     [Arguments]    ${value1}    ${value2}    ${value3}
#    Precondition for attn    value1=${value1}    value2=${value2}    value3=${value3}
# 
# Precondition for attn
#     [Arguments]    ${value1}    ${value2}    ${value3}
#     Run Keyword if    '${release}' == 'SBTS21B_ENB_0000'    Precondition for attn 21B    value1=${value1}    value2=${value2}
#     ...    value3=${value3}
#     ...    ELSE IF     '${release}' == 'SBTS22R1_ENB_0000'    Precondition for attn Trunk    value1=${value1}    value2=${value2}
#     ...    value3=${value3}
#     ...    ELSE    Precondition for attn Trunk    value1=${value1}    value2=${value2}    value3=${value3}
# 
# Precondition for attn Trunk
#     [Arguments]    ${value1}    ${value2}=${127}    ${value3}=${127}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_3}    att_port_2=${att_port_4}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_5}    att_port_2=${att_port_6}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value2}    att_port_1=${att_port_7}    att_port_2=${att_port_8}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
# 
# Precondition for attn 21B
#     [Arguments]    ${value1}    ${value2}=${127}    ${value3}=${127}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_3}    att_port_2=${att_port_4}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_5}    att_port_2=${att_port_6}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_7}    att_port_2=${att_port_8}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
# 
# Precondition for attn 22R1
#     [Arguments]    ${value1}    ${value2}    ${value3}=${127}
#     adjust the HBTE attenuation value    value=${value1}    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_3}    att_port_2=${att_port_4}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_5}    att_port_2=${att_port_6}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value2}    att_port_1=${att_port_7}    att_port_2=${att_port_8}    atten_ip=${atten_ip}
#     adjust the HBTE attenuation value    value=${value3}    att_port_1=${att_port_9}    att_port_2=${att_port_10}    atten_ip=${atten_ip}
# 
# Make a EC and check successful procedure
#     [Arguments]    ${nglogname}    ${ue_index}=${2}
#     Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface1}
# #    Connect to control pc via cygwin    ue_index=${ue_index}
#     Make an emergency call on UE
#     Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}
#     Check wireshark log for successful EC procedure    logname=${nglogname}
# 
# 
# Make an emergency call on UE
#     [Arguments]    ${serial_number}=${tl.ues[0].serial_number}
#     Make a call on UE dial 911 on UE
#     End an emergency call on UE
# 
# Make a call on UE dial 911 on UE
#     [Arguments]    ${serial_number}=${tl.ues[0].serial_number}
#     csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
#     ...    username=${tl.ues[0].ssh_connection_details.username}
#     ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin
#     sleep   5s
#     Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin
#     sleep   2s
#     Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin
#     sleep   2s
#     csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:911    connection=cygwin
#     sleep   5s
#     csn.send_command    command=adb -s ${serial_number} shell input keyevent 66    connection=cygwin
#     sleep   30s
#     check voice call status
#     [Teardown]    csn.disconnect      connection=cygwin
# 
# End an emergency call on UE
#     [Arguments]    ${serial_number}=${tl.ues[0].serial_number}
#     csn.Connect to    hostname=${tl.ues[0].ssh_connection_details.addr}
#     ...    username=${tl.ues[0].ssh_connection_details.username}
#     ...    password=${tl.ues[0].ssh_connection_details.password}    alias=cygwin
#     sleep   5s
#     #####Press the Home button to open the screen#####
#     Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
#     ...    connection=cygwin
#     sleep   2s
#     #####Swipe up to unlock the phone#####
#     Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
#     ...    connection=cygwin
#     sleep   2s
#     #####Samsung S21 WA to click time cancel
#     csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
#     sleep    2s
#     csn.send_command    command=adb -s ${serial_number} shell input tap 485 37    connection=cygwin
#     sleep    2s
#     csn.send_command    command=adb -s ${serial_number} shell input tap 360 30    connection=cygwin
#     sleep    2s
#     csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
#     ...    connection=cygwin
#     sleep   20s
#     check voice call status    status=${0}
#     [Teardown]    csn.disconnect      connection=cygwin
# 
# check voice call status
#     [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=${2}
#     Wait Until Keyword Succeeds    6x    5s    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
#     ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
#     ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
#     sleep   2s
#     ##### check voice call enable  #####
#     ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
#     csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
#     ...    connection=cpc_${ue_index}
#     sleep   2s
#     ${result} =    csn.read output    connection=cpc_${ue_index}
#     sleep    1s
#     should contain    ${result}    mCallState=${status}
#     [Teardown]    csn.disconnect      connection=cpc_${ue_index}
# 
# Check wireshark log for successful EC procedure
#     [Arguments]    ${logname}
#     Check wireshark log for EC setup    logname=${logname}
#     Check wireshark log for EC 5QI 5    logname=${logname}
#     Check wireshark log for EC 5QI 1    logname=${logname}
#     Check wireshark log for EC release    logname=${logname}
# 
# Check wireshark log for EC setup
#     [Arguments]    ${logname}
#     Check wireshark log for VoNR    logname=${logname}
#     ...    message_filter=ngap.procedureCode == 46 and nas_5gs.mm.req_type == 3
#     ...    xpath_filter=nas_5gs.mm.req_type    expect_value=3
# 
# Check wireshark log for EC 5QI 1
#     [Arguments]    ${logname}
#     Check wireshark log for VoNR    logname=${logname}
#     ...    message_filter=ngap.procedureCode == 26 and ngap.fiveQI == 1
#     ...    xpath_filter=ngap.fiveQI    expect_value=1
#     Check wireshark log for VoNR    logname=${logname}
#     ...    message_filter=ngap.procedureCode == 26 and ngap.priorityLevelARP == 1
#     ...    xpath_filter=ngap.priorityLevelARP    expect_value=1
# 
# Check wireshark log for EC 5QI 5
#     [Arguments]    ${logname}
#     Check wireshark log for VoNR    logname=${logname}
#     ...    message_filter=ngap.fiveQI == 5 and ngap.priorityLevelARP == 1
#     ...    xpath_filter=ngap.fiveQI    expect_value=5
# 
# Check wireshark log for EC release
#     [Arguments]    ${logname}
#     Check wireshark log for VoNR    logname=${logname}
#     ...    message_filter=ngap.procedureCode == 28 and ngap.nas == 0
#     ...    xpath_filter=ngap.nas    expect_value=0
#     Check wireshark log for VoNR    logname=${logname}
#     ...    message_filter=ngap.procedureCode == 28
#     ...    xpath_filter=ngap.PDUSessionResourceReleaseResponse_element
#     ...    expect_value=PDUSessionResourceReleaseResponse
#     ...    attribute_name=showname
# 
# Check wireshark log for VoNR
#     [Arguments]    ${logname}    ${message_filter}    ${xpath_filter}    ${expect_value}    ${attribute_name}=show
#     ...    ${command_template}=${command_template_Y}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
#     ...    command_template=${command_template}
#     ${filter_expression}=     Catenate    ${message_filter}
#     ${filtered_packets}=    parser.filter_packets_by_expression
#     ...    filter_expression=${filter_expression}
#     ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
#     ...    xpath=.//${xpath_filter}
#     ...    attribute_name=${attribute_name}
#     should be equal    ${filtered_value[0]}    ${expect_value}
# 
# Check the PM counter shuould be specific value
#     [Arguments]    ${counter_id}    ${dic_path}    ${value}    ${timeout}=${60}
#     ${counter_lenth}    Get Length    ${counter_id}
#     Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#     ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#     ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
#     :For    ${index}    INRANGE    ${counter_lenth}
#     \    ${counter_value}=    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
#          ...    dic_path=${dic_path[${index}]}    timeout=${timeout}
#     \    Should contain    ${counter_value}    ${value}
#     [Teardown]    COAM Teardown gnb connections
# 
# Check the PM counter shuould not zero
#     [Arguments]    ${counter_id}    ${dic_path}    ${value}    ${timeout}=${60}
#     ${counter_lenth}    Get Length    ${counter_id}
#     Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#     ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#     ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
#     :For    ${index}    INRANGE    ${counter_lenth}
#     \    ${counter_value}=    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
#          ...    dic_path=${dic_path[${index}]}    timeout=${timeout}
#     \    should contain any    ${counter_value}    ${value}
#     [Teardown]    COAM Teardown gnb connections
# 
# Check the PM counter shuould not zero for counter2
#     [Arguments]    ${counter_id}    ${dic_path}    ${value}    ${timeout}=${60}
#     ${counter_lenth}    Get Length    ${counter_id}
#     Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#     ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#     ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
#     :For    ${index}    INRANGE    ${counter_lenth}
#     \    ${counter_value}=    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
#          ...    dic_path=${dic_path[${index}]}    timeout=${timeout}
#     \    should contain any    ${counter_value}    ${value}
#     [Teardown]    COAM Teardown gnb connections
# 
# Check the PM counter shuould not be zero
#     [Arguments]    ${counter_id}    ${dic_path}
#     ${counter_result_value}    Create List
#     ${counter_result}    Create List
#     ${counter_lenth}    Get Length    ${counter_id}
#     Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#     ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#     ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
#     :For    ${index}    INRANGE    ${counter_lenth}
#     \    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
#          ...    dic_path=${dic_path[${index}]}
#     \    ${counter_dict}    Create Dictionary    ${counter_id[${index}]}=${counter_value[0]}
#     \    append to list    ${counter_result_value}    ${counter_value[0]}
#     \    append to list    ${counter_result}    ${counter_dict}
#     ${counter_result_lenth}    Get Length    ${counter_result_value}
#     Should be equal    ${counter_lenth}    ${counter_result_lenth}
#     Should not contain    ${counter_result_value}    ${0}    msg=check counter fail
#     [Teardown]    COAM Teardown gnb connections
# 
# Record the counter action timer
#     @{utc0} =    Get Time    hour min sec    UTC
#     ${utc0_min} =    convert to integer  @{utc0}[1]
#     ${utc_min} =    Evaluate    ${utc0_min}%5
#     Run Keyword If    ${utc_min}>3    Record time again
# #    ${utc_left} =    Evaluate    5-${utc_min}+1
#     ${utc_left} =    Evaluate    5-${utc_min}
#     set test variable    ${utc_left}
# 
# Record time again
#     sleep    1min
#     @{utc0} =    Get Time    hour min sec    UTC
#     ${utc0_min} =    convert to integer  @{utc0}[1]
#     ${utc_min} =    Evaluate    ${utc0_min}%5
#     Set Suite Variable    ${utc_min}
# 
# Get release info
#     ${release_info}    Get sagnb release
#     Set Suite Variable    ${release}    ${release_info}
# 
# Get sagnb release
#     [Arguments]   ${host}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#     ...    ${username}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#     ...    ${password}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#     csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
#     ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
# #    ${release_info}     set variable    ${info.split('_')[1]}
#     ${release_info}    set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
#     [Return]    ${release_info}
#     [Teardown]   csn.Disconnect   connection=release_info
# 
# Test recover
#     power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
# 
# Tear down wireshark log and detach
#     run keywords
#     ...    run keyword and ignore error    Teardown Stop Capture Wireshark Logs on gNB    AND
#     ...    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${0}
# 
# Teardown Stop Capture Wireshark Logs on gNB
#     [Arguments]    ${connection}=Local gnb1
#     gNB connections to ssh    connection=${connection}
#     csn.send command    command=killall tcpdump     connection=${connection}
#     sleep    3
#     [Teardown]    csn.disconnect    connection=${connection}
# 
# make WA with Samsung S21
#     [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#     Connect to control pc via cygwin    ue_index=${ue_index}
#     sleep   5s
#     Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
#     sleep   2s
#     Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
#     sleep   4s
#     #####Samsung S21 WA to click time cancel
#     csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
#     sleep    2s
#     [Teardown]    csn.disconnect    connection=cygwin