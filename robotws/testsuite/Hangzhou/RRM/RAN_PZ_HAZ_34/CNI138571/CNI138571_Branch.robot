*** Settings ***
Documentation
...    author: jiana song
...    contact: jiana.song@nokia-sbell.com
...    squal group: SG03
...    feature: CNI138571

Force Tags  CA_5G_RRM    PY36
...    CRT_UTE    STATE_SW_UPLOADED    CRT    SBTS26R2
Suite Setup    Run Keywords
...                            robot_common_operations.Common Suite Setup
...                            AND    Common Suite Setup for COAM
...                            AND    Get sagnb version for selenium
...                            AND    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_SCF.xml
...                            AND    Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False
...                                   tl_scf_file_name=${tl_gnb1_scf_${sw_version}}
...                            AND    Get gnb release info

Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CNI138571/Resources/CNI138571_common_keywords.robot

*** Variables ***
${log_name_138571_1}    log_name_138571_1.pcap
${log_name_138571_2}    log_name_138571_2.pcap
${log_name_138571_3}    log_name_138571_3.pcap
${expected_tput_dl}    50
${Send_Tput_DL}        80M
${expected_tput_ul}    50
${Send_Tput_UL}        80M
${Send_Tput_DL_small}        5M
${Send_Tput_UL_small}        10M
@{expected_value_D001_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{Counter_D001}    ${0}
${kpis_templates_id}    1040
${tool_path}    /opt/workspace/Tool
${X70_wap2apn_location}    959 1370
${X70_mdrb2apn_location}    959 1576
${X70_mdrb1apn_location}    959 1802
@{enb_id}    2400    355
@{cell_id}    1    2    3    4    31
@{cell_id_355}    1    2    3
@{multi_gnb_PA}    ${0}     ${120}     ${20}     ${50}
@{multi_gnb_PA_358}    ${0}
@{multi_gnb_PA_348}    ${0}    ${50}    ${70}    ${10}
@{multi_gnb_PA_383}    ${0}    ${50}    ${70}    ${10}
${att_ipaddr_1}      ${tl.attenuator[0].ip_addr}
${DL_PORT_K01}    ${tl.ues[0].iperf_details.port}
${UL_PORT_K01}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
@{gnb_list}    ${0}
${scf_dir_path}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CNI138571/SCF/
${tl_scf_file_name1}    gNB1_SCF.xml
${golden_scf_name}    gNB1_Golden_SCF_trunk.xml

# TL2400
${4Gcells1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${4Gcells1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${4Gcells1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${4Gcells1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${4Gcells2_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${4Gcells2_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${4Gcells2_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${4Gcells2_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${4Gcells3_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${4Gcells3_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${4Gcells3_ANT3}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${4Gcells3_ANT4}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${4Gcells4_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${4Gcells4_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${4Gcells4_ANT3}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${4Gcells4_ANT4}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${dxdata2_apn}    95 943
#${dxdata2_apn_348}    150 943
${dxdata2_apn_348}    95 1030
${click_access_point}    380 1060
# ${iperf_server}=    Set Variable    ${tl.appserver[0]}
# ${SSH_CONN}=    Set Variable    ${tl.appserver[0].iperf_details.ssh_connection_details}
${dxdata2}    ${tl.ues[0].pdn[0]}
${mdrb_apn_name}    ${tl.ues[0].pdn[1]}
${mdrb1_apn_name}    ${tl.ues[0].pdn[2]}
${X75_dxdata2_location}    959 940
${X75_mdrb_location}    959 1152
${X75_mdrb1_location}    959 1350
@{GNB_INDEX_list_snapshot}    ${0}
${ue_type_qcom}    ${tl.ues[0].capabilities[0]}
@{counter_list_CNI138571}    M8029C34   M8029C35    M8011C230    M8051C119
@{counter_dic_path_cni138571}    BTS/MRBTS-2400/LNBTS-2400/LNCEL-1/MCC-262/MNC-03/LTE_MAC
...    BTS/MRBTS-2400/LNBTS-2400/LNCEL-1/MCC-262/MNC-03/LTE_MAC
...    BTS/MRBTS-2400/LNBTS-2400/LNCEL-1/MCC-262/MNC-03/LTE_Cell_Resource
...    BTS/MRBTS-2400/LNBTS-2400/LNCEL-1/MCC-262/MNC-03/LTE_UE_Quantity

*** Test Cases ***
CNI-138571_TC17_Performance of the CNI-138571 -FDD 8RX IRC intermediate solution with two FDD CPRI 4Tx4Rx RRH_20MHz
    [Documentation]    [1]CNI-138571
    [Tags]    CNI138571    QCD_MN_RAN      QCP_RAN_VRF
    [Setup]
    NEW Prerequisite
    NEW Step 1 UE attach
    NEW Step 2 UE make traffic on DL
    NEW Step 3 UE1 Start UL traffic on cell1
    NEW Step 4 check counters
    [Teardown]    CNI138571 Teardown

*** Keywords ***
NEW Prerequisite
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,6327,7311,4546
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    AlarmWatchdog.add_allow_alarms    fault_id=7311
    AlarmWatchdog.add_allow_alarms    fault_id=4546
    Check UE device status with adb recover    ue_index=${0}
    comment    Prerequisite
    Online modify parmeters     parameters_to_update=${PARAMS_TO_MODIFY_CB0138571}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
        ###set gnb1 cell1 PA to 0
    Set the Topyoung attenuation value for 4 ports Cell    cell=4Gcells${cell_id}[0]   value=${multi_gnb_PA}[2]    ip_addr=${att_ipaddr_1}
    Set the Topyoung attenuation value for 4 ports Cell    cell=4Gcells${cell_id}[2]   value=${multi_gnb_PA}[2]    ip_addr=${att_ipaddr_1}

NEW Step 1 UE attach
    comment    step1: ue attach to FDD cell
    power_ue.Prepare UE    ue_type=${ue_type_qcom}    ue_index=${0}
    Start capture gNB log on master    filename=${log_name_138571_1}
    Attach and check power UE LTE    ue_type=${ue_type_qcom}    ue_index=${0}    gnb_index=${0}    4G_check=True
    [Teardown]    Stop and download Logs on gNB on master    filename=${log_name_138571_1}

NEW Step 2 UE make traffic on DL
    comment    step3: make DL traffic traffic on Pcell and Scell
    Start capture gNB log on master    filename=${log_name_138571_2}
    Start only DL traffic and check tput common ue    ue_index=${0}    ue_type=${ue_type_qcom}
        ...                                dl_throughput=${Send_Tput_DL}    duration=${900}
        ...                                dl_port=${DL_PORT}
    [Teardown]     Stop and download Logs on gNB on master    filename=${log_name_138571_2}

NEW Step 3 UE1 Start UL traffic on cell1
    comment    step5: make UL traffic traffic on cell1
    Prepare with PM counter time to caculate    period=start
    Start capture gNB log on master    filename=${log_name_138571_3}
    Start only UL traffic and check tput common ue    ue_index=${0}   ue_type=${ue_type_qcom}
        ...                                ul_throughput=${Send_Tput_UL}    duration=${900}
        ...                                ul_port=${UL_PORT}
    [Teardown]     Stop and download Logs on gNB on master    filename=${log_name_138571_3}

NEW Step 4 check counters
    comment    step4: check counters
    Prepare with PM counter time to caculate    period=end
    sleep    1min    reason=check KPIs xml report generated 1min
    check counters for cni138571

CNI138571 Teardown
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    AlarmWatchdog.remove_allow_alarms    fault_id=6327
    AlarmWatchdog.remove_allow_alarms    fault_id=7311
    AlarmWatchdog.remove_allow_alarms    fault_id=4546
    Stop DL or UL traffic common ue    ue_index=${0}    ue_type=${ue_type_qcom}    direction=DL
    Stop DL or UL traffic common ue    ue_index=${0}    ue_type=${ue_type_qcom}    direction=UL
    Case Detach UE    ue_type=${ue_type_qcom}    ue_index=${0}
    Online modify parmeters     parameters_to_update=${PARAMS_TO_MODIFY_CB0138571_recover}    skip_parameter_relation_errors=False
    COAM Wait for gnb ready and cell setup
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    get gnb snapshot    gnb_index=${0}
    Set the Topyoung attenuation value for 4 ports Cell    cell=4Gcells${cell_id}[0]   value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
    Set the Topyoung attenuation value for 4 ports Cell    cell=4Gcells${cell_id}[2]   value=${multi_gnb_PA}[1]    ip_addr=${att_ipaddr_1}
    Run Keyword And Ignore Error    Common Case Teardown for COAM
#    Run Keyword And Ignore Error    Get SCF Internal Id By Scout    no_ute=${False}

check counters for cni138571
    Check gnb counter greater expected_value
    ...    counter_id=${counter_list_CNI138571[0]}
    ...    dic_path=${counter_dic_path_cni138571}[0]
    ...    expected_value=${0}
    ...    gnb_id=${1}
    Check gnb counter greater expected_value
    ...    counter_id=${counter_list_CNI138571[1]}
    ...    dic_path=${counter_dic_path_cni138571}[1]
    ...    expected_value=${100}
    ...    gnb_id=${1}
    Check gnb counter greater expected_value
    ...    counter_id=${counter_list_CNI138571[2]}
    ...    dic_path=${counter_dic_path_cni138571}[2]
    ...    expected_value=${100}
    ...    gnb_id=${1}
    Check gnb counter greater expected_value
    ...    counter_id=${counter_list_CNI138571[3]}
    ...    dic_path=${counter_dic_path_cni138571}[3]
    ...    expected_value=${99}
    ...    gnb_id=${1}

modify and commission scf file
    ${new_log_scf_path}=    change scf file
    ...    scf_path=${tl_scf_dir_path}    scf_name=${tl_gnb1_scf_${sw_version}}    new_scf_path=${TS_LOG_PATH_BASE}
    ${file_name}=    Evaluate    '${new_log_scf_path}'.split('/')[-1]
    Common Case TestLine Setup    is_commission=${True}    is_commission_for_second_gnb=${False}
    ...    scf_path=${TS_LOG_PATH_BASE}    golden_scf_name=${file_name}
    ...    skip_parameter_relation_errors=${False}

Case Detach UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Adjust the TL Topyoung attenuation value cell1 and cell3
    [Arguments]    ${cell1_value}=${120}    ${cell3_value}=${120}
    ####create cell list#####
    @{att_ports_enb1_cell1}    Create List    ${4Gcells1_ANT1}    ${4Gcells1_ANT2}    ${4Gcells1_ANT3}    ${4Gcells1_ANT4}
    @{att_ports_enb1_cell3}    Create List    ${4Gcells3_ANT1}    ${4Gcells3_ANT2}    ${4Gcells3_ANT3}    ${4Gcells3_ANT4}
    ###create value list####
    @{values_enb1_cell1}    Create List    ${cell1_value}    ${cell1_value}
    @{values_enb1_cell3}    Create List    ${cell3_value}    ${cell3_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value topyoung    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
    ...    att_ipaddr=${att_ipaddr_1}
    Set the attenuation value topyoung    att_ports=${att_ports_enb1_cell3}    values=${values_enb1_cell3}
    ...    att_ipaddr=${att_ipaddr_1}