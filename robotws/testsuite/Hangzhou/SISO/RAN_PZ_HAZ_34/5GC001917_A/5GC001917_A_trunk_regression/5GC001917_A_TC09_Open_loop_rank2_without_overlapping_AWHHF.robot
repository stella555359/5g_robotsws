*** Settings ***
Documentation
...   author: yuegong&liu xu
...   contact: yue.1.gong@nokia-sbell.com
...   squad group: SG_03
...   feature : 5GC001917-A in trunk

Force Tags    5G_SISO            7.2836
...    PY36

Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup    AND
...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
...            Load SCF for each TL

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.pdu       WITH NAME    pdu
Library    taf.analyzer.pcap    WITH NAME    cap
Resource    ../Resources/5GC001917_A_common_keyword_MTK.robot
#Variables    ../Resources/__init__.py

*** Variables ***
#${tl_scf_dir_path}    /opt/workspace/CIT/Master/SCF_file/
#${tl_scf_filename}    Full_Configuration_scf_MRBTS-233_golden_v1.xml
${tl_36011_scf_gnb1}    gy_36011_GNB1.xml
${tl_36012_scf_gnb2}    gy_36012_GNB2.xml
${tl_34711_scf_gnb1}    gy_34711_GNB1.xml
${tl_34712_scf_gnb2}    gy_34712_GNB2.xml
${tl_23311_scf_gnb1}    gy_23311_GNB1.xml
${tl_23312_scf_gnb2}    gy_23312_GNB2.xml
#${tl_scf_dir_path}    /opt/workspace/SCF/
#${tl_scf_filename}    gold_347_236_233.xml
${TS_LOG_PATH_BASE}    /opt/workspace/CIT/Master/Case_Logs
#${tl_scf_filename}    TL233_gnb_SCF_open_dlMimoMode.xml
${enb_BTS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${gnb_BTS}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
${enb_instance}     ${tl.enbs[0].instance_id}
${gnb_instance}     ${tl.gnbs[0].instance_id}
${enbx2_para}    administrativeState
${atten_ip}    ${tl.attenuator[0].ip_addr}
${x2logname_A09}    1917_A09_x2.pcap
${ul_port}    ${tl.ues[0].iperf_details.port}
${ul_time}    600
${ul_length}    1024B
${ul_throughput}     60M
${dl_port}    ${tl.appserver.iperf_details.port}
${dl_time}    600
${dl_length}    1024B
${dl_throughput}    300M
${Expect_UPLINK}    0
${Expect_DOWNLINK}    5
${ul_tp_expect}    10
${dl_tp_expect}    200
${tshark_path}      /usr/bin/tshark
${command_template_Y}       {tshark_path} -r {pcap_file} -Y  \"x2ap\"  -T pdml
${ue_type}    ${tl.ues[0].capabilities[0]}
@{BTSID}    36011    34711    23311

${enb1_gnb2_x2_dist}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNADJGNB-2
${enb2_gnb2_x2_dist}    MRBTS-${tl.enbs[1].instance_id}/LNBTS-${tl.enbs[1].instance_id}/LNADJGNB-2
${eNB1_cell1_distname}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
${eNB2_cell1_distname}    MRBTS-${tl.enbs[1].instance_id}/LNBTS-${tl.enbs[1].instance_id}/LNCEL-1
${eNB_X2_ON_OFF}    administrativeState
@{gnb_list}    ${0}    ${1}
${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${bts_host1}    ${tl.gnbs[1].cu.oam_http_connection_details.addr}
@{gnb_ips}    ${bts_host0}    ${bts_host1}
${eNB2_defaultLnRelGnbCellId_distname}    defaultLnRelGnbCellId

*** Test Cases ***
[1][1.0] [1]5GC001917_A_09_Open_loop_rank2_CSI_RS_On_PUCCH_with_E2E_system_setup_with_data_transfer_without_overlapping
    [Tags]    CIT_TRUNK    CIT_22R4    CIT_22R3    CRT_22R3
    [Timeout]    1 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Connect and Modify the ENB parameter    value=locked    dist_name=${enb1_gnb2_x2_dist}    parameter=${eNB_X2_ON_OFF}
    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${Lock_gnb2_AMF1}
    ...    ModifySCF_Aftercommission_for_GNB2=True
    Connect and Modify the ENB parameter    value=unlocked    dist_name=${enb1_gnb2_x2_dist}    parameter=${eNB_X2_ON_OFF}
    Connect and Modify the ENB parameter    value=3    dist_name=${eNB1_cell1_distname}    parameter=${eNB2_defaultLnRelGnbCellId_distname}
    Prepare the atten for each TL
    Wait Until Keyword Succeeds    30min    120s    Repeat check until success
    Stop capture syslog via btslog on ute
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Stop and download the Logs    filename=${x2logname_A09}   gNB_index=${1}    AND
    ...    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${Unlock_gnb2_AMF1}
    ...    ModifySCF_Aftercommission_for_GNB2=True    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}    AND
    ...    Adjust the TL HBTE attenuation value    AND
    ...    Hanging resource test    AND
    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute    AND
    ...    get and analysis syslog    AND
    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM

*** Keywords ***
Repeat check until success
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
    Start capture gNB log on master    filename=${x2logname_A09}   gNB_index=${1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${1}    4G_check=True
    Stop and download the Logs    filename=${x2logname_A09}   gNB_index=${1}
    sleep    3s
    Analysis capture log    x2logname=${x2logname_A09}
    [Teardown]    Run Keywords
    ...    Stop and download the Logs    filename=${x2logname_A09}   gNB_index=${1}    AND
    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}

Analysis capture log
    [Arguments]    ${x2logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${x2logname}
    ...    tshark_path=${tshark_path}    command_template=${command_template_Y}
    ${filter_expression}=     Catenate    x2ap.X2AP_PDU == 1 && x2ap.procedureCode == 27
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${AS_ciphering_algorithms}=    cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.cipheringAlgorithm
    should contain    ${AS_ciphering_algorithms}    1

Start UE DLUL traffic
    [Arguments]    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}    ${ul_throughput}=${Send_Tput_UL}
    ...    ${dl_port}=${DL_PORT}
    Power UE Start DL traffic    ue_type=${ue_type}    dl_throughput=${dl_throughput}    dl_port=${dl_port}
    Power UE Start UL traffic    ue_type=${ue_type}    ul_throughput=${ul_throughput}

Stop UE DLUL traffic
    [Arguments]
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul

Hanging resource test
    [Arguments]    ${gnb_ips}=@{gnb_ips}    ${ue_index}=${0}
    [Documentation]    hanging resource test
    [Timeout]    1hour
    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ue_index=${ue_index}

#Prepare the atten for TL
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[0]'    Prepare the atten
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[1]'
#     ...    adjust the HBTE attenuation value    value_1=${16}    value_2=${16}   value_3=${127}    value_4=${127}
#     Run Keyword If    '${gnb_instance}' == '@{BTSID}[2]'    Prepare the atten
