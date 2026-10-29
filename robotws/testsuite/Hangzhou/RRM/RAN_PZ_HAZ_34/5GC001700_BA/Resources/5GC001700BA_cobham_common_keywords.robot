*** Settings ***
Documentation
...    author: Wang Yishuang
...    contact: yishuang.wang@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC001700_BA

Library    OperatingSystem
Library    Collections
Library    taf.stc.config
Library    String
Library    BuiltIn
Variables    1700_cases_commission/__init__.py
Library    ../../5GC000738/Resources/get_pm_counter.py
#Library    ../../libraries/ece_fastReg.py
Library    taf.analyzer.pcap     WITH NAME    cap
Library    taf.ue.tm500.asc      WITH NAME    asc
Library    taf.config.scf    WITH NAME    scf
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.sbts.oam.coam.admin   WITH NAME    wmplte
Library    taf.ue.tm500.rci       WITH NAME    tm500_remote
#Resource   ../../../../../resources/common/tm500.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource   taf/rfrl/common_resources/robot/gnb_classical.robot
Resource   taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot

*** Variables ***
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ul_addr}    ${tl.ues[0].iperf_details.network_interface_address}
${testpc_ip}    ${tl.test_pc.default_ssh_connection_details.addr}
${TMA_APP_PATH}    ${tl.ues[0].tma_path}
${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
${E500_IP}    ${tl.ues[0].tma_host.addr}
${E500_USER}    ${tl.ues[0].tma_host.username}
${E500_PW}    ${tl.ues[0].tma_host.password}
${E500_SCRIPTS_BASE}    ${CURDIR}/E500_scripts
${gnb_path}    /tmp/
${asik}    BB1
${tl_scf_dir_path}    /opt/workspace/CIT/Master/Scf_files/
${tl_scf_filename}    Full_Configuration_scf_MRBTS-229_HZ_SG3_TL229_1700BA.xml
${enb_instance_id}    ${tl.enbs[0].instance_id}
${gnb_instance_id}    ${tl.gnbs[0].instance_id}
${enbx2_dist}    MRBTS-${enb_instance_id}/LNBTS-${enb_instance_id}/LNADJGNB-1
${enbx2_para}    administrativeState
${gnb_cell1}    MRBTS-${gnb_instance_id}/NRBTS-1/NRCELL-1
${gnb_cell2}    MRBTS-${gnb_instance_id}/NRBTS-1/NRCELL-2
${f1_sctp_port}    38472
${x2_sctp_port}    36422
${TMA_SSH_ALIAS}    tma_ssh
${TMA_TELNET_ALIAS}    tma
${TMA_APP_ALIAS}    e500
${4g_cellid_expected}    1
${ul_time}    1800
${ul_port}    5410
${ul_length}    1024B
${ul_throughput}     2M
${dl_time}    1800
${dl_port}    53229
${dl_length}    1024B
${dl_throughput}    10M
${UPLINK_DATA_TRANSFER}    1.8
${dl_bler_expected}    0.8
${repeat_times}    1
${TMA_ASC_ALIAS}    ASC
${E500_ASC_USER}    switch
${E500_ASC_PW}    switch
${E500_ASC_PORT}    10011


*** Keywords ***
#coam cell setup##
Prepare with COAM classical BTS cell onair
    Perform full commission for COAM gnb
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    Check coam classical gnb start normally
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    wait until keyword succeeds    1min    20s    Check the gnb cells onair
#    Unlock cell2 and check cell status onair

#Perform full commission for COAM gnb
#    Connect to gnb coam via ssl
#    COAM Commission with scf file    file_path=${tl_scf_dir_path}${tl_scf_filename}
#    COAM Teardown gnb connections

Perform full commission for COAM gnb
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${tl_scf_dir_path}${tl_scf_filename}
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    selenium_coam.logout
    wait until keyword succeeds    3 min    10 s    Reset Viavi via ASC    tma_asc_alias=ASC_INIT

Check coam classical gnb start normally
    wait until keyword succeeds    5min   10s    Check All Board Status
    wait until keyword succeeds    5min   30s    Check the sctp port UP    port_num=${f1_sctp_port}
    Check the gnb RU status ready
    wait until keyword succeeds    10min   30s    Check the sctp port UP    port_num=${x2_sctp_port}

Check All Board Status
    wait until keyword succeeds    5min    10sec    Connect to Common Unit Master    alias=asik
    check 0x10 board status
    check 0x12 board status
    check 0x13 board status
#    check 0x14 board status

check ${hw_num} board status
    ${result}    check hw status    hw_num=${hw_num}
    should be true      ${result}


Check the sctp port UP
    [Arguments]    ${port_num}
    Connect to Common Unit Master    alias=BB1
    csn.sendCommand    command=netstat -anl |grep sctp    connection=BB1
    sleep    3s
    ${sctp_status} =    csn.read_output    connection=BB1
    csn.disconnect     connection=BB1
    should contain     ${sctp_status}     ${port_num}

Check the gnb RU status ready
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${ru_status1} =    selenium_coam.get_ru_info    ru_index=1
    ${ru_status2} =    selenium_coam.get_ru_info    ru_index=2
    selenium_coam.logout
    Get info status check    info_status=${ru_status1}
    Get info status check    info_status=${ru_status2}

Check the gnb cells onair
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${cell_status1} =    selenium_coam.get_cell_info    cell_idx=1
    ${cell_status2} =    selenium_coam.get_cell_info    cell_idx=2
    selenium_coam.logout
    Get info status check    info_status=${cell_status1}
    Get info status check    info_status=${cell_status2}

Get info status check
    [Arguments]    ${info_status}
    ${Status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${Status}    Operational state
    should be equal    ${opr_state}    Enabled
#    ${avi_state} =   get from dictionary    ${Status}   Availability status
#    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${Status}    Administrative state
    should be equal    ${adm_state}    Unlocked

Common Suite Setup for COAM
    COAM Create log directory    ${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

Common Suite Teardown for COAM
    Connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    COAM Teardown gnb connections

Modify the COAM parameter with admin API
    [Arguments]    ${parameters}
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

Start Capture Classical x2_WS Logs
    [Arguments]    ${x2logname}
    RUN KEYWORD AND IGNORE ERROR    gNB connections
    Start To Capture Wireshark Logs    filename=${x2logname}    connection=gnb    interface=fp0


Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${filename}   connection=${connection}

gNB connections
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb

Stop and Save Logs
    [Arguments]    ${x2logname}
    gNB connections
#    Stop and download Logs    logname=${f1logname}    connection=gnb
    Stop and download Logs    logname=${x2logname}    connection=gnb

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}
    sleep    3

Kill all tcpdump
    Connect to Common Unit Master    alias=${asik}
    csn.send command    command=killall tcpdump     connection=${asik}
    csn.disconnect    connection=${asik}

Backup all pcap logs
    Kill all tcpdump
    wait until keyword succeeds    5 min    10 sec    Connect to TestPc
    csn.send command    command=sshpass -p ${asik_password} scp ${asik_username}@${asik_addr}:/tmp/*.pcap ${epc_log_path}    connection=TestPc

Recovery
    Cobham UE Recovery
    Close the iperf process on APPserver    port=${dl_port}
    Close the iperf process on VIAVI
    Backup all pcap logs
    csn.disconnect    connection=gnb
    csn.disconnect    connection=asik
    csn.disconnect    connection=fct0b
    csn.disconnect    connection=tma
    csn.disconnect    connection=tma_ssh
    csn.disconnect    connection=e500


## Cobham UE Attach ###
Cobham UE attach and retry if failed
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}
    ...            ${tma_path}=${TMA_APP_PATH}    ${retry_time}=2
    ${time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
        Postcondition_SSH    tma_alias=${TMA_TELNET_ALIAS}
        tm500.Precondition_SSH   tma_alias=${TMA_TELNET_ALIAS}    TMA_PATH=${tma_path}
        wait until keyword succeeds    2 min    10 s    tm500.Connect    tm500_alias=${TMA_APP_ALIAS}
        sleep    30s
        ${connect_status}    ${value} =    run keyword and ignore error
        ...    TMA Connect and Initialize    hw_connect_script_path=${e500_script_path}/Init_Config.txt
        run keyword if    '${connect_status}' == 'FAIL'
        ...    Retry TMA connect    hw_connect_script_path=${e500_script_path}/Init_Config.txt
        tm500.Perform cell search
        ...    cell_search_script_path=${e500_script_path}/NSA_5G_Cell_Config.txt    tm500_alias=${TMA_APP_ALIAS}
        ${attach_status}    ${value} =    run keyword and ignore error    E500 attach and verify
        ...    attach_script_path=${e500_script_path}/NSA_5G_UEattach.txt    e500_alias=${TMA_APP_ALIAS}
        Exit for loop if    '${attach_status}' == 'PASS'
        wait until keyword succeeds    5 min    10 s    Reset Viavi via ASC    tma_asc_alias=${TMA_ASC_ALIAS}_${i}
        sleep    1 min
        ${time}    Evaluate    ${time}+1
        Log to console    RA failed, retry time ${time}
    END
    Should be true    ${time} < ${retry_time}    msg=Retry UE Random access with ${retry_time} times and still failed

E500 attach and verify
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${attach_script_path}    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${e500_alias}=${TMA_APP_ALIAS}
    Log to console    Sending attach_script from ${attach_script_path}
    ${response1}=  tm500_remote.send script  filename=${attach_script_path}  alias=${e500_alias}
    Sleep    1min
    ${response2}=  tm500_remote.read_responses    alias=${e500_alias}
    ${response}=  Catenate    ${response1}    ${response2}
    Should contain    ${response}    Random Access Complete    msg=UE attach failed, string "Random Access Complete" is not found
    Should contain    ${response}    Attach Result: EPS Only    msg=UE attach failed, string "Attach Result: EPS Only" is not found
    Should contain    ${response}    NR-RRCReconfigurationComplete    msg=UE attach failed, string "NR-RRCReconfigurationComplete" is not found
    ${e500_ue_ip}    Get ue ip address    attach_response=${response}
    Set test variable    ${UE_IP}    ${e500_ue_ip}

TMA Connect and Initialize
    [Arguments]   ${hw_connect_script_path}      ${timeout}=5 minutes    ${tm500_alias}=${TMA_APP_ALIAS}
    ${response}=  tm500_remote.send script  filename=${hw_connect_script_path}  timeout=${timeout}    alias=${tm500_alias}
    Should Not Contain    ${response}    Failure
    sleep   10s

Retry TMA connect
    [Arguments]   ${hw_connect_script_path}
    Kill tma process    tma_telnet_alias=${TMA_TELNET_ALIAS}
    wait until keyword succeeds    5 min    10 s    Reset Viavi via ASC    tma_asc_alias=TMA_ASC
    sleep    1 min
    tm500.Precondition    tma_alias=${TMA_TELNET_ALIAS}    TMA_PATH=${TMA_APP_PATH}
    wait until keyword succeeds    2 min    10 s    tm500.Connect    tm500_alias=${TMA_APP_ALIAS}
    sleep    30s
    tm500.Connect hw and initialize    hw_connect_script_path=${hw_connect_script_path}    tm500_alias=${TMA_APP_ALIAS}

Cobham UE detach
    [Arguments]  ${e500_script_path}=${E500_SCRIPTS_BASE}
    tm500.TM500 detach    tm500_alias=${TMA_APP_ALIAS}    detach_script_path=${e500_script_path}/NSA_5G_UEdetach.txt

Cobham UE Recovery
    Cobham UE detach
    Postcondition_SSH

Kill tma process
    [Arguments]    ${tma_telnet_alias}=${TMA_TELNET_ALIAS}
    tm500_remote.create telnet runner       host=${E500_IP}    username=${E500_USER}    password=${E500_PW}    alias=${tma_telnet_alias}
    sleep  5s
    ${status}    run keyword and return status    tm500.Postcodition    tma_alias=${tma_telnet_alias}
    run keyword if  ${status}==${True}
    ...    Sleep    5s

Reset Viavi via ASC
    [Arguments]    ${username}=tm500    ${group}=Units-1    ${tma_asc_alias}=${TMA_ASC_ALIAS}
    csn.Connect to    hostname=${E500_IP}    username=${E500_ASC_USER}    password=${E500_ASC_PW}    port=${E500_ASC_PORT}
    ...            alias=${tma_asc_alias}
    asc.set username    name=${username}    connection=${tma_asc_alias}
    asc.set power off    group_name=${group}    connection=${tma_asc_alias}
    sleep    10s
    asc.set power on    group_name=${group}    connection=${tma_asc_alias}
    sleep    10s
    wait until keyword succeeds    5min    5sec    Ping cobham asc ip
    sleep    10s
    csn.disconnect    connection=${tma_asc_alias}

Ping cobham asc ip
    [Arguments]    ${cobham_asc_ip}=192.168.10.9        ${tma_ssh_alias}=${TMA_SSH_ALIAS}
    Connect to cobham control pc via ssh    tma_ssh_alias=${tma_ssh_alias}
    ${response}    csn.execute    command=ping ${cobham_asc_ip}    connection=${tma_ssh_alias}
    Should Contain    ${response}    Reply from ${cobham_asc_ip}: bytes=32
    csn.disconnect    connection=${tma_ssh_alias}

Get ue ip address
    [Arguments]    ${attach_response}
    @{ue_ip_list}    Get regexp matches    ${attach_response}    IPv4 Address:(.*)    1
    ${ue_ip}    strip_string    ${ue_ip_list}[0]
    [Return]    ${ue_ip}

Start logging on cobham
    [Arguments]    ${connection}=${TMA_APP_ALIAS}
    ${output_start_logging}    tm500_remote.send_command    command=#$$START_LOGGING    alias=${connection}
    should contain    ${output_start_logging}      START_LOGGING 0x00 OK    msg=Start logging on cobham failed

Stop logging on cobham
    [Arguments]    ${connection}=${TMA_APP_ALIAS}
    ${output_stop_logging}    tm500_remote.send_command    command=#$$STOP_LOGGING   alias=${connection}
    should contain    ${output_stop_logging}      STOP_LOGGING 0x00 OK    msg=Stop logging on cobham failed
    ${Converted_log}    tm500_remote.send_command    command=#$$CONVERT_TO_TEXT 2    alias=${connection}
    should contain    ${Converted_log}      Conversion complete    msg=Convert log on cobham failed
    ${cobham_log_folder}    csn.execute    command=${output_stop_logging}| sed -r "s/.*'(.*)'.*/\1/" test | tail -1    connections=asik

##Data transfer##
Start DL UL traffic and monitor throughput
    Start DL traffic via iperf on Appserver    ue_addr=${UE_IP}    dl_time=${dl_time}    dl_port=${dl_port}
    ...    dl_throughput=${dl_throughput}    dl_length=${dl_length}
    Start UL traffic via iperf on VIAVI    iperf_path=${iperf_path}    ul_addr=${ul_addr}    ul_time=${ul_time}
    ...    ul_port=${ul_port}    ul_throughput=${ul_throughput}    ul_length=${ul_length}
    sleep    5s
    Evaluate throughput on source cell

Caculate DL throughput on gnb
    [Arguments]     ${abil_num}    ${abil_alias}
    wait until keyword succeeds    1min    10s    Connect to Common Unit Master    alias=asik
    wait until keyword succeeds    1min    10s    Connect to Capacity Unit Master    hw_slot=${abil_num}    alias=${abil_alias}    asik_alias=asik
    ${DL_throughoutput}=    Calculate DL throughoutput    alias=${abil_alias}
    csn.disconnect    connection=${abil_alias}
    csn.disconnect    connection=asik
    [Return]    ${DL_throughoutput}


Caculate DL throughput on cobham
    [Arguments]    ${dl_throughput_log_file_path}=${epc_log_path}    ${TP_script}=CheckThroughput5g.txt
    ...            ${e500_script_path}=${E500_SCRIPTS_BASE}    ${e500_alias}=${TMA_APP_ALIAS}
    [Timeout]    5 minutes
    ${response}    tm500_remote.send script  filename=${e500_script_path}/${TP_script}  alias=${e500_alias}
    ${timestamp}    Get timestamp
    Log to console    Execute check throughput command and write to file
    Run   echo '${response}'>${dl_throughput_log_file_path}/Check_Tput_Cobham_${timestamp}.txt

    ${dl_average}    Run    echo '${response}' |grep -A 1 "DL LogCh"|tail -n 1|awk '{print $4}'
    ${dl_average_tput}    Evaluate  float("${dl_average}") / 1048576
    [Return]    ${dl_average_tput}

Evaluate DL throughput
    [Arguments]     ${abil_num}    ${abil_alias}    ${TP_script}=CheckThroughput5g.txt
    ${dl_tput_ue}=    Caculate DL throughput on cobham    TP_script=${TP_script}
    ${dl_tput_gnb}=    Caculate DL throughput on gnb    abil_num=${abil_num}     abil_alias=${abil_alias}
    ${dl_bler} =    Evaluate    float(${dl_tput_ue}/${dl_tput_gnb})
    should be true    ${dl_bler} >= ${dl_bler_expected}

Evaluate UL throughput
    [Arguments]     ${abil_num}    ${abil_alias}    ${UPLINK_DATA_TRANSFER}=${UPLINK_DATA_TRANSFER}
    wait until keyword succeeds    1min    10s    Connect to Common Unit Master    alias=asik
    wait until keyword succeeds    1min    10s    Connect to Capacity Unit Master    hw_slot=${abil_num}    alias=${abil_alias}    asik_alias=asik
    ${UL_throughoutput}=    Calculate UL throughoutput    alias=${abil_alias}
    should be true    ${UL_throughoutput} >= ${UPLINK_DATA_TRANSFER}
    csn.disconnect    connection=${abil_alias}
    csn.disconnect    connection=asik

Evaluate throughput on source cell
    Evaluate DL throughput    abil_num=${1}    abil_alias=abil1_master
    run keyword and ignore error    Evaluate UL throughput    abil_num=${1}    abil_alias=abil1_master

Evaluate throughput on target cell
    Evaluate DL throughput    abil_num=${2}    abil_alias=abil2_master    TP_script=CheckThroughput5g_cell2.txt
    run keyword and ignore error    Evaluate UL throughput    abil_num=${2}    abil_alias=abil2_master
