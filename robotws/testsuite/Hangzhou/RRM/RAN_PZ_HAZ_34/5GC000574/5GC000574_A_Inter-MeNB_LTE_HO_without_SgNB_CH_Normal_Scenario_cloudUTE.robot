*** Settings ***
Documentation
...    author: yayun
...    contact: yayun.zhang@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC000574_5GC001200 interworking

Force Tags    CA_5G_RRM    CRT_TRUNK    RAN_5G    RAN_5G_TDD
...    PY36
...    CRT_UTE    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_QC_ASILL_ABIOB1B2_AEHC_AHFII_ENB    SBTS00

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000574/Resources/5G000574_common_keywords_cloudUTE.robot

Suite Setup    Run Keywords
...    SUITE SETUP FOR UTE    AND
...    Common Suite Setup for COAM

Suite Teardown    Run Keywords
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM    log_path=${OUTPUT_DIR}
...    AND        Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${eNB1_LNG_distname}    MRBTS-${tl.enbs[1].instance_id}/LNBTS-${tl.enbs[1].instance_id}/LNADJGNB-1
#############case parameter###############
${Send_Tput_DL_C001}    20M
${expected_tput_dl_C001}    15
${ul_throughput}    20M
${dl_throughput}    100M
${ul_expected_throughput}    15
${dl_expected_throughput}    90
#############574-C case parameter###############
${eNB1_x2_log_001}    574_C_001_eNB1.pcap
${eNB2_x2_log_001}    574_C_001_eNB2.pcap
${gNB_x2_log_001}    574_C_001_gNB.pcap
@{BTSID}    10318    34711    23311
${enb1_gnb2_x2_dist}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNADJGNB-2
${enb2_gnb2_x2_dist}    MRBTS-${tl.enbs[1].instance_id}/LNBTS-${tl.enbs[1].instance_id}/LNADJGNB-2
${eNB1_cell1_distname}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
${enb_instance}    ${tl.enbs[0].instance_id}
${eNB_tac}    tac
@{value_counter_C01}    ${0}     ${0}    ${0}     ${0}
@{value_counter_C011}    ${0}     ${0}    ${0}
@{value_counter_C012}    ${0}
@{gnb_list}    ${0}
@{gnb_ips}    ${bts_host0}
${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}

*** Test Cases ***
[1]5GC000574_C_001_SGW_relocation_without_PSCell_change
    [Documentation]    The purpose of this test case is to check the handling of SgNB Addition procedure with SGW
    ...    relocation by 5GNB to support Inter MeNB handover without SgNB Change (No change in the SCG configuration,
    ...    just the Security Key Refresh at SgNB).

    [Tags]    CIT_TRUNK    CDRT
    [Timeout]    2 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107,4681
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    ${release_info}    Get gnb release info
    Set Counter Path for trunk
    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online=${Lock_gnb1_AMF2}
    ...    ModifySCF_Aftercommission=True
    Adjust the HBTE attenuation value for cloud UTE    gnb_cell1_value=${0}    enb2_cell1_value=${0}
    Connect and Modify the ENB parameter
    ...    enb_index=${0}    value=21000    dist_name=${eNB1_cell1_distname}    parameter=${eNB_tac}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    #ui_version=S20UI2.5    #power_reset=True
    Start to collect the log on eNB    log_name=${eNB1_x2_log_001}    eNB_index=${0}
    Start to collect the log on eNB    log_name=${eNB2_x2_log_001}    eNB_index=${1}
    Start capture gNB log on master    filename=${gNB_x2_log_001}   gNB_index=${0}
    Prepare with PM counter time to caculate    period=start
    Wait Until Keyword Succeeds    4min    40s    Attach and check power UE    ue_type=${ue_type}
    ...    ue_index=${1}    gnb_index=${0}    4G_check=True
    Prepare with PM counter time to caculate    period=end
    Comment    check UE NSA attach counter -20240923
    Check the relocation counters C011
    Comment    check with anle, this case can start UL or DL to make sure traffic not drop after enb HO--20240923
    Start only DL traffic and check tput    ue_index=${1}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl_C001}    dl_throughput=${Send_Tput_DL_C001}    duration=${7200}
    Prepare with PM counter time to caculate    period=start
    Comment    Change PA to Menb Handover for cloud UTE
    Adjust the HBTE attenuation value for cloud UTE    gnb_cell1_value=${0}    enb1_cell1_value=${0}    enb2_cell1_value=${20}
    Comment    sleep 60s to guarantee counter can be triggered in correct time interval
    sleep    60s
    Prepare with PM counter time to caculate    period=end
    Stop and download Logs on eNB    log_name=${eNB1_x2_log_001}    eNB_index=${0}
    Stop and download Logs on eNB    log_name=${eNB2_x2_log_001}    eNB_index=${1}
    Stop and download the Logs    filename=${gNB_x2_log_001}   gNB_index=${0}
    Comment    check HO counter
    Check the relocation counters C010
    Comment    after HO, check traffic still onging--20240923
    Check single direction throughput     ue_index=${1}    ue_type=${ue_type}    direction=DL    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${expected_tput_dl_C001}    gnb_index=${0}
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type}    direction=DL
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
    Check the logs when actInterMeNBMobility equal to true for 1200    eNB1_x2_log=${eNB1_x2_log_001}
    ...    eNB2_x2_log=${eNB2_x2_log_001}    gNB_x2_log=${gNB_x2_log_001}
#    Stop capture syslog via btslog on ute
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Stop and download Logs on eNB    log_name=${eNB1_x2_log_001}    eNB_index=${0}    AND
    ...    Run Keyword And Ignore Error    Stop and download Logs on eNB    log_name=${eNB2_x2_log_001}    eNB_index=${1}    AND
    ...    Run Keyword And Ignore Error    Stop and download the Logs    filename=${gNB_x2_log_001}   gNB_index=${0}    AND
    ...    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type}    direction=DL    AND
    ...    Connect and Modify the ENB parameter    enb_index=${0}    value=20000    dist_name=${eNB1_cell1_distname}    parameter=${eNB_tac}    AND
    ...    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online=${Unlock_gnb1_AMF2}    ModifySCF_Aftercommission=True    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}    AND
    ...    Adjust the HBTE attenuation value for cloud UTE    AND
#    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute    AND
#    ...    get and analysis syslog    AND
    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM


*** Keywords ***
Adjust the HBTE attenuation value for cloud UTE
    [Arguments]     ${tl}=${MRBTS_ID}    ${gnb_cell1_value}=${127}     ${gnb_cell3_value}=${127}
    ...    ${enb1_cell1_value}=${127}    ${enb2_cell1_value}=${127}

    ####create cell list#####
    @{att_ports_gnb_cell1}    Create List    ${att_port_1_cell1_${tl}}      ${att_port_2_cell1_${tl}}
    ...                                      ${att_port_3_cell1_${tl}}      ${att_port_4_cell1_${tl}}
    @{att_ports_gnb_cell3}    Create List    ${att_port_5_cell3_${tl}}      ${att_port_6_cell3_${tl}}
    ...                                      ${att_port_7_cell3_${tl}}      ${att_port_8_cell3_${tl}}
    @{att_ports_enb1_cell1}    Create List    ${att_port_9_ENB1cell1_${tl}}    ${att_port_10_ENB1cell1_${tl}}
    @{att_ports_enb2_cell1}    Create List    ${att_port11_ENB2cell1_${tl}}    ${att_port_12_ENB2cell1_${tl}}
    ###create value list####
    @{values_gnb_cell1}    Create List    ${gnb_cell1_value}    ${gnb_cell1_value}    ${gnb_cell1_value}    ${gnb_cell1_value}
    @{values_gnb_cell3}    Create List    ${gnb_cell3_value}    ${gnb_cell3_value}    ${gnb_cell3_value}    ${gnb_cell3_value}
    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}    ${enb1_cell1_value}
    @{values_enb2_cell1}    Create List    ${enb2_cell1_value}    ${enb2_cell1_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_gnb_cell1}    values=${values_gnb_cell1}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_gnb_cell3}    values=${values_gnb_cell3}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
    ...    att_ports=${att_ports_enb2_cell1}    values=${values_enb2_cell1}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}

#Adjust the HBTE attenuation value for cloud UTE
#    [Arguments]     ${tl}=${MRBTS_ID}    ${gnb_cell1_value}=${127}     ${gnb_cell3_value}=${127}
#    ...    ${enb1_cell1_value}=${127}    ${enb2_cell1_value}=${127}
#
#    ####create cell list#####
#    @{att_ports_gnb_cell1}    Create List    ${att_port_13_cell1_${tl}}      ${att_port_14_cell1_${tl}}
#    @{att_ports_gnb_cell3}    Create List    ${att_port_15_cell3_${tl}}      ${att_port_16_cell3_${tl}}    #share with lte
#    @{att_ports_enb1_cell1}    Create List    ${att_port_7_ENBcell1_${tl}}
#    @{att_ports_enb2_cell1}    Create List    ${att_port_8_ENBcell1_${tl}}
#    ###create value list####
#    @{values_gnb_cell1}    Create List    ${gnb_cell1_value}    ${gnb_cell1_value}
#    @{values_gnb_cell3}    Create List    ${gnb_cell3_value}    ${gnb_cell3_value}
#    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}
#    @{values_enb2_cell1}    Create List    ${enb2_cell1_value}
#    ###Adjust the HBTE attenuation value###
#    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
#    ...    att_ports=${att_ports_gnb_cell1}    values=${values_gnb_cell1}
#    ...    att_connection_port=${att_port_13_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
#    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
#    ...    att_ports=${att_ports_gnb_cell3}    values=${values_gnb_cell3}
#    ...    att_connection_port=${att_port_13_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
#    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
#    ...    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
#    ...    att_connection_port=${att_port_13_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}
#    Set the attenuation value    att_api_port=${att_api_port_${tl}}    vendor=${vendor_${tl}}
#    ...    att_ports=${att_ports_enb2_cell1}    values=${values_enb2_cell1}
#    ...    att_connection_port=${att_port_13_cell1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}    model=${model_${tl}}

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Start only DL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=DL    ${tput_dl_cell}=${expected_tput_dl}     ${protocol}=udp    ${dl_port}=${DL_PORT}    ${duration}=${600}
    Power UE Start DL traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_throughput=${dl_throughput}    duration=${duration}
    ...    dl_port=${dl_port}    protocol=${protocol}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Set Suite Variable     ${nrcellid_cell}    ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_dl_cell}    gnb_index=${gnb_index}


Stop DL or UL traffic
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${direction}=DL     ${protocol}=udp    ${iperf_port}=default
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}    iperf_port=${iperf_port}

Check the relocation counters C010
    Sleep    60s
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${0}    counter_id=${counter_id_C01}
    ...    dic_path=${suit_counter_dic_path_C01}    value=${value_counter_C01}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${0}    counter_id=${counter_id_C01}
    ...    dic_path=${suit_counter_dic_path_C01}    value=${value_counter_C01}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${0}    counter_id=${counter_id_C01}
    ...    dic_path=${suit_counter_dic_path_C01}    value=${value_counter_C01}


Check the relocation counters C011
    Sleep    60s
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${0}    counter_id=${counter_id_C011}
    ...    dic_path=${suit_counter_dic_path_C11}    value=${value_counter_C011}
    #...    dic_path=${counter_dic_path_C01}    value=${value_counter_C01}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${0}    counter_id=${counter_id_C011}
    ...    dic_path=${suit_counter_dic_path_C11}    value=${value_counter_C011}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${0}    counter_id=${counter_id_C011}
    ...    dic_path=${suit_counter_dic_path_C11}    value=${value_counter_C011}

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}    ${release_info.split('_')[0]}
    [Return]    ${release_info}

Set Counter Path for trunk
    Set Suite Variable     ${suit_counter_dic_path_C01}     ${counter_dic_path_C01_trunk}
    Set Suite Variable     ${suit_counter_dic_path_C11}     ${counter_dic_path_C011_trunk}
    Set Suite Variable     ${suit_counter_dic_path_C12}     ${counter_dic_path_C012_trunk}
