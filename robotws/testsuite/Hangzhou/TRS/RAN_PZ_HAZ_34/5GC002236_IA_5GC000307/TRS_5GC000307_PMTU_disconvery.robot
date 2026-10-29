# *** Settings ***
# Force Tags    PY36
# Suite Setup      TRANS Common Setup
# Suite Teardown   TRANS Common Teardown
# 
# Resource   ../5GC002236_FA/resources/trans_comm.robot
# 
# 
# *** Variables ***
# ${oam_ssh_addr}=            ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# ${oam_ssh_username}=        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
# ${oam_ssh_password}=        ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
# ${WEBUI_URL}      https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
# ${webui_ip}       ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${webui_username}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${webui_password}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${dest_ip1}         10.108.227.129
# ${dest_ip2}         10.108.227.134
# ${mtu_conf_gw}    1500
# 
# *** Test Cases ***
# TRS_5GC000307_PMTU_discovery
# 
#     [Documentation]  The case is to check basic scenario of using PMTU Discovery feature
#     [Tags]
#     [Setup]
#     [Teardown]
#     Step1: Check PMTU discovery with reachable destination IP
#     Step2：Check PMTU discovery with unreachable destination IP
# 
# *** Keywords ***
# Step1: Check PMTU discovery with reachable destination IP
#     ${MTU_conf}    Get mtu value
#     ${local_MTU_conf}   Convert To Integer    ${MTU_conf}
#     Set Test Variable  ${local_MTU_conf}
#     ${path_mtu_conf}    Get path MTU configured
#     ${out}    start pmtu discovry  dest_ip=${dest_ip1}
#     log to console  PMTU  discovery result is : ${out[2]}
#     Should not contain    ${out[2]}    failed
# 
#     ${path_MTU}   set variable  ${out[0]}
#     ${local_MTU}   set variable  ${out[1]}
#     log to console   path mtu value is ${path_MTU}
#     log to console   local mtu value is ${local_MTU}
#     should be true    ${local_MTU_conf}== ${local_MTU}
#     should be true    ${path_mtu_conf}== ${path_MTU}
# 
# Step2：Check PMTU discovery with unreachable destination IP
#     ${out}    start pmtu discovry  dest_ip=${dest_ip2}
#     log to console  PMTU  discovery result is : ${out[2]}
#     should contain    ${out[2]}    failed
# 
# start pmtu discovry
#     [Arguments]  ${dest_ip}
#     selenium_coam.enable_virtual_display
#     wait until keyword succeeds  3x   3s    selenium_coam.login    url=${DU_OAM_WEBUI_URL}    username=${DU_OAM_WEBUI_USER}
#     ...    password=${DU_OAM_WEBUI_PASSWORD}
# 
#     #coam.disable_screen_lock
#     sleep    3s
#     ${out}    selenium_coam.start_pmtu_discovery  source_ip=${oam_ssh_addr}  destination_ip=${dest_ip}
#     sleep    10s
#     Run Keyword And Ignore Error    selenium_coam.logout
# #    selenium_coam.disable_virtual_display
#     [return]  ${out}
# 
# Get mtu value
# 
#     selenium_coam.enable_virtual_display
#     wait until keyword succeeds  3x   3s    selenium_coam.login    url=${WEBUI_URL}    username=${webui_username}   password=${webui_password}
# 
#     #coam.disable_screen_lock
#     sleep    3s
#     ${mrbtsId}    selenium_coam.get_bts_id
#     ${out}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1   abbr=ipMtu
#     ...    filter_param=Maximum transfer unit
#     log to console  current MTU value is: ${out}
#     selenium_coam.logout
# 
#     ${mtu_value}   get regexp matches  ${out}    (\\d+)  1
#     [return]  ${mtu_value[0]}
# 
# 
# Get path MTU configured
# 
#     ssh.connect_to   hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}
#     ${cmd}   Get Full Command Path For Simulator  command=${TOOLS_INFO["pmtu"]}
#     ${cmd}   Set Variable  ${cmd} -T ${dest_ip1} -l 1000 -u 2000
#     ssh.Send Command   command=${cmd}
#     ${out}  ssh.Read Output
#     log to console   ${out}
#     ${out1}    get regexp matches   ${out}  \\d+$
#     ssh.Disconnect
#     [return]  ${out1[0]}
# 
# 
