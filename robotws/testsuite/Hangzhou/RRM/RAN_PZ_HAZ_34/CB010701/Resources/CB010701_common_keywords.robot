*** Settings ***
Documentation
...    author: xiaodan.li
...    contact: xiaodan.li@nokia-sbell.com
...    squad group: SG_03
...    feature : CB010701

Library     taf.config.testline    WITH NAME    testline
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
${tl_scf_dir_path}    /opt/workspace/SCF/
${ue_type}           ${tl.ues[-1].capabilities[0]}
${serial_number}    ${tl.ues[-1].serial_number}
${DL_PORT}        ${tl.ues[-1].iperf_details.port}
${UL_PORT}        ${tl.ues[-1].iperf_details.port}
${appserver_addr}    ${tl.ues[-1].iperf_details.ssh_connection_details.addr}
#${gnb_index}    ${1}
${tshark_path}      /usr/bin/tshark
${gnb_instance0}    ${tl.gnbs[0].instance_id}
${enb_instance}    ${tl.enbs[0].instance_id}
${bts_host}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
@{gnb_id}    38711    38611
${ue_index}    ${-1}
${Test_PC_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}    ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}    ${tl.test_pc.default_ssh_connection_details.password}
${server_ip}    ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${server_username}    ${tl.ues[0].iperf_details.ssh_connection_details.username}
${server_password}    ${tl.ues[0].iperf_details.ssh_connection_details.password}
###TL343
${att_port_1_gnb1_cell1_38611}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_gnb1_cell1_38611}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_gnb1_cell1_38611}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_gnb1_cell1_38611}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_gnb2_cell1_38611}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb2_cell1_38611}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb2_cell1_38611}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb2_cell1_38611}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_1_gnb1_cell3_38611}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_gnb1_cell3_38611}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_gnb1_cell3_38611}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_gnb1_cell3_38611}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_1_gnb2_cell2_38611}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_gnb2_cell2_38611}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_gnb2_cell2_38611}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_gnb2_cell2_38611}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_gnb1_cell2_38611}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb1_cell2_38611}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb1_cell2_38611}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb1_cell2_38611}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_1_gnb2_cell3_38611}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_gnb2_cell3_38611}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_gnb2_cell3_38611}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_gnb2_cell3_38611}                ${tl.attenuator[0].attenuator_ports[12]}

${att_ipaddr_gnb1_cell1_38611}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell1_38611}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell3_38611}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell2_38611}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb1_cell2_38611}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell3_38611}                ${tl.attenuator[1].ip_addr}

${att_port_1_gnb1_cell1_38711}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_gnb1_cell1_38711}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_gnb1_cell1_38711}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_gnb1_cell1_38711}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_1_gnb1_cell3_38711}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_gnb1_cell3_38711}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_gnb1_cell3_38711}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_gnb1_cell3_38711}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_1_gnb2_cell1_38711}                ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_gnb2_cell1_38711}                ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_gnb2_cell1_38711}                ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_gnb2_cell1_38711}                ${tl.attenuator[1].attenuator_ports[4]}
${att_port_1_gnb2_cell2_38711}                ${tl.attenuator[1].attenuator_ports[5]}
${att_port_2_gnb2_cell2_38711}                ${tl.attenuator[1].attenuator_ports[6]}
${att_port_3_gnb2_cell2_38711}                ${tl.attenuator[1].attenuator_ports[7]}
${att_port_4_gnb2_cell2_38711}                ${tl.attenuator[1].attenuator_ports[8]}
${att_port_1_gnb2_cell3_38711}                ${tl.attenuator[1].attenuator_ports[9]}
${att_port_2_gnb2_cell3_38711}                ${tl.attenuator[1].attenuator_ports[10]}
${att_port_3_gnb2_cell3_38711}                ${tl.attenuator[1].attenuator_ports[11]}
${att_port_4_gnb2_cell3_38711}                ${tl.attenuator[1].attenuator_ports[12]}

${att_ipaddr_gnb1_cell1_38711}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell2_38711}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell3_38711}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell1_38711}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell2_38711}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell3_38711}                ${tl.attenuator[1].ip_addr}

${traffic_duration}    360
${Send_Tput_DL}    300M
${Send_Tput_UL}    60M
${seg_size}    1180
${protocol_UDP}    udp
${ports_38711}    1
${ports_38611}    2
${length_38711}    27
${length_38611}    29

*** Keywords ***
Online modify NIDD on gnb
    [Arguments]    ${gnb_index}=${0}    ${Modify_Para_Online}='NULL'    ${Add_Para_Online}='NULL'
    ...    ${ParameterToDelete}='NULL'    ${Add_Mo_Online}='NULL'    ${Delete_Mo_Online}='NULL'
    Common Case TestLine Setup with singe BTS    gnb_index=${gnb_index}    ModifySCF_Aftercommission=True
    ...    Modify_Para_Online=${Modify_Para_Online}    Add_Para_Online=${Add_Para_Online}
    ...    Delete_Para_Online=${ParameterToDelete}    Add_Mo_Online=${Add_Mo_Online}
    ...    Delete_Mo_Online=${Delete_Mo_Online}
    Wait until keyword succeeds    20 min    20s
    ...    Check the cells status on air    bts_host=${bts_host}   connection=gnb${gnb_index}

Case Teardown
    Run Keyword And Ignore Error    Teardown Stop Capture Wireshark Logs on gNB    gnb_index=${1}
    Run Keyword And Ignore Error    Stop UL DL data transfer    ue_index=${-1}
    Common Case Teardown for COAM

Common Case TestLine Setup prepare
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[0]'
    ...    Run keywords    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${parameters_to_update_GNB1_prepare}
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-372    parameter=administrativeState     value=locked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-375    parameter=administrativeState     value=locked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-376    parameter=administrativeState     value=locked
    ...    ELSE    Run keywords    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-362    parameter=administrativeState     value=locked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-365    parameter=administrativeState     value=locked

Common Case TestLine Setup recover
    Run keyword if    '${gnb_instance0}' == '${gnb_id}[0]'
    ...    Run keywords    Modify Parameters for Cases   gnb_index=${0}    Modify_Para_Online=${parameters_to_update_GNB1_recover}
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-372    parameter=administrativeState     value=unlocked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-375    parameter=administrativeState     value=unlocked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-376    parameter=administrativeState     value=unlocked
    ...    ELSE    Run keywords    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-362    parameter=administrativeState     value=unlocked
    ...    AND    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-365    parameter=administrativeState     value=unlocked

############### wireshark log #######################
Check wireshark log
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${attribute_name}=show    ${epc_log_path}=${epc_log_path}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${filtered_result}=     cap.get_field_value_by_xpath    attribute_name=${attribute_name}    xpath=${xpath}    pcap_parser=test6
    [Return]    ${filtered_result}

Teardown Stop Capture Wireshark Logs on gNB
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    connection=gnb${gnb_index}    bts_host=${bts_host${gnb_index}}    gnb_index=${gnb_index}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    [Teardown]    csn.disconnect    connection=gnb${gnb_index}

Get UE IP from wirehsark
    [Arguments]    ${logname}    ${apn}=dxdata2
    ...    ${message_filter}=nas-5gs.cmn.dnn == "${apn}" and nas-5gs.sm.5qi == 7
    ...    ${xpath}=.//nas-5gs.sm.pdu_addr_inf_ipv4
    Log    Get UE IP from wirehsark
    ${UE_IP}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    [Return]    ${UE_IP}[-1]

Check wireshark log for 2CC
    [Arguments]    ${logname}    ${scell_index}=${31}    ${pcell_index}=${1}    ${scell_gnb_index}=${1}
    ...    ${message_filter}=nokiaf1ap.procedureCode ==7 and nr-rrc.sCellToAddModList == 1
    ...    ${xpath_filter}=.//nr-rrc.physCellId
    ${scell_list}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath_filter}
    ${pci_cclist}    Create List
    ${pcell_PCI}=    get required cell info   required_info=physicalCellId
    ...    cell_index=${pcell_index}   gnb_index=${scell_gnb_index}
    ${pcell_PCI}=    Convert To String    ${pcell_PCI}
    ${scell_PCI}=    get required cell info   required_info=physicalCellId
    ...    cell_index=${scell_index}   gnb_index=${scell_gnb_index}
    ${scell_PCI}=    Convert To String    ${scell_PCI}
    Append to list    ${pci_cclist}    ${pcell_PCI}    ${scell_PCI}
    List should Contain Sub List    ${scell_list}    ${pci_cclist}

Check wireshark log for 3TX capability
    [Arguments]    ${logname}    ${TDD_MIMO_Layers}=2    ${TDD_SRS_Ports}=1
    ...    ${message_filter}=nokiaf1ap.procedureCode ==12 and nr-rrc.sCellToAddModList == 1
    ...    ${xpath_filter1}=.//nr-rrc.pusch_ServingCellConfig/nr-rrc.setup_element/nr-rrc.maxMIMO_Layers
    ...    ${xpath_filter2}=.//nr-rrc.nrofSRS_Ports
    ${maxMIMO_Layers}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath_filter1}
    Should be equal    ${maxMIMO_Layers}[-1]    ${TDD_MIMO_Layers}
    ${SRS_Ports}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath_filter2}
    Should be equal    ${SRS_Ports}[-1]    ${TDD_SRS_Ports}

### PA adjust ###
Adjust gNB_RU Attenuation for 2gnb
    [Arguments]     ${tl}=${gnb_instance0}
    ...    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}
    ...    ${gnb1_cell3_value1}=${127}     ${gnb1_cell3_value2}=${127}    ${gnb1_cell3_value3}=${127}     ${gnb1_cell3_value4}=${127}
    ...    ${gnb2_cell2_value}=${127}
    ...    ${gnb2_cell1_value1}=${127}    ${gnb2_cell1_value2}=${127}    ${gnb2_cell1_value3}=${127}    ${gnb2_cell1_value4}=${127}
    ...    ${gnb2_cell3_value1}=${127}    ${gnb2_cell3_value2}=${127}    ${gnb2_cell3_value3}=${127}    ${gnb2_cell3_value4}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_gnb1_cell1_${tl}}    ${att_port_2_gnb1_cell1_${tl}}
    ...    ${att_port_3_gnb1_cell1_${tl}}    ${att_port_4_gnb1_cell1_${tl}}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_1_gnb1_cell2_${tl}}    ${att_port_2_gnb1_cell2_${tl}}
    ...    ${att_port_3_gnb1_cell2_${tl}}    ${att_port_4_gnb1_cell2_${tl}}
    @{att_ports_gnb1_cell3}    Create List    ${att_port_1_gnb1_cell3_${tl}}    ${att_port_2_gnb1_cell3_${tl}}
    ...    ${att_port_3_gnb1_cell3_${tl}}    ${att_port_4_gnb1_cell3_${tl}}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_1_gnb2_cell1_${tl}}    ${att_port_2_gnb2_cell1_${tl}}
    ...    ${att_port_3_gnb2_cell1_${tl}}    ${att_port_4_gnb2_cell1_${tl}}
    @{att_ports_gnb2_cell2}    Create List    ${att_port_1_gnb2_cell2_${tl}}    ${att_port_2_gnb2_cell2_${tl}}
    ...    ${att_port_3_gnb2_cell2_${tl}}    ${att_port_4_gnb2_cell2_${tl}}
    @{att_ports_gnb2_cell3}    Create List    ${att_port_1_gnb2_cell3_${tl}}    ${att_port_2_gnb2_cell3_${tl}}
    ...    ${att_port_3_gnb2_cell3_${tl}}    ${att_port_4_gnb2_cell3_${tl}}
    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb1_cell3}    Create List    ${gnb1_cell3_value1}    ${gnb1_cell3_value2}    ${gnb1_cell3_value3}    ${gnb1_cell3_value4}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value1}    ${gnb2_cell1_value2}    ${gnb2_cell1_value3}    ${gnb2_cell1_value4}
    @{values_gnb2_cell2}    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}
    @{values_gnb2_cell3}    Create List    ${gnb2_cell3_value1}    ${gnb2_cell3_value2}    ${gnb2_cell3_value3}    ${gnb2_cell3_value4}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_gnb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_gnb1_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell3}    values=${values_gnb1_cell3}
    ...    att_connection_port=${att_port_1_gnb1_cell3_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell3_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_gnb2_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${att_port_1_gnb2_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell3}    values=${values_gnb2_cell3}
    ...    att_connection_port=${att_port_1_gnb2_cell3_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell3_${tl}}

############### UE #######################
MTK prepare UE
    [Arguments]    ${ue_index}=${ue_index}    ${ue_type}=${ue_type}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}

MTK UE reboot
    [Arguments]    ${ue_index}=${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} reboot   connection=cygwin
    sleep   70s
    [Teardown]    csn.disconnect      connection=cygwin

MTK UE Down all ccmni
    [Arguments]    ${ue_index}=${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell ifconfig ccmni1 down   connection=cygwin
    sleep   3s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell ifconfig ccmni2 down   connection=cygwin
    sleep   3s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell ifconfig ccmni1 down   connection=cygwin
    sleep   3s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell ifconfig ccmni2 down   connection=cygwin
    sleep   3s
    ${output}    csn.Execute    command=adb -s ${serial_number} shell ifconfig   connection=cygwin
    sleep   3s
    ${port_lines}    String.Get Lines Containing String    ${output}    Link encap
    ${network_ports}    String.Get Regexp Matches    ${port_lines}    (\\S+)\\s+Link encap.*    1
    List should not contain value   ${network_ports}    ccmni1
    List should not contain value   ${network_ports}    ccmni2
    [Teardown]    csn.disconnect      connection=cygwin

MTK UE Attach
    [Arguments]    ${ue_index}=${ue_index}    ${ue_type}=mtk    ${gnb_index}=${1}    ${ue_alias}=UE_${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    ...    ue_alias=${ue_alias}    timeout=5
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=${4G_check}
#    ...    gnb_index=${gnb_index}
    sleep    5s

MTK UE Act Additional PDN
    [Arguments]    ${ue_index}=${ue_index}    ${pdn}=pdn
    ute_ue.Connect Additional Pdn    ue_alias=UE_${ue_index}    pdn=${pdn}

bollinger attach and collect log
    [Arguments]    ${logname}    ${names}=NULL    ${ue_index}=${ue_index}    ${gnb_index}=${1}
    ...    ${counter_id}=${EMPTY}    ${dic_path}=NULL    ${capture_time}=2s    ${nr_phy_cell_ids}=712
    ${counter_len}    Get length    ${counter_id}
    Start capture gNB log on master    filename=${logname}    gNB_index=${gnb_index}
    enable_vonr_capability    alias=UE_${ue_index}
    sleep    5s
    MTK UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    Stop and download the Logs    filename=${logname}   gNB_index=${gnb_index}
    Run keyword If   "${names}" != "NULL"    Capture Ttitrace With Admin Mode and Convert format    names=${names}
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    capture_time=${capture_time}
    Run keyword If   ${counter_len}>0    Prepare to caculate PM counter    period=start
    Run keyword If    ${counter_len}>0    Run keywords    Prepare to caculate PM counter    period=end
    ...    AND    Sleep    40s
    ...    AND    Check counter for 3TX when attach    counter_id=${counter_id}    dic_path=${dic_path}    gnb_index=${gnb_index}
    [Teardown]    Run Keyword And Ignore Error    Stop and download the Logs    filename=${logname}   gNB_index=${gnb_index}

Start DLUL traffic and check throughput
    [Arguments]    ${logname}=NULL    ${scellid}=1   ${pcellid}=3    ${apn}=dxdata2
    ...    ${tput_dl_pcell}=${expected_tput_dl_F}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${tput_ul_pcell}=${expected_tput_ul_F}    ${tput_ul_scell}=${expected_tput_ul_T}
    ...    ${dl_throughput}=${Send_Tput_DL}    ${ul_throughput}=${Send_Tput_UL}    ${ue_index}=${ue_index}
    ...    ${dl_port}=${DL_PORT}    ${seg_size}=1180    ${TDD_layer}=2    ${gnb_index}=${1}
    ...    ${dl_length}=1024B    ${duration}=30s    ${counter_id}=${EMPTY}    ${dic_path_F}=NULL    ${dic_path_T}=NULL
    run keyword If    '${logname}'!='NULL'
    ...    Start UE DLUL traffic MTK    dl_port=${dl_port}    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}
    ...    seg_size=${seg_size}    ue_index=${ue_index}    dl_length=${dl_length}    logname=${logname}    apn=${apn}
    ${counter_len}    Get length    ${counter_id}
    Run keyword If   ${counter_len}>0    Prepare to caculate PM counter    period=start
    sleep    20s
    Check 2CC DLUL tput for 387    scellid=${scellid}    pcellid=${pcellid}    tput_dl_pcell=${tput_dl_pcell}
    ...    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}    tput_ul_scell=${tput_ul_scell}
    ...    duration=${duration}    gnb_index=${gnb_index}
    Run keyword If   ${counter_len}>0    Run keywords    Prepare to caculate PM counter    period=end    AND
    ...    Sleep    40s    AND
    ...    Check counter for 3TX with traffic    counter_id=${counter_id}    dic_path=${dic_path_F}    cell_TYPE=FDD
    ...    gnb_index=${gnb_index}
    ...    AND    Check counter for 3TX with traffic    counter_id=${counter_id}    dic_path=${dic_path_T}
    ...    cell_TYPE=TDD    TDD_layer=${TDD_layer}    gnb_index=${gnb_index}

Prepare bollinger for UL traffic
    [Arguments]    ${ue_ip_addr}    ${ue_index}=${ue_index}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${ports}=1    ${length}=29
    Connect to control pc via cygwin    ue_index=${ue_index}
    sleep   5s
    ${output}    csn.execute    command=adb -s ${serial_number} shell ifconfig    connection=cygwin
    Sleep    10s
    ${port_lines}    String.Get Lines Containing String    ${output}    Link encap
    Sleep    2s
    ${network_ports}     String.Get Regexp Matches    ${port_lines}    (\\S+)\\s+Link encap.*    1
    Sleep    2s
    ${wwan_port}    Set Variable    ${network_ports}[${ports}]
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell ip addr add ${ue_ip_addr}/${length} dev ${wwan_port}    connection=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell ifconfig ${wwan_port} up    connection=cygwin
    sleep   10s
    csn.send_command    command=adb -s ${serial_number} shell ip route add default dev ${wwan_port}    connection=cygwin
    sleep   10s
    [Teardown]    csn.disconnect      connection=cygwin

Start UE DLUL traffic MTK
    [Arguments]    ${logname}    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}
    ...    ${dl_port}=${DL_PORT}    ${duration}=3000    ${seg_size}=1180   ${ul_throughput}=${Send_Tput_UL}
    ...    ${dl_length}=1024B    ${ue_index}=${ue_index}    ${apn}=dxdata2
    ...    ${ports}=${ports_${gnb_instance0}}    ${length}=${length_${gnb_instance0}}
    ${UE_IP}    Get UE IP from wirehsark    logname=${logname}    apn=${apn}
    Prepare bollinger for UL traffic    ue_ip_addr=${UE_IP}    ue_index=${ue_index}    ports=${ports}    length=${length}
    run keyword If    '${dl_throughput}'!='NULL'
    ...    Power UE Start DL traffic    ue_type=${ue_type}    dl_throughput=${dl_throughput}    dl_port=${dl_port}
    ...    duration=${duration}    seg_size=${seg_size}    ue_index=${ue_index}    dl_length=${dl_length}
    run keyword If    '${ul_throughput}'!='NULL'
     ...    bollinger UE Start UL traffic    ue_ip=${UE_IP}    ul_time=${duration}


bollinger UE Start UL traffic
    [Documentation]  This keyword connect to android control pc and start the iperf data.
    ...    2020-03-19 Cui Lingxue: use ${ue_sn} to indicate specific UE; add verification for iperf process
    ...    2020-12-22 Jia Lei: abstract three arguments for cpc_ip, cpc_usrname and cpc_passwd
    [Arguments]    ${ue_ip}    ${ue_index}=${ue_index}    ${ul_time}=3000    ${ul_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...    ${ul_throughput}=${Send_Tput_UL}   ${ul_length}=1400
    ...    ${ue_sn}=${tl.ues[${ue_index}].serial_number}    ${iperf_index}=${1}
    ...    ${EPC_addr}=${tl.ues[${ue_index}].iperf_details.network_interface_address}
    ...    ${iperf_path}=/usr/bin/iperf
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=UL_${ue_index}
    csn.send_command    command=adb -s ${ue_sn} shell ps |grep iperf |grep -v grep |awk '{print $${iperf_index}}'
    ...    connection=UL_${ue_index}   timeout=120
    ${output}    csn.read_output    size=1000    connection=UL_${ue_index}
    ${iperf_process_before}    Run Keyword And Continue On failure    run keyword if    '${output}'!='${EMPTY}'    evaluate    ${output.strip()}
    run keyword if    '${iperf_process_before}'!='${EMPTY}'    csn.send_command
    ...    command=adb -s ${ue_sn} shell kill -9 ${iperf_process_before}
    ...    connection=UL_${ue_index}
    ${cmd_ul_traffic}     catenate    adb -s ${ue_sn} shell
    ...    ${iperf_path} -c ${EPC_addr} -u -t ${ul_time} -i 1 -p ${ul_port} -P 10 -f m -b ${ul_throughput}
    ...    -l ${ul_length} -T 64 -B ${ue_ip} &
    csn.send_command    command=${cmd_ul_traffic}    connection=UL_${ue_index}   timeout=120
    sleep    3s
    csn.send_command    command=adb -s ${ue_sn} shell ps |grep iperf |grep -v grep |awk '{print $${iperf_index}}'
    ...    connection=UL_${ue_index}    timeout=120
    ${str}    csn.read_output    size=1000    connection=UL_${ue_index}
    ${iperf_process_id}    evaluate    ${str.strip()}
    should be true    ${iperf_process_id}  > ${0}
    [Teardown]    csn.disconnect      connection=UL_${ue_index}

bollinger UE Stop UL traffic
    [Documentation]  This keyword connect to android control pc and start the iperf data.
    ...    2020-03-19 Cui Lingxue: use ${ue_sn} to indicate specific UE; add verification for iperf process
    ...    2020-12-22 Jia Lei: abstract three arguments for cpc_ip, cpc_usrname and cpc_passwd
    [Arguments]    ${ue_index}=${ue_index}
    ...    ${ue_sn}=${tl.ues[${ue_index}].serial_number}      ${iperf_index}=${1}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${ue_sn} shell ps |grep iperf |grep -v grep |awk '{print $${iperf_index}}'
    ...    connection=cygwin    timeout=120
    ${output}    csn.read_output    size=1000    connection=cygwin
    ${iperf_process_before}    evaluate    ${output.strip()}
    run keyword if    '${iperf_process_before}'!='${EMPTY}'    csn.send_command
    ...    command=adb -s ${ue_sn} shell kill -9 ${iperf_process_before}
    ...    connection=cygwin
    [Teardown]    csn.disconnect      connection=cygwin

Check 2CC DLUL tput
    [Arguments]    ${tput_dl_pcell}=NULL    ${tput_dl_scell}=NULL
    ...    ${tput_ul_pcell}=NULL    ${tput_ul_scell}=NULL
    ...    ${scellid}=1   ${pcellid}=3    ${gnb_index}=${1}    ${ue_type}=${ue_type}    ${duration}=30s
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}    gnb_index=${gnb_index}
    ${nrcellid_scell}    COAM Get nrcellid with lcrid    lcrid=${scellid}    gnb_index=${gnb_index}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${nrcellid_scell}    Create list  ${nrcellid_scell}
    ${tput_log}    power_ue.Collect Tput    duration=${duration}   ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_index}
    Run keyword If    '${tput_dl_pcell}'!='NULL'
    ...    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}
    Run keyword If    '${tput_dl_scell}'!='NULL'
    ...    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell}    log=${tput_log}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell}
    Run keyword If    '${tput_ul_pcell}'!='NULL'
    ...    power_ue.Check Tput    direction=UL    cells=${nrcellid_pcell}    log=${tput_log}   ue_type=${ue_type}
    ...    target_throughput=${tput_ul_pcell}
    Run keyword If    '${tput_ul_scell}'!='NULL'
    ...    power_ue.Check Tput    direction=UL    cells=${nrcellid_scell}    log=${tput_log}   ue_type=${ue_type}
    ...    target_throughput=${tput_ul_scell}

Check 2CC DLUL tput for 387
    [Arguments]    ${tput_dl_pcell}=${expected_tput_dl_F}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${tput_ul_pcell}=${expected_tput_ul_F}    ${tput_ul_scell}=${expected_tput_ul_T}
    ...    ${scellid}=1   ${pcellid}=3    ${gnb_index}=${1}    ${ue_type}=${ue_type}    ${duration}=30s
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}    gnb_index=${gnb_index}
    ${nrcellid_scell}    COAM Get nrcellid with lcrid    lcrid=${scellid}    gnb_index=${gnb_index}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${nrcellid_scell}    Create list  ${nrcellid_scell}
    ${tput_log}    power_ue.Collect Tput    duration=${duration}   ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_index}
    ${DL_pcell}    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log}
    ...    ue_type=${ue_type}    target_throughput=${tput_dl_pcell}
    ${DL_pcell_avg}    Get From Dictionary    ${DL_pcell}[0]    average
    ${DL_scell}    run keyword If    ${DL_pcell_avg} < ${300}    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell}
    ...    log=${tput_log}    ue_type=${ue_type}    target_throughput=${tput_dl_scell}
    ${DL_scell_avg}    run keyword If    ${DL_pcell_avg} < ${300}    Get From Dictionary    ${DL_scell}[0]    average
    ...    ELSE    Set Variable    ${0}
    Should Be true    ${DL_pcell_avg}+ ${DL_scell_avg} > ${300}
    power_ue.Check Tput    direction=UL    cells=${nrcellid_pcell}    log=${tput_log}   ue_type=${ue_type}
    ...    target_throughput=${tput_ul_pcell}
    power_ue.Check Tput    direction=UL    cells=${nrcellid_scell}    log=${tput_log}   ue_type=${ue_type}
    ...    target_throughput=${tput_ul_scell}

Stop UE DLUL traffic
    [Arguments]    ${ue_index}=${ue_index}    ${dl_port}=${DL_PORT}    ${ul_port}=${UL_PORT}
#    ...    ${ue_type}=${tl.ues[0].capabilities[1]}
    run keyword If    '${ul_port}'!='NULL'
    ...    bollinger UE Stop UL traffic    ue_index=${ue_index}
    run keyword If    '${dl_port}'!='NULL'
    ...    power_ue.Stop traffic    ue_type=${tl.ues[0].capabilities[0]}    direction=dl    ue_index=${0}    iperf_port=${dl_port}

#####counter check#####
Check counter for 3TX when attach
    [Arguments]    ${counter_id}=NULL    ${dic_path}=NULL    ${gnb_index}=${1}
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${gnb_index}    counter_id=${counter_id}    dic_path=${dic_path}
    ${M55181C00013_NUM_3TX_UE_CAP}    Set Variable    ${counter_value_list}[0]
    ${M55181C00003_AVG_NUM_UE_DENOM}    Set Variable    ${counter_value_list}[1]
    ${M55165C00039_NUM_3TX_UE_CONFIG}    Set Variable    ${counter_value_list}[2]
    ${M55118C00054_1_SEC_SAMPLE}    Set Variable    ${counter_value_list}[3]
    Should Be True    ${M55181C00003_AVG_NUM_UE_DENOM} == 300
    Should Be True    305 > ${M55181C00013_NUM_3TX_UE_CAP} >295
    Should Be True    ${M55118C00054_1_SEC_SAMPLE} == 300
    Should Be True    305 > ${M55165C00039_NUM_3TX_UE_CONFIG} >295

Check counter for 3TX with traffic
    [Arguments]    ${counter_id}=NULL    ${dic_path}=NULL    ${cell_TYPE}=FDD    ${TDD_layer}=2
    ...    ${gnb_index}=${1}
    ${counter_value_list}    Get the all PM counter value
    ...    gnb_index=${gnb_index}    counter_id=${counter_id}    dic_path=${dic_path}
    ${M55370C00038_1L_2P}    Set Variable    ${counter_value_list}[0]
    ${M55370C00039_2L_2P}    Set Variable    ${counter_value_list}[1]
    ${M55370C00040_1L_1P}    Set Variable    ${counter_value_list}[2]
    ${M55302C15112_PUG}    Set Variable    ${counter_value_list}[3]
    ${M55302C15113_PUG}    Set Variable    ${counter_value_list}[4]
    Run keyword If    '${TDD_layer}' == '1'    Should Be True    150000 > ${M55370C00038_1L_2P} > 100000
    ...    ELSE    Should Be True    ${M55370C00038_1L_2P} == 0
    Run keyword If    '${cell_TYPE}' == 'FDD'    Run keywords
    ...    Should Be True    310000 > ${M55370C00040_1L_1P} > 280000    AND
    ...    Should Be True    ${M55370C00039_2L_2P} == 0     AND
    ...    Should Be True    ${M55302C15113_PUG} > 0     AND
    ...    Should Be True    ${M55302C15112_PUG} > 0    ELSE IF    '${cell_TYPE}' == 'TDD' and '${TDD_layer}' == '2'
    ...    Run keywords    Should Be True    200000 > ${M55370C00039_2L_2P} > 100000    AND
    ...    Should Be True    ${M55370C00040_1L_1P} == 0    AND
    ...    Should Be True    ${M55302C15112_PUG} == 0    AND
    ...    Should Be True    ${M55302C15113_PUG} == 0    ELSE    Run keywords
    ...    Should Be True    200000 > ${M55370C00039_2L_2P} == 0    AND
    ...    Should Be True    ${M55370C00040_1L_1P} == 0     AND
    ...    Should Be True    ${M55302C15112_PUG} == 0     AND
    ...    Should Be True    ${M55302C15113_PUG} == 0


Get the all PM counter value
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_list}    create list
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}    timeout=300
        append to list    ${counter_value_list}    ${counter_value[0]}
    END
    [Return]    ${counter_value_list}

Start BTSlogs Collection
    Run Keyword And Ignore error    put btslog_ini file to ute    server_ip=${server_ip}
    ...    server_username=${server_username}    server_password=${server_password}
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog

Stop Btslogs Collection
    Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
    Run keyword and continue on failure     Check ERR Or WRN From Syslog    sys_logs_path=${UTE_syslogs_path}

 #### ----------------------------TTI--------------------------------#####
Analysis tti for ulProGrantType
    [Arguments]    ${names}
    log to console    analysis tti file for per cell's ulFdSchedData.ulProGrantType
    ${GrantType_pcell}    get_GrantType_value    csv_file=${epc_log_path}${names}_ul.csv
    ...    PCI=${nr_phy_cell_ids}[0]    key_filter=physCellId    target_filter=ulFdSchedData.ulProGrantType
    ${GrantType_pcell}    Remove Duplicates    ${GrantType_pcell}
    ${GrantType_pcell_num}    Get Length   ${GrantType_pcell}
    Should be true    ${GrantType_pcell_num} > 0
    Should Contain    ${GrantType_pcell}    DRBPRIOPUGNONSKIPPABLE
    ${GrantType_scell}    get_GrantType_value    csv_file=${epc_log_path}${names}_ul.csv
    ...    PCI=${nr_phy_cell_ids}[1]    key_filter=physCellId    target_filter=ulFdSchedData.ulProGrantType
    ${GrantType_scell_num}    Get Length   ${GrantType_scell}
    Should be true    ${GrantType_scell_num} > 0
    ${GrantType_scell}    Remove Duplicates    ${GrantType_scell}
    Should not Contain    ${GrantType_scell}    DRBPRIOPUGNONSKIPPABLE