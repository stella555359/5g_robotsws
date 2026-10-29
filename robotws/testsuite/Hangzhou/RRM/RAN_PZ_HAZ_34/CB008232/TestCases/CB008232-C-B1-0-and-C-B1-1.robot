*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                feature : CB008232


Suite Setup         Run keywords
...    robot_common_operations.Common Suite Setup    AND
...    8232 Suite Setup    #swconfig_modify=${SWCONFIG_C_002}

Suite Teardown      Run keywords
...    robot_common_operations.Common Suite Teardown    AND
...    Run Keyword And Ignore Error       Common Suite Teardown for COAM


Resource         ../Resources/CB008232_keywords.robot


*** Variables ***
@{dlexpect_tp}           110    60
${MO_sig}                mo-Signalling
${MPS}                   mps-PriorityAccess
${HPA}                   highPriorityAccess
${pre-emption}           release-due-to-pre-emption
${wiresharklog_01}        wiresharklog_01
${wiresharklog_02}        wiresharklog_02
${wiresharklog_03}        wiresharklog_03
${wiresharklog_04}        wiresharklog_04.pcap
${APN2}                   wap1.nokia.com
${options}          -i any sctp -s 0
${HO_failure_expect}    no-radio-resources-available-in-target-cell
${ra_P_MPS+MCS}     c0
${APN1_trunk}       wap1
${APN1_23R1}        wap2
${cpif_log}     /home/ute/Downloads/wiresharklog_01.pcap
@{NGAP_PAGING_value}        ${2}    ${2}
@{NGAP_priPAGING_value}     ${1}


${Send_Tput_DL_C002}        10M
${expected_tput_dl_C002}    1
${DL_PORT}                  ${tl.ues[1].iperf_details.port}
*** Test Cases ***
[1]CB008232_C_002_Paging_Prioritization_during_Paging_overload_with_more_PR
    [Documentation]
    ...    C-002 describes the gNB behavior during Paging overload and creation of Paging Record List when Paging Prioritization is activated
    ...          with more paging record is stored
    ...    C-001 describes the gNB behavior during Paging overload and creation of Paging Record List when Paging Prioritization is activated
    ...    RRC--applyPriorityAccess=HPA+MPS; ICS--HPA is PA
    ...    UE0----normal,wap1-NOT preemptable
    ...    UE1----HPA,Not preemptible
    ...    UE2----MPS/MCS,Not preemptible
    ...    20241224 SWCONFIG_C_002 not trigger ,25R2(TRUNK)Set srbInactivityTimerSA NIDD to test this paging case
    [Tags]     CRT_23R1    CRT_TRUNK
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    ${release_info}    Get gnb release info
    Set suite variable for 8232_A_030
    step1 prepare the envrionment
    step2 test procedures
    step3 case check point
    Stop capture syslog via btslog on ute
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute    AND
    ...    Case TearDown


*** Keywords ***
step1 prepare the envrionment
    [Arguments]
    Common Case TestLine Setup    ModifySCF_Aftercommission=True    #alarm_check=True
    ...                           Modify_Para_Online=${C_002_Modify_Online}
    Common Case TestLine Setup    ModifySCF_Aftercommission=True    #alarm_check=True
    ...                           Add_Para_Online=${C_002_ADD_Para}
    NRCellid Set suit varaible    cellid=${${cellid}}
    Adjust the GNB1CELL1 HBTE attenuation value
    Adjust the GNB1CELL2 HBTE attenuation value
    Adjust the GNB2CELL1 HBTE attenuation value
    Adjust the ENB1CELL1 HBTE attenuation value
    Adjust the ENB2CELL1 HBTE attenuation value
#    Switch APN to Test_need_APN    target_APN=${${target_APN1}}
    Switch APN to Test_need_APN    ue_index=${0}    target_APN=${${target_APN1}}   ui_version=S24UI5.1    APN_ui_version=one ui 5.1

step2 test procedures
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_01}    options=${options}    gnb_index=${0}
    Attach UE_1 for 8232_C    ue_index=${1}
    ${UE1_ip}    Get Samsung UE IP    ue_index=${1}
    ${cpif_log_01}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog_01}    target_dir=${epc_log_path}
    ${UE1_MO}    Get UE TMSI    file_path=${cpif_log_01}
    Start capture gNB log on master    filename=${wiresharklog_04}
    Start only DL traffic and check tput    ue_index=${1}    cellid=${1}    ue_type=${ue_type}    gnb_index=${0}
    ...                                tput_dl_cell=${expected_tput_dl_C002}    dl_throughput=${Send_Tput_DL_C002}    duration=${7200}
    FOR     ${N}    IN RANGE    ${10}
      UE Detach With Power UE Index    ue_index=${2}
      Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_02}    options=${options}    gnb_index=${0}
      Attach UE_1 for 8232_C    ue_index=${2}
      ${UE2_ip}    Get Samsung UE IP    ue_index=${2}
      sleep    10s
      ${cpif_log_02}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog_02}    target_dir=${epc_log_path}
      ${UE2_MO}     Get UE TMSI    file_path=${cpif_log_02}
      Run Keyword IF     '${UE1_MO}' == '${UE2_MO}'      EXIT FOR LOOP
    END
    Stop DL or UL traffic    ue_index=${1}    ue_type=${ue_type}    direction=DL
    sleep    120s
    Stop and download Logs on gNB on master    filename=${wiresharklog_04}
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_03}    options=${options}    gnb_index=${0}
    Start Ping on iperf_APP    ue_index=${1}    UE1_IP=${UE1_ip}    UE2_IP=${UE2_ip}
    sleep    10s
    ${cpif_log_03}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog_03}    target_dir=${epc_log_path}
    BuiltIn.Set Test Variable    ${cpif_log_01}
    BuiltIn.Set Test Variable    ${cpif_log_02}
    BuiltIn.Set Test Variable    ${cpif_log_03}
    [Teardown]    Run keywords
    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${wiresharklog_04}
    ...    AND    Enable Moble_data and detached    ue_index=${1}
    ...    AND    Enable Moble_data and detached    ue_index=${2}
    ...    AND    Run Keyword And Ignore Error    Stop Traffic for 3UES with Power UE
    ...    AND    Run Keyword And Ignore Error    UE Detach With Power UE for 3UES


step3 case check point
    Check counter for counter_id_PAGING
    Check PagingPriority    file_path=${cpif_log_03}
    Check TMSI_Part2 from server_request    file_path=${cpif_log_03}
    Check counter for counter_id_priPAGING


Check counter for counter_id_PAGING
    Run Keyword IF    '${release_info}' == 'SBTS24R1'    Check PM counter for 8232    counter_id=${counter_id_PAGING}
    ...         counter_dic_path=${counter_dic_PAGING_GNB1CELL1}       counter_should_value=${NGAP_PAGING_value}
    ...    ELSE     Check PM counter for 8232    counter_id=${counter_id_PAGING}
    ...         counter_dic_path=${counter_dic_PAGING_GNB1CELL1_trunk}       counter_should_value=${NGAP_PAGING_value}
#    [Arguments]   ${gnb_index}=${0}   ${du_index}=${0}    ${common_unit_index}=${0}     #${connection}==du_coam
#    ${var_status}    ${var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
#    ...    gnb_index=${gnb_index}   du_index=${du_index}    common_unit_index=${common_unit_index}
#    Run Keyword If    '${var_dict}[stream]' == 'SBTS00'    Check PM counter for 8232    counter_id=${counter_id_PAGING}
#    ...         counter_dic_path=${counter_dic_PAGING_GNB1CELL1_trunk}       counter_should_value=${NGAP_PAGING_value}
#    ...    ELSE    Check PM counter for 8232    counter_id=${counter_id_PAGING}
#    ...         counter_dic_path=${counter_dic_PAGING_GNB1CELL1}       counter_should_value=${NGAP_PAGING_value}

Check counter for counter_id_priPAGING
    Run Keyword IF    '${release_info}' == 'SBTS24R1'     Check PM counter for 8232    counter_id=${counter_id_priPAGING}
    ...         counter_dic_path=${counter_dic_priPAGING_GNB1CELL1}     counter_should_value=${NGAP_priPAGING_value}
    ...    ELSE     Check PM counter for 8232    counter_id=${counter_id_priPAGING}
    ...         counter_dic_path=${counter_dic_priPAGING_GNB1CELL1_trunk}     counter_should_value=${NGAP_priPAGING_value}
#    [Arguments]   ${gnb_index}=${0}   ${du_index}=${0}    ${common_unit_index}=${0}     #${connection}==du_coam
#    ${var_status}    ${var_dict}    run keyword and ignore error    CI_commssion._Set Variables For Test
#    ...    gnb_index=${gnb_index}   du_index=${du_index}    common_unit_index=${common_unit_index}
#    Run Keyword If    '${var_dict}[stream]' == 'SBTS00'    Check PM counter for 8232    counter_id=${counter_id_priPAGING}
#    ...         counter_dic_path=${counter_dic_priPAGING_GNB1CELL1_trunk}     counter_should_value=${NGAP_priPAGING_value}
#    ...    ELSE     Check PM counter for 8232    counter_id=${counter_id_priPAGING}
#    ...         counter_dic_path=${counter_dic_priPAGING_GNB1CELL1}     counter_should_value=${NGAP_priPAGING_value}


Case TearDown
    8232 Case TearDown


Start only DL traffic and check tput
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=DL    ${tput_dl_cell}=${expected_tput_dl}    ${dl_port}=${DL_PORT}    ${duration}=${600}    #${protocol}=udp
    Power UE Start DL traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_throughput=${dl_throughput}    duration=${duration}
    ...    dl_port=${dl_port}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_dl_cell}    gnb_index=${gnb_index}


Stop DL or UL traffic
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${direction}=DL     ${protocol}=udp    ${iperf_port}=default
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}    iperf_port=${iperf_port}
