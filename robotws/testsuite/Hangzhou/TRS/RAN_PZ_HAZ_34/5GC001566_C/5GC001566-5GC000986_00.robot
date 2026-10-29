# *** Settings ***
# Force Tags    PY36
# Documentation    Suite description
# ...   author: kaijia.chen@nokia-sbell.com
# ...   contact: kaijia.chen@nokia-sbell.com
# ...   squad group: MMW_SG_04
# 
# Suite Setup       Tests_suite_setup
# Suite Teardown
# 
# Library        taf.transport.ssh           WITH NAME    ssh
# Library        taf.sbts.oam.coam.admin    WITH NAME    admin
# Resource       resources/1566_C_resource.robot
# Variables      resources/5GC001566_modify_para.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${DU_URL}                     https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${WEBEM_USERNAME}             ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBEM_PASSWORD}             ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${BTS_id}                     ${tl.gnbs[0].instance_id}
# ${IPAPP_distname}             MRBTS-${BTS_id}/TNLSVC-1/TNL-1/IPAPP-1
# ${IPRT_distname_1}            MRBTS-${BTS_id}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1
# 
# *** Test Cases ***
# [1]5GC001566-5GC000986_001_NE_ipv4_shall_support_a_read-only_parameter_actFastIpRerouting_TRUE
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Documentation]
#     ...    5GC001566-C-001:NE ipv4 shall support a read-only parameter actFastIpRerouting TRUE
#     ...    -27.10.2020,kaijia.chen@nokia-sbell.com,case draft
# 
#     [Setup]
#     Parameter recommissioning
#     Check actFastIPRerouting parameter
#     [Teardown]    Run keywords   Parameter teardown   AND   CI_interface.Common Case Teardown
# 
# [1]5GC001566-5GC000986_002_BFD_admin_down_state_control_FALSE_with_alarm
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Documentation]
#     ...    5GC001566-C-002:BFD admin down state control FALSE with alarm
#     ...    -27.10.2020,kaijia.chen@nokia-sbell.com,case draft
# 
#     [Setup]
#     Create IPAPP_BFD    ip_value=12.34.56.78
#     Check BFD Alarm Info
#     Modify BFD parameter    filter_param=BFD session admin down state control    new_value=false
#     Check BFD Alarm Info Not Exist
#     [Teardown]    Run keywords  Delete IPAPP_BFD    ip_value=12.34.56.78   AND   CI_interface.Common Case Teardown
# 
# [1]5GC001566-5GC000986_003_BFD_Activation
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Documentation]
#     ...    5GC001566-C-003:BFD Activation
#     ...    -27.10.2020,kaijia.chen@nokia-sbell.com,case draft
# 
#     [Setup]
#     Create IPAPP_BFD    ip_value=20.0.0.0
#     Check tcpdump output
#     [Teardown]    Run keywords   Delete IPAPP_BFD    ip_value=20.0.0.0   AND   CI_interface.Common Case Teardown
# 
# [1]5GC001566-5GC000986_004_BFD_Deactivation
#     [Tags]    5GC001566    CRT_20B    CRT_TRUNK
#     [Documentation]
#     ...    5GC001566-C-004:BFD Deactivation
#     ...    -27.10.2020,kaijia.chen@nokia-sbell.com,case draft
# 
#     [Setup]
#     Create IPAPP_BFD    ip_value=10.57.243.65
#     Check tcpdump output_1
#     Modify BFD para
#     Check tcpdump output_2
#     [Teardown]    Run keywords   Delete IPAPP_BFD    ip_value=10.57.243.65   AND   CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Parameter recommissioning
#     Cloud DU connect to gnb coam via ssl
# #   create BFD
#     perform muti object recommissioning    dist_name=${IPAPP_distname}    parameter=${PARAMS_IPAPP}
#     perform muti object recommissioning    dist_name=${BFD_distname}      parameter=${PARAMS_BFD_10}
# #   create Trigger
#     perform muti object recommissioning    dist_name=${Trigger_distname_1}    parameter=${PARAMS_TRIGGER_10}
# #   create IPRT
#     perform muti Parameter recommissioning    dist_name=${IPRT_distname_1}    parameter=staticRoutes   value=${PARAMS_staticRoutes_11}
#     [Teardown]    COAM Teardown gnb connections
# 
# perform muti object recommissioning
#     [Arguments]   ${dist_name}    ${parameter}   ${operation}=create   ${skip_parameter_relation_errors}=${True}
#     ...    ${should_activate}=${True}    ${connection}=GNB_OAM
# #    Cloud DU connect to gnb coam via ssl
#     admin.perform_object_recommissioning
#     ...      dist_name=${dist_name}
#     ...      parameter=${parameter}
#     ...      operation=${operation}
#     ...      skip_parameter_relation_errors= ${skip_parameter_relation_errors}
#     ...      should_activate=${should_activate}
#     ...      connection=${connection}
# #    COAM Teardown gnb connections
# 
# perform muti Parameter recommissioning
#     [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=update    ${connection}=GNB_OAM
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
# Check actFastIPRerouting parameter
#     WEBUI Login
#     Log To Console      \n start check actFastIPRerouting parameter is true...
#     ${Actual_value}      selenium_coam.get parameter value    dist_name=${MRBTS}/TNLSVC-1/TNL-1/TNL_R-1
#     ...                  filter_param=Feature activation flag for Fast IP Rerouting
#     Should be equal      ${Actual_value}    true
#     WEBUI Logout
# 
# Parameter teardown
#     Cloud DU connect to gnb coam via ssl
# #   create BFD
#     run keyword and continue on failure    perform muti object recommissioning    dist_name=${IPAPP_distname}
#     ...    parameter=${PARAMS_IPAPP}    operation=delete
# #   create Trigger
#     run keyword and continue on failure    perform muti object recommissioning    dist_name=${Trigger_distname_1}
#     ...    parameter=${PARAMS_TRIGGER_1}    operation=delete
# #   create IPRT
#     run keyword and continue on failure    perform muti Parameter recommissioning    dist_name=${IPRT_distname_1}
#     ...    parameter=staticRoutes   value=${PARAMS_staticRoutes_10}
#     [Teardown]    COAM Teardown gnb connections
# 
# Check BFD Alarm Info
#     WEBUI Login
#     Wait Until Keyword Succeeds    15min    10s    Check Alarm Info
#     ...                            alarmID=61605    alarmInfo=BFD-1 down in ingress
# 
# Check BFD Alarm Info Not Exist
#     WEBUI Login
#     Wait Until Keyword Succeeds    15min    10s    Check Alarm Info Not Exist
#     ...                            alarmID=61605    alarmInfo=BFD-1 down in ingress
#     [Teardown]    WEBUI Logout
# 
# Check tcpdump output
#     Log To Console      \n start check Output should contain bfd control pakets sent from BTS...
#     ssh.Connect to    hostname=${DU_SSH_IP}     username=${DU_SSH_USERNAME}
#     ...   password=${DU_OAM_SSH_PASSWORD}    alias=VM
#     sleep    2s
#     ssh.send_command    tcpdump -i fp0.3 udp -vvv > /ffs/run/config/toor4nsn/output.txt    connection=VM
#     sleep    15s
#     ssh.send_command    killall tcpdump    connection=VM
#     sleep    2s
#     ${response}    ssh.execute    command=cat /ffs/run/config/toor4nsn/output.txt    connection=VM
#     sleep    2s
#     Should contain     ${response}    20.0.0.0
#     [Teardown]    ssh.disconnect     connection=VM
# 
# Check tcpdump output_1
#     Log To Console      \n start check Output should contain bfd-control...
#     ssh.Connect to    hostname=${DU_SSH_IP}     username=${DU_SSH_USERNAME}
#     ...   password=${DU_OAM_SSH_PASSWORD}    alias=VM
#     sleep    2s
#     ssh.send_command    tcpdump -i fp0.3 udp -vvv > /ffs/run/config/toor4nsn/output.txt    connection=VM
#     sleep    15s
#     ssh.send_command    killall tcpdump    connection=VM
#     sleep    2s
#     ${response}    ssh.execute    command=cat /ffs/run/config/toor4nsn/output.txt    connection=VM
#     sleep    2s
#     Should contain     ${response}    bfd-control
#     [Teardown]    ssh.disconnect     connection=VM
# 
# Modify BFD para
#     WEBUI Login
#     Modify BFD parameter    filter_param=BFD session activation    new_value=false
#     [Teardown]    WEBUI Logout
# 
# Check tcpdump output_2
#     Log To Console      \n start check Output should not contain bfd control pakets sent from BTS...
#     ssh.Connect to    hostname=${DU_SSH_IP}     username=${DU_SSH_USERNAME}
#     ...   password=${DU_OAM_SSH_PASSWORD}    alias=VM
#     sleep    2s
#     ssh.send_command    tcpdump -i fp0.3 udp -vvv > /ffs/run/config/toor4nsn/output2.txt    connection=VM
#     sleep    15s
#     ssh.send_command    killall tcpdump    connection=VM
#     sleep    2s
#     ${response}    ssh.execute    command=cat /ffs/run/config/toor4nsn/output2.txt    connection=VM
#     sleep    2s
#     Should not contain     ${response}    10.57.243.65.bfd-control
#     [Teardown]    ssh.disconnect     connection=VM
# 
# 
# 
# 
# 
#  