# *** Settings ***
# Documentation
# ...    author: cai.cris
# ...    contact:cai.cris@nokia-sbell.com
# ...    squad group: SG_03
# ...    feature : 5GC000519_classical
# 
# Force Tags    CA_5G_RRM            0.830
# ...    PY36
# 
# Suite Setup    Prepare the classical COAM BTS cell onair for SA    scf_file=${scf_file}    bts_host=${bts_host}
# Suite Teardown    Suite Recover
# Resource    ../Resources/collect_log.robot
# Resource    ../Resources/5GC000519_coam_common_keywords.robot
# Resource    ../Resources/5GC000519_CC_common_keywords.robot
# Variables    ../Resources/519_Case_Commission_Classical/__init__.py
# Library    taf.analyzer.pcap    WITH NAME     cap
# Library    String
# Library    taf.stc.config    WITH NAME    stc
# Library    ../Resources/tshark_parser.py
# Library    tshark_parser.Parser     WITH NAME    tsk
# 
# 
# *** Variables ***
# ${bts_host}      ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
# ${TESTLINE_NAME}    7_5_CLOUD402T042
# ${WEBUI_URL}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
# ${WEBUI_COAM}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
# ${WEBUI_NAME}    ${tl.gnbs[1].cu.oam_http_connection_details.username}
# ${WEBUI_PWD}    ${tl.gnbs[1].cu.oam_http_connection_details.password}
# ${asik_addr}    ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
# ${asik_username}    ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.username}
# ${asik_password}    ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.password}
# ${gnb_instance}    ${tl.gnbs[1].instance_id}
# ${gNB_dist}    MRBTS-${tl.gnbs[1].instance_id}/TNLSVC-1/TNL-1/ETHSVC-1
# ${l2ShaperRate}     20000
# ${gnb_arp_log}    gnb_arp_log.pcap
# ${enb_arp_log}    enb_arp_log.pcap
# ${scf_file}    /opt/workspace/CIT/Master/SCF_file/cris/SCF/Full_Configuration_scf_TL042_gnb2_all.xml
# ${test_path}    /opt/workspace/CIT/Master/SCF_file/cris/SQ3project/
# ${testcase_status}    false
# ${vlan102ip}    192.168.109.9
# ${plain_ip}     ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${vlan501_ip}    192.168.159.9
# ${vlan1901_ip}    192.168.199.9
# ${vlan4093_ip}   192.168.249.9
# ${vlan2500_ip}    192.168.189.9
# ${vlan1901_no_configed_ip}    192.168.209.9
# ${vlan102_id}    102
# ${vlan501_id}    501
# ${vlan1901_id}    1901
# ${vlan4093_id}    4093
# ${vlan2500_id}    2500
# ${FDB_mac_address}     d6:ef:cd:b1:1a:3c
# ${Linux_SCT_IP_addr}    ${tl.test_pc.default_ssh_connection_details.addr}
# ${Linux_SCT_username}    ${tl.test_pc.default_ssh_connection_details.username}
# ${Linux_SCT_password}    ${tl.test_pc.default_ssh_connection_details.password}
# ${tl_scf_filename_pcp_vlantag}    Full_Configuration_scf_TL042_gnb2_pcp_vlantag.xml
# ${tl_scf_filename_dscp_vlantag}    Full_Configuration_scf_TL042_gnb2_dscp.xml
# ${testcenter_pcp_vlantag_file}    /home/ute/SQ3project/519STC/519-E01_PCP_vlan_tag.tcl
# ${testcenter_dscp_tag_and_untag_file}    /home/ute/SQ3project/519STC/519-E07_DSCP_tag.tcl
# ${enblog_E01}    519_E_01.pcap
# ${enblog_E07}    519_E_07.pcap
# ${enb_path}    /user/toor4nsn/
# ${gnb_path}    /tmp/
# ${gnblog_E01}    519_E_01_port15.pcap
# ${gnblog_E07}    519_E_07_port15.pcap
# ${tsc_ip_src_dest_vlan102}     192.168.109.7,192.168.109.155
# ${tsc_ip_src_dest_vlan501}     192.168.159.7,192.168.159.155
# ${dl_port}      ${tl.ues[0].iperf_details.port}
# ${ul_time}    60s
# ${ul_length}    1024B
# ${ul_throughput}     10M
# ${ul_port}      ${tl.ues[0].iperf_details.ssh_connection_details.port}
# ${dl_time}    60s
# ${dl_length}    1024B
# ${dl_throughput}    10M
# ${ul_expect}    0
# ${dl_expect}    0
# ${epc_log_path}    /home/ute/SQ3project/
# ${appserver_addr}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
# ${appserver_username}    ${tl.appserver.iperf_details.ssh_connection_details.username}
# ${appserver_password}    ${tl.appserver.iperf_details.ssh_connection_details.password}
# ${ueType}    huawei
# ${gNB_dist_l2sw}      MRBTS-${tl.gnbs[1].instance_id}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
# 
# *** Test Cases ***
# [1]5GC000519_E_001_QoS_Aware_primary_classification_criteria_Vlan_PCP_for_VLAN_tagged_frame_in_vlan_aware_or_unaware
#     [Documentation]
#     ...    This case is used to verifyied the pcp classification for vlan tagged frames in vlan aware or unaware
#     [Tags]     0.830    classical
#     [Setup]    5GC000519_coam_common_keywords.killall firefox progress
#     RUN KEYWORD IF    '${cell_status}'=='FAIL'     Prepare the classical COAM BTS cell onair for SA
#     ...                                            scf_file=${scf_file}   bts_host=${bts_host}
#     should be equal    ${cell_status}    PASS
#     Check gnb COAM classical start normally for SA
#     ${Qos_tag}=    get QoS classification mode
#     RUN KEYWORD IF    '${Qos_tag}'=='DSCP'    change QoS classification mode to pcp
#     Start To Capture ENB Logs       filename=${enblog_E01}   connection=ENB
#     sleep    3s
#     Send PCP vlan tag traffic from testcenter to enb
#     sleep    90s
#     Stop and download ENB Logs       filename=${enblog_E01}   connection=ENB
#     Analysis enblog E01       Log_name=${enblog_E01}
#     Backup wireshark Files     connection=TestPC    wireshark_log_path=${test_path}
#     [Teardown]    Run Keywords    Run Keyword And Ignore Error    Tests Recover for SA    AND
#     ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Check FDB mac address for VLAN-ID and DST-MAC
#     [arguments]    ${VLAN_ID}
#     eNB connections
#     gNB connections
#     ${eNB_mac}=    csn.execute    command=ifconfig br1 |grep ether |awk '{print$2}'    connection=enb
#     ${IPV_status}    csn.execute    command=dbgrrc show mac|grep Dy|grep 15    connection=gnb
#     should contain    container=${eNB_mac}     item=${FDB_mac_address}
#     should contain    container=${IPV_status}    item=${VLAN_ID}
#     should contain    ${IPV_status}   ${FDB_mac_address}              Dynamic     ${VLAN_ID}      15
# 
# ping eNB with vlan interface should be success
#     ping eNB with vlan ID interface should be success     VLAN_ID=${vlan102_id}    ip_address=${vlan102_ip}
#     ping eNB with vlan ID interface should be success     VLAN_ID=${vlan501_id}    ip_address=${vlan501_ip}
#     ping eNB with vlan ID interface should be success     VLAN_ID=${vlan1901_id}    ip_address=${vlan1901_ip}
#     ping eNB with vlan ID interface should be success     VLAN_ID=${vlan4093_id}    ip_address=${vlan4093_ip}
# 
# at eNB ping with vlan interface should be success
#     at eNB ping with vlan ID interface should be success    VLAN_ID=${vlan102_id}    ip_address=${vlan102_ip}
#     at eNB ping with vlan ID interface should be success    VLAN_ID=${vlan501_id}    ip_address=${vlan501_ip}
#     at eNB ping with vlan ID interface should be success    VLAN_ID=${vlan1901_id}    ip_address=${vlan1901_ip}
#     at eNB ping with vlan ID interface should be success    VLAN_ID=${vlan4093_id}    ip_address=${vlan4093_ip}
# 
# at eNB ping with vlan interface should not be success
#     at eNB ping with vlan ID interface should not be success    VLAN_ID=${vlan102_id}    ip_address=${vlan102_ip}
#     at eNB ping with vlan ID interface should not be success    VLAN_ID=${vlan501_id}    ip_address=${vlan501_ip}
#     at eNB ping with vlan ID interface should not be success    VLAN_ID=${vlan1901_id}    ip_address=${vlan1901_ip}
#     at eNB ping with vlan ID interface should not be success    VLAN_ID=${vlan4093_id}    ip_address=${vlan4093_ip}
# 
# ping gNB with vlan 501 interface should be failed
#     eNB connections
#     csn.sendCommand    command=ping ${vlan501_ip} -c 20    connection=enb
#     sleep    time_=10s
#     ${ping_status}=    csn.read_output    connection=enb
#     should contain     container=${ping_status}    item=100% packet loss
#     csn.disconnect     connection=enb
# 
# ping eNB with vlan 1901 interface with no configured ip should be failed
#     at eNB ping with vlan ID interface should not be success    VLAN_ID=${vlan1901_id}
#     ...   ip_address=${vlan1901_no_configed_ip}
# 
# at eNB ping with vlan ID interface should be success
#     [arguments]    ${VLAN_ID}    ${ip_address}
#     Comment    ping ${VLAN_ID} should be success
#     eNB connections
#     csn.sendCommand    command=ping ${ip_address} -c 2    connection=enb
#     sleep    time_=3s
#     ${sctp_status} =    csn.read_output    connection=enb
#     should contain     container=${sctp_status}     item=2 received, 0% packet loss
#     csn.disconnect     connection=enb
# 
# at eNB ping with vlan ID interface should not be success
#     [arguments]    ${VLAN_ID}    ${ip_address}
#     Comment    ping ${VLAN_ID} should not be success
#     eNB connections
#     csn.sendCommand    command=ping ${ip_address} -c 2    connection=enb
#     sleep    time_=3s
#     ${sctp_status} =    csn.read_output    connection=enb
#     should contain     container=${sctp_status}     item=100% packet loss
#     csn.disconnect     connection=enb
# 
# Check eNB ping with vlan ID interface and FDB mac address
#     [arguments]    ${VLAN_ID}    ${ip_address}
#     at eNB ping with vlan ID interface should be success   VLAN_ID=${VLAN_ID}    ip_address=${ip_address}
#     #Check FDB mac address for VLAN-ID and DST-MAC    VLAN_ID=${VLAN_ID}
# 
# Send PCP vlan tag traffic from testcenter to enb
#     Send traffic from testcenter     connection=TestPC    testcenter_tclfile=${testcenter_pcp_vlantag_file}
# 
# Send DSCP vlan tag traffic from testcenter to enb
#     Send traffic from testcenter     connection=TestPC    testcenter_tclfile=${testcenter_dscp_tag_and_untag_file}
# 
# get QoS classification mode
#     ${value}=    Get parameter value    dis_name=${gNB_dist}/L2SWI-1    filter_name=QoS classification mode
#     [Return]    ${value}
# 
# change QoS classification mode to dscp
#     set new tag value    dis_name=${gNB_dist}/L2SWI-1   filter_name=QoS classification mode   new_value=DSCP
# 
# change QoS classification mode to pcp
#     set new tag value   dis_name=${gNB_dist}/L2SWI-1    filter_name=QoS classification mode   new_value=PCP
# 
# change l2ShaperRate for BRGPRT-1
#     set new tag value    dis_name=${gNB_dist}/L2SWI-1/BRGPRT-1    filter_name=Ethernet interface shaper rate
#     ...   new_value=${l2ShaperRate}
# 
# Analysis enblog E01
#     [Arguments]    ${Log_name}
#     tsk.read_cap    cap_file=${epc_log_path}${Log_name}
#     ${result}=    tsk.get_latest50_packages_startwith_192_168     field_expression=ip.src
#     Should not contain   container=${result}     item=${tsc_ip_src_dest_vlan501}
#     Should contain    container=${result}   item=${tsc_ip_src_dest_vlan102}
# 
# Analysis enblog E07
#     [Arguments]    ${Log_name}
#     tsk.read_cap    cap_file=${epc_log_path}${Log_name}
#     ${result}=    tsk.get_latest50_packages_startwith_192_168    field_expression=ip.src
#     Should contain    container=${result}     item=${tsc_ip_src_dest_vlan501}
#     Should not contain    container=${result}   item=${tsc_ip_src_dest_vlan102}
# 
# Lock 2gNB cells
#     Run keyword and ignore error    Perform gNB Cell Lock    gNB_id=${0}
#     Run keyword and ignore error    Perform gNB Cell Lock    gNB_id=${1}
# 
# UnLock 2gNB cells
#     Run keyword and ignore error    Perform gNB Cell Unlock    gNB_id=${0}
#     Run keyword and ignore error    Perform gNB Cell Unlock    gNB_id=${1}
# 
# UE teardown
#     Commercial UE detach    UE_type=${ueType}
#     UnLock 2gNB cells
#     sleep   120s
#     Change android UE 5Gstatus to    5Gstatus=Enabled
# 
# TestCase.Destory
#     Run keyword and ignore error    UE teardown
#     csn.ResetCache
#     Tests Recover for SA
# 
# Prepare Env for testing
#     Check UE device exist
#     power_ue.Prepare UE     ue_type=${ueType}
#     make sure enb cell is on air
#     Lock 2gNB cells
#     Change android UE 5Gstatus to    5Gstatus=Disabled
