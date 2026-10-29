*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library    list_parse.py
Library    check_sfn_and_solt.py

*** Variables ***
${tshark_path}       /usr/bin/tshark

*** Keywords ***
Get ucibits from bip
    [Arguments]    ${bip_file}
    ${Parser}    cap.setup    infile=${bip_file}    display_filter=${display_filter}
    ...    tshark_path=${tshark_path}    alias="Parser"
    [Return]    ${Parser}

Get UE Type
    [Arguments]    ${ue_index}=0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set suite variable     ${ue_type}

Prepare UE 7608
    [Arguments]    ${ue_index}=0    ${power_reset}=False
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    power_reset=${power_reset}

UE Attach 7608
    [Arguments]    ${ue_index}=0    ${power_reset}=False    ${log_type}=Aasyslog
    log to console  \n***UE Attach***
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    
    ...    log_type=Aasyslog    power_reset=${power_reset}
	set suite variable     ${ue_type}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed_0}    4G_check=False
	[return]    ${5Grach_ed_0}

UE Detach 7608
    [Arguments]    ${ue_index}=0    ${power_reset}=False
    log to console    \n***UE Detach***
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}    power_reset=${power_reset}

Start DL Traffic 7608
    [Arguments]    ${ue_index}=0    ${dl_tp}==100MKbits/sec    ${apn_address}=dxdata1    ${duration}=900
    log to console    \n***Start traffic***
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl    throughput=${dl_tp}
    ...    apn_address=${apn_address}    duration=${duration}

Start UL Traffic 7608
    [Arguments]    ${ue_index}=0    ${ul_tp}==100MKbits/sec    ${apn_address}=dxdata1    
    ...    ${duration}=900    ${iperf_type}=via_command
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul    throughput=${ul_tp}
    ...    apn_address=${apn_address}    duration=${duration}    iperf_type=${iperf_type}

Get Cell ID
    Connect to gnb coam via ssl
    ${list_of_cell_ids}    Get List of NR Cell ID
    set suite variable     ${list_of_cell_ids}
    [Teardown]    COAM Teardown gnb connections

Check Tput 7608
    [Arguments]    ${ul_target}=100    ${dl_target}=100    ${avg_percent}=0.1    
    ...    ${min_percent}=0.01    ${actCarrierAggregation}=${True}
    Get Cell ID
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=3m
    ${result}    Run Keyword And Ignore Error    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}
    ...    cells=${list_of_cell_ids}    actCarrierAggregation=${actCarrierAggregation}
    ...    ultarget_throughput=${ul_target}    dltarget_throughput=${dl_target}
    ...    target_avg_percent=${avg_percent}    min_percent=${min_percent}
    Set Test Variable    ${all_tp}    ${result}[1]

Stop L3Call
    [Arguments]    ${ue_index}=0    ${apn_address}=dxdata1    ${power_reset}=False
    log to console    \n***Stop traffic***
    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}
    ...    direction=dl    apn_address=${apn_address}
    power_ue.Stop traffic    ue_type=${ue_type}    ue_index=${ue_index}
    ...    direction=ul    apn_address=${apn_address}
    UE Detach 7608

Asil Bip Capture with gnbMirroring scripts
    [Arguments]    ${connection}=ASIK Master    ${gnb_mirroring}=gnbMirroring.sh     ${mirroring_mode}=local
    ...    ${bb_slot_1}=false    ${bb_slot_2}=false    ${bb_slot_3}=false
    ...    ${bb_slot_5}=true    ${bb_slot_6}=false    ${bb_slot_7}=false    ${l2_l1_bip}=true
    ...    ${syscom_mirroring}=true    ${carrier_aggregation}=false    ${backhaul_mirroring}=false
    ...    ${l2hi_l2lo_mirroring}=false    ${filtering}=off    ${use_gulp}=false     
    ...    ${capturing_time_seconds}=infinite
    ...    ${number_of_files}=1    ${file_size_mbytes}=100    ${xtrace}=off    ${sleep_time}=10s    
    ...    ${bip_prefix}=tcpdump_L2L1
    ${cmd_local}    catenate    nohup sh /ffs/run/config/scripts/${gnb_mirroring} --mirroring_mode=${mirroring_mode}
    ...     --bb_slot_1=${bb_slot_1} --bb_slot_2=${bb_slot_2}
    ...     --bb_slot_3=${bb_slot_3} --bb_slot_5=${bb_slot_5} --bb_slot_6=${bb_slot_6} --bb_slot_7=${bb_slot_7}
    ...     --l2_l1_bip=${l2_l1_bip} --syscom_mirroring=${syscom_mirroring}
    ...     --carrier_aggregation=${carrier_aggregation} --backhaul_mirroring=${backhaul_mirroring}
    ...     --l2hi_l2lo_mirroring=${l2hi_l2lo_mirroring} --filtering=${filtering} --use_gulp=${use_gulp}
    ...     --capturing_time_seconds=${capturing_time_seconds} --number_of_files=${number_of_files}
    ...     --file_size_mbytes=${file_size_mbytes} --xtrace=${xtrace} &>/dev/null &
    csn.send_command    command=${cmd_local}    connection=${connection}
    Sleep    ${sleep_time}
    Trace capturing process should be triggered    log_prefix=${bip_prefix}    connection_alias=${connection}

TL334 Stop BIP Capture
    [Arguments]     ${interface}=nac_eth2  ${connection}=ASIK Master
    ${check_process_command}    Set Variable    ps -ef | grep tcpdump | grep -v grep | grep ${interface}
    ${is_process_on}    csn.execute    command=${check_process_command}    connection=${connection}
    Should Not Be Empty    ${is_process_on}    msg=Fail to stop bip log capturing on ASIK
    csn.Execute        ps -ef | grep tcpdump | grep -v grep | grep ${interface} | awk '{print $2}' | xargs kill -2
    ...                connection=${connection}
    sleep  10 sec
    ${is_process_killed} =    csn.Execute    command=${check_process_command}    connection=${connection}

TL334 Stop BIP capture and download BIP Logs to testPC
    [Arguments]     ${interface}=nac_eth2    ${connection}=ASIK Master
    ...             ${log_path}=${TS_CASE_LOG_PATH}    ${download_type}=Download
    ...             ${log_prefix}=${None}    ${bip_prefix}=tcpdump_L2L1
    ${multiRAT}    Check if multiRAT BTS
    run keyword if    ${multiRAT}    Connect To MultiRAT GNB Common Unit Master
    ${connection}    set variable if    ${multiRAT}    MultiRAT GNB Master    ${connection}
    ${common_unit_type}    Get hardware type    alias=${connection}
    ${capture_interface}    set variable if    '${common_unit_type}'=='ASIB'    eths2    ${interface}
    TL334 Stop BIP Capture    interface=${capture_interface}    connection=${connection}
    ${list_log_path_local}    Download BIP Logs From ASIK To TestPC and rename it
    ...    log_path=${log_path}
    ...    connection=${connection}
    ...    download_type=${download_type}
    ...    log_prefix=${log_prefix}
    ...    bip_prefix=${bip_prefix}
    [Return]    ${list_log_path_local}

TL334 Capture BIP log and download
    [Arguments]    ${duration}=5s    ${log_path}=${logPath}    ${interface}=nac_eth2
    Connect to Common Unit Master
    Precondition for bip capture with gnbMirroring scripts
    Asil Bip Capture with gnbMirroring scripts
    sleep    ${duration}
    ${list_log_path_local}    TL334 Stop BIP capture and download BIP Logs to testPC
    ...    log_path=${log_path}    interface=${interface}
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    ssh.Disconnect    connection=ASIK Master
    [Return]    ${bip_log_path}

Start to collect X2log on eNB
    [Documentation]  Author: meiya.cheng
    ...              Description: collect X2 LOGS for classical BTS
    [Arguments]    ${log_name}
    wait until keyword succeeds    10 min    10 sec    Connect to eNB   alias=ENB
	csn.send command    command=tcpdump -i br1 -w /tmp/${log_name}   connection=ENB

Stop and get X2Logs on eNB
    [Documentation]  Author: meiya.cheng
    ...              Description: stop collect X2 LOGS and upload for classical BTS
    [Arguments]     ${log_name}
    wait until keyword succeeds    10 min    10 sec    Connect to eNB   alias=ENB
    sleep    30
    csn.send command    command=killall tcpdump     connection=ENB
    sleep    5
    csn.download_file   remote_path=/tmp${/}${log_name}    local_path=${logPath}${/}${log_name}   connection=ENB

Make L3Call and Check TP
    [Arguments]    ${ue_index}=0    ${power_reset}=False
    ...    ${dl_tp}=300MKbits/sec     ${apn_address}=dxdata1    ${duration}=900
    ...    ${ul_tp}=100MKbits/sec    ${ul_target}=100    ${dl_target}=100
    ...    ${avg_percent}=0.1    ${min_percent}=0.01    ${iperf_type}=via_command
    Get Ue Type    ue_index=${ue_index}
    Prepare UE 7608    ue_index=${ue_index}    power_reset=${power_reset}
    UE Attach 7608    ue_index=${ue_index}    power_reset=${power_reset}
    Start DL Traffic 7608    ue_index=${ue_index}    dl_tp=${dl_tp}
    ...    apn_address=${apn_address}    duration=${duration}
    Start UL Traffic 7608    ue_index=${ue_index}    ul_tp=${ul_tp}    apn_address=${apn_address}
    ...    duration=${duration}    iperf_type=${iperf_type}
    Check Tput 7608    ul_target=${ul_target}    dl_target=${dl_target}
    ...    avg_percent=${avg_percent}    min_percent=${min_percent}
    [Teardown]    Run Keyword And Ignore Error    Stop L3Call    ue_index=${ue_index}
    ...    apn_address=${apn_address}    power_reset=${power_reset}
