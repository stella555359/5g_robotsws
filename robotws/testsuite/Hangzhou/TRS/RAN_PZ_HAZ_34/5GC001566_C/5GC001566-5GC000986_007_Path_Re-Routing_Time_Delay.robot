# *** Settings ***
# Force Tags    PY36
# Documentation     author: Ruizzhan
# ...               contact: ruizhi.zhang@nokia-sbell.com
# ...               squad group: MMW_SG_04
# 
# Suite Setup       Tests_suite_setup
# Suite Teardown
# 
# Library           taf.sbts.oam.coam.admin    WITH NAME    admin
# Library           taf.transport.ssh       WITH NAME   ssh
# Library           ./resources/routes.py
# Library           XML
# Library           ./resources/5GC001566_common_keyword.py
# Variables         ./resources/5GC001566_modify_para.py
# #Resource          ../../../../resources/common/DEPRECATED/wireshark_parsing.robot
# Resource          ./resources/1566_C_resource.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${filename}                   zrz_tcpdump_ca_dl7.pcap
# ${BTS_id}                     ${tl.gnbs[0].instance_id}
# ${DU_OAM_IP}                  ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DEST_IPV4}=                 20.0.0.0
# ${GATE_IPV4}=                 10.57.243.65
# ${Iface}                      fp0.3
# ${dist_name}                  MRBTS-${BTS_id}/TNLSVC-1/TNL-1
# ${bfdDestIpAddr}              10.57.243.10
# ${IPRT_distname_1}            MRBTS-${BTS_id}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1
# ${BFD_distname}               MRBTS-${BTS_id}/TNLSVC-1/TNL-1/IPAPP-1/BFD-1
# 
# *** Test Cases ***
# [1]5GC001566-5GC000986_007_Path_Re-Routing_Time_Delay
#     [Documentation]    the purpose of the case validates the delay time is within the range when trigger status changed
#     ...    to be down the routing table setforward and deleted.
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Setup]
#     Step1: Modify Configuration
#     Step2: Get Tcpdump
#     Step3: Check bfdDscp
#     Step4: Check IPRT
#     Step5: BFD session state down
#     Step6: checking time delay
#     [Teardown]    Run keywords   Teardown configuration  AND  CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Tests_suite_setup
#     Input default SCF
# 
# Step1: Modify Configuration
#     Create IPAPP_BFD    ip_value=${GATE_IPV4}
#     Cloud DU connect to gnb coam via ssl
#     perform muti object recommissioning    dist_name=${Trigger_distname_3}    parameter=${PARAMS_TRIGGER_3}
#     perform muti Parameter recommissioning    dist_name=${IPRT_distname_1}    parameter=staticRoutes     value=${PARAMS_staticRoutes_3}
#     ...    operation=update
#     [Teardown]    COAM Teardown gnb connections
# 
# Step2: Get Tcpdump
#     Start Capture Logs    logname=${filename}
#     Stop and Save Logs    logname=${filename}
# 
# Step3: Check bfdDscp
#     Check Wireshark Log     filename=${filename}
# 
# Step4: Check IPRT
#     Check IPV4 Route Exist
# 
# Step5: BFD session state down
#     Cloud DU connect to gnb coam via ssl
#     perform muti Parameter recommissioning    dist_name=${BFD_distname}    parameter=bfdDestIpAddr   value=${bfdDestIpAddr}
#     ...    operation=update
#     [Teardown]    COAM Teardown gnb connections
# 
# Step6: checking time delay
#     ${local_path}     Download trs_tpl_events.log with ssh
#     ${t2_time}  ${t1_time}    analysis_trs_log_delay_time     file_path=${local_path}
#     check_trs_log_time_delay_time    time_1=${t1_time}     time_2=${t2_time}
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
#     [Return]    ${result}
# 
# Check IPV4 Route Exist
#     Check Route     DU_OAM_IP=${DU_OAM_IP}   dst_ip=${DEST_IPV4}    gateway=${GATE_IPV4}
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
#     [Arguments]  ${ip_address}=${tl.gnbs[0].dus[0].f1_m_ip_addr}         ${alias}=cOAM_toor4nsn
#     ...          ${user}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#     ...          ${password}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#     ${connection}=  ssh.Connect to  ${ip_address}
#     ...                             ${user}
#     ...                             ${password}
#     ...                             alias=${alias}
#     [Return]    ${connection}
# 
# Download trs_tpl_events.log with ssh
#     [Arguments]    ${trs_tpl_events}=trs_tpl_events.log      ${local_path}=${output_dir}/trs_tpl_events.log
#    ${alias_gnb_common_unit}=  Connect to gNB Common Unit   gnb_id=${0}  du_id=${0}  comu_id=${0}
#     ...  alias=common_unit_extract_eqid
# #    ${output}=    ssh.execute    command=cd /tmp;scp    connection=${alias_gnb_common_unit}
#     ssh.download_file      remote_path=/tmp/${trs_tpl_events}      local_path=${local_path}    connection=${alias_gnb_common_unit}
#     [Return]   ${local_path}
# 
# Connect to gNB Common Unit
#     [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}  ${alias}=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
#     ${proxy}=    Run keyword if    '${tl.test_pc.connections}'!='[]'   gnb_id=${gnb_id}
#     ...    ELSE    Set variable    ${None}
#     ssh.Connect_to      hostname=${tl.gnbs[${gnb_id}].dus[${du_id}].f1_m_ip_addr}
#     ...                 username=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
#     ...                 password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
#     ...                 alias=${alias}
#     ...                 proxy=${proxy}
#     ssh.Force Reconnect    ${alias}
#     [Return]    ${alias}
# 
# Teardown configuration
#     Cloud DU connect to gnb coam via ssl
#     perform muti object recommissioning    dist_name=${IPAPP_distname_1}     parameter=${PARAMS_IPAPP_1}    operation=delete
#     perform muti object recommissioning    dist_name=${Trigger_distname_3}    parameter=${PARAMS_TRIGGER_3}    operation=delete
#     perform muti Parameter recommissioning    dist_name=${IPRT_distname_1}    parameter=staticRoutes     value=${PARAMS_staticRoutes_3_3}
#     ...    operation=update
#     COAM Teardown gnb connections
