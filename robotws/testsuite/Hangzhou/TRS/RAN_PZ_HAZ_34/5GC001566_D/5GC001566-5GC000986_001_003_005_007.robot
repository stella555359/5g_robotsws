# *** Settings ***
# Force Tags    PY36
# Documentation     author: Steven Liu
# ...               contact: steven.liu@nokia-sbell.com
# ...               squad group: MMW_SG_04
# 
# Suite Setup       Tests_suite_setup
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource          ./Resources/1566_D_Keywords.robot
# #Resource          ../../../../resources/common/DEPRECATED/wireshark_parsing.robot
# Variables         ./Resources/5GC001566_modify_para.py
# Library           taf.sbts.oam.coam.admin    WITH NAME    admin
# Library    taf.analyzer.pcap    WITH NAME    cap
# 
# *** Variables ***
# ${BTS_NAME}                   ${tl.gnbs[0].instance_id}
# ${DU_OAM_IP}                  ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${WEBEM_USERNAME}             ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBEM_PASSWORD}             ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${fault_ip}                   10.101.48.65
# ${ID}                         1
# ${file_name}                  st_tcpdump_ca_dl7.pcap
# ${bfd_stat}                   bfd.sta == 0x3
# ${bfd_local_to_dest}          ip.src == 10.101.53.4 && ip.dst == 10.101.53.1 && bfd.flags.p == 1 && bfd.flags.f == 0
# ${bfd_dest_to_local}          ip.src == 10.101.53.1 && ip.dst == 10.101.53.4 && bfd.flags.p == 0 && bfd.flags.f == 1
# ${bfd_valid_IP}               10.101.53.1
# ${check_param1}               bfd.desired_min_tx_interval
# ${max_interval1}              625000
# ${min_interval1}              375000
# ${max_interval2}              1250000
# ${min_interval2}              750000
# ${ip_filter}                  ip.src == 10.101.53.4
# ${luashark_path}             /opt/ute/luashark/luashark_script/generated_luashark
# 
# *** Test Cases ***
# [1]5GC001566-5GC000986_001_NE_ipv6_shall_support_a_read-only_parameter_actFastIpRerouting_TRUE
#     [Documentation]    Add IPV6 actFastIpRerouting become true
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Setup]
#     Step1: Modify Configuration 001
#     Step2: Check actFastIpRerouting
#     [Teardown]    Teardown configuration 001
# 
# [1]5GC001566-5GC000986_003_BFD_Deactivation_with_alarm
#     [Documentation]    BFD Deactivation with alarm ID
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Setup]
#     Step1: Modify Configuration 003
#     Step2: Modify Configuration1
#     Step3: Check Alarm Info
#     Step4: Modify Configuration2
#     Step5: Check None Alarm Info
#     [Teardown]    Teardown configuration 003
# 
# [1]5GC001566-5GC000986_005_BFD_Poll_Sequence_after_not_reciving_P_bit_F_bit_should_be_clear
#     [Documentation]    BFD Poll Sequence after not reciving P bit F bit should be clear
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Setup]
#     Step1: Start Tcpdump
#     Step2: Modify Configuration
#     Convert pcap to text And Get txt Content    pacp_filename=${file_name}    txt_filename=testcase5.txt
#      ...    condition_expression=${bfd_local_to_dest}
#     [Teardown]    Teardown configuration 003
# 
# [1]5GC001566-5GC000986_007_after_BFD_Poll_Sequence_NE_should_immediately_use_new_value
#     [Documentation]    after BFD Poll Sequence NE should immediately use new value
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Setup]
#     Step1: Modify Configuration to add BFD
#     Step2: Check bfdDscp state
#     Step3: Modify BFD desMinTxlnt to 500
#     Step4: Check bfdDscp state
#     Convert pcap And Get Content    pacp_filename=${filename}    txt_filename=testcase5.txt
#      ...    condition_expression=${ip_filter}
#     Step6: Modify BFD desMinTxlnt to 1000
#     Step7: check TX to 1000
#     [Teardown]    Teardown configuration 003
# 
# *** Keywords ***
# 
# Convert pcap to text And Get txt Content
#     [Arguments]      ${pacp_filename}  ${txt_filename}   ${condition_expression}
#     csn.connect_to    hostname=${test_ute}    username=${ute_name}    password=${test_password}
#     ...    alias=connection_ute
#     csn.send command   command=/usr/bin/tshark -r ${output_dir}/${pacp_filename} -X ${lua_path} -Y "${bfd_local_to_dest}"
#     ...    connection=connection_ute
#     ${return_value}    csn.Read Output    connection=connection_ute
#     run keyword and continue on failure    should not be empty    ${return_value}
#     csn.send command   command=/usr/bin/tshark -r ${output_dir}/${pacp_filename} -X ${lua_path} -Y "${bfd_dest_to_local}"
#     ...    connection=connection_ute
#     ${return_value}    csn.Read Output    connection=connection_ute
#     run keyword and continue on failure    should not be empty    ${return_value}
#     [Teardown]  Run keyword and ignore error    csn.Disconnect	connection=connection_ute
# 
# 
# Convert pcap And Get Content
#     [Arguments]      ${pacp_filename}  ${txt_filename}   ${condition_expression}
#     csn.connect_to    hostname=${test_ute}    username=${ute_name}    password=${test_password}
#     ...    alias=connection_ute
#     csn.send command
#     ...    command=/usr/bin/tshark -r ${output_dir}/${filename} -X ${lua_path} -Y "${ip_filter}" -T fields -e bfd.desired_min_tx_interval
#     ...    connection=connection_ute
#     ${return_value}    csn.Read Output    connection=connection_ute
#     @{return_value}    Split To Lines    ${return_value}
#     ${return_value}    Evaluate     map(eval, ${return_value})
#     FOR    ${item}    IN    @{return_value}
#         should be true    ${min_interval1}<${item}<${max_interval1}
#     END
#     [Teardown]  Run keyword and ignore error    csn.Disconnect	connection=connection_ute
# 
# Tests_suite_setup
#     Input default SCF
# 
# Step1: Modify Configuration 001
#     Cloud DU connect to gnb coam via ssl
#     perform muti object recommissioning    dist_name=${IPAPP_distname_1}     parameter=${PARAMS_IPAPP_1}
#     perform muti object recommissioning    dist_name=${BFD_distname_1}      parameter=${PARAMS_BFD_1}
#     perform muti object recommissioning    dist_name=${Trigger_distname_8}    parameter=${PARAMS_TRIGGER_8}
#     perform muti Parameter recommissioning    dist_name=${IPRT_distname_8}    parameter=staticRoutes     value=${PARAMS_staticRoutes_8}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${IPV6_distname_1}    parameter=staticIpv6Routes     value=${PARAMS_staticIpv6Routes_1}
#     ...    operation=update
#     [Teardown]    COAM Teardown gnb connections
# 
# Step2: Check actFastIpRerouting
#     Login Page Via WebUI
#     Log To Console      \n start get actFastIpRerouting
#     ${trig_state}    selenium_coam.get parameter value    dist_name=${TNL_R_distname_1}
#     ...                              filter_param=Feature activation flag for Fast IP Rerouting
#     should be equal    ${trig_state}    true
#     selenium_coam.logout
# 
# Login Page Via WebUI
#     selenium_coam.Enable Virtual Display
#     :FOR    ${var}    IN RANGE    10
#     \    ${login_result}    ${error}    Run Keyword And Ignore Error    selenium_coam.Login
#         ...    url=https://${DU_OAM_IP}
#         ...    username=${WEBEM_USERNAME}
#         ...    password=${WEBEM_PASSWORD}
#     \    ${logout_result}    ${error}    Run Keyword If    '${login_result}'=='FAIL'    Run Keyword And Ignore Error    selenium_coam.Logout
#     \    Exit For Loop If    '${login_result}'=='PASS'
#     \    Sleep    5s
#     selenium_coam.Disable Message Box
#     selenium_coam.Disable Screen Lock
# 
# Teardown configuration 001
#     Cloud DU connect to gnb coam via ssl
#     perform muti object recommissioning    dist_name=${IPAPP_distname_1}     parameter=${PARAMS_IPAPP_1}    operation=delete
#     perform muti object recommissioning    dist_name=${Trigger_distname_8}    parameter=${PARAMS_TRIGGER_8}    operation=delete
#     perform muti Parameter recommissioning    dist_name=${IPRT_distname_8}    parameter=staticRoutes     value=${PARAMS_staticRoutes_8_8}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${IPV6_distname_1}    parameter=staticIpv6Routes     value=${PARAMS_staticIpv6Routes_1}
#     ...    operation=delete
#     COAM Teardown gnb connections
# 
# Step1: Modify Configuration 003
#     1566_D_Keywords.Check cell on air
#     Cloud DU connect to gnb coam via ssl
#     perform muti object recommissioning    dist_name=${IPAPP_distname_1}     parameter=${PARAMS_IPAPP_1}
#     perform muti object recommissioning    dist_name=${BFD_distname_1}      parameter=${PARAMS_BFD_1}
#     sleep     10s
#     [Teardown]    COAM Teardown gnb connections
# 
# Step2: Modify Configuration1
#     Cloud DU connect to gnb coam via ssl
#     perform muti Parameter recommissioning    dist_name=${BFD_distname_1}    parameter=bfdDestIpAddr    value=10.101.48.65
#     ...    operation=update
#     [Teardown]    COAM Teardown gnb connections
# 
# Step3: Check Alarm Info
#     Check bfd Alarm Info
# 
# Step4: Modify Configuration2
#     Cloud DU connect to gnb coam via ssl
#     perform muti Parameter recommissioning    dist_name=${BFD_distname_1}    parameter=bfdActivation    value=${false}
#     ...    operation=update
#     [Teardown]    COAM Teardown gnb connections
# 
# Step5: Check None Alarm Info
#     Check None bfd Alarm Info
# 
# Check bfd Alarm Info
#     ${conn}    Connect to DU
#     Wait Until Keyword Succeeds    2min    10s    Check Alarm Info    connection=${conn}
#     [Teardown]    Disconnect from DU
# 
# Check None bfd Alarm Info
#     ${conn}    Connect to DU
#     Wait Until Keyword Succeeds    2min    10s    Check None Alarm Info    connection=${conn}
#     [Teardown]    Disconnect from DU
# 
# Check Alarm Info
#     [Arguments]    ${connection}=${conn}
#     @{alarms}    coam.get_active_alarms    connection=${connection}    timeout=${100}    #alarm_filter=${alarm_filter}
#     sleep    1s
#     log     ${alarms}
#     ${fault_id_list}    create list
#     ${fault_name_list}    create list
#     :FOR    ${item}    IN    @{alarms}
#     \    ${fault_id}    get from dictionary    ${item}    faultId
#     \    ${fault_name}    get from dictionary    ${item}    faultName
#     \    append to list    ${fault_id_list}    ${fault_id}
#     \    append to list    ${fault_name_list}    ${fault_name}
#     list should contain value     ${fault_id_list}      ${61605}
#     list should contain value     ${fault_name_list}    BFD-1 down in ingress
# 
# Check None Alarm Info
#     [Arguments]    ${connection}=${conn}
#     @{alarms}    coam.get_active_alarms    connection=${connection}    timeout=${100}    #alarm_filter=${alarm_filter}
#     sleep    1s
#     log     ${alarms}
#     ${fault_id_list}    create list
#     ${fault_name_list}    create list
#     :FOR    ${item}    IN    @{alarms}
#     \    ${fault_id}    get from dictionary    ${item}    faultId
#     \    ${fault_name}    get from dictionary    ${item}    faultName
#     \    append to list    ${fault_id_list}    ${fault_id}
#     \    append to list    ${fault_name_list}    ${fault_name}
#     list should not contain value     ${fault_id_list}      ${61605}
#     list should not contain value     ${fault_name_list}    BFD-1 down in ingress
# 
# Teardown configuration 003
#     Cloud DU connect to gnb coam via ssl
#     perform muti object recommissioning    dist_name=${IPAPP_distname_1}     parameter=${PARAMS_IPAPP_1}    operation=delete
#     COAM Teardown gnb connections
# 
# Step1: Start Tcpdump
#     Cloud DU connect to gnb coam via ssl
#     perform muti object recommissioning    dist_name=${IPAPP_distname_1}     parameter=${PARAMS_IPAPP_1}
#     perform muti object recommissioning    dist_name=${BFD_distname_1}      parameter=${PARAMS_BFD_3}
#     sleep     10s
#     Start Capture Logs    logname=${file_name}
# 
# Step2: Modify Configuration
#     perform muti Parameter recommissioning    dist_name=${BFD_distname_1}    parameter=bfdAdminUp    value=${True}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${BFD_distname_1}    parameter=desMinTxInt    value=1000
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${BFD_distname_1}    parameter=reqMinRxInt    value=1000
#     ...    operation=update
#     sleep    10s
#     [Teardown]    COAM Teardown gnb connections
# 
# Step3: Get Tcpdump and check local to dest
#     Stop and Save Logs    logname=${file_name}
#     Check Wireshark Log     filename=${file_name}    condition_expression=${bfd_local_to_dest}
# 
# Step4: Get Tcpdump and check dest to local
#     Check Wireshark Log     filename=${file_name}    condition_expression=${bfd_dest_to_local}
# 
# Check Wireshark Log
#     [Arguments]      ${filename}   ${condition_expression}
#     csn.connect_to    hostname=${test_ute}    username=${ute_name}    password=${test_password}
#     ...    alias=connection_ute
#     csn.send command
#     ...    command=/usr/bin/tshark -r ${output_dir}/${filename} -X ${lua_path} -Y "${bfd_stat}" -T fields -e ${bfd_stat}
#     ...    connection=connection_ute
#     ${return_value}    csn.Read Output    connection=connection_ute
#     [Teardown]  Run keyword and ignore error    csn.Disconnect	connection=connection_ute
# 
# Step1: Modify Configuration to add BFD
#     Cloud DU connect to gnb coam via ssl
#     perform muti object recommissioning    dist_name=${IPAPP_distname_1}    parameter=${PARAMS_IPAPP_1}
#     perform muti object recommissioning    dist_name=${BFD_distname_1}      parameter=${PARAMS_BFD_2}
#     sleep    20s
#     [Teardown]    COAM Teardown gnb connections
# 
# Step2: Check bfdDscp state
#     Start Capture Logs    logname=${filename}
#     Stop and Save Logs    logname=${filename}
#     Check Wireshark Log     filename=${filename}   condition_expression=${bfd_stat}
# 
# Step3: Modify BFD desMinTxlnt to 500
#     [Arguments]    ${desMinTxInt}=500
#     Cloud DU connect to gnb coam via ssl
#     perform muti Parameter recommissioning    dist_name=${BFD_distname_1}    parameter=desMinTxInt   value=${desMinTxInt}
#     ...    operation=update
#     [Teardown]    COAM Teardown gnb connections
# 
# Step4: Check bfdDscp state
#     Start Capture Logs    logname=${filename}
#     Stop and Save Logs    logname=${filename}
#     Check Wireshark Log    filename=${filename}    condition_expression=${bfd_stat}
# 
# Step5: Check TX to 500
#     Start Capture Logs    logname=${filename}
#     Stop and Save Logs    logname=${filename}
#     Read Wireshark Logs     filename=${filename}    filter=${ip_filter}    max_interval=${max_interval1}    min_interval=${min_interval1}
# 
# Read Wireshark Logs
#     [Arguments]    ${filename}    ${filter}=${None}    ${check_param}=${check_param1}    ${dscp_value}=${None}
#     ...    ${max_interval}=${None}    ${min_interval}=${None}
#     cap.Read Cap    cap_file=${output_dir}/${filename}    display_filter=${filter}
#     log to console  Read Wireshark Log successful
#     ${return_dscp}    Get PARAM Value from Wireshark Log    check_param=${check_param}    element_idx=${0}    condition_expression=${none}
#     :FOR    ${item}    IN    @{return_dscp}
#     \    should be true    ${min_interval}<${item}<${max_interval}
# 
# Get PARAM Value from Wireshark Log
#     [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
#     ${value}     cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
#     ...    default_value=${default_value}    condition_expression=${condition_expression}
#     log to console  Get PARAM Value from Wireshark Log successful
#     [Return]    ${value}
# 
# Step6: Modify BFD desMinTxlnt to 1000
#     [Arguments]    ${desMinTxInt}=1000
#     Cloud DU connect to gnb coam via ssl
#     perform muti Parameter recommissioning    dist_name=${BFD_distname}    parameter=desMinTxInt   value=${desMinTxInt}
#     ...    operation=update
#     sleep   20s
#     [Teardown]    COAM Teardown gnb connections
# 
# Step7: check TX to 1000
#     Start Capture Logs    logname=${filename}
#     Stop and Save Logs    logname=${filename}
#     Get Content     filename=${filename}    condition_expression=${ip_filter}
# 
# Get Content
#     [Arguments]      ${filename}   ${condition_expression}
#     csn.connect_to    hostname=${test_ute}    username=${ute_name}    password=${test_password}
#     ...    alias=connection_ute
#     csn.send command
#     ...    command=/usr/bin/tshark -r ${output_dir}/${filename} -X ${lua_path} -Y "${ip_filter}" -T fields -e bfd.desired_min_tx_interval
#     ...    connection=connection_ute
#     ${return_value}    csn.Read Output    connection=connection_ute
#     @{return_value}    Split To Lines    ${return_value}
#     ${return_value}    Evaluate     map(eval, ${return_value})
#     FOR    ${item}    IN    @{return_value}
#         should be true    ${min_interval2}<${item}<${max_interval2}
#     END
#     [Teardown]  Run keyword and ignore error    csn.Disconnect	connection=connection_ute
