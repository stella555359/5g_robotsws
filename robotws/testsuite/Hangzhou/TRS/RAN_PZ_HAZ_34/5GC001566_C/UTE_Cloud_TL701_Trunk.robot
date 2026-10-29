# *** Settings ***
# Documentation    Suite description
# ...   author: chun.tian@nokia-sbell.com
# ...   contact: chun.tian@nokia-sbell.com
# 
# Force Tags              RAN_5G_TDD    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_ASIKL_ABILB1_AEUD_ENB_HZIV    master_pDU
# ...    PY36
# ...    CRT_UTE   RAN_5G    5G_RAN    5G_RAN_TDD
# 
# Library        resources/TL701_trunk_common_keyword.py
# Resource       resources/TL701_trunk_common_keyword.robot
# Variables      resources/TL701_trunk_modify_para.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# Suite Setup       CI_interface.Common Suite Setup
# 
# *** Variables ***
# ${LOG_PATH}               ${OUTPUT DIR}
# ${ID}                      1
# ${log_dir}                 /tmp
# ${filename}                e_tcpdump.pcap
# ${filenames}               trs_tpl_events.log
# ${bfd_log}                 bfd_tcpdump.pcap
# ${listen_port}             fp0.3
# ${listen_ports}            fp0
# ${vlan_ip}                 10.57.243.66
# ${src_ip_second}           10.57.243.70
# ${bfd_dest_ip_addr}        10.57.243.65
# ${bfd_dest_ip_addrs}       10.57.243.69
# ${modify_ip}               10.46.65.64
# ${TOPMASTERIP}             10.57.249.62
# ${IP_2}                    20.0.0.0
# ${parameter}               staticRoutes
# ${DN_value}                ${MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1
# ${DN_value_double}         ${MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPIF-3/IPADDRESSV4-1
# ${bfd_distname}            MRBTS-${test_line}/TNLSVC-1/TNL-1/IPAPP-1/BFD-1
# ${dist_name}               MRBTS-${test_line}/TNLSVC-1/TNL-1/TRIGGER-1
# ${dist_name_iptr}          MRBTS-${test_line}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1
# ${filter}                  ip.src==${vlan_ip}
# 
# 
# *** Test Cases ***
# [1]5GC001566-5GC000986_011_BFD_transmission_interval_jittered
#     [Tags]    5GC001566     CRT_TRUNK  CRT_20B
#     [Setup]    Input default SCF
#     [Documentation]     This TC check interval jittered in bfd control packets
#     Create IPAPP_BFD    ip_value=${bfd_dest_ip_addr}    b_Id=1   bfd_Port=3784  bfd_DN=${DN_value}  ID=1
#     Start to Capture tcpdump    listen_port=${listen_port}     log_dir=${log_dir}    filename=${filename}
#     Stop and Download tcpdump       filename=${filename}
#     Get relative_time from Wireshark log     filename=${filename}   condition_expression=${filter}
#     [Teardown]    Run keywords   Delete IPAPP_BFD    ip_value=${bfd_dest_ip_addr}  b_Id=1    bfd_Port=3784  bfd_DN=${DN_value}  ID=1
#     ...    AND   CI_interface.Common Case Teardown
# 
# [1]5GC001566-5GC000986_009_BFD_diffrent_value_of_My_Discriminator_for_each_bfd_session
#     [Tags]    5GC001566     CRT_TRUNK   CRT_20B
#     [Setup]    Input default SCF
#     [Documentation]     This TC check My discriminator parameter in bfd control packets
#     Create IPAPP_BFD    ip_value=${bfd_dest_ip_addr}   b_Id=1    bfd_Port=53785  bfd_DN=${DN_value}  ID=1
#     ${dict_bfd}    Create BFD list via parameters   ip_value=${bfd_dest_ip_addrs}   b_Id=1    bfd_Port=53784   bfd_DN=${DN_value_double}
#     Modify object    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-1/BFD-2    para_name=${dict_bfd}    operation=create
#     Start to Capture tcpdump   listen_port=${listen_ports}   log_dir=${log_dir}    filename=${bfd_log}
#     Stop and Download tcpdump    filename=${bfd_log}
#     Read Log and check        bfd_log=${bfd_log}
#    [Teardown]    Run keywords  Delete IPAPP_BFD    ip_value=${bfd_dest_ip_addr}   b_Id=1    bfd_Port=53785  bfd_DN=${DN_value}  ID=1
#    ...   AND   CI_interface.Common Case Teardown
# 
# [1] 5GC001566-5GC000986_017_Alarm_BFD_DOWN_Ingress_from_rightful_objec and Action_trigger_ipv4 _shall_be_able_to_bind_static_routet
#     [Tags]    5GC001566    CRT_TRUNK   CRT_20B
#     [Setup]    Input default SCF
#     [Documentation]    this TC check if alarm 61605 works properly and  we can bind static route to action trigger
#     Create IPAPP_BFD      ip_value=${modify_ip}    b_Id=1    bfd_Port=3784    bfd_DN=${DN_value}  ID=1
#     ${conn}    Connect to DU
#     Get Alarm Info and Check alarm       timeout=${100}    exp_alarm_id=${61605}    flag=${True}    connection=${conn}
#     Modify id_para_bfd    dist_name=${bfd_distname}   parameter=bfdDestIpAddr    operation=update    value=${bfd_dest_ip_addr}   connection=${conn}
#     Get Alarm Info and Check alarm       timeout=${100}    exp_alarm_id=${61605}    flag=${False}    connection=${conn}
#     Delete trriger object    dist_name=${dist_name}   parameter=${PARAMS_TRIGGER}    operation=create    connection=${conn}
#     Modify id_para_bfd    dist_name=${dist_name_iptr}      parameter=${parameter}    operation=update    value=${PARAMS_staticRoutes_11}
#     ...    connection=${conn}
#     Disconnect from DU
#     sleep    10s
#     Download file       log_dir=${log_dir}    filenames=${filenames}    connection=du_con
#     ${return_contain}     trnsport_bfd     filename=${output_dir}/${filenames}     c=${bfd_dest_ip_addr}    d=${IP_2}
#     should be true     ${return_contain}
#     [Teardown]  1566_017 case teardown    ip_value=${modify_ip}    parameter=${PARAMS_TRIGGER}    bfd_Port=3784    dist_name=${dist_name}
# 
# [1]5GC001577-SA_5GC000320_A_110_1PPS-TOD_holdover_very_short_failure_(less_than_5s)
#     [Documentation]
#     ...    The purpose of this test is to check the behavior of the system when 5gNB face as very short lost of
#     ...    1PPS-TOD signal (less than 5s)
#     ...    -11.11.2020,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_20B    CRT_TRUNK    5GC001577_320
#     [Setup]    1577 case setup
#     Check BTS Should Be Normal
#     Check Sync Status    sync_list_length=${1}    expect_syncInfo_list=${sync_1577_info_2}
#     Start Catch BTS Log
#     Disconnect Sync Connector less than 5s
#     sleep    1min
#     Check Sync Status    sync_list_length=${1}    expect_syncInfo_list=${sync_1577_info_2}
#     Stop BTS Log and Check Phase Error
#     [Teardown]    1577 case teardown
# 
# [1]5GC002377-FA_10_Phase_Sync_Change_priority
#     [Documentation]
#     ...    change priority level of déclared synchro source
#     ...    Check Active synchronization move to the new highest priority source declared
#     ...    -12.11.2020,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]    CRT_20B    CRT_TRUNK    5GC002377_319
#     [Setup]    2377 Setup
#     Check BTS Should Be Normal
#     @{synctype}    Create list    2    1
#     Change Sync Input Type    synctype=${synctype}    sync_key=syncInputPrio
#     Check Sync Status    sync_list_length=${2}    expect_syncInfo_list=${sync_2377_info_1}
#     Check BTS Should Be Normal
#     @{synctype}    Create list    1    2
#     Change Sync Input Type    synctype=${synctype}    sync_key=syncInputPrio
#     Check Sync Status    sync_list_length=${2}    expect_syncInfo_list=${sync_2377_info_2}
#     Check BTS Should Be Normal
#     [Teardown]    2377 Teardown
# 
