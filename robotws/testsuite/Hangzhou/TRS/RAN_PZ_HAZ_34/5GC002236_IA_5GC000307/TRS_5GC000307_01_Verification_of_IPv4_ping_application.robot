# *** Settings ***
# Force Tags    PY36
# #############################   Author：xiaofeng.1.zhu@nokia-sbell.com   2020.9.22 #################################
# Suite Setup       TRANS Common Setup
# Suite Teardown    TRANS Common Teardown
# Documentation     Suite description
# Resource          ../5GC002236_FA/resources/trans_comm.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library           ./Resources/common_keyword.py
# Library    taf.analyzer.pcap    WITH NAME    cap
# *** Variables ***
# 
# ${DU_OAM_IP_URL}            https://${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.addr}
# ${DU_OAM_WEBUI_IP}         ${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.addr}
# ${DU_OAM_WEBUI_USER}        ${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.username}
# ${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.password}
# ${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[0].airscale.common_units[2].lmp_connection.addr}
# ${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[2].lmp_connection.username}
# ${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[2].lmp_connection.password}
# 
# ${Interface}    fp0
# ${dest_ip1}         ${tl.gnbs[0].dus[0].f1_c_ip_addr}
# ${dest_ip2}         ${tl.gnbs[0].dus[0].f1_m_cu}
# ${oam_ssh_addr_V6}     ${tl.gnbs[0].dus[0].f1_u_ip_addr}
# ${filename_1}         topp02.pcap
# ${filename_2}         topp03.pcap
# ${epc_log_path}     /tmp
# ${TS_CASE_LOG_PATH}    ${OUTPUT_DIR}
# ${ip_test_scope}    User-defined address
# ${ip_test_scope2}    All configured hosts
# ${dscp}         44
# ${Payload_size}     59
# 
# *** Test Cases ***
# [1]5GC002236_5GC000307_01_Verification_of_IPv4_ping_application
#     [Tags]        CRT_21B     CRT_22R2
#     [Setup]   Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     start IP connectivity test
#     Log to console  Check Collect the wireshark
#     check wireshark log     ${filename_1}
#     check wireshark log     ${filename_2}
#     [Teardown]   run keywords  selenium_coam.logout   AND   CI_interface.Common Case Teardown
# 
# *** Keywords ***
# start IP connectivity test
#     Log to console  start IP connectivity test
#     selenium_coam.Enable Virtual Display
#     selenium_coam.login  url=${DU_OAM_IP_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
#     ${serverHost}  ${gateway}   Get Web_config value
#     start pmut extract log    ${filename_1}
#     selenium_coam.start_ip_connectivity_test    scope=${ip_test_scope}  source_address=${DU_OAM_IP_TL}  dscp=${dscp}  address=${serverHost}
#     ...      payload_size=${Payload_size}
#     sleep    5s
#     end pmtu extract log
#     sleep    3s
#     start pmut extract log    ${filename_2}
#     selenium_coam.start_ip_connectivity_test    scope=${ip_test_scope}  source_address=${DU_OAM_IP_TL}  dscp=${dscp}  address=$${gateway}
#     ...      payload_size=${Payload_size}
#     sleep    5s
#     end pmtu extract log
# 
# start pmut extract log
#     [Arguments]    ${filename}
#     ssh.connect_to   hostname=${DU_OAM_IP_TL}    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}
#     log to console  start pmut extract log
#     ${cmd}   Set Variable  tcpdump -n -i fp0 -w /tmp/${filename} -vv
#     ssh.Send Command   command=${cmd}
# 
# end pmtu extract log
#     ssh.Send Command  command=ps -ef |grep tcpdump|awk '{{print $2}}'|head -n 1
#     ${PID}  ssh.Read Output
#     ${PID}  strip_string    ${PID}
#     log to console  Extract log successful
#     log to console  PID output: ${PID}
#     ssh.Send Command  command=kill ${PID}
# 
# Read Wireshark Log
#     [Arguments]    ${filename}    ${filter}=${None}
#     cap.Read Cap    cap_file=${LOG_PATH}/${filename}    display_filter=${filter}
#     log to console  Read Wireshark Log successful
# Get PARAM Value from Wireshark Log
#     [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
#     ${value}=    cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
#     ...    default_value=${default_value}    condition_expression=${condition_expression}
#     log to console  Get PARAM Value from Wireshark Log successful
#     [Return]    ${value}
# 
# Wireshark DownloadLog
#     [Arguments]    ${filename}
#     ssh.download_file   local_path=${LOG_PATH}/${filename}    remote_path=${epc_log_path}/${filename}
#     sleep    20s
#     log to console  Download Log successful
# 
# Get Web_config value
#     Log to console  Web_config value
#     Log to console  login DU WEBUI successful
#     ${mrbtsId}    selenium_coam.get_bts_id
#     ${out1}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/MNL-1/CERTH-1/CMP-1   abbr=serverHost
#     ...    filter_param=CMP server IP address
#     ${out2}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1   abbr=gateway
#     ...    filter_param=IP address of the next hop of the route
#     [return]  ${out1}      ${out2}
# 
# check wireshark log
#     [Arguments]    ${filename}
#     Wireshark DownloadLog    ${filename}
#     Read Wireshark Log  filename=${filename}
#     ${icmp.resptime}   Get PARAM Value from Wireshark Log    icmp.resptime
#     ...   element_idx=${0}
#     ...    condition_expression=${None}
#     ${ip.dsfield.dscp}   Get PARAM Value from Wireshark Log    ip.dsfield.dscp
#     ...   element_idx=${0}
#     ...    condition_expression=${None}
#     ${ip.len}   Get PARAM Value from Wireshark Log    ip.len
#     ...   element_idx=${0}
#     ...    condition_expression=${None}
# #    ${ip.dsfield.dscp}   swith_number_to_16      list=${ip.dsfield.dscp}
# #    ${ip.len}            swith_number_to_16      list=${ip.len}
#     should not be empty    ${icmp.resptime}
#     Log to console   SET DSCP:${dscp}
#     ${Payload_size_change}    evaluate   ${Payload_size}+28
#     ${Payload_size_change}    convert to string    ${Payload_size_change}
#     Log to console   Payload_size:${Payload_size_change}
#     run keyword and continue on failure  list should contain value     ${ip.dsfield.dscp}    ${dscp}
#     run keyword and continue on failure  list should contain value     ${ip.len}    ${Payload_size_change}
