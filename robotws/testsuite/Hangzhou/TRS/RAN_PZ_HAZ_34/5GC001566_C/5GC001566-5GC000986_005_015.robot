# *** Settings ***
# Force Tags    PY36
# Documentation     author: Steven Liu
# ...               contact: steven.liu@nokia-sbell.com
# ...               squad group: MMW_SG_04
# 
# Suite Setup       Tests_suite_setup
# 
# #Library           taf.gnb.oam.megazone_client   WITH NAME   megazone
# Library           taf.sbts.oam.coam.admin    WITH NAME    admin
# Library           taf.transport.ssh       WITH NAME   ssh
# Library           ./resources/routes.py
# #Library           ../../../../resources/Python/coam_parameter.py
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_parameter.py
# Variables         ./resources/5GC001566_modify_para.py
# #Resource          ../../../../resources/common/DEPRECATED/wireshark_parsing.robot
# Resource          ./resources/1566_C_resource.robot
# 
# *** Variables ***
# ${file_name}                  st_tcpdump_ca_dl7.pcap
# ${ip_value}                   10.57.243.65
# ${BTS_NAME}                   ${tl.gnbs[0].instance_id}
# ${DU_OAM_IP}                  ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${WEBEM_USERNAME}             ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBEM_PASSWORD}             ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${IPV4_FLAG}=                 -4
# ${DEST_IPV4}=                 20.0.0.0
# ${GATE_IPV4}=                 10.57.243.65
# ${Iface}                      fp0.3
# ${dist_name}                  MRBTS-${BTS_NAME}/TNLSVC-1/TNL-1
# ${bfdDestIpAddr}              10.57.243.65
# ${filter}                     ip.src == 10.57.243.66
# ${lua_path}       lua_script:/opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
# 
# *** Test Cases ***
# [1]5GC001566-5GC000986_005_BFD_ipv4 _to_DSCP_mapping
#     [Documentation]    Create bfd and check being successful
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Setup]
#     Step1: Modify Configuration 005
#     Step2: Get Tcpdump
#     Step3: Check bfdDscp 005
#     [Teardown]    Delete IPAPP_BFD    ip_value=${ip_value}
# 
# [1]5GC001566-5GC000986_015_Action_trigger_is_TRUE_when_BFD_session_is_Deleted
#     [Documentation]    Trigger is TRUE when BFD session is Deleted
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Setup]
#     Step1: Modify Configuration 015
#     Step2: Get Tcpdump
#     Step3: Check bfdDscp 015
#     Step4: Check IPRT
#     Step5: Delete BFD
#     Step6: getPara and check
#     [Teardown]    Teardown configuration
# 
# *** Keywords ***
# Tests_suite_setup
#     Input default SCF
# 
# Step1: Modify Configuration 005
#     Check cell on air
#     Create IPAPP_BFD    ip_value=${ip_value}
# 
# Step2: Get Tcpdump
#     Start Capture Logs    logname=${file_name}
#     Stop and Save Logs    logname=${file_name}
# 
# Step3: Check bfdDscp 005
#    Get content from Wireshark   filename=${filename}   condition_expression=${filter}
# 
# Get content from Wireshark
#     [Arguments]    ${filename}    ${condition_expression}
#     csn.connect_to    hostname=${test_ute}    username=${ute_name}    password=${test_password}
#     ...    alias=connection_ute
#     csn.send command
#     ...    command=/usr/bin/tshark -r ${output_dir}/${filename} -X ${lua_path} -Y "${filter}" -T fields -e ip.dsfield.dscp
#     ...    connection=connection_ute
#     ${return_value}  csn.Read Output   connection=connection_ute
#     should contain   ${return_value}   ${bDIA}
# 
# #Read Wireshark Log
# #    [Arguments]    ${filename}    ${filter}=${None}    ${dscp_value}=${bDIA}
# #    cap.Read Cap    cap_file=${output_dir}/${filename}    display_filter=${filter}
# #    log to console  Read Wireshark Log successful
# #    ${return_dscp}    Get PARAM Value from Wireshark Log      check_param=ip.dsfield.dscp   element_idx=${0}     condition_expression=${none}
# #    list should contain value  ${return_dscp}   ${dscp_value}
# 
# Step1: Modify Configuration 015
#     Cloud DU connect to gnb coam via ssl
#     perform muti object recommissioning    dist_name=${IPAPP_distname_1}     parameter=${PARAMS_IPAPP_1}
#     perform muti object recommissioning    dist_name=${BFD_distname_1}      parameter=${PARAMS_BFD_1}
#     perform muti object recommissioning    dist_name=${Trigger_distname_8}    parameter=${PARAMS_TRIGGER_8}
#     perform muti Parameter recommissioning    dist_name=${IPRT_distname_8}    parameter=staticRoutes     value=${PARAMS_staticRoutes_8}
#     ...    operation=update
#     perform muti Parameter recommissioning    dist_name=${BFD_distname_1}    parameter=bfdDestIpAddr   value=${bfdDestIpAddr}
#     ...    operation=update
#     [Teardown]    COAM Teardown gnb connections
# 
# Step3: Check bfdDscp 015
#     Check Wireshark Log     filename=${file_name}
# 
# Step4: Check IPRT
#     Check IPV4 Route Exist
# 
# Step5: Delete BFD
#     ${dict_bfd}    Create BFD list via parameters    ip_value=10.57.243.65
#     Delete object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-1/BFD-${ID}    para_name=${dict_bfd}
# 
# Step6: getPara and check
#     Login Page Via WebUI
#     Log To Console      \n start get trig_stat
#     ${trig_state}    selenium_coam.get parameter value    dist_name=${Trigger_distname_8_1}
#     ...    filter_param=State of the trigger
#     should be equal    ${trig_state}    TRUE
#     [Teardown]    selenium_coam.logout
# 
# Check Wireshark Log
#     [Arguments]    ${filename}    ${filter}=${None}
#     cap.Read Cap    cap_file=${output_dir}/${filename}    display_filter=${filter}
#     cap.check_expression    condition_expression=bfd.sta == 0x3
# 
# perform muti object recommissioning
#     [Arguments]   ${dist_name}    ${parameter}   ${operation}=create   ${skip_parameter_relation_errors}=${True}
#     ...    ${should_activate}=${True}    ${connection}=GNB_OAM
#     admin.perform_object_recommissioning
#     ...      dist_name=${dist_name}
#     ...      parameter=${parameter}
#     ...      operation=${operation}
#     ...      skip_parameter_relation_errors= ${skip_parameter_relation_errors}
#     ...      should_activate=${should_activate}
#     ...      connection=${connection}
# 
# perform muti Parameter recommissioning
#     [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=create    ${connection}=GNB_OAM
#     ...    ${skip_parameter_relation_errors}=${True}     ${should_activate}=${True}
#     admin.Perform Parameter Recommissioning
#     ...    dist_name=${dist_name}
#     ...    parameter=${parameter}
#     ...    value=${value}
#     ...    operation=${operation}
#     ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
#     ...    should_activate=${should_activate}
#     ...    connection=${connection}
# 
# Check Route
#     [Documentation]    Login gNB and check Route on gNB
#     [Arguments]    ${DU_OAM_IP}    ${dst_ip}    ${gateway}    ${table}=main
#     ${rTable}=              getRTable       ${table}
#     ${result}=              Login and Send Command          route -n
#     #...    ip ${ip_flag} route list table ${rTable}
#     Log To Console          \n checking route
#     Should Match Regexp     ${result}   ${dst_ip}.*${GATE_IPV4}.*${Iface}.*
#     #.*via.*${gateway} dev.*
#     [Return]                ${result}
# 
# Check IPV4 Route Exist
#     Check Route     DU_OAM_IP=${DU_OAM_IP}   dst_ip=${DEST_IPV4}    gateway=${GATE_IPV4}
# 
# Check IPV4 Route not Exist
#     Check Route None     DU_OAM_IP=${DU_OAM_IP}   dst_ip=${DEST_IPV4}    gateway=${GATE_IPV4}
# 
# Check trigger_state
#     [Arguments]    ${connection}=cOAM_admin
#     &{trigger_state}    coam.get_parameters    dist_name=${MRBTS}/TNLSVC-1/TNL-1/TRIGGER-8    pattern=state    connection=${connection}
#     should be equal     &{trigger_state}      ${true}
# 
# Login and Send Command
#     [Documentation]   Login gNB and execute commands on gNB
#     [Arguments]    ${commands}
#     ${connection}=      Connect to ASIK
#     ${result}=          ssh.execute         command=${commands}         connection=${connection}
#     ${stdout}=          ssh.Read Output     connection=${connection}
#     ${stderr}=          ssh.Read Error      connection=${connection}
#     [Teardown]          ssh.Disconnect      connection=${connection}
#     [Return]    ${result}
# 
# Connect to ASIK
#     [Arguments]  ${ip_address}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}         ${alias}=cOAM_toor4nsn
#     ...          ${user}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#     ...          ${password}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#     ${connection}=  ssh.Connect to  hostname=${ip_address}
#     ...                             username=${user}
#     ...                             password=${password}
#     ...                             alias=${alias}
#     [Return]    ${connection}
# 
# Teardown configuration
#     Cloud DU connect to gnb coam via ssl
#     perform muti object recommissioning    dist_name=${IPAPP_distname_1}     parameter=${PARAMS_IPAPP_1}    operation=delete
#     perform muti object recommissioning    dist_name=${Trigger_distname_8}    parameter=${PARAMS_TRIGGER_8}    operation=delete
#     perform muti Parameter recommissioning    dist_name=${IPRT_distname_8}    parameter=staticRoutes     value=${PARAMS_staticRoutes_8_8}
#     ...    operation=update
#     COAM Teardown gnb connections
#     Disconnect from DU
# 
# Login Page Via WebUI
#     selenium_coam.Enable Virtual Display
#     FOR    ${var}    IN RANGE    10
#        ${login_result}    ${error}    Run Keyword And Ignore Error    selenium_coam.Login
#         ...    url=https://${DU_OAM_IP}
#         ...    username=${WEBEM_USERNAME}
#         ...    password=${WEBEM_PASSWORD}
#         ${logout_result}    ${error}    Run Keyword If    '${login_result}'=='FAIL'    Run Keyword And Ignore Error    selenium_coam.Logout
#         Exit For Loop If    '${login_result}'=='PASS'
#         Sleep    5s
#     END
#     selenium_coam.Disable Message Box
#     selenium_coam.Disable Screen Lock
