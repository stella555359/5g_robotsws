# *** Settings ***
# Force Tags    PY36
# Documentation    Suite description
# ...   author: chun.tian@nokia-sbell.com
# ...   contact: chun.tian@nokia-sbell.com
# 
# Suite Setup     Tests_suite_setup
# Suite Teardown    CI_interface.Common Case Teardown
# 
# Library    taf.analyzer.pcap    WITH NAME   cap
# Library        resources/check_parameter.py
# Library        taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
# Library        taf.sbts.oam.coam.admin     WITH NAME      admin
# Resource       resources/1566_C_resource.robot
# #Resource       ../../../../resources/sites/Wroclaw/common/tests.robot
# #Resource       ../../../../resources/sites/Wroclaw/common/mzoam.robot
# Variables      resources/5GC001566_modify_para.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${log_dir}                  /tmp
# ${filename}                 e_tcpdump.pcap
# ${DU_OAM_IP}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_SSH_USERNAME}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${DU_OAM_SSH_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# ${BFD_CASE_LOG_PATH}        ${output_dir}
# ${listen_port}              fp0.3
# ${connection}               du_con
# ${test_ute}                 ${tl.test_pc.default_ssh_connection_details.addr}
# ${ute_name}                 ${tl.test_pc.default_ssh_connection_details.username}
# ${test_password}            ${tl.test_pc.default_ssh_connection_details.password}
# ${vlan_ip}                  10.57.243.66
# ${DN_value}      ${MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1
# ${MRBTS}         MRBTS-${tl.gnbs[0].instance_id}
# ${bfd_dest_ip_addr}       10.57.243.65
# ${bfd_dest_ip_addrs}   10.57.243.69
# ${src_ip_second}       10.57.243.70
# ${bfd_log}            bfd_tcpdump.pcap
# ${listen_ports}    fp0
# ${DN_value}    ${MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1
# ${DN_value_double}    ${MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-3/IPADDRESSV4-1
# ${modify_ip}     10.46.65.64
# ${test_line}     ${tl.gnbs[0].instance_id}
# ${dist_name}     MRBTS-${test_line}/TNLSVC-1/TNL-1/TRIGGER-1
# ${bfd_distname}  MRBTS-${test_line}/TNLSVC-1/TNL-1/IPAPP-1/BFD-1
# ${dist_name_iptr}      MRBTS-${test_line}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1
# ${parameter}    staticRoutes
# ${filenames}    trs_tpl_events.log
# ${LOG_PATH}    ${output_dir}
# ${b_Id}    1
# ${bfd_Port}  3784
# ${IP_2}     20.0.0.0
# ${connection}    du_con
# ${filter}   ip.src==${vlan_ip}
# 
# *** Test Cases ***
# [1]5GC001566-5GC000986_011_BFD_transmission_interval_jittered
#     [Tags]    5GC001566     CRT_TRUNK  CRT_20B  CRT_21B
#     [Setup]   Set test variable   ${LOG_PATH}      ${BFD_CASE_LOG_PATH}
#     [Documentation]     This TC check interval jittered in bfd control packets
#     Create IPAPP_BFD    ip_value=${bfd_dest_ip_addr}
#     Start to Capture tcpdump    listen_port=${listen_port}     log_dir=${log_dir}    filename=${filename}
#     ...   connection=${connection}
#     Stop and Download tcpdump       filename=${filename}
#     Get relative_time from Wireshark log     filename=${filename}   condition_expression=${filter}
#     [Teardown]    Delete IPAPP_BFD    ip_value=${bfd_dest_ip_addr}
# 
# [1]5GC001566-5GC000986_009_BFD_diffrent_value_of_My_Discriminator_for_each_bfd_session
#     [Tags]    5GC001566     CRT_TRUNK   CRT_20B   CRT_21B
#     [Setup]
#     [Documentation]     This TC check My discriminator parameter in bfd control packets
#     Create IPAPP_BFD_again    ip_value=${bfd_dest_ip_addr}   b_Id=1    bfd_Port=53785  bfd_DN=${DN_value}  id=1
#     ${dict_bfd}    Create BFD list via parameters_bfd   ip_value=${bfd_dest_ip_addrs}   b_Id=1    bfd_Port=53784   bfd_DN=${DN_value_double}
#     Create object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-1/BFD-2    para_name=${dict_bfd}
#     Start to Capture Log   listen_ports=${listen_ports}     log_dir=${log_dir}    bfd_log=${bfd_log}
#     ...   connection=${connection}
#     Download Log       bfd_log=${bfd_log}
#     Read Log and check        bfd_log=${bfd_log}    filter=${None}
#    [Teardown]   Run keywords   Delete IPAPP_BFD_again    ip_value=${bfd_dest_ip_addr}   b_Id=1    bfd_Port=53785  bfd_DN=${DN_value}  id=1
#    ...   AND   CI_interface.Common Case Teardown
# 
# [1] 5GC001566-5GC000986_017_Alarm_BFD_DOWN_Ingress_from_rightful_objec_and_Action_trigger_ipv4_shall_be_able_to_bind_static_route
#     [Tags]    5GC001566    CRT_TRUNK   CRT_20B   CRT_21B
#     [Setup]
#     [Documentation]    this TC check if alarm 61605 works properly and  we can bind static route to action trigger
#     Create IPAPP_BFD_again      ip_value=${modify_ip}    b_Id=${b_Id}    bfd_Port=${bfd_Port}    bfd_DN=${DN_value}  id=1
#     ${conn}    Connect to DU
#     Get Alarm Info and Check alarm       timeout=${100}    exp_alarm_id=${61605}    connection=${conn}
#     Modify id_para_bfd    connection=${conn}
#     Get Alarm Info and Check alarm again       timeout=${100}    exp_alarm_id=${61605}    connection=${conn}
#     perform muti object recommissioning      dist_name=${dist_name}   parameter=${PARAMS_TRIGGER}    connection=${conn}
#     Multi para_update      dist_name_iptr=${dist_name_iptr}      parameter=${parameter}   value=${PARAMS_staticRoutes_11}    connection=${conn}
#     Disconnect from DU
#     sleep    10s
#     Download file       log_dir=${log_dir}    filenames=${filenames}    connection=${connection}
#     ${return_contain}     trnsport_bfd     ${output_dir}/${filenames}     ${bfd_dest_ip_addr}    ${IP_2}
#     should be true     ${return_contain}
#     Delete IPAPP_BFD_again    ip_value=${modify_ip}    b_Id=${b_Id}    bfd_Port=${bfd_Port}    bfd_DN=${DN_value}  id=1
#     ${conn}    Connect to DU
#     Delete trriger object     dist_name=${dist_name}    parameter=${parameter}    connection=${conn}
#     [Teardown]    Disconnect from DU
# 
# 
# 
# 
# 
# 
