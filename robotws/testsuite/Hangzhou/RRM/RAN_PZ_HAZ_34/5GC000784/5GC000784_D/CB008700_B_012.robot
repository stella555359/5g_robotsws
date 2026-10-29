*** Settings ***
Force Tags    PY36
Documentation     author: xiaodan.li
...                 contact: xiaodan.li@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB008700+CB008247-EDA-02775785

Resource    ../5GC000784_C/Resources/5GC000784_common_keyword_xiaomi.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Variables    ../5GC000784_C/Resources/5GC00784_C_variables.py

Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup    AND
...            Run Keyword And Ignore Error       Common Suite Setup for COAM 784    AND
...            Load SCF with different release    AND
...            Adjust gNB_RU Attenuation    AND
...            Adjust enb attenuation    AND
...            Get sagnb release    AND
...            get_release_check_result

Suite Teardown    Run Keywords
...            robot_common_operations.Common Suite Teardown    AND
...            Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...            Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
...            Adjust gNB_RU Attenuation

*** Variables ***
${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
${tl_scf_filename_784B}    7326_784_SCF.xml
${tl_scf_filename_784B_2}    7326_784_SCF_gnb2.xml
${epc_log_path}       /tmp/
${localFilePath_swconfig_6112}    /opt/workspace/CRT/Master/SCF_file/swconfig.txt
${interface1}    any
${interface_gnb}    any
${log_name_B_012_EDA_1}    log_name_B_012_EDA_GNB1.pcap
${log_name_B_012_EDA_2}    log_name_B_012_EDA_GNB2.pcap
${log_name_B_012_1}    log_name_B_012_1.pcap
${log_name_B_012_2}    log_name_B_012_2.pcap
${log_name_B_012_3}    log_name_B_012_3.pcap
${log_name_B_012_4}    log_name_B_012_4.pcap
${log_name_B_012_5}    log_name_B_012_5.pcap
${log_name_784_1}    log_name_784_1.pcap
${log_name_784_2}    log_name_784_2.pcap
${log_name_784_test1}    log_name_784_test1.pcap
${log_name_784_test2}    log_name_784_test2.pcap
${log_name_784_test3}    log_name_784_test3.pcap

${message_filter1}      (nas-5gs.sm.5qi == 9 and f1ap.procedureCode == 12)
${message_filter2}      (nas-5gs.sm.5qi == 6 and f1ap.procedureCode == 12)
${message_filter3}      (nas-5gs.sm.5qi == 8 and f1ap.procedureCode == 12)
${message_filter4}      (nas-5gs.sm.5qi == 7 and f1ap.procedureCode == 12)

${asik_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}

${att_good}    ${0}
${att_bad}    ${127}
${att_HO}     ${10}
${att_good_376}    ${0}
${att_HO_388}    ${20}

@{gnb_id}    37611    37711    38811
${counter_end}    2
@{expected_value}    1    1    1    7    1   7    8    7    2    1    8    7
@{expected_value_B12_gnb1}    ${1}    ${1}    ${7}    ${1}    ${7}
@{expected_value_B12_gnb2}    ${1}    ${8}    ${7}    ${2}    ${1}    ${8}    ${7}
#${local_ngap_radioNetwork}    ngap.radioNetwork    ngap.radioNetwork    ngap.radioNetwork
${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"(ngap or e1ap or f1ap or xnap or s1ap)\"  -T pdml
@{dRB_To_Remove}    4    5    6   7
@{physCellId_38811}    498    499
@{physCellId_37711}    321    322
@{physCellId_37611}    376    378
${dl_expect_throughput_cell1_37611}    400
${dl_expect_throughput_cell1_38811}    400
${dl_expect_throughput_cell2_37611}    310
${dl_expect_throughput_cell2_37711}    630
${dl_expect_throughput_cell2_38811}    630
${dl_throughput}    1800M
${mdrb3_apn_name}    ${tl.ues[0].pdn[1]}
${dxdata2_apn_name}    ${tl.ues[0].pdn[0]}
@{allow_fault_list}    7311
${Send_Tput_DL}    10M
${expected_tput_dl}    8
@{transformPrecoderID}    6    2

*** Test Cases ***
[1]Forced_DFT-s-OFDM_during_EC_call_with_multiple_Emergency_ARP_CB007292_CB009849
    [Documentation]    UE1 911 call+Traffic and UE2 traffic
    [Tags]            classical    CRT_TRUNK
    [Setup]
    robot_common_operations.Common Case Setup
    Check UE device exist    ue_index=${0}
    Check UE device exist    ue_index=${1}
    Modify the parameters for case 784    parameters_to_update=${PARAMETERS_TO_UPDATE_784_GNB1_test}    gnb_index=${0}
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${10}
    Start Capture Wireshark Logs on gNB    nglogname=${log_name_784_test1}    interface=${interface1}    gnb_index=${0}
    UEs attach    gnb_index=${0}
    sleep    5s
    Make EMC call on samsung UE    ue_index=${0}
    sleep    5s
    Start only DL traffic and check tput    ue_index=${0}    ue_type=${ue_type}    dl_throughput=${Send_Tput_DL}    cellid=${1}    gnb_index=${0}
    Start only DL traffic and check tput    ue_index=${1}    ue_type=${ue_type}    dl_throughput=${Send_Tput_DL}    cellid=${1}    gnb_index=${0}
    Stop Capture Wireshark Logs on gNB     nglogname=${log_name_784_test1}    gnb_index=${0}
    Start Capture Wireshark Logs on gNB    nglogname=${log_name_784_test2}    interface=${interface1}    gnb_index=${0}
    hang up EMC call on samsung UE    ue_index=${0}
    sleep    3s
    Stop Capture Wireshark Logs on gNB     nglogname=${log_name_784_test2}    gnb_index=${0}
    Start Capture Wireshark Logs on gNB    nglogname=${log_name_784_test3}    interface=${interface1}    gnb_index=${0}
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${55}
    sleep    10s
    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_784_test3}    gnb_index=${0}
    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type}    direction=DL
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type}    direction=DL
    check UE1 911 call transformPrecoder enable        logname=${log_name_784_test1}
    check Release 911 call transformPrecoder disable    logname=${log_name_784_test2}
#    check RSRP110db transformPrecoder enable       logname=${log_name_784_test3}
    [Teardown]     Run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    run keyword and ignore error    Tear Down 784 test

[1]5GC000784_C_01_Verify_successful_EC_setup_with_5QI5_in_ICSR_UE_LSM_without_SIM_with_UE_Radio_Capability
    [Documentation]    No SIM 911 call
    [Tags]            classical    CRT_TRUNK
    [Setup]
    robot_common_operations.Common Case Setup
    Check UE device exist    ue_index=${2}
    Modify the parameters for case 784    parameters_to_update=${PARAMETERS_TO_UPDATE_784_GNB1}    gnb_index=${0}
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${10}
    Precondition for Sansumg UE    ue_index=${2}    ue_type=${ue_type}    ui_version=S21UI3.1
    Start Capture Wireshark Logs on gNB    nglogname=${log_name_784_1}    interface=${interface1}    gnb_index=${0}
    sleep    5s
    Make EMC call on samsung UE    ue_index=${2}
    sleep    5s
    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_784_1}    gnb_index=${0}
    Start Capture Wireshark Logs on gNB    nglogname=${log_name_784_2}    interface=${interface1}    gnb_index=${0}
    hang up EMC call on samsung UE    ue_index=${2}
    sleep    3s
    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_784_2}    gnb_index=${0}
    check NO sim 911 call checkpoint    logname=${log_name_784_1}
    check NO sim 911 call release checkpoint    logname=${log_name_784_2}
    [Teardown]     Run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    run keyword and ignore error    Tear Down 784

[1]CB008700-B_012_Counter_Inter-gNB_handover_when_ARP_based_admission_control_enabled_with_Voice_PDU_Session_with_DRBs_not_available_QOS_FLOW
    [Documentation]    Test case description the gNB behaviour for inter gnb HO with DRX configuration
    [Tags]            classical    CRT_TRUNK    CRT_22R3    CRT_22R4
    [Setup]
    robot_common_operations.Common Case Setup
    Check UE device exist
    Set APN point for sanmsungS22
    Modify the parameters for case B12    parameters_to_update=${PARAMETERS_TO_UPDATE_8700_B12_GNB1}    gnb_index=${0}
    ##ADD 8247_EDA 02775785 check point 2023-1-12
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${5}
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
    ADD 8247_EDA 02775785 check point
    ##follow is the CB008700-B12 check point
    ##Modify the COAM parameter with admin API
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Modify the parameters for case B12    parameters_to_update=${PARAMETERS_TO_UPDATE_8700_B12_GNB2}    gnb_index=${1}
    AlarmWatchdog.remove_allow_alarms    fault_id=${allow_fault_list}
    ##set gNB1 cell1 PA to 0,and gNB2 cell2 PA to 127
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${10}
    Run keyword if    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Set APN point for sanmsung until succeed    apn_name=${mdrb3_apn_name}
    ...    ELSE    set apn with special method    usedapn=${apn_mdrb3}    location_apn=${location_apn}
    ##1.1 UE1 attach to gnb and MultiDRB setup
#    put btslog_ini file to ute
#    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
#    Start capture syslog via btslog on ute
    Prepare with PM counter time to caculate    period=start
    Start Capture Wireshark Logs on gNB    nglogname=${log_name_B_012_1}    interface=${interface1}    gnb_index=${0}
    Power UE Attach and Verify attach
    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_B_012_1}    gnb_index=${0}
    ##1.2 UE1 make a VONR and EMC(hold on 6688)
    Start Capture Wireshark Logs on gNB    nglogname=${log_name_B_012_2}    interface=${interface1}    gnb_index=${0}
    Make a VoNR call(+6688) samsung
    Make EMC call on samsung UE
    sleep    5s
    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_B_012_2}    gnb_index=${0}
    ##1.3 triger Intragnb HO,EMC HO sucess and VONR HO cancel(cell 2 PA to 10db)
    Start Capture Wireshark Logs on gNB    nglogname=${log_name_B_012_3}    interface=${interface1}    gnb_index=${0}
    Start Capture Wireshark Logs on gNB    nglogname=${log_name_B_012_4}    interface=${interface1}    gnb_index=${1}
    sleep    5s
    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${25}    gnb2_cell1_value=${0}
    ...    ELSE
    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${35}    gnb2_cell1_value=${0}
    sleep    200s
    Stop Capture Wireshark Logs on gNB   nglogname=${log_name_B_012_3}    gnb_index=${0}
    Stop Capture Wireshark Logs on gNB   nglogname=${log_name_B_012_4}    gnb_index=${1}
    wait until keyword succeeds    5min   10s    Check counter for B12
    Start Capture Wireshark Logs on gNB    nglogname=${log_name_B_012_5}    interface=${interface1}    gnb_index=${1}
    sleep    5s
    hang up EMC call on samsung UE
    sleep    5s
    Stop Capture Wireshark Logs on gNB   nglogname=${log_name_B_012_5}    gnb_index=${1}
#    Stop capture syslog via btslog on ute
    Check wireshark log for 8700_B012_001
    Check wireshark log for 8700_B012_002
    Check wireshark log for 8700_B012_003
    Check wireshark log for 8700_B012_004
    [Teardown]     Run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    run keyword and ignore error    Tear Down 8700_B12


*** Keywords ***
check UE1 911 call transformPrecoder enable
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 7) && (nr-rrc.transformPrecoder == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${transformPrecoder}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.transformPrecoder    pcap_parser=test6
    ${transformPrecoder_num1}    get length    ${transformPrecoder}
    Should Be True   ${transformPrecoder_num1}==${transformPrecoderID[0]}

check Release 911 call transformPrecoder disable
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 12) && (nr-rrc.transformPrecoder == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${transformPrecoder}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.transformPrecoder    pcap_parser=test6
    Should Be Equal    ${transformPrecoder[0]}    1
    ${transformPrecoder_num2}    get length    ${transformPrecoder}
    Should Be True   ${transformPrecoder_num2}==${transformPrecoderID[1]}

check RSRP110db transformPrecoder enable
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    (nokiaf1ap.procedureCode == 7) && (nr-rrc.transformPrecoder == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${transformPrecoder}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.transformPrecoder    pcap_parser=test6
    ${transformPrecoder_num}    get length    ${transformPrecoder}
    Should Be True   ${pucch_ResourceId_num}==${transformPrecoderID[0]}

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

UEs attach
    [Arguments]    ${gnb_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${1}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${1}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False

UEs detach
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}
    power_ue.UE Detach     ue_type=${ue_type}    ue_index=${1}

Tear Down 784 test
    hang up EMC call on samsung UE    ue_index=${0}
    Stop DL or UL traffic    ue_index=${0}    ue_type=${ue_type}    direction=DL
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type}    direction=DL
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${0}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${1}
    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_784_test1}    gnb_index=${0}
    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_784_test2}    gnb_index=${0}
    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_784_test3}    gnb_index=${0}
    Modify NIDD parameter on gnb    parameters_to_update=${PARAMETERS_TO_recover_784_GNB1_test}    gnb_index=${0}
    Run Keyword And Ignore Error    coam.teardown    connection=GNB_OAM
    Run keyword and ignore error    CI_interface.Common Case Teardown

check NO sim 911 call checkpoint
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    (ngap.procedureCode == 15) && (ngap.RRCEstablishmentCause == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${RRCEstablishmentCause}=     cap.Get Field Value By Xpath    xpath=.//ngap.RRCEstablishmentCause    pcap_parser=test6
    Should Be Equal    ${RRCEstablishmentCause[0]}    0
    ${filter_expression}=     Catenate    (ngap.procedureCode == 46) && (nas-5gs.sm.message_type == 0xcc)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${message_type}=     cap.Get Field Value By Xpath    xpath=.//nas-5gs.sm.message_type    pcap_parser=test6
    Should Be Equal    ${message_type[0]}    0xcc
    ${filter_expression}=     Catenate    ngap.procedureCode == 26
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${procedureCode}=     cap.Get Field Value By Xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${procedureCode[1]}    26

check NO sim 911 call release checkpoint
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    (ngap.procedureCode == 28) && (ngap.nas == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Be Equal    ${ngap_nas[0]}    0
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    (ngap.procedureCode == 46) && (nas-5gs.sm.message_type == 0xd4)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${message_type}=     cap.Get Field Value By Xpath    xpath=.//nas-5gs.sm.message_type    pcap_parser=test6
    Should Be Equal    ${message_type[0]}    0xd4

Tear Down 784
    hang up EMC call on samsung UE    ue_index=${2}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${2}
    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_784_1}    gnb_index=${0}
    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_784_2}    gnb_index=${0}
    Modify NIDD parameter on gnb    parameters_to_update=${PARAMETERS_TO_recover_784_GNB1}    gnb_index=${0}
    Run Keyword And Ignore Error    coam.teardown    connection=GNB_OAM
    Run keyword and ignore error    CI_interface.Common Case Teardown

Modify the parameters for case 784
    [Arguments]    ${parameters_to_update}=${PARAMETERS_TO_UPDATE_784_GNB1}    ${gnb_index}=${0}
    Modify NIDD parameter on gnb    parameters_to_update=${parameters_to_update}    gnb_index=${gnb_index}    timeout=${300}
    wait until keyword succeeds    15min   60s    Check the gnb2 cell status onair    gnb_index=${gnb_index}

Modify the parameters for case B12
    [Arguments]    ${parameters_to_update}=${PARAMETERS_TO_UPDATE_8700_B12}    ${gnb_index}=${0}
    Modify NIDD parameter on gnb    parameters_to_update=${parameters_to_update}    gnb_index=${gnb_index}    timeout=${300}
    wait until keyword succeeds    15min   60s    Check the gnb2 cell status onair    gnb_index=${gnb_index}

Prepare env with UE
    [Arguments]    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}

hold on VONR and make an emergency
    [Arguments]    ${ue_index}=${0}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    hold on an VONR
    Start a emergency call
    sleep    40s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

Check wireshark log for 8700_B012_001
    Check gnb1 cell1 Multidrb    logname=${log_name_B_012_1}    message_filter1=${message_filter1}    message_filter2=${message_filter2}
    ...    message_filter3=${message_filter3}    message_filter4=${message_filter4}

Check gnb1 cell1 Multidrb
    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}    ${message_filter3}    ${message_filter4}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter1}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nas-5gs.sm.5qi    pcap_parser=test6
    Should Contain    '${ngap_fiveQI}'    9
    ${filter_expression}=     Catenate    ${message_filter2}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nas-5gs.sm.5qi    pcap_parser=test6
    Should Contain    '${ngap_fiveQI}'    6
    ${filter_expression}=     Catenate    ${message_filter3}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nas-5gs.sm.5qi    pcap_parser=test6
    Should Contain    '${ngap_fiveQI}'    8
    ${filter_expression}=     Catenate    ${message_filter4}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//nas-5gs.sm.5qi    pcap_parser=test6
    Should Contain    '${ngap_fiveQI}'    7

Check wireshark log for 8700_B012_002
    ###Check wireshark log for hold on and successful EC procedure
    Check wireshark log for VONR hold on successful    logname=${log_name_B_012_2}
    Check wireshark log for successful EC procedure    logname=${log_name_B_012_2}

Check wireshark log for successful EC procedure
    [Arguments]    ${logname}
    Check wireshark log for EC setup    logname=${logname}
    Check wireshark log for EC 5QI 5    logname=${logname}
    Check wireshark log for EC 5QI 1    logname=${logname}

Check wireshark log for VONR hold on successful
    [Arguments]    ${logname}
    Check wireshark log for VONR and EC unrelease    logname=${logname}

Check wireshark log for VONR and EC unrelease
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ###Check wireshark log for EMC unrelease
    ${filter_expression}=     Catenate    (ngap.nas == 0 and ngap.procedureCode == 28)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Not Contain    ${ngap_nas}    0
    ###Check wireshark log for VONR unrelease
    ${filter_expression}=     Catenate     (ngap.nas == 0 and ngap.procedureCode == 26)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Not Contain    ${ngap_nas}    0

Check wireshark log for VoNR
    [Arguments]    ${logname}    ${message_filter}    ${xpath_filter}    ${expect_value}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}
    should be equal    ${filtered_value[0]}    ${expect_value}


Check wireshark log for 8700_B012_004
    Check wireshark log for EMC normal release    logname=${log_name_B_012_5}

Check wireshark log for EMC normal release
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    (ngap.nas == 0 and ngap.procedureCode == 28)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Be Equal    ${ngap_nas[0]}    0

Check wireshark log for 8700_B012_003_trunk
    Check wireshark log for EMC HO sucess and VONR release and 8700 checkpoint trunk    logname=${log_name_B_012_3}
    Check wireshark log for VONR release for QOS trunk    logname1=${log_name_B_012_2}    logname2=${log_name_B_012_3}
    check HO point1    logname=${log_name_B_012_3}

Check wireshark log for 8700_B012_003
    Check wireshark log for EMC HO sucess and VONR release and 8700 checkpoint
    ...    logname_source=${log_name_B_012_3}    logname_target=${log_name_B_012_4}
    Comment    202050916 chat ,remove check normal release 6688
#    Check wireshark log for VONR release for QOS and pdusession    logname1=${log_name_B_012_2}    logname2=${log_name_B_012_4}

Check wireshark log for VONR release for QOS trunk
    [Arguments]    ${logname1}      ${logname2}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname2}    command_template=${command_template_with_Y}    alias=test6
    ###check  PDU Session Resource Notify message
    ${filter_expression}=     Catenate    ngap.radioNetwork == 22 and ngap.procedureCode == 30
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_radioNetwork}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    22
    ${filter_expression}=     Catenate        ngap.qosFlowIdentifier and ngap.procedureCode == 30
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${qosFlowIdentifier1}=     cap.Get Field Value By Xpath    xpath=.//ngap.qosFlowIdentifier    pcap_parser=test6
    ###check  PDU Session Resource Notify message
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname1}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ngap.qosFlowIdentifier and ngap.fiveQI == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${qosFlowIdentifier2}=     cap.Get Field Value By Xpath    xpath=.//ngap.qosFlowIdentifier    pcap_parser=test6
    Should Be Equal    ${qosFlowIdentifier1[0]}    ${qosFlowIdentifier2[0]}

Check wireshark log for VONR release for QOS and pdusession
    [Arguments]    ${logname1}    ${logname2}
    ###check Source gNB Vonr qosFlowIdentifier and pdusession
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname1}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    (ngap.fiveQI == 1) and (ngap.priorityLevelARP == 4 or ngap.priorityLevelARP == 3)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nomal_call_pdu_id}=     cap.Get Field Value By Xpath    xpath=.//ngap.pDUSessionID    pcap_parser=test6
    ${filter_expression}=     Catenate    (ngap.fiveQI == 1) and (ngap.priorityLevelARP == 4 or ngap.priorityLevelARP == 3)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nomal_call_qos}=     cap.Get Field Value By Xpath    xpath=.//ngap.qosFlowIdentifier    pcap_parser=test6


    ###check target gNB release nomal call pdusession and qosFlowIdentifier
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname2}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate        (ngap.procedureCode == 26 and ngap.qosFlowIdentifier)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${release_call_pdu_id}=     cap.Get Field Value By Xpath    xpath=.//ngap.pDUSessionID    pcap_parser=test6
    ${filter_expression}=     Catenate        (ngap.procedureCode == 26 and ngap.qosFlowIdentifier)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${release_call_qos}=     cap.Get Field Value By Xpath    xpath=.//ngap.qosFlowIdentifier    pcap_parser=test6

    Should Be Equal    ${nomal_call_pdu_id[0]}    ${release_call_pdu_id[0]}
    Should Be Equal    ${nomal_call_qos[0]}    ${release_call_qos[0]}

check HO point1
    [Arguments]    ${logname}
    ###check HO point1
    RUN KEYWORD IF    '${gnb_instance}'=='${gnb_id[0]}'    check HO TL376    logname=${logname}
    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[1]}'    sleep    1s
    ...    ELSE    check HO TL388    logname=${logname}

Check wireshark log for EMC HO sucess and VONR release and 8700 checkpoint trunk
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ###check  BearerContextModificationRequest::
    ###default DRB 6789 still exist,filter:e1ap.dRB_To_Remove_List_NG_RAN==1 means release VONR DRB PDU ID2
    ${filter_expression}=     Catenate    e1ap.dRB_ID == 4 and e1ap.id == 43 and e1ap.dRB_To_Remove_List_NG_RAN == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//e1ap.dRB_ID    pcap_parser=test6
    Sort List    ${ngap_fiveQI}
    List Should Contain Sub List    ${ngap_fiveQI}   ${dRB_To_Remove}
    ###filter:e1ap.dRB_To_Remove_List_NG_RAN == 1 means release VONR DRB PDU ID2
    ${filter_expression}=     Catenate    e1ap.dRB_To_Remove_List_NG_RAN == 1 and e1ap.dRB_ID == 9
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//e1ap.dRB_ID    pcap_parser=test6
    Should Contain    '${ngap_fiveQI}'    9
    ### check HO point2: UEContextModificationRequest:eventA2,eventA3
    ${filter_expression}=     Catenate     nr-rrc.eventId == 1 and f1ap.id == 119
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_eventId}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
    Should Contain    ${nr_rrc_eventId}    1
    ${filter_expression}=     Catenate     nr-rrc.eventId == 2 and f1ap.id == 119
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_eventId}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
    Should Contain    ${nr_rrc_eventId}    2
    ###check HO point3: check Intra HO UE Context Modification Response
    ${UeModify_res_filter}    Catenate    f1ap.protocolIEs == 5
    ${UeModify_res_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_res_filter}    pcap_parser=test6
    ${UeModify_res}    cap.get_field_value_by_xpath    xpath=.//f1ap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UeModify_res[0]}    7
    ###check VONR normal release
    ${filter_expression}=     Catenate    f1ap.dRBID == 9 and f1ap.id == 33 and f1ap.procedureCode == 7
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${f1ap_dRBID}=     cap.Get Field Value By Xpath    xpath=.//f1ap.dRBID    pcap_parser=test6
    Should Be Equal    ${f1ap_dRBID[-1]}    9    ##VONR 5QI 1
    ${filter_expression}=     Catenate    ngap.nas == 0 and ngap.procedureCode == 26
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    Should Be Equal    ${ngap_nas[0]}    0
    ${filter_expression}=     Catenate    ngap.procedureCode == 26 and ngap.radioNetwork == 27
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_radioNetwork}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${ngap_radioNetwork[0]}    27

Check wireshark log for EMC HO sucess and VONR release and 8700 checkpoint
    [Arguments]    ${logname_source}    ${logname_target}
    Check wireshark log for EMC HO in source gNB    logname=${logname_source}
    Check wireshark log for EMC HO in target gNB    logname=${logname_target}


Check wireshark log for EMC HO in source gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6

    ### Check Source gNB HO point1:Measurement Report has receives Measurement report
    ${filter_expression}=     Catenate    (f1ap.procedureCode==13 and nr-rrc.physCellId)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${f1ap_MeasureReport_phycellid}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Sort List    ${f1ap_MeasureReport_phycellid}
    List Should Contain Sub List    ${f1ap_MeasureReport_phycellid}    ${physCellId_${gnb_instance}}

    ### check Source gNB HO point2: has Handover request message
    ${filter_expression}=     Catenate    (xnap.procedureCode==0 and xnap.radioNetwork ==1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${xnap_radioNetwork}=     cap.Get Field Value By Xpath    xpath=.//xnap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${xnap_radioNetwork[0]}    1

    ### check Source gNB HO point3: RRC reconfiguration has event A3,has released list
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 7 and nr-rrc.eventId == 2)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_eventId }=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.eventId    pcap_parser=test6
    Should Contain    ${nr_rrc_eventId}    2
    ###  RRC reconfiguration has target physical
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 7 and nr-rrc.physCellId)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_physCellId}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Contain    ${nr_rrc_physCellId}    ${physCellId_${gnb_instance}}[1]
    ###   RRC reconfiguration has drb-ToReleaseList(9)
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 7 and nr-rrc.DRB_Identity == 9)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_DRB_Identity}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.DRB_Identity    pcap_parser=test6
    Should Be Equal    ${nr_rrc_DRB_Identity[0]}    9


Check wireshark log for EMC HO in target gNB
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ### check Target gNB HO point1: has BEARER Context Setup Request
    ${filter_expression}=     Catenate    (e1ap.procedureCode==8 and e1ap.System_BearerContextSetupRequest == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${System_BearerContextSetupRequest}=     cap.Get Field Value By Xpath    xpath=.//e1ap.System_BearerContextSetupRequest    pcap_parser=test6
    Should Be Equal    ${System_BearerContextSetupRequest[0]}    1

    ### check Target gNB HO point2: has BEARER Context Setup Response
    ${filter_expression}=     Catenate    (e1ap.procedureCode==8 and e1ap.System_BearerContextSetupResponse == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${System_BearerContextSetupResponse}=     cap.Get Field Value By Xpath    xpath=.//e1ap.System_BearerContextSetupResponse    pcap_parser=test6
    Should Be Equal    ${System_BearerContextSetupResponse[0]}    1

    ### check Target gNB HO point3: has qosFlowsNotAdmitted-List  4=no-radio-resources-available-in-target-cell
    ${filter_expression}=     Catenate    (xnap.procedureCode == 0 and xnap.radioNetwork == 4)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${radioNetwork}=     cap.Get Field Value By Xpath    xpath=.//xnap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${radioNetwork[0]}    4

    ### check Target gNB HO point4: has UE Context Modification Request
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 7 and f1ap.GNB_DUConfigurationQuery == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${GNB_DUConfigurationQuery}=     cap.Get Field Value By Xpath    xpath=.//f1ap.GNB_DUConfigurationQuery    pcap_parser=test6
    Should Be Equal    ${GNB_DUConfigurationQuery[0]}    0

    ### check Target gNB HO point5: has RRC reconfiguration complete
    ${filter_expression}=     Catenate    (f1ap.procedureCode == 13 and nr-rrc.rrc_TransactionIdentifier == 0)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${rrc_TraIdentifier}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.rrc_TransactionIdentifier    pcap_parser=test6
    Should Be Equal    ${rrc_TraIdentifier[0]}    0

    ### check Target gNB HO point6: has the Path Switch Acknowledge
    ${filter_expression}=     Catenate    (ngap.procedureCode == 25 and ngap.NGAP_PDU == 1)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${RedirectionVoiceFallback}=     cap.Get Field Value By Xpath    xpath=.//ngap.NGAP_PDU    pcap_parser=test6
    Should Be Equal    ${RedirectionVoiceFallback[0]}    1

    ### check Target gNB HO point6: has UE Context Release Request
    ${filter_expression}=     Catenate    (xnap.procedureCode == 6)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${xnap_procedureCode}=     cap.Get Field Value By Xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${xnap_procedureCode[0]}    6

Check intergNB HO process on source gNB
    [Arguments]    ${logname}    ${asik_addr}=${asik_addr}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    (xnap.procedureCode == 0 and ip.src == ${asik_addr} and xnap.XnAP_PDU == 0)
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    (xnap.procedureCode == 0 and ip.dst == ${asik_addr} and xnap.XnAP_PDU == 1)
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode     pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel_filter}=     Catenate    (xnap.procedureCode == 6 and ip.src == ${asik_addr})
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    6
    ####HandoverCancel
    Log To Console    HandoverCancel
    ${HO_Cancel_filter}=     Catenate     (xnap.procedureCode == 2 and xnap.XnAP_PDU == 0)
    ${HO_Cancel_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_Cancel_filter}    pcap_parser=test6
    ${HO_Cancel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    should not contain    ${HO_Cancel}    2
    ####UEContextReleaseCommand
    Log To Console    UEContextReleaseCommand
    ${UE_Cont_rel_filter}=     Catenate    (f1ap.procedureCode == 6 and f1ap.radioNetwork == 10)
    ${UE_Cont_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_Cont_rel_filter}    pcap_parser=test6
    ${UE_Cont_rel}=     cap.get_field_value_by_xpath    xpath=.//f1ap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${UE_Cont_rel[0]}    10
    ####UEContextReleaseCompleted
    Log To Console    UEContextReleaseCompleted
    ${UE_Cont_relC_filter}=     Catenate     (f1ap.procedureCode == 6 and f1ap.F1AP_PDU == 1)
    ${UE_Cont_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_Cont_relC_filter}    pcap_parser=test6
    ${UE_Cont_relC}=     cap.get_field_value_by_xpath    xpath=.//f1ap.F1AP_PDU    pcap_parser=test6
    should contain    ${UE_Cont_relC}    1

Check intergNB HO process on target gNB
    [Arguments]    ${logname}    ${asik_addr}=${asik2_addr}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    (xnap.procedureCode == 0 and ip.src == ${asik_addr} and xnap.XnAP_PDU == 0)
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    (xnap.procedureCode == 0 and ip.dst == ${asik_addr} and xnap.XnAP_PDU == 1)
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####PathSwitchRequest
    Log To Console    PathSwitchRequest
    ${PathS_req_filter}=     Catenate    (ngap.procedureCode == 25 and ip.src == ${asik_addr})
    ${PathS_req_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_req_filter}    pcap_parser=test6
    ${PathS_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${PathS_req[0]}    25
    ####PathSwitchRequestAckonwledge
    Log To Console    PathSwitchRequestAckonwledge
    ${PathS_ACK_filter}=     Catenate    (ngap.procedureCode == 25 and ip.dst == ${asik_addr})
    ${PathS_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_ACK_filter}    pcap_parser=test6
    ${PathS_ACK}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode     pcap_parser=test6
    Should Be Equal    ${PathS_ACK[0]}    25
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel_filter}=     Catenate    (xnap.procedureCode == 6 and ip.dst == ${asik_addr})
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    6
    ####UEContextReleaseReq
    Log To Console    UEContextReleaseReq
    ${UE_contextreleasereq_filter}=     Catenate    (ngap.procedureCode == 42 and ngap.radioNetwork == 0)
    ${UE_contextreleasereq_packets}=    cap.Filter Packets By Expression    filter_expression=${UE_contextreleasereq_filter}    pcap_parser=test6
    ${UE_contextreleasereq}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    should not contain    ${UE_contextreleasereq}    0

Check power saving BWP and RB nums
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ####HandoverRequest
    Log To Console    bwp-id is 2
    ${RRC_Reconfiguration_filter}=     Catenate    (f1ap.procedureCode == 5 and f1ap.F1AP_PDU == 0)
    ${RRC_Reconfigurationpackets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration_filter}    pcap_parser=test6
    ${bwp_Id}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.bwp_Id   pcap_parser=test6
    Should contain    ${bwp_Id}    2
    Log To Console    nrofRBs is 156
    ${RRC_Reconfiguration_filter}=     Catenate    (f1ap.procedureCode == 5 and f1ap.F1AP_PDU == 0 and nr-rrc.nzp_CSI_RS_ResourceId == 0)
    ${RRC_Reconfigurationpackets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration_filter}    pcap_parser=test6
    ${bwp_Id}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.nrofRBs   pcap_parser=test6
    Should contain    ${bwp_Id}    156

Check counter for B12
    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter shuould be value
    ...    gnb_index=${0}    counter_id=${counter_id_inter_gNB1}    dic_path=${counter_dic_path_inter_gNB1_Trunk}
    ...    value=${expected_value_B12_gnb1}
    ...    ELSE    Check the PM counter shuould be value
    ...    gnb_index=${0}    counter_id=${counter_id_inter_gNB1}    dic_path=${counter_dic_path_inter_gNB1}
    ...    value=${expected_value_B12_gnb1}
    RUN KEYWORD IF    '${check_result}' == 'True'    Check the PM counter shuould be value
    ...    gnb_index=${1}    counter_id=${counter_id_inter_gNB2}    dic_path=${counter_dic_path_inter_gNB2_Trunk}
    ...    value=${expected_value_B12_gnb2}
    ...    ELSE    Check the PM counter shuould be value
    ...    gnb_index=${1}    counter_id=${counter_id_inter_gNB2}    dic_path=${counter_dic_path_inter_gNB2}
    ...    value=${expected_value_B12_gnb2}


Check gnb counter as expected_value
    [Arguments]    ${counter_id}    ${dic_path}    ${expected_value}    ${gnb_id}=${1}    ${counter_end}=${1}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}
    ${counter_latest}    get slice from list    ${counter_value}    0    ${counter_end}
    should contain    '${counter_latest}'   ${expected_value}
    [Teardown]    COAM Teardown gnb connections

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Stop the emergency call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${stop_call}
    ...    connection=cygwin${ue_index}
    sleep    10s

check HO TL376
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 7 and nr-rrc.physCellId == 376 and nr-rrc.measResultNeighCellListNR == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_physCellId}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Contain    ${nr_rrc_physCellId}    376
    ${filter_expression}=     Catenate    f1ap.procedureCode == 7 and nr-rrc.physCellId == 378 and nr-rrc.measResultNeighCellListNR == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_physCellId}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Contain    ${nr_rrc_physCellId}    378

check HO TL388
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 7 and nr-rrc.physCellId == 498 and nr-rrc.measResultNeighCellListNR == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_physCellId}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Contain    ${nr_rrc_physCellId}    498
    ${filter_expression}=     Catenate    f1ap.procedureCode == 7 and nr-rrc.physCellId == 499 and nr-rrc.measResultNeighCellListNR == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_physCellId}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    Should Contain    ${nr_rrc_physCellId}    499

Tear Down 8700_B12
#    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute
#    get and analysis syslog
    Run Keyword And Ignore Error    hang up EMC call on samsung UE
    Run keyword if    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Set APN point for sanmsung    ue_index=${0}    ue_type=${ue_type}    apn_name=${dxdata2_apn_name}    ui_version=one ui 5.1
    ...    ELSE    set apn with special method    usedapn=${apn_dxdata2}    location_apn=${location_apn}
    Run Keyword And Ignore Error    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${0}
    Check hanging resource for gnb    gnb_ips=${gnb_ips}
    Run Keyword And Ignore Error
    ...    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_B_012_1}    gnb_index=${0}
    Run Keyword And Ignore Error
    ...    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_B_012_2}    gnb_index=${0}
    Run Keyword And Ignore Error
    ...    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_B_012_3}    gnb_index=${0}
    Run Keyword And Ignore Error
    ...    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_B_012_4}    gnb_index=${1}
    Run Keyword And Ignore Error
    ...    Stop Capture Wireshark Logs on gNB    nglogname=${log_name_B_012_5}    gnb_index=${1}
    Modify NIDD parameter on gnb    parameters_to_update=${PARAM_8700_recover_B_12_GNB1}    gnb_index=${0}
    Modify NIDD parameter on gnb    parameters_to_update=${PARAM_8700_recover_B_12_GNB2}    gnb_index=${1}    timeout=600s
    Run Keyword And Ignore Error    coam.teardown    connection=GNB_OAM
    Run Keyword And Ignore Error    UnLock LTE
    Run keyword and ignore error    CI_interface.Common Case Teardown


Check cell tput
    [Arguments]    ${lcrid}=${1}    ${gnb_index}=${0}    ${dl_expect_throughput}=${dl_expect_throughput}
    ${cell1_id}=    COAM Get nrcellid with lcrid    lcrid=${lcrid}    gnb_index=${gnb_index}
    ${list_of_cell_ids}    Create list    ${cell1_id}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}    duration=10s
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL
    ...    log=${log}   cells=${list_of_cell_ids}    target_throughput=${dl_expect_throughput}

ADD 8247_EDA 02775785 check point
    Attach and check power UE    ue_type=${ue_type}
    Start Capture Wireshark Logs on gNB    nglogname=${log_name_B_012_EDA_1}    interface=${interface1}    gnb_index=${0}
    Start Capture Wireshark Logs on gNB    nglogname=${log_name_B_012_EDA_2}    interface=${interface1}    gnb_index=${1}
    Make a VoNR call(+6688) samsung
    check voice call status    status=${2}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}
    sleep    20s
    wait until keyword succeeds    3X   5s    Check cell tput    lcrid=${1}
    ...    gnb_index=${0}    dl_expect_throughput=${dl_expect_throughput_cell1_${gnb_instance}}
    #### adjust PA cell1 0, cell2 0, from gnb 1 cell1 handover to gnb2 cell2 with vonr and tput
    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Adjust gNB_RU Attenuation    gnb1_cell1_value=${25}    gnb2_cell1_value=${0}
    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell1_value=${35}    gnb2_cell1_value=${0}
    check voice call status    status=${2}
    wait until keyword succeeds    3X   5s    Check cell tput    lcrid=${2}
    ...    gnb_index=${1}    dl_expect_throughput=${dl_expect_throughput_cell2_${gnb_instance}}
    #### adjust PA cell1 0, cell2 12, from gnb 2 cell2 handover to gnb1 cell1 with vonr and tput
    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'    Adjust gNB_RU Attenuation    gnb1_cell1_value=${25}    gnb2_cell1_value=${30}
    ...    ELSE    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb2_cell1_value=${20}
    check voice call status    status=${2}
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    gnb2_cell1_value=${20}
    wait until keyword succeeds    3X   5s    Check cell tput    lcrid=${1}
    ...    gnb_index=${0}    dl_expect_throughput=${dl_expect_throughput_cell1_${gnb_instance}}
    Stop Capture Wireshark Logs on gNB   nglogname=${log_name_B_012_EDA_1}    gnb_index=${0}
    Stop Capture Wireshark Logs on gNB   nglogname=${log_name_B_012_EDA_2}    gnb_index=${1}
    Check wireshark log for 8247_EDA_02775785
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB   nglogname=${log_name_B_012_EDA_1}    gnb_index=${0}    AND
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB   nglogname=${log_name_B_012_EDA_2}    gnb_index=${1}    AND
    ...    Stop UL DL data transfer    AND
    ...    hang up VoNR call samsung    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}

Check wireshark log for 8247_EDA_02775785
    Check intergNB HO process on source gNB    logname=${log_name_B_012_EDA_1}    asik_addr=${asik_addr}
    Check intergNB HO process on target gNB    logname=${log_name_B_012_EDA_2}    asik_addr=${asik2_addr}
    Check intergNB HO process on source gNB    logname=${log_name_B_012_EDA_2}    asik_addr=${asik2_addr}
    Check intergNB HO process on target gNB    logname=${log_name_B_012_EDA_1}    asik_addr=${asik_addr}

    Check power saving BWP and RB nums    logname=${log_name_B_012_EDA_1}
    Check power saving BWP and RB nums    logname=${log_name_B_012_EDA_2}

Set APN point for sanmsung until succeed
    [Arguments]    ${apn_name}=${mdrb_apn_name}    ${ui_version}=one ui 5.1    ${ue_index}=${0}    ${ue_type}=${ue_type}
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${10}
    ${result}    Run keyword and return status    Wait until keyword succeeds    1X    10s
    ...    Set APN point for sanmsung    ue_index=${0}    ue_type=${ue_type}    apn_name=${apn_name}    ui_version=${ui_version}
    Run keyword If    '${result}'=='False'    Run keywords    Before test reset QCOM use adb command    ue_index=${ue_index}
    ...    AND    Set APN point for sanmsung    ue_index=${0}    ue_type=${ue_type}    apn_name=${apn_name}    ui_version=${ui_version}
    ...    ELSE    Log To Console    ***No need reboot UE***
    Log To Console    ***Set APN OK***