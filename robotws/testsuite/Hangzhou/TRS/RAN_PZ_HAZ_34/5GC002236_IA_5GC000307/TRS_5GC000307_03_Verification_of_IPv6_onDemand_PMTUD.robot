# *** Settings ***
# Force Tags    PY36
# 
# Suite Setup       TRANS Common Setup
# Suite Teardown    TRANS Common Teardown
# Documentation     Suite description
# Resource          ../5GC002236_FA/resources/trans_comm.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library    taf.analyzer.pcap
# Library           Resources/common_keyword.py
# Library    taf.analyzer.pcap    WITH NAME    cap
# 
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
# ${dest_ip2}         ${tl.gnbs[0].dus[0].f1_u_ip_addr}
# ${oam_ssh_addr_V6}     ${tl.gnbs[0].dus[0].f1_m_cu}
# ${filename}         topp02.pcap
# ${epc_log_path}     /tmp
# ${TS_CASE_LOG_PATH}    /home/ute/robotws5g/testsuite/TRS/Hangzhou/5GC002236_IA_5GC000307/log
# 
# ${dscp}         44
# 
# *** Test Cases ***
# [1]5GC002236_5GC000307_03_Verification_of_IPv6_onDemand_PMTUD
#     [Tags]    IPV6      CRT_20B     5GC000307    CRT_TRUNK
#     [Setup]    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     Log to console  Step1 Check PMTU discovery with reachable destination IP
#     Step1: Check PMTU discovery with reachable destination IP
#     Step2：Check Collect the wireshark
#     [Teardown]
# 
# *** Keywords ***
# Step1: Check PMTU discovery with reachable destination IP
#     Log to console  Step1: Check PMTU discovery with reachable destination IP
#     ${MTU_conf}    Get mtu value
#     ${local_MTU_conf}   Convert To Integer    ${MTU_conf}
#     Set Test Variable  ${local_MTU_conf}
#     ${path_mtu_conf}    Get path MTU configured
#     start pmut extract log     filename=${filename}
#     ${out}    start pmtu discovry  dest_ip=${dest_ip1}
#     log to console  PMTU discovery result is : ${out[2]}
#     sleep    2s
#     end pmtu extract log
#     Should not contain    ${out[2]}    failed
#     ${path_MTU}   set variable  ${out[0]}
#     ${local_MTU}   set variable  ${out[1]}
#     log to console  path mtu value is ${path_MTU}
#     log to console  local mtu value is ${local_MTU}
#     should be true    ${local_MTU_conf}== ${local_MTU}
#     should be true    ${path_mtu_conf}== ${path_MTU}
#     Log to console  Check PMTU discovery with unreachable destination IP
#     ${out}    start pmtu discovry  dest_ip=${dest_ip2}
#     log to console  PMTU discovery result is : ${out[2]}
#     should contain    ${out[2]}    failed
# 
# Step2：Check Collect the wireshark
#     Log to console  Step2：Check Collect the wireshark
#     ssh.connect_to   hostname=${DU_OAM_IP_TL}    username=${DU_OAM_SSH_USERNAME_TL}   password=${DU_OAM_SSH_PASSWORD_TL}
#     Wireshark DownloadLog    filename=${filename}
#     Read Wireshark Log  filename=${filename}
#     ${ipv6.tclass.dscp}   Get PARAM Value from Wireshark Log    ipv6.tclass.dscp
#     ...   element_idx=${0}
#     ...    condition_expression=${None}
#     Log to console   SET DSCP:${dscp}
#     ${status}    run keyword and return status    list should contain value     ${ipv6.tclass.dscp}    ${dscp}
#     run keyword if    '${status}'=='False'    list should contain value     ${ipv6.tclass.dscp}    2C
#     [Teardown]  ssh.Disconnect
# 
# Get mtu value
#     Log to console  start Get mtu value
#     selenium_coam.enable_virtual_display
#     selenium_coam.login  url=${DU_OAM_IP_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
#     sleep    20s
#     Log to console  login DU WEBUI successful
#     ${mrbtsId}    selenium_coam.get_bts_id
#     ${out}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1   abbr=ipMtu
#     ...    filter_param=Maximum transfer unit
#     log to console  get MTU value is: ${out}
#     selenium_coam.logout
#     ${mtu_value}   get regexp matches  ${out}    (\\d+)  1
#     log to console  get MTU value is: ${mtu_value}
#     [return]  ${mtu_value[0]}
# 
# start pmtu discovry
#     [Arguments]  ${dest_ip}
#     Log to console  start pmtu discovry
#     selenium_coam.enable_virtual_display
#    # wait until keyword succeeds  3x   3s    selenium_coam.login    url=${DU_OAM_IP_URL}    username=${DU_OAM_WEBUI_USER}
#    # ...    password=${DU_OAM_WEBUI_PASSWORD}
#     selenium_coam.login  url=${DU_OAM_IP_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
#     ${out}    selenium_coam.start_pmtu_discovery  source_ip=${oam_ssh_addr_V6}  destination_ip=${dest_ip}    dscp=${dscp}
#     sleep    10s
#     Run Keyword And Ignore Error    selenium_coam.logout
#     Log to console  end pmtu discovry
#     [return]  ${out}
# 
# Get path MTU configured
#     log to console  start get path MTU configured
#     ssh.connect_to   hostname=${DU_OAM_IP_TL}    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}
# #    ${cmd}   Get Full Command Path For Simulator  command=${TOOLS_INFO["pmtu"]}
#     ${cmd}   Set Variable  tracepath6 ${dest_ip1}
#     ssh.Send Command   command=${cmd}
#     ${out}  ssh.Read Output
# #    log to console   ${out}
#     ssh.Disconnect
#     ${pmtu}    get_pmtu    ${out}
#     log to console  get path MTU configured:${pmtu}
#     [return]  ${pmtu}
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
#     ssh.Disconnect
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
