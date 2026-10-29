*** Settings ***
Force Tags    PY36
Documentation     author: yifan hu
...                 contact: yifan.hu@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC000784-B

Resource     ../5GC000784-A/Resources/5GC000784_common_keyword.robot
Resource     ./Resources/5GC000784_B_common_keyword.robot
Variables    ./Resources/variables_B.py


Suite Setup    Run Keywords
...    robot_common_operations.Common Suite Setup    AND
...    Common Suite Setup for COAM    AND
...    Prepare with COAM classical BTS cell onair    scf_filename=${tl_scf_filename_784B}    AND
#...    Connect and commission enb    enb_scf_file_name=${scf_file_enb}    AND
...    wait the eNB onair    AND
...    prepare eNB parameter    AND
...    Adjust gNB_RU Attenuation    AND
...    Adjust enb attenuation    AND
...    Get sagnb release

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Run Keyword If Any Tests Failed
...               Run Keyword And Ignore Error    Classical_gNB.Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
...               Adjust gNB_RU Attenuation    AND
...               Adjust enb attenuation



*** Variables ***
${gnb_path}    /tmp
${enb_path}    /tmp/
${tl_scf_filename_784B}    7326_784_SCF_peak.xml
${tl_scf_filename1}    7326_784_SCF
${scf_file_enb}    Configuration_scf_Enb.xml
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${interface1}    any
${interface_s1ap}    br1
${interface_ngap}    br0
${nglogname5}       784B05.pcap
${nglogname5_2nd}   784B05_2nd.pcap
${nglogname6_1}     784B06_service.pcap
${nglogname6_2}     784B06_target.pcap
${nglogname17}      784B17.pcap
${nglogname18_1}    784B18_service.pcap
${nglogname18_2}    784B18_target.pcap
${nglogname15}      784B15_gnb.pcap
${enblogname15}     784B15_enb.pcap
${nomal_call_number}    6688
${EC_number}    911
${epc_log_path}    /tmp/
${GNB2_addr}        ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBUI_COAM2}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
###traffic###
${Send_Tput_DL}    500M
${Send_Tput_UL}    100M
${traffic_duration}    600
${bandwidth}    10M
${dl_port}    ${tl.ues[0].iperf_details.port}
${ul_port}    ${tl.appserver[0].port}
${inter_rat_target_value}    ${62}
${origin_value}    ${40}
${dl_throughput}    500M
${dl_expect_throughput}    1529
${MME_inter-rat}    ${tl.ues[0].imsi}
${MME_5G-HO-4G}    ${tl.ues[0].dmc_path}
${dxdata2_apn_name}    ${tl.ues[0].pdn[0]}
${ue1_type}    ${tl.ues[1].capabilities[0]}

*** Test Cases ***
[1]5GC000784_B_015_success_Inter_RAT_HO_with_EC_call_with_emergencyCallMrListIgnore_on
    [Documentation]
    [Tags]    CRT_TRUNK    5GC000784-B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=7311,7107
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Modify NIDD parameter for 784_A    parameters_to_update=${PARAMETERS_TO_UPDATE_COUNTER}
    Modify NIDD parameter for 784_A   parameters_to_update=${PARAMETERS_TO_UPDATE_B15}
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${10}
    Precondition for Sansumg UE    ue_type=${ue_type}    ui_version=S21UI3.1
    Set APN point for sanmsung    ue_index=${0}    ue_type=${ue_type}    apn_name=${dxdata2_apn_name}    ui_version=one ui 5.1
    put btslog_ini file to ute
    ...    server_ip=${appserver_addr}    server_username=${appserver_username}    server_password=${appserver_password}
    Start capture syslog via btslog on ute
    Run keyword if    '${gnb_instance}'=='${gnb_id[0]}'    Attach And Check Tput DL
    Inter-RAT HO with EC ongoing    logname1=${nglogname15}    logname2=${enblogname15}
    Stop capture syslog via btslog on ute
    Wait Until Keyword Succeeds    10min    10s    Check PM counter for B15
    Check inter-RAT HO with EC ongoing    logname1=${nglogname15}    logname2=${enblogname15}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Stop capture syslog via btslog on ute    AND
    ...    get and analysis syslog    AND
    ...    Load SCF with different release    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    eNB parameter teardown    AND
    ...    Run Keyword And Ignore Error    eNB stop wireshark log_teardown    AND
    ...    Run Keyword And Ignore Error    784-A case teardown

*** Keywords ***
Load SCF with different release
    ${release}=    Get sagnb release title
    Prepare with COAM classical BTS cell onair    scf_filename=${tl_scf_filename1}_${release}.xml

Inter-gnb HO without MRL with EC and traffic ongoing
    Modify NIDD parameter for 784_A    parameters_to_update=${PARAMETERS_TO_UPDATE_B06}
    Modify NIDD parameter for 784_A    parameters_to_update=${PARAMETERS_TO_UPDATE_B06_target}
    ...    bts_host=${GNB2_addr}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname6_1}    interface=${interface1}    connection=Local gnb1
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname6_2}    interface=${interface1}    connection=Local gnb2
    ...    hostname=${GNB2_addr}
    Power UE Attach and Verify attach
    Start udp traffic
    Connect to control pc via cygwin    ue_index=${0}
    Start a emergency call
    Adjust service Attenuation    value=${15}
    Adjust target Attenuation_B06
    sleep    5s
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname6_1}    connection=Local gnb1
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname6_2}    connection=Local gnb2
    ...    hostname=${GNB2_addr}
    Check the cell DLUL throughput    gnb_index=${0}
    Check inter-F inter-gNB intra-PLMN HO with EC ongoing    logname1=${nglogname6_1}    logname2=${nglogname6_2}
    [Teardown]    Stop the emergency call

Intra-F intra-gNB HO with EC ongoing
    [Arguments]    ${logname}
    Start Capture Wireshark Logs on gNB    nglogname=${logname}    interface=${interface1}    connection=Local gnb1
    Connect to control pc via cygwin    ue_index=${0}
    Start a emergency call
    Record the counter action timer
    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Adjust the tl HBTE attenuation value    tl=${376}    value1=${0}    value2=${5}
    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[2]}'
    ...    Adjust the tl HBTE attenuation value    tl=${388}    value1=${15}    value2=${0}
    ...    ELSE    Adjust the tl HBTE attenuation value    tl=${377}    value1=${10}    value2=${0}
    sleep    5s
    Stop Capture Wireshark Logs on gNB    nglogname=${logname}    connection=Local gnb1
    Modify NIDD parameter for 784_A    parameters_to_update=${PARAMETERS_TO_UPDATE_784off}
    sleep    5s
    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Adjust the tl HBTE attenuation value    tl=${376}    value1=${0}    value2=${35}
    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[2]}'
    ...    Adjust the tl HBTE attenuation value    tl=${388}    value1=${0}    value2=${15}
    ...    ELSE    Adjust the tl HBTE attenuation value    tl=${377}    value1=${0}    value2=${15}
    sleep    10s
    Check intra-F intra-gNB intra-PLMN HO with EC ongoing    logname=${logname}
    [Teardown]    Stop the emergency call

Make another EC and check procedure
    [Arguments]    ${logname}
    Start Capture Wireshark Logs on gNB    nglogname=${logname}    interface=${interface1}    connection=Local gnb2
    ...    hostname=${GNB2_addr}
    Connect to control pc via cygwin    ue_index=${0}
    Start a emergency call
    Stop the emergency call
    Stop Capture Wireshark Logs on gNB    nglogname=${logname}    connection=Local gnb2
    ...    hostname=${GNB2_addr}
    Check wireshark log for EC setup    logname=${logname}
    Check wireshark log for EC 5QI 5    logname=${logname}
    Check wireshark log for EC 5QI 1    logname=${logname}

Inter-F inter-gNB HO with EC ongoing
    [Arguments]    ${logname1}    ${logname2}
    Start Capture Wireshark Logs on gNB    nglogname=${logname1}    interface=${interface1}    connection=Local gnb1
    Start Capture Wireshark Logs on gNB    nglogname=${logname2}    interface=${interface1}    connection=Local gnb2
    ...    hostname=${GNB2_addr}
    Connect to control pc via cygwin    ue_index=${0}
    Start a emergency call
    Adjust gNB_RU Attenuation    value_1=${15}
    sleep    5s
    Stop Capture Wireshark Logs on gNB    nglogname=${logname1}    connection=Local gnb1
    Stop Capture Wireshark Logs on gNB    nglogname=${logname2}    connection=Local gnb2
    ...    hostname=${GNB2_addr}
    Check inter-F inter-gNB intra-PLMN HO with EC ongoing    logname1=${logname1}    logname2=${logname2}
    [Teardown]    Stop the emergency call

Inter-RAT HO with EC ongoing
    [Arguments]    ${logname1}    ${logname2}
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${0}
    Prepare with PM counter time to caculate    period=start
    Start Capture Wireshark Logs on gNB    nglogname=${logname1}    interface=${interface_ngap}    connection=Local gnb1
    eNB start capture wireshark log    filename=${logname2}    interface=${interface_s1ap}
    Attach and check power UE    ue_type=${ue_type}
    Connect to control pc via cygwin    ue_index=${0}
    Make EMC call on samsung UE
    Adjust enb attenuation    enb_cell_value=${0}
    FOR  ${value}    IN RANGE    ${origin_value}    ${inter_rat_target_value}    ${2}
       Adjust one port attenuation    gnb1_cell1_value=${value}
    END
    sleep    10s
    Stop Capture Wireshark Logs on gNB    nglogname=${logname1}    connection=Local gnb1
    eNB stop and Save classical Logs    filename=${logname2}
    [Teardown]    Run keywords
    ...    hang up EMC call on samsung UE
    ...    AND    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${0}

##############################################################################################################
Prepare with COAM classical BTS cell onair_784B
    Prepare with COAM classical BTS cell onair    scf_filename=${tl_scf_filename_784B}
    Prepare with COAM classical BTS cell onair    scf_filename=${tl_scf_filename_784B_2}
    ...    bts_host=${GNB2_addr}

Check PM counter for B05
    [Arguments]    ${counter_id}    ${dic_path_service}    ${dic_path_target}
    Check the PM counter shuould be 1    counter_id=${counter_id}    dic_path=${dic_path_service}
    Check the PM counter shuould be 1    counter_id=${counter_id}    dic_path=${dic_path_target}

Check PM counter for B15
    run keyword if    '${gnb_instance}'=='${gnb_id[0]}'    Check the PM counter shuould be 1
    ...    counter_id=${counter_id_interRAT}    dic_path=${counter_dic_path_interRAT_376}
    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[1]}'    Check the PM counter shuould be 1
    ...    counter_id=${counter_id_interRAT}    dic_path=${counter_dic_path_interRAT_377}
    ...    ELSE    Check the PM counter shuould be 1
    ...    counter_id=${counter_id_interRAT}    dic_path=${counter_dic_path_interRAT_388}

Check the PM counter shuould be 1
    [Arguments]    ${counter_id}    ${dic_path}
    ...    ${bts_host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
        ...    dic_path=${dic_path[${index}]}
        Should contain    ${counter_value}    ${1}
    END
    [Teardown]    COAM Teardown gnb connections

prepare eNB parameter
    Connect and Modify the parameter on enblte
    ...    dist_name=${BTSnameEnb[0]}/LNMME-0    parameter=ipAddrPrim    value=${MME_5G-HO-4G}
    Connect and Modify the parameter on enblte
    ...    dist_name=${BTSnameEnb[0]}/LNCEL-1    parameter=tac    value=20201
    Connect and Modify the parameter on enblte
    ...    dist_name=${BTSnameEnb[0]}    parameter=actHoFromNr    value=true
    Connect and Modify the parameter on enblte
    ...    dist_name=${BTSnameEnb[0]}    parameter=rachAccessForHoFromNr    value=contentionBased
    Connect and Modify the parameter on enblte
    ...    dist_name=${BTSnameEnb[0]}    parameter=actIfHo    value=enabled

eNB parameter teardown
    run keyword if    '${gnb_instance}'=='${gnb_id[0]}'    Connect and Modify the parameter on enblte
    ...    dist_name=${BTSnameEnb[0]}/LNMME-0    parameter=ipAddrPrim    value=${MME_5G-HO-4G}
    run keyword if    '${gnb_instance}'=='${gnb_id[0]}'    Connect and Modify the parameter on enblte
    ...    dist_name=${BTSnameEnb[0]}/LNCEL-1    parameter=tac    value=20200

B17 parameter teardown
    Modify NIDD parameter for 784_A    parameters_to_update=${PARAMETERS_TO_UPDATE_B17_teardown}

remove object NRADJGNB and XNLINK
    [Arguments]    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}    ${index2}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${NRADJGNB_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRADJGNB-${index}
    Set Suite Variable    ${XNLINK_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/XNLINK-${index2}
    selenium_coam.remove_object  object_name=${NRADJGNB_distname}
    selenium_coam.remove_object  object_name=${XNLINK_distname}
    sleep    3s
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

############################traffic#########################
Start udp traffic
    [Arguments]
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${Send_Tput_DL}
    ...    duration=${traffic_duration}    ue_index=${0}
    power_ue.Start traffic    ue_type=huawei    direction=ul    throughput=${Send_Tput_UL}
    ...    duration=${traffic_duration}    ue_index=${0}    iperf_type=via_iperf_command

Stop udp traffic
    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=huawei
    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=huawei    iperf_type=via_iperf_command

Check the cell DLUL throughput
    [Arguments]    ${cellid}=1    ${gnb_index}=${0}
    ${nrcellid}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    Wait Until Keyword Succeeds   3x    10s    power_ue.Check Throughput    gnb_index=${gnb_index}
    ...    ue_type=huawei    direction=dl    throughput=10    cellid=${nrcellid}    sleep_time=${20}
    Wait Until Keyword Succeeds   3x    10s    power_ue.Check Throughput    gnb_index=${gnb_index}
    ...    ue_type=huawei    direction=ul    throughput=10    cellid=${nrcellid}    sleep_time=${20}
    Stop udp traffic


#COAM Get nrcellid with lcrid
#    [Arguments]   ${lcrid}    ${gnb_index}=${0}    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
#    Connect to gnb coam via ssl   bts_host=${bts_host}
#    ${cell_info}   coam.get_subcells_info   timeout=20    connection=GNB_OAM
#    ${number_of_cell_group_info}    get length    ${cell_info}
#    FOR  ${index}  IN RANGE   ${number_of_cell_group_info}
#        ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    NRCELLGRP-${index}
#        ${nrCellId}    Get nrcellid in all cellgroup with lcrid    cell_from_cellgrp=${cell_from_cellgrp}    lcrid=${lcrid}
#        exit for loop if    '${nrCellId}'!='None'
#    END
#    [Return]    ${nrCellId}
#    [Teardown]    COAM Teardown gnb connections

Get nrcellid in all cellgroup with lcrid
    [Arguments]   ${cell_from_cellgrp}    ${lcrid}
    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
    FOR  ${cell}  IN   @{cell_list}
        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
        ${lcrid_get} =    set variable    ${eachcell['NRCELL_L']['parameters']['lcrId']}
        ${nrCellIdentity}     run keyword if     '${lcrid_get}'=='${lcrid}'
    ...    set variable    ${eachcell['NRCELL_L']['parameters']['nrCellIdentity']}
    END
    [Return]    ${nrCellIdentity}

Attach And Check Tput DL
    Adjust gNB_RU Attenuation    tl=${gnb_instance}_UE2    gnb1_cell1_value=${8}
    power_ue.Prepare UE    ue_type=${ue1_type}    ue_index=${1}
    Attach and check power UE    ue_type=${ue1_type}    ue_index=${1}
#    ${cell1_id}=    COAM Get nrcellid with lcrid    lcrid=${1}
    ${cell1_id}=    COAM Get nrcellid with lcrid    lcrid=${1}    gnb_index=${0}
    ${list_of_cell_ids}    Create list    ${cell1_id}
    Start traffic with qct_dx50    direction=dl    throughput=${dl_throughput}    ue_type=${ue1_type}    ue_index=${1}
    ...    process_num=${4}    duration=2400s    ue_apn='mdrb.nokia.com'
    Adjust gNB_RU Attenuation    tl=${gnb_instance}_UE2    gnb1_cell1_value=${11}
    sleep    120s
    Wait Until Keyword Succeeds    3X    10s    Check tput OK    list_of_cell_ids=${list_of_cell_ids}
    [Teardown]    Run keywords    power_ue.Stop traffic    ue_type=${ue1_type}   direction=dl    ue_index=${1}
    ...    AND    power_ue.UE Detach  ue_type=${ue1_type}    ue_index=${1}
    ...    AND    Adjust gNB_RU Attenuation    tl=${gnb_instance}_UE2

Check tput OK
    [Arguments]    ${list_of_cell_ids}=${list_of_cell_ids}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL
    ...    log=${log}   cells=${list_of_cell_ids}    target_throughput=${dl_expect_throughput}

Start traffic with qct_dx50
    [Arguments]    ${direction}=dl    ${throughput}=10    ${duration}=600    ${iperf_port}=default    ${ue_index}=${0}
    ...            ${buffer_size}=1400B    ${appserver}=APPserver    ${protocol}=udp    ${process_num}=${5}
    ...            ${seg_size}=${1180}    ${ue_apn}=${ue_apn}    ${window}=2M    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer, like 10M
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  iperf_port: port number used for traffic start via iperf.
    ...  :param  process_num: the number of process which are used for tcp data transfer, the more the better.
    ...  :param  window: tcp window size. eg, default value is 2M
    ${ue_addr} =    Get the UE need Ip address    ue_index=${ue_index}    ue_apn=${ue_apn}
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    wait until keyword succeeds    3x    10s    Start DL traffic via iperf on Appserver
    ...                                                                                    ue_addr=${ue_addr}
    ...                                                                                    dl_time=${duration}
    ...                                                                                    dl_port=${port}
    ...                                                                                    dl_throughput=${throughput}
    ...                                                                                    dl_length=${buffer_size}
    ...                                                                                    appserver=${appserver}
    ...                                                                                    protocol=${protocol}
    ...                                                                                    ue_index=${ue_index}
    ...                                                                                    process_num=${process_num}
    ...                                                                                    seg_size=${seg_size}
    ...                                                                                    window=${window}
    ...    ELSE IF    '${direction}' == 'ul'    wait until keyword succeeds    3x    10s    Start UL traffic via iperf from andriod UE
    ...                                                                                       ue_index=${ue_index}
    ...                                                                                       ul_time=${duration}
    ...                                                                                       ul_port=${port}
    ...                                                                                       ul_throughput=${throughput}
    ...                                                                                       ul_length=${buffer_size}
    ...                                                                                       appserver=${appserver}
    ...                                                                                       protocol=${protocol}
    ...                                                                                       process_num=${process_num}
    ...                                                                                       window=${window}

Get the UE need Ip address
    [Documentation]  After UE attach success, can use this keyword to get the UE IP for data transfer.
    [Arguments]    ${ue_index}=${0}    ${ue_apn}=${ue_apn}
    ${ips}    Get Ue Info    UE_${ue_index}    IPS
    ${IP}=    Set variable    ${ips[${ue_apn}]['ip_address']}
    [return]    ${IP}
