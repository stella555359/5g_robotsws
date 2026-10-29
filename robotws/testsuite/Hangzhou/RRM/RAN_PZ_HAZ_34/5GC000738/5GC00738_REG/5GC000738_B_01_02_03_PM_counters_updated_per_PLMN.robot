*** Settings ***
Documentation
...    author: yue.1.gong
...    contact: yue.1.gong@nokia-sbell.com
...   squad group: SG_03
...   feature : 5GC000738

Force Tags    CA_5G_RRM
...    PY36

Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup    AND
...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
...            Load SCF for each TL

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections

Resource    Resources/5GC000738_REG_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Variables    Resources/__init__.py

*** Variables ***
${5GRU2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5GRU2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${s1log_B01}    738_B_01_S1.pcap
${E1log_B01}    738_B_01_E1.pcap
${s1log_B02}    738_B_02_S1.pcap
${E1log_B02}    738_B_02_E1.pcap
${s1log_B03}    738_B_03_S1.pcap
${E1log_B03}    738_B_03_E1.pcap
${tl_36011_scf_gnb1}    gy_36011_GNB1.xml
${tl_36012_scf_gnb2}    gy_36012_GNB2.xml
${tl_34711_scf_gnb1}    gy_34711_GNB1.xml
${tl_34712_scf_gnb2}    gy_34712_GNB2.xml
${T34721_SCF}           gy_34721_ENB1.xml
${T34722_SCF}           gy_34722_ENB2.xml
${tl_23311_scf_gnb1}    gy_23311_GNB1.xml
${tl_23312_scf_gnb2}    gy_23312_GNB2.xml
${enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
${enb1_gnb2_x2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-2
${enb1_def_gnb_dist}     MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enb_def_cell_para}     defaultLnRelGnbCellId
${eNB_X2_ON_OFF}    administrativeState
${x2_lock}    locked
${x2_unloack}    unlocked
@{BTSID}    36011    34711    23311
#${epc_log_path}        /opt/workspace/CRT/Master/Case_Logs/
@{value_counter_B01}    ${0}     ${0}
${dl_60M}    300M
${ul_60M}    10M
${dl_e}    140
${ul_e}    15

${duration}    600
#@{gnb_ips}    ${bts_host0}    ${bts_host1}
#${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
#${bts_host1}    ${tl.gnbs[1].cu.oam_http_connection_details.addr}
@{gnb_list}    ${0}     ${1}
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}

*** Test Cases ***
[1]5GC000738_B_01_PM_counters_updated_per_PLMN_when_NR_RAN_sharing_for_Cplane
    [Documentation]
    ...    The purpose of this test case is to verify the PM counters updated Per PLMN when RAN sharing enabled
    [Tags]     Qualcomm    classical    CIT_TRUNK    CIT_22R4    CDRT    CIT_23R1    CIT_22R3
    [Timeout]    1 hour
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
    Connect and Modify the ENB parameter    value=locked    dist_name=${enb1_gnb2_x2_dist}    parameter=${eNB_X2_ON_OFF}
    Connect and Modify the ENB parameter    value=3    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${Lock_gnb2_AMF1}
    ...    ModifySCF_Aftercommission_for_GNB2=True
    Connect and Modify the ENB parameter    value=unlocked    dist_name=${enb1_gnb2_x2_dist}    parameter=${eNB_X2_ON_OFF}
    Prepare the atten for each TL
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
    Start to collect the log on eNB    log_name=${s1log_B01}
    Start capture gNB log on master    filename=${E1log_B01}   gNB_index=${1}
    Wait Until Keyword Succeeds    10min    40s    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${1}    4G_check=True
    Wait until keyword succeeds    16 min    30s    Check counter for B01
    start DL UL    ue_index=${1}    #gnb_index=${1}
    sleep    6s
    Check DLUL tput    gnb_index=${1}
    Stop UL DL data transfer    ue_type=${ue_type}    ue_index=${1}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}
    Stop and download Logs on eNB    log_name=${s1log_B01}
    Stop and download the Logs    filename=${E1log_B01}   gNB_index=${1}
    ${M_plmn}    run keyword and return status    Wait until keyword succeeds    1 min    20s   Check counter for B01-1
    RUN KEYWORD IF    '${M_plmn}'=='None'    Wait until keyword succeeds    1 min    20s   Check counter for B01-2
    Stop capture syslog via btslog on ute
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error     Stop and download Logs on eNB    log_name=${s1log_B01}    AND
    ...    Run Keyword And Ignore Error    Stop and download the Logs    filename=${E1log_B01}   gNB_index=${1}    AND
    ...    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${Unlock_gnb2_AMF1}
    ...    ModifySCF_Aftercommission_for_GNB2=True    AND
    ...    Stop UL DL data transfer    ue_index=${1}    dl_port=${dl_port}    ul_port=${ul_port}    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}    AND
    ...    Adjust the TL HBTE attenuation value    AND
    ...    Hanging resource test    AND
    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute    AND
    ...    get and analysis syslog    AND
    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM


#[1]5GC000738_B_03_PM_counters_updated_per_PLMN_when_NR_RAN_sharing_for_Uplane_UL
#    [Documentation]
#    ...    The purpose of this test case is to verify the PM counters updated Per PLMN when RAN sharing enabled.
#    [Tags]     0.836    Qualcomm    classical    CRT_TRUNK    CRT_22R4    CRT_23R1
#    [Timeout]    1 hour
#    [Setup]
#    Connect and Modify the ENB parameter    value=locked    dist_name=${enb1_gnb2_x2_dist}    parameter=${eNB_X2_ON_OFF}
#    Connect and Modify the ENB parameter    value=3    dist_name=${enb1_def_gnb_dist}    parameter=${enb_def_cell_para}
#    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${Lock_gnb2_AMF1}
#    ...    ModifySCF_Aftercommission_for_GNB2=True
#    Connect and Modify the ENB parameter    value=unlocked    dist_name=${enb1_gnb2_x2_dist}    parameter=${eNB_X2_ON_OFF}
#    Prepare the atten for each TL
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}    ui_version=S20UI2.5    power_reset=True
#    Start to collect the log on eNB    log_name=${s1log_B03}
#    Start capture gNB log on master    filename=${E1log_B03}   gNB_index=${1}
#    Attach and check power UE    ue_type=${ue_type}    ue_index=${1}    gnb_index=${1}
#    sleep    10s
#    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${ul_time}
#    ...    iperf_port=${ul_port}    ue_index=${1}
#    sleep    10s
#    Stop and download Logs on eNB    log_name=${s1log_B03}
#    Stop and download the Logs    filename=${E1log_B03}   gNB_index=${1}
#    Wait until keyword succeeds    16 min    30s    Check counter for B03 each TL
#    [Teardown]    Run Keywords
#    ...    Run Keyword And Ignore Error     Stop and download Logs on eNB    log_name=${s1log_B03}    AND
#    ...    Run Keyword And Ignore Error    Stop and download the Logs    filename=${E1log_B03}   gNB_index=${1}    AND
#    ...    Online modify NIDD on gnb1 and gnb2    Modify_Para_Online_GNB2=${Unlock_gnb2_AMF1}
#    ...    ModifySCF_Aftercommission_for_GNB2=True    AND
#    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}    AND
#    ...    Run Keyword And Ignore Error    Common Case Teardown for COAM


*** Keywords ***
Load SCF for each TL
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_36011_scf_gnb1}    golden_scf_name_gnb2=${tl_36012_scf_gnb2}    is_pdl_checking_needed=False
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...    Enb_commission=True   Enb_commission_For_ENB2=True    enb_scf=${T34721_SCF}    enb2_scf=${T34722_SCF}
    ...     golden_scf_name=${tl_34711_scf_gnb1}    golden_scf_name_gnb2=${tl_34712_scf_gnb2}    is_pdl_checking_needed=False
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_23311_scf_gnb1}    golden_scf_name_gnb2=${tl_23312_scf_gnb2}    is_pdl_checking_needed=False

Prepare the atten for each TL
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}


Check counter for B01
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_B01}
    ...    dic_path=${suit_counter_dic_path_B01}    value=${value_counter_B01}
    #...    dic_path=${counter_dic_path_B01}    value=${value_counter_B01}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_B01}
    ...    dic_path=${suit_counter_dic_path_B01}    value=${value_counter_B01}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_B01}
    ...    dic_path=${suit_counter_dic_path_B01}    value=${value_counter_B01}

Check counter for B01-1
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_B01_1}
    ...    dic_path=${suit_counter_dic_path_B01_1}    value=${value_counter_B01}
    #...    dic_path=${counter_dic_path_B01_1}    value=${value_counter_B01}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_B01_1}
    ...    dic_path=${suit_counter_dic_path_B01_1}    value=${value_counter_B01}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_B01_1}
    ...    dic_path=${suit_counter_dic_path_B01_1}    value=${value_counter_B01}


Check counter for B01-2
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...   Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_B01_2}
    ...    dic_path=${suit_counter_dic_path_B01_2}    value=${value_counter_B01}
    #...    dic_path=${counter_dic_path_B01_2}    value=${value_counter_B01}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_B01_2}
    ...    dic_path=${suit_counter_dic_path_B01_2}    value=${value_counter_B01}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_B01_2}
    ...    dic_path=${suit_counter_dic_path_B01_2}    value=${value_counter_B01}


Check the PM counter should be value
    [Arguments]   ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    ${counter_value} =    taf.sbts.oam.coam.admin.get_pm_counters_by_dist_name    connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections

Check counter for B03 each TL
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Check counter for B03 36012
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Check counter for B03 34712
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Check counter for B03 23312

start DL UL
    [Arguments]    ${ue_index}=${0}    #${gnb_index}=${0}
#    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=${duration}    ue_index=${ue_index}
#    sleep    5s
    Power UE Start UL traffic    ul_throughput=${ul_throughput}    duration=${duration}    ue_index=${ue_index}




Check DLUL tput
    [Arguments]    ${gnb_index}=${0}
    ${cell1_id}=    COAM Get nrcellid with lcrid    lcrid=${1}    gnb_index=${1}
    ${list_of_cell_ids}    Create list    ${cell1_id}
    ${tput_log}    power_ue.Collect Tput    duration=10s    ue_type=${ue_type}    gnb_index=${gnb_index}
#    power_ue.Check Tput    direction=DL    cells=${list_of_cell_ids}    log=${tput_log}    ue_type=${ue_type}
#    ...    target_throughput=${dl_e}
    power_ue.Check Tput    direction=UL    cells=${list_of_cell_ids}    log=${tput_log}   ue_type=${ue_type}
    ...    target_throughput=${ul_e}


Attach ue and check tput
    [Arguments]    ${dl_expect_throughput}=${dl_expect_throughput}    ${list_of_cell_ids}=${list_of_cell_ids}
    ...    ${ue_index}=${0}    ${gnb_index}=${0}
#    wait until keyword succeeds    3X    10s
    Attach and check power UE     ue_type=${ue_type}    4G_check=False     ue_index=${ue_index}    gnb_index=${gnb_index}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=${duration}    ue_index=${ue_index}
    sleep    150s
    ${output}    Check single direction throughput    expect_throughput=${dl_expect_throughput}
    ...    list_of_cell_ids=${list_of_cell_ids}    duration=2m    ue_index=${ue_index}    gnb_index=${gnb_index}
    Power UE stop dl traffic and detach    ue_index=${ue_index}
    [Return]    ${output}

get peak value
    [Arguments]    ${peak_list}
    ${Peak_list_value}=    get from list    ${peak_list}    0
    ${Peak_value}=    get from dictionary   ${Peak_list_value}    average
    ${Peak_value}=    convert to integer    ${Peak_value}
    [Return]    ${Peak_value}

Check counter for B03 36012
    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_B03}
    ...    dic_path=${counter_dic_path_B03_36012}    value=${value_counter_B01}

Check counter for B03 34712
    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_B03}
    ...    dic_path=${counter_dic_path_B03_34712}    value=${value_counter_B01}

Check counter for B03 23312
    Check the PM counter should be greater than 1
    ...    gnb_index=${1}    counter_id=${counter_id_B03}
    ...    dic_path=${counter_dic_path_B03_23312}    value=${value_counter_B01}

Hanging resource test
    [Arguments]    ${gnb_ips}=@{gnb_ips}    ${ue_index}=${0}
    [Documentation]    hanging resource test
    [Timeout]    1hour
    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ue_index=${ue_index}

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
    Set Suite Variable     ${suit_counter_dic_path_B01}     ${counter_dic_path_B01_trunk}
    Set Suite Variable     ${suit_counter_dic_path_B01_1}     ${counter_dic_path_B01_1_trunk}
    Set Suite Variable     ${suit_counter_dic_path_B01_2}     ${counter_dic_path_B01_2_trunk}

Set Counter Path for legacy
    Set Suite Variable     ${suit_counter_dic_path_B01}     ${counter_dic_path_B01}
    Set Suite Variable     ${suit_counter_dic_path_B01_1}     ${counter_dic_path_B01_1}
    Set Suite Variable     ${suit_counter_dic_path_B01_2}     ${counter_dic_path_B01_2}
