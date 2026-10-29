# #*** Settings ***
# #Documentation
# #...    author: cai.cris
# #...    contact:cai.cris@nokia-sbell.com
# #...    squad group: SG_03
# #...    feature : 5GC000519_classical
# #
# #Force Tags    CA_5G_RRM            9.1800
# #...    PY36
# #
# #Suite Setup    Prepare the classical COAM BTS cell onair for SA    scf_file=${scf_file}    bts_host=${bts_host}
# ##...    set and check value of parameter administrativeState on MO SNSSAI    value=Locked    new_value=Locked   AND
# #
# #Suite Teardown    Suite Recover
# #Resource    ../Resources/collect_log.robot
# #Resource    ../Resources/5GC000519_coam_common_keywords.robot
# #Resource    ../Resources/5GC000519_CC_common_keywords.robot
# #Variables    ../Resources/519_Case_Commission_Classical/__init__.py
# #Library    String
# #Library    taf.stc.config    WITH NAME    stc
# #Library    ../Resources/tshark_parser.py
# #Library    tshark_parser.Parser     WITH NAME    tsk
# #Library    taf.analyzer.pcap      WITH NAME      cap
# #
# #*** Variables ***
# #${bts_host}      ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
# #${WEBUI_URL}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
# #${WEBUI_COAM}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
# #${WEBUI_NAME}    ${tl.gnbs[1].cu.oam_http_connection_details.username}
# #${WEBUI_PWD}    ${tl.gnbs[1].cu.oam_http_connection_details.password}
# #${asik_addr}    ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
# #${asik_username}    ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.username}
# #${asik_password}    ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.password}
# #${gnb_instance}    ${tl.gnbs[1].instance_id}
# #${gNB_dist}    MRBTS-${tl.gnbs[1].instance_id}/TNLSVC-1/TNL-1/ETHSVC-1
# #${l2ShaperRate}     20000
# #${gnb_arp_log}    gnb_arp_log.pcap
# #${enb_arp_log}    enb_arp_log.pcap
# #${scf_file}    /opt/workspace/CIT/Master/SCF_file/cris/SCF/Full_Configuration_scf_20A_519.xml
# #${test_path}    /opt/workspace/CIT/Master/SCF_file/cris/SQ3project/
# #${testcase_status}    false
# #${vlan100ip}    192.168.108.9
# #${plain_ip}     ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# #${vlan500_ip}    192.168.158.9
# #${vlan1500_ip}    192.168.198.9
# #${vlan2500_ip}   192.168.248.9
# #${vlan1500_no_configed_ip}    192.168.208.9
# #${vlan100_id}    100
# #${vlan500_id}    500
# #${vlan1500_id}    1500
# #${vlan2500_id}    2500
# #${FDB_mac_address}     d6:ef:cd:ac:3a:dc
# #${Linux_SCT_IP_addr}    ${tl.test_pc.default_ssh_connection_details.addr}
# #${Linux_SCT_username}    ${tl.test_pc.default_ssh_connection_details.username}
# #${Linux_SCT_password}    ${tl.test_pc.default_ssh_connection_details.password}
# #${testcenter_pcp_vlantag_file}    /home/ute/SQ3project/519STC/519-E01_PCP_vlan_tag.tcl
# #${enblog_E01}    519_E_01.pcap
# #${enb_path}    /user/toor4nsn/
# #${gnb_path}    /tmp/
# #${gnblog_E01}    519_E_01_port15.pcap
# #${tsc_ip_src_dest_vlan102}     192.168.108.7,192.168.108.155
# #${tsc_ip_src_dest_vlan501}     192.168.158.7,192.168.158.155
# #${dl_port}      ${tl.ues[0].iperf_details.port}
# #${ul_time}    60s
# #${ul_length}    1024B
# #${ul_throughput}     10M
# #${ul_port}      ${tl.ues[0].iperf_details.ssh_connection_details.port}
# #${dl_time}    60s
# #${dl_length}    1024B
# #${dl_throughput}    10M
# #${ul_expect}    0
# #${dl_expect}    0
# #${epc_log_path}    /home/ute/SQ3project/cit
# #${appserver_addr}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
# #${appserver_username}    ${tl.appserver.iperf_details.ssh_connection_details.username}
# #${appserver_password}    ${tl.appserver.iperf_details.ssh_connection_details.password}
# #${ueType}    huawei
# #${gNB_dist_l2sw}      MRBTS-${tl.gnbs[1].instance_id}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
# #
# #*** Test Cases ***
# #[1]5GC000519_E_001_QoS_Aware_primary_classification_criteria_Vlan_PCP_for_VLAN_tagged_frame_in_vlan_aware_or_unaware
# #    [Documentation]
# #    ...    This case is used to verifyied the pcp classification for vlan tagged frames in vlan aware or unaware
# #    [Tags]     9.1800    classical        #QC_586063
# #    [Setup]    5GC000519_coam_common_keywords.killall firefox progress
# #    RUN KEYWORD IF    '${cell_status}'=='FAIL'     Prepare the classical COAM BTS cell onair for SA
# #    ...                                            scf_file=${scf_file}   bts_host=${bts_host}
# #    should be equal    ${cell_status}    PASS
# #    Check gnb COAM classical start normally for SA
# #    ${Qos_tag}=    get QoS classification mode
# #    RUN KEYWORD IF    '${Qos_tag}'=='DSCP'    change QoS classification mode to pcp
# #    Start To Capture ENB Logs       filename=${enblog_E01}   connection=ENB
# #    sleep    3s
# #    Send PCP vlan tag traffic from testcenter to enb
# #    sleep    40s
# #    Stop and download ENB Logs       filename=${enblog_E01}   connection=ENB
# #    Analysis enblog E01       Log_name=${enblog_E01}
# #    Backup wireshark Files     connection=TestPC    wireshark_log_path=${test_path}
# #    [Teardown]    Tests Recover for SA
# #
# #*** Keywords ***
# #Check FDB mac address for VLAN-ID and DST-MAC
# #    [arguments]    ${VLAN_ID}
# #    eNB connections
# #    gNB connections
# #    ${eNB_mac}=    csn.execute    command=ifconfig br1 |grep ether |awk '{print$2}'    connection=enb
# #    #${IPV_status}    csn.execute    command=dbgrrc show mac|grep Dy|grep 15    connection=gnb
# #    should contain    container=${eNB_mac}     item=${FDB_mac_address}
# #    #should contain    container=${IPV_status}    item=${VLAN_ID}
# #    #should contain    ${IPV_status}   ${FDB_mac_address}              Dynamic     ${VLAN_ID}      15
# #
# #ping eNB with vlan interface should be success
# #    ping eNB with vlan ID interface should be success     VLAN_ID=${vlan100_id}    ip_address=${vlan100_ip}
# #    ping eNB with vlan ID interface should be success     VLAN_ID=${vlan500_id}    ip_address=${vlan500_ip}
# #    ping eNB with vlan ID interface should be success     VLAN_ID=${vlan1500_id}    ip_address=${vlan1500_ip}
# #    ping eNB with vlan ID interface should be success     VLAN_ID=${vlan2500_id}    ip_address=${vlan2500_ip}
# #
# #ping eNB with vlan 1500 interface with no configured ip should be failed
# #    at eNB ping with vlan ID interface should not be success    VLAN_ID=${vlan1500_id}
# #    ...   ip_address=${vlan1500_no_configed_ip}
# #
# #at eNB ping with vlan ID interface should be success
# #    [arguments]    ${VLAN_ID}    ${ip_address}
# #    Comment    ping ${VLAN_ID} should be success
# #    eNB connections
# #    csn.sendCommand    command=ping ${ip_address} -c 2    connection=enb
# #    sleep    time_=3s
# #    ${sctp_status} =    csn.read_output    connection=enb
# #    should contain     container=${sctp_status}     item=2 received, 0% packet loss
# #    csn.disconnect     connection=enb
# #
# #at eNB ping with vlan ID interface should not be success
# #    [arguments]    ${VLAN_ID}    ${ip_address}
# #    Comment    ping ${VLAN_ID} should not be success
# #    eNB connections
# #    csn.sendCommand    command=ping ${ip_address} -c 2    connection=enb
# #    sleep    time_=3s
# #    ${sctp_status} =    csn.read_output    connection=enb
# #    should contain     container=${sctp_status}     item=100% packet loss
# #    csn.disconnect     connection=enb
# #
# #Check eNB ping with vlan ID interface and FDB mac address
# #    [arguments]    ${VLAN_ID}    ${ip_address}
# #    at eNB ping with vlan ID interface should be success   VLAN_ID=${VLAN_ID}    ip_address=${ip_address}
# ##    Check FDB mac address for VLAN-ID and DST-MAC    VLAN_ID=${VLAN_ID}
# #
# #Send PCP vlan tag traffic from testcenter to enb
# #    Send traffic from testcenter     connection=TestPC    testcenter_tclfile=${testcenter_pcp_vlantag_file}
# #
# #get QoS classification mode
# #    ${value}=    Get parameter value    dis_name=${gNB_dist}/L2SWI-1    filter_name=QoS classification mode
# #    [Return]    ${value}
# #
# #change QoS classification mode to dscp
# #    set new tag value    dis_name=${gNB_dist}/L2SWI-1   filter_name=QoS classification mode   new_value=DSCP
# #
# #change QoS classification mode to pcp
# #    set new tag value   dis_name=${gNB_dist}/L2SWI-1    filter_name=QoS classification mode   new_value=PCP
# #
# #Analysis enblog E01
# #    [Arguments]    ${Log_name}
# #    tsk.read_cap    cap_file=${epc_log_path}${Log_name}
# #    ${result}=    tsk.get_latest50_packages_startwith_192_168     field_expression=ip.src
# #    Should not contain   container=${result}     item=${tsc_ip_src_dest_vlan501}
# #    Should contain    container=${result}   item=${tsc_ip_src_dest_vlan102}
# #
# #Lock 2gNB cells
# #    Run keyword and ignore error    Perform gNB Cell Lock    gNB_id=${0}
# #    Run keyword and ignore error    Perform gNB Cell Lock    gNB_id=${1}
# #
# #UnLock 2gNB cells
# #    Run keyword and ignore error    Perform gNB Cell Unlock    gNB_id=${0}
# #    Run keyword and ignore error    Perform gNB Cell Unlock    gNB_id=${1}
# #
# #UE teardown
# #    Commercial UE detach     UE_type=${ueType}
# #    UnLock 2gNB cells
# #    sleep   120s
# #    UE.Change android UE 5Gstatus to    5Gstatus=Enabled
# #
# #TestCase.Destory
# #    Run keyword and ignore error    UE teardown
# #    csn.ResetCache
# #    Tests Recover for SA
# #
# #Prepare Env for testing
# #    Check UE device exist
# #    power_ue.Prepare UE     ue_type=${ueType}
# #    UE.make sure enb cell is on air
# #    Lock 2gNB cells
# #    UE.Change android UE 5Gstatus to    5Gstatus=Disabled
# #
# #UE.Preparation and execution for Commercial UE Attach
# #    [Documentation]    UE attach, make Commercial is on Airplane mode in default before, then Determine if UE has
# #    ...    attached to confirm whether the button was clicked once or twice
# #    ...    :param  UE_IP_net: check UP IP if eaqul this IP_net.
# #    ...    :param  UE_type: UE type
# #    ...    :param  ue_index: The list index from tl.ues[]
# #    [Arguments]    ${UE_IP_net}=127.0.0   ${UE_type}=${brand}    ${ue_index}=${0}
# #    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
# #    ...    ${home}=${home}    ${airplane}=${airplane}    ${close_task}=${close_task}
# #    UE.Get Commercial UE IP    ue_index=${ue_index}
# #    ${passed}=    Run Keyword And Return Status    Should Contain    ${UE_IP}    ${UE_IP_net}
# #    run keyword if    '${passed}'=='${True}'
# #    ...    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}    AND
# #    ...    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}
# #    ...    close_task=${close_task}    AND
# #    ...    Log to console    INFO:click AIRPLANE once for ${UE_type} UE attach.
# #    ...    ELSE
# #    ...    Run Keywords    Connect to control pc via cygwin    hostname=${hostname}    ue_index=${ue_index}    AND
# #    ...    Commercial UE click AIRPLANE twice    Home_button=${home}    airplane=${airplane}
# #    ...    close_task=${close_task}    AND
# #    ...    Log to console    INFO:click AIRPLANE twice for ${UE_type} UE attach.
# #
# #UE.Get Commercial UE IP
# #    [Arguments]    ${ue_index}=${0}
# #    Connect to control pc via cygwin    ue_index=${ue_index}
# #    UE.Get Commercial UE IP with first UE
# #
# #UE.Get Commercial UE IP with first UE
# #    [Documentation]    get UE IP
# #    ...    :param  command: common which to get UE IP
# #    [Arguments]    ${command}=adb shell ip -f inet addr |grep inet | cut -d '/' -f 1 |tail -n -1 |head -1 |awk '{print $2}'
# #    sleep   120s
# #    csn.send_command    command=${command}
# #    ...    connection=cygwin
# #    ${UE_IP}=    csn.Read Output    connection=cygwin
# #    ${UE_IP}=    Strip String    ${UE_IP}
# #    Set Suite Variable    ${UE_IP}    ${UE_IP}
# #    [Teardown]    csn.disconnect      connection=cygwin
# #
# #UE.unlocked LTE cell
# #    Connect and Modify the parameter on enblte
# #    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
# #    ...    parameter=administrativeState
# #    ...    value=unlocked
# #    sleep    10s
# #
# #UE.Change android UE 5Gstatus to
# #    [Documentation]   Verify 4G UE network type normal by ADB command.
# #    [Arguments]    ${5Gstatus}     ${ue_index}=${0}    ${sleep_time_before_read_output}=${None}
# #    UE.Preparation and execution for Commercial UE Attach
# #    sleep    20s
# #    ${SN} =    set variable    ${tl.ues[${ue_index}].serial_number}
# #    Connect to control pc enhanced    ue_index=${ue_index}
# #    csn.send command
# #    ...    command=adb -s ${SN} shell getprop gsm.network.type
# #    ...    connection=cpc_${ue_index}
# #    ...    timeout=5
# #    run keyword if    '${sleep_time_before_read_output}'!='${None}'    sleep    ${sleep_time_before_read_output}
# #    ${result} =    csn.read output    connection=cpc_${ue_index}
# #    csn.disconnect   connection=cpc_${ue_index}
# #    sleep    30s
# #    ${Is_5G_on}=    Run Keyword And Return Status    Should contain     container=${result}   item=NR
# #    run keyword if    '${Is_5G_on}'=='${True}' and '${5Gstatus}'=='Enabled'
# #    ...               Log    INFO:${UE_type} UE 5G status was already Enabled.
# #    ...    ELSE IF    '${Is_5G_on}'=='${True}' and '${5Gstatus}'=='Disabled'
# #    ...               Run Keywords    wait until keyword succeeds    5min    50s    make sure android UE 4G Attached
# #    ...               AND     Log to console    \nINFO:${UE_type} UE 4G Attached.
# #    ...    ELSE IF    '${Is_5G_on}'=='${False}' and '${5Gstatus}'=='Disabled'
# #    ...               Log to console    \nINFO:${UE_type} UE 5G status was already Disabled.
# #    ...    ELSE IF    '${Is_5G_on}'=='${False}' and '${5Gstatus}'=='Enabled'
# #    ...               Run Keywords    wait until keyword succeeds    5min    50s    make sure android UE 5G Attached
# #    ...               AND     Log to console    \nINFO:${UE_type} UE 5G Attached.
# #    ...    ELSE       Log to console    \nINFO:${UE_type} UE is abnormal.
# #
# #UE.make sure enb cell is on air
# #    Connect to eNB via ssl
# #    ${Is_Onair}=    Run Keyword And Return Status    Check enb status is in cell on air status
# #    run keyword if    '${Is_Onair}'=='${False}'    Run Keywords    UE.unlocked LTE cell     AND
# #    ...                Wait until enb cell on air status
