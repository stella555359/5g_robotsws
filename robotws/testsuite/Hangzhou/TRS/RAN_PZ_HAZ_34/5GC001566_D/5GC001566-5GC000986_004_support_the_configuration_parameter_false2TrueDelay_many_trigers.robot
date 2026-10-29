# *** Settings ***
# Force Tags    PY36
# Documentation    Suite description
# 
# Suite Setup
# Suite Teardown    CI_interface.Common Case Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource          ./Resources/5GC001566_D_common_keyword.robot
# Variables         ./Resources/5GC001566_modify_para.py
# Library           ./Resources/5GC001566_common_keyword.py
# Library           taf.transport.ssh    WITH NAME    ssh
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${gNB_ip}               ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${gNB_username}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${gNB_password}         ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${default_scf}          ${CURDIR}/../../../commissionings/HGZ/${testline_name}/SCF_10.1100_DU.xml
# ${bfdDestIpAddr}        10.101.53.1
# ${bfdDestIpAddr1}       10.57.53.99
# 
# *** Test Cases ***
# 5GC001566-5GC000986_004_support_the_configuration_parameter_false2TrueDelay_many_trigers
#     [Documentation]
#     [Tags]    CRT_20B    CRT_TRUNK
#     [Setup]    Case Setup ready
#     COAM Commission with scf file       scf_file_path=${default_scf}       connection=GNB_OAM
#     wait until keyword succeeds     10min  30s     COAM Check GNB cell on air
#     Parameter recommissioning
#     ${local_path}    Download trs tpl events log with ssh
#     ${expect_false2TrueDelay1}     get from dictionary   @{PARAMS_TRIGGER_1}[0]    value
#     ${expect_false2TrueDelay2}     get from dictionary   @{PARAMS_TRIGGER_2}[0]    value
#     ${ip1}     get from dictionary     @{PARAMS_staticRoutes_1}[1]    destIpAddr
#     ${ip2}     get from dictionary     @{PARAMS_staticRoutes_2}[0]    destIpAddr
#     ${trigger2_time}  ${trigger1_time}   ${bfd_time}    run keyword and continue on failure    analysis_trs_event_log
#     ...    file_path=${local_path}   ip1=${ip1}   ip2=${ip2}
#     run keyword and continue on failure    check_trs_event_log_time      bfd_up_time=${bfd_time}    trigger1_time=${trigger1_time}   tolerance=0.1
#     ...    trigger2_time=${trigger2_time}    false2TrueDelay1=${expect_false2TrueDelay1}   false2TrueDelay2=${expect_false2TrueDelay2}
#     ${bfdDestIpAddr_down}   get from dictionary   @{PARAMS_BFD}[2]    value
#     perform muti Parameter recommissioning    dist_name=${BFD_distname}    parameter=bfdDestIpAddr   value=${bfdDestIpAddr_down}
#     sleep  1min
#     ${local_path2}    Download trs tpl events log with ssh    local_path=${output_dir}/trs_tpl_events_2.log
#     analysis_trs_event_log_delete_bfd    file_path=${local_path2}   ip1=${ip1}   ip2=${ip2}
#     [Teardown]      Run keywords  COAM Teardown gnb connections  AND   CI_interface.Common Case Teardown
# 
# 
# *** Keywords ***
# Case Setup ready
#     Cloud DU connect to gnb coam via ssl    connection=GNB_OAM
# 
# Parameter recommissioning
# #   create BFD
#     perform muti object recommissioning    dist_name=${IPAPP_distname_1}    parameter=${PARAMS_IPAPP}
#     sleep  2s
#     perform muti object recommissioning    dist_name=${BFD_distname}      parameter=${PARAMS_BFD}
#     sleep  2s
# #   create Trigger
#     perform muti object recommissioning    dist_name=${Trigger_distname_1}    parameter=${PARAMS_TRIGGER_1}
#     sleep  2s
#     perform muti object recommissioning    dist_name=${Trigger_distname_2}    parameter=${PARAMS_TRIGGER_2}
#     sleep  2s
# #   create IPRT
#     perform muti Parameter recommissioning    dist_name=${IPRT_distname_1}    parameter=staticRoutes   value=${PARAMS_staticRoutes_1}
#     sleep  2s
#     perform muti Parameter recommissioning    dist_name=${IPRT_distname_2}    parameter=staticRoutes   value=${PARAMS_staticRoutes_2}
#     sleep  20s
# #   modify BFD
#     perform muti Parameter recommissioning    dist_name=${BFD_distname}    parameter=bfdDestIpAddr      value=${bfdDestIpAddr}
#     sleep  30s
#     perform muti Parameter recommissioning    dist_name=${BFD_distname}      parameter=bfdDestIpAddr      value=${bfdDestIpAddr1}
#     sleep  20s
#     perform muti Parameter recommissioning    dist_name=${BFD_distname}    parameter=bfdDestIpAddr     value=${bfdDestIpAddr}
#     sleep  30s
#     perform muti Parameter recommissioning    dist_name=${BFD_distname}      parameter=bfdDestIpAddr      value=${bfdDestIpAddr1}
#     sleep  20s
#     perform muti Parameter recommissioning    dist_name=${BFD_distname}    parameter=bfdDestIpAddr     value=${bfdDestIpAddr}
#     sleep  30s
