*** Settings ***
Documentation
...    author: yuegong
...    contact: yue.1.gong@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC000574_5GC001200 interworking

Force Tags    CA_5G_RRM
...    PY36

Resource    Resources/5G000574_common_keywords.robot
#Resource    ./../../../../../resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Variables    Resources/variables.py
Variables    Resources/prarameters_variables.py
#Library     taf.selenium.sbts      WITH NAME       selenium_coam


Suite Setup    Run Keywords
...            Run Keyword And Ignore Error    Common Suite Setup for COAM
...    AND     Load SCF for each TL

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown
...    AND        Run Keyword And Ignore Error    Common Suite Teardown for COAM
...    AND        Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${tl_scf_dir_path}    /opt/workspace/SCF/
${eNB1_LNG_distname}    MRBTS-${tl.enbs[1].instance_id}/LNBTS-${tl.enbs[1].instance_id}/LNADJGNB-1
${eNB_1_scf_file_default}    Configuration_scf_eNB2.xml
${eNB_2_scf_file_default}    Configuration_scf_eNB1.xml
${connection_1}    eNB1
${connection_2}    eNB2
${TS_LOG_PATH_BASE}     /opt/workspace/CIT/Master/Case_Logs/
#############case parameter###############
${eNB1_x2_log}    574_A_000_eNB1.pcap
${eNB2_x2_log}    574_A_000_eNB2.pcap
${gNB_x2_log}    574_A_000_gNB.pcap
#${eNB1_x2_log_001}    574_A_001_eNB1.pcap
#${eNB2_x2_log_001}    574_A_001_eNB2.pcap
#${gNB_x2_log_001}    574_A_001_gNB.pcap
${eNB1_x2_log_103}    574_A_103_eNB1.pcap
${eNB2_x2_log_103}    574_A_103_eNB2.pcap
${gNB_x2_log_103}    574_A_103_gNB.pcap

${Send_Tput_DL_C001}    20M
${expected_tput_dl_C001}    15
${ul_throughput}    20M
${dl_throughput}    100M
${ul_expected_throughput}    15
${dl_expected_throughput}    90

#############574_A_7 case parameter###############
${eNB1_x2_log_007}    574_A_007_eNB1.pcap
${eNB2_x2_log_007}    574_A_007_eNB2.pcap
${gNB_x2_log_007}    574_A_007_gNB.pcap
${ul_throughput_1}    100M
${dl_throughput_1}    900M
#${ul_expected_throughput}    50
#${dl_expected_throughput}    245
${ul_expected_throughput_1}    5
${dl_expected_throughput_1}    40
${M8012C71_path}    CELLS/LNCEL-2/LTE_Cell_Throughput/MAC_SDU_VOL_UL_DTCH
${M8012C76_path}    CELLS/LNCEL-2/LTE_Cell_Throughput/MAC_SDU_VOL_DL_DTCH
${M8012C71_path_1}    CELLS/LNCEL-1/LTE_Cell_Throughput/MAC_SDU_VOL_UL_DTCH
${M8012C76_path_1}    CELLS/LNCEL-1/LTE_Cell_Throughput/MAC_SDU_VOL_DL_DTCH
${M8012C71_path_2}    [TL080] CELLS/LNCEL-1/LTE_Cell_Throughput/MAC_SDU_VOL_UL_DTCH
${M8012C76_path_2}    [TL080] CELLS/LNCEL-1/LTE_Cell_Throughput/MAC_SDU_VOL_DL_DTCH

#############574-C case parameter###############
${eNB1_x2_log_001}    574_C_001_eNB1.pcap
${eNB2_x2_log_001}    574_C_001_eNB2.pcap
${gNB_x2_log_001}    574_C_001_gNB.pcap
${eNB_parameter}    tac
${eNB_X2_parameter}    administrativeState
${x2_1_value}    locked
${x2_2_value}    unlocked
#${tac_new_value}    8600
${tac_new_value}    21000
${tac_origin_value}    20000
${M55112C04001_path}    CELLS/NRCELL-1/NX2CC/X2_SGNB_MOD_REQ_RECEIVD
${M55112C04002_path}    CELLS/NRCELL-1/NX2CC/X2_SGNB_MOD_REQ_ACK_SNT
@{BTSID}    36011    34711    23311
${tl_36011_scf_gnb1}    gy_36011_GNB1.xml
${tl_36012_scf_gnb2}    gy_36012_GNB2.xml
${tl_34711_scf_gnb1}    gy_34711_GNB1.xml
${tl_34712_scf_gnb2}    gy_34712_GNB2.xml
${tl_23311_scf_gnb1}    gy_23311_GNB1.xml
${tl_23312_scf_gnb2}    gy_23312_GNB2.xml

${enb1_gnb2_x2_dist}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNADJGNB-2
${enb2_gnb2_x2_dist}    MRBTS-${tl.enbs[1].instance_id}/LNBTS-${tl.enbs[1].instance_id}/LNADJGNB-2
${eNB1_cell1_distname}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
${eNB2_cell1_distname}    MRBTS-${tl.enbs[1].instance_id}/LNBTS-${tl.enbs[1].instance_id}/LNCEL-1
${enb1_def_gnb_dist}     MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enb_def_cell_para}     defaultLnRelGnbCellId
${enb_instance}    ${tl.enbs[0].instance_id}
${eNB_X2_ON_OFF}    administrativeState
${eNB_tac}    tac
@{value_counter_C01}    ${0}     ${0}    ${0}     ${0}
@{value_counter_C011}    ${0}     ${0}    ${0}
@{value_counter_C012}    ${0}
#${epc_log_path}    /home/ute/TAF/gy354/574logs/Logs/tmp/
@{gnb_list}    ${0}    ${1}
@{gnb_ips}    ${bts_host0}    ${bts_host1}
${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${bts_host1}    ${tl.gnbs[1].cu.oam_http_connection_details.addr}

*** Test Cases ***
[1]5GC000574_C_001_SGW_relocation_without_PSCell_change
    [Documentation]    The purpose of this test case is to check the handling of SgNB Addition procedure with SGW
    ...    relocation by 5GNB to support Inter MeNB handover without SgNB Change (No change in the SCG configuration,
    ...    just the Security Key Refresh at SgNB).

    [Tags]    CIT_TRUNK    CRT_22R3    CRT_22R2    CIT_22R4    CDRT
    [Timeout]    2 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    ${release_info}    Get gnb release info
    Run Keyword IF    '${release_info}' == 'SBTS24R1'     Set Counter Path for legacy
    ...    ELSE     Set Counter Path for trunk
#    Config counter path depends on Release
    Set Test Variable     ${ue_index}    ${0}
#    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
#    ...       Set Test Variable     ${ue_index}    ${1}
    Connect and Modify the ENB parameter
    ...    enb_index=${0}    value=locked    dist_name=${enb1_gnb2_x2_dist}    parameter=${eNB_X2_ON_OFF}
    Connect and Modify the ENB parameter
    ...    enb_index=${1}    value=locked    dist_name=${enb2_gnb2_x2_dist}    parameter=${eNB_X2_ON_OFF}
    Connect and Modify the ENB parameter    value=3    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${Lock_gnb2_AMF1}
    ...    ModifySCF_Aftercommission_for_GNB2=True
    Connect and Modify the ENB parameter
    ...    enb_index=${0}    value=unlocked    dist_name=${enb1_gnb2_x2_dist}    parameter=${eNB_X2_ON_OFF}
    Connect and Modify the ENB parameter
    ...    enb_index=${1}    value=unlocked    dist_name=${enb2_gnb2_x2_dist}    parameter=${eNB_X2_ON_OFF}
    Prepare the atten for each TL
    Connect and Modify the ENB parameter
    ...    enb_index=${1}    value=21000    dist_name=${eNB2_cell1_distname}    parameter=${eNB_tac}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=S20UI2.5    power_reset=True
    Start to collect the log on eNB    log_name=${eNB1_x2_log_001}    eNB_index=${0}
    Start to collect the log on eNB    log_name=${eNB2_x2_log_001}    eNB_index=${1}
    Start capture gNB log on master    filename=${gNB_x2_log_001}   gNB_index=${1}
    Prepare with PM counter time to caculate    period=start
    Wait Until Keyword Succeeds    4min    40s    Attach and check power UE    ue_type=${ue_type}
    ...    ue_index=${ue_index}    gnb_index=${1}    4G_check=True
    Prepare with PM counter time to caculate    period=end
    Comment    check UE NSA attach counter -20240923
    Check the relocation counters C011
#    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${ul_time}
#    ...    iperf_port=${ul_port}    ue_index=${ue_index}
    Comment    check with anle, this case can start UL or DL to make sure traffic not drop after enb HO--20240923
    Start only DL traffic and check tput    ue_index=${0}    cellid=${1}    ue_type=${ue_type}    gnb_index=${1}
    ...                                tput_dl_cell=${expected_tput_dl_C001}    dl_throughput=${Send_Tput_DL_C001}    duration=${7200}
    Prepare with PM counter time to caculate    period=start
    Comment    sleep 60s to guarantee counter can be triggered in correct time interval
    sleep    60s
    Change PA to Menb Handover
    Prepare with PM counter time to caculate    period=end
    Stop and download Logs on eNB    log_name=${eNB1_x2_log_001}    eNB_index=${0}
    Stop and download Logs on eNB    log_name=${eNB2_x2_log_001}    eNB_index=${1}
    Stop and download the Logs    filename=${gNB_x2_log_001}   gNB_index=${1}
    Comment    check HO counter
    Check the relocation counters C010
    Comment    after HO, check traffic still onging--20240923
    Check single direction throughput     ue_index=${0}    ue_type=${ue_type}    direction=DL    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${expected_tput_dl_C001}    gnb_index=${1}
    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type}    direction=DL
#    wait until keyword succeeds    8min    29s    Check the relocation counters C011
#    wait until keyword succeeds    8min    29s    Check the relocation counters C010
#    wait until keyword succeeds    8min    29s    Check the relocation counters C012
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    Check the logs when actInterMeNBMobility equal to true for 1200    eNB1_x2_log=${eNB1_x2_log_001}
    ...    eNB2_x2_log=${eNB2_x2_log_001}    gNB_x2_log=${gNB_x2_log_001}
    Stop capture syslog via btslog on ute
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error
    ...    Stop and download Logs on eNB    log_name=${eNB1_x2_log_001}    eNB_index=${0}    AND
    ...    Run Keyword And Ignore Error
    ...    Stop and download Logs on eNB    log_name=${eNB2_x2_log_001}    eNB_index=${1}    AND
    ...    Run Keyword And Ignore Error
    ...    Stop and download the Logs    filename=${gNB_x2_log_001}   gNB_index=${1}    AND
    ...    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type}    direction=DL    AND
    ...    Run Keyword And Ignore Error        Connect and Modify the ENB parameter
    ...    enb_index=${1}    value=20000    dist_name=${eNB2_cell1_distname}    parameter=${eNB_tac}    AND
    ...    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${Unlock_gnb2_AMF1}
    ...    ModifySCF_Aftercommission_for_GNB2=True    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    AND
    ...    Adjust the TL HBTE attenuation value    AND
    ...    Hanging resource test    AND
    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute    AND
    ...    get and analysis syslog    AND
    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM


*** Keywords ***
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
    Sleep    40s
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_C01}
    ...    dic_path=${suit_counter_dic_path_C01}    value=${value_counter_C01}
    ##...    dic_path=${counter_dic_path_C01}    value=${value_counter_C01}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_C01}
    ...    dic_path=${suit_counter_dic_path_C01}    value=${value_counter_C01}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_C01}
    ...    dic_path=${suit_counter_dic_path_C01}    value=${value_counter_C01}


Check the relocation counters C011
    Sleep    40s
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_C011}
    ...    dic_path=${suit_counter_dic_path_C11}    value=${value_counter_C011}
    #...    dic_path=${counter_dic_path_C01}    value=${value_counter_C01}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_C011}
    ...    dic_path=${suit_counter_dic_path_C11}    value=${value_counter_C011}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_C011}
    ...    dic_path=${suit_counter_dic_path_C11}    value=${value_counter_C011}

Check the relocation counters C012
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_C012}
    ...    dic_path=${suit_counter_dic_path_C12}    value=${value_counter_C012}
    #...    dic_path=${counter_dic_path_C01}    value=${value_counter_C01}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_C012}
    ...    dic_path=${suit_counter_dic_path_C12}    value=${value_counter_C012}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_C012}
    ...    dic_path=${suit_counter_dic_path_C12}    value=${value_counter_C012}

reboot enb2
    wait until keyword succeeds    2 min    10 sec    Connect to eNB2   alias=ENB2
    csn.send command    command=reboot   connection=ENB2

Check cell status on webui
    [Arguments]    ${connection}
    Connect to gnb coam via ssl    connection=${connection}
    Verify all cells should be onair    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

Check the throughput
    Check the DL and UL throughput    dl_expected_throughput=${dl_expected_throughput}
    ...    ul_expected_throughput=${ul_expected_throughput}

Modify the eNB Tac parameter
    [Arguments]    ${tac_value}
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Modify the enblte parameter
    ...    dist_name=${eNB_cell1_distname}   parameter=${eNB_parameter}     value=${tac_value}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Modify the enblte parameter
    ...    dist_name=${eNB_cell1_distname}   parameter=${eNB_parameter}     value=${tac_value}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Modify the enblte parameter
    ...    dist_name=${eNB_cell1_distname_1}   parameter=${eNB_parameter}     value=${tac_value}

Modify the eNB x2 parameter
    [Arguments]    ${x2_value}
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Modify the enblte parameter
    ...    dist_name=${eNB2_LNG_distname}   parameter=${eNB_X2_parameter}     value=${x2_value}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Modify the enblte parameter
    ...    dist_name=${eNB2_LNG_distname}   parameter=${eNB_X2_parameter}     value=${x2_value}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Modify the enblte parameter
    ...    dist_name=${eNB2_LNG_distname}   parameter=${eNB_X2_parameter}     value=${x2_value}

Modify the eNB1 x2 parameter
    [Arguments]    ${x2_value}
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Modify the enblte1 parameter
    ...    dist_name=${eNB1_LNG_distname}   parameter=${eNB_X2_parameter}     value=${x2_value}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Modify the enblte1 parameter
    ...    dist_name=${eNB1_LNG_distname}   parameter=${eNB_X2_parameter}     value=${x2_value}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Modify the enblte1 parameter
    ...    dist_name=${eNB1_LNG_distname}   parameter=${eNB_X2_parameter}     value=${x2_value}

Modify the enblte parameter
    [Arguments]    ${dist_name}    ${parameter}     ${value}
    Connect to eNB via ssl
    enblte.perform_parameter_recommissioning       dist_name=${dist_name}
    ...                                            parameter=${parameter}
    ...                                            operation=update
    ...                                            value=${value}
    ...                                            connection=enblte
    enblte.teardown    connection=enblte

Modify the enblte1 parameter
    [Arguments]    ${dist_name}    ${parameter}     ${value}
    Connect to eNB1 via ssl
    enblte.perform_parameter_recommissioning       dist_name=${dist_name}
    ...                                            parameter=${parameter}
    ...                                            operation=update
    ...                                            value=${value}
    ...                                            connection=enblte
    enblte.teardown    connection=enblte


Hanging resource test
    [Arguments]    ${gnb_ips}=@{gnb_ips}    ${ue_index}=${ue_index}
    [Documentation]    hanging resource test
    [Timeout]    1hour
    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ue_index=${ue_index}

#Connect to eNB via ssl
#    [Arguments]    ${BTS_PORT}= 443     ${USE_SSL}= True    ${connection}=enblte
#    enblte.connect_to    bts_host=${tl.enbs[2].airscale.common_units[0].lmp_connection.addr}
#    ...    bts_port=${BTS_PORT}  use_ssl=${USE_SSL}    name=${connection}

Connect to eNB1 via ssl
    [Arguments]    ${BTS_PORT}= 443     ${USE_SSL}= True    ${connection}=enblte
    enblte.connect_to    bts_host=${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
    ...    bts_port=${BTS_PORT}  use_ssl=${USE_SSL}    name=${connection}

Check the relocation log
    [Arguments]    ${input_file}
    Check the relocation x2log    input_file=${input_file}
    Check the relocation e1log    input_file=${input_file}
    should be equal    ${e1ap_SgNBmodify_IP_value}    ${x2ap_SgNBmodify_IP_value}
    should be equal    ${e1ap_SgNBmodify_teid_value}    ${x2ap_SgNBmodify_teid_value}

Check the relocation x2log
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_Y}
    ${SgNBmodify_request}=     Catenate    x2ap.procedureCode == 29
    ${SgNBmodify_packets}=    wireshark.filter_packets_by_expression
    ...    filter_expression=${SgNBmodify_request}
    ${SgNBmodify_IP_value}=    wireshark.get_field_value_by_xpath    pdml_list=${SgNBmodify_packets}
    ...    xpath=.//x2ap.transportLayerAddressIPv4
    ${SgNBmodify_teid_value}=    wireshark.get_field_value_by_xpath    pdml_list=${SgNBmodify_packets}
    ...    xpath=.//x2ap.gTP_TEID
    Should not be empty    ${SgNBmodify_IP_value}
    Set Suite Variable    ${x2ap_SgNBmodify_IP_value}    ${SgNBmodify_IP_value[0]}
    Should not be empty    ${SgNBmodify_teid_value}
    Set Suite Variable    ${x2ap_SgNBmodify_teid_value}    ${SgNBmodify_teid_value[0]}
    ${SgNBmodify_ACK}    Catenate    x2ap.procedureCode == 29 and ip.dst == ${eNB_asik_addr}
    ${SgNBmodify_ACK_packets}=    wireshark.filter_packets_by_expression
    ...    filter_expression=${SgNBmodify_ACK}
    ${SgNBmodify_ACK_value}=    wireshark.get_field_value_by_xpath    pdml_list=${SgNBmodify_ACK_packets}
    ...    xpath=.//x2ap.procedureCode
    should contain     ${SgNBmodify_ACK_value}    29
    ${Not_release}     Catenate    x2ap.procedureCode == 31 and ip.src == ${eNB_asik_addr}
    ${Not_release_packets}=    wireshark.filter_packets_by_expression
    ...    filter_expression=${Not_release}
    ${Not_release_value}=    wireshark.get_field_value_by_xpath    pdml_list=${SgNBmodify_ACK_packets}
    ...    xpath=.//x2ap.procedureCode

Check the relocation E1log
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_Z}
    ${bearmodify_request}=     Catenate    e1ap.id == 18
    ${bearmodify_request_packets}=    wireshark.filter_packets_by_expression
    ...    filter_expression=${bearmodify_request}
    ${bearmodify_request_ip_value}=    wireshark.get_field_value_by_xpath    pdml_list=${bearmodify_request_packets}
    ...    xpath=.//e1ap.transportLayerAddressIPv4
    ${bearmodify_request_teid_value}=    wireshark.get_field_value_by_xpath    pdml_list=${bearmodify_request_packets}
    ...    xpath=.//e1ap.gTP_TEID
    Should not be empty    ${bearmodify_request_ip_value}
    Set Suite Variable    ${e1ap_SgNBmodify_IP_value}    ${bearmodify_request_ip_value[-1]}
    Should not be empty    ${bearmodify_request_teid_value}
    Set Suite Variable    ${e1ap_SgNBmodify_teid_value}        ${bearmodify_request_teid_value[-1]}
    ${bearmodify_rsp}    Catenate   e1ap.id == 19
    ${bearmodify_rsp_packets}=    wireshark.filter_packets_by_expression
    ...    filter_expression=${bearmodify_rsp}
    ${bearmodify_rsp_value}=    wireshark.get_field_value_by_xpath    pdml_list=${bearmodify_rsp_packets}
    ...    xpath=.//e1ap.id
    should contain     ${bearmodify_rsp_value}    19

#Check the relocation counters
#    selenium_coam.enable_virtual_display
#    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    Check counter M55112C04001 as 1
    Check counter M55112C04002 as 1
    sleep    5s
#    [Teardown]    Run keyword and ignore error   selenium_coam.logout

Check the split throughput on enb UI
    [Arguments]    ${eNB_asik_addr}    ${M8012C71_path}    ${M8012C76_path}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${eNB_asik_addr}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    Check the bts counter M8012C71 from ${M8012C71_path} as 10000
    Check the bts counter M8012C76 from ${M8012C76_path} as 10000
    sleep    5s
    [Teardown]    Run keyword and ignore error   selenium_coam.logout

reset eNB site
    [Arguments]    ${eNB_asik_addr}=${eNB_asik_addr}    ${connection}=${connection}
    enblte.connect_to    bts_host=${eNB_asik_addr}
    ...    bts_port=443  use_ssl=True    name=${connection}
    enblte.reset_site    connection=${connection}

Check the split throughput on enb1 and enb2
    [Arguments]    ${eNB_asik_addr}    ${eNB_asik_addr_2}    ${M8012C71_path}
    ...    ${M8012C76_path}    ${M8012C71_path_1}    ${M8012C76_path_1}
    Check the split throughput on enb UI    eNB_asik_addr=${eNB_asik_addr}    M8012C71_path=${M8012C71_path}
    ...    M8012C76_path=${M8012C76_path}
    Check the split throughput on enb UI    eNB_asik_addr=${eNB_asik_addr_2}    M8012C71_path=${M8012C71_path_1}
    ...    M8012C76_path=${M8012C76_path_1}

Check the split throughput via counter on enb1 and enb2
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Check the split throughput on enb1 and enb2
    ...    eNB_asik_addr=${eNB_asik_addr}    eNB_asik_addr_2=${eNB_asik_addr_2}
    ...    M8012C71_path=${M8012C71_path}    M8012C76_path=${M8012C76_path}
    ...    M8012C71_path_1=${M8012C71_path_1}    M8012C76_path_1=${M8012C76_path_1}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Check the split throughput on enb1 and enb2
    ...    eNB_asik_addr=${eNB_asik_addr}    eNB_asik_addr_2=${eNB_asik_addr_2}
    ...    M8012C71_path=${M8012C71_path}    M8012C76_path=${M8012C76_path}
    ...    M8012C71_path_1=${M8012C71_path_2}    M8012C76_path_1=${M8012C76_path_2}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Check the split throughput on enb1 and enb2
    ...    eNB_asik_addr=${eNB_asik_addr}    eNB_asik_addr_2=${eNB_asik_addr_2}
    ...    M8012C71_path=${M8012C71_path_1}    M8012C76_path=${M8012C76_path_1}
    ...    M8012C71_path_1=${M8012C71_path}    M8012C76_path_1=${M8012C76_path}

Unlock all gNB cells
    Run Keyword And Ignore Error    Unlock the gNB cell    cell_idx=${2}
    Run Keyword And Ignore Error    Unlock the gNB cell    cell_idx=${3}
    Run Keyword And Ignore Error    Unlock the gNB cell    cell_idx=${4}

Config counter path depends on Release
    [Arguments]   ${gnb_index}=${0}   ${du_index}=${0}    ${common_unit_index}=${0}     #${connection}==du_coam
    ${var_status}    ${var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
    ...    gnb_index=${gnb_index}   du_index=${du_index}    common_unit_index=${common_unit_index}
    Run Keyword IF    '${var_dict}[stream]' == 'SBTS24R1'     Set Counter Path for legacy
    ...    ELSE     Set Counter Path for trunk

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}    ${release_info.split('_')[0]}
    [Return]    ${release_info}

Set Counter Path for trunk
    Set Suite Variable     ${suit_counter_dic_path_C01}     ${counter_dic_path_C01_trunk}
    Set Suite Variable     ${suit_counter_dic_path_C11}     ${counter_dic_path_C011_trunk}
    Set Suite Variable     ${suit_counter_dic_path_C12}     ${counter_dic_path_C012_trunk}

Set Counter Path for legacy
    Set Suite Variable     ${suit_counter_dic_path_C01}     ${counter_dic_path_C01}
    Set Suite Variable     ${suit_counter_dic_path_C11}     ${counter_dic_path_C011}
    Set Suite Variable     ${suit_counter_dic_path_C12}     ${counter_dic_path_C012}
