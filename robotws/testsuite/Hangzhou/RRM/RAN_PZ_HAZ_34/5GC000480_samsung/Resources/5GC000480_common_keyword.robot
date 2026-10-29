*** Settings ***
Documentation     Auther: fangmin.wu@nokia-sbell.com
...               Description: 480_common_keyword
Library           ./counter_anaylysis.py
#Resource          ../../../../../resources/common/tm500.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/tm500_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.collectors.pmcounters      WITH NAME     tafpmcounters
Library    taf.analyzer.pcap    WITH NAME    cap
Library           taf.transport.ssh    WITH NAME    csn
*** Variables ***
${TMA_SSH_ALIAS}    tma
${TMA_APP_ALIAS}    e500
${TAM_APP_PATH}    ${tl.ues[0].tma_path}
${E500_IP}        ${tl.ues[0].tma_host.addr}
${E500_USER}      ${tl.ues[0].tma_host.username}
${E500_PW}        ${tl.ues[0].tma_host.password}
${E500_SSH_DOMAIN}    ${tl.ues[0].tma_host.private_key}
${nrbtsId}    ${tl.gnbs[0].global_bts_id}
${mrbtsId}    ${tl.gnbs[0].instance_id}
${WEBUI_HOST}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
${ul_port_list}    ${tl.ues[0].iperf_details.ports}
${dl_port}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
${ul_power_port_list}    ${tl.ues[0].iperf_details.ports[0:4]}
${dl_power_port_list}    ${tl.ues[0].iperf_details.ports[4:8]}
${eNB_ip}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${gNB_ssh_name}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gNB_ssh_pass}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
*** Keywords ***
Synchron gNB and VIAVI
    [Arguments]    ${alias}=${asik}
    Connect to BB1 master
    ${cmd_export_pylib}    Evaluate    'export PYTHONPATH=/opt/hwmt/python:/opt/hwmt/lib/python2.7/site-packages'
    ${cmd_sync_clock}    Catenate    /opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/SYNCOUT-1 --proto SYNC/sync_out
    ...                             -t execute --action setClock10MHz --args clock10MHz=1
    ${cmd_sync_frame_clock}    Catenate    /opt/hwmt/python/sendommessage.sh -s 0x04dc -d HWASYNC-1/CLOCKOUTPUTS-1/SYNCOUT-1 --proto SYNC/sync_out
    ...                    -t execute --action setFrameClock --args frameClock=1
    csn.send command    ${cmd_export_pylib}    connection=${alias}
    ${output_sync_clock}    csn.execute    ${cmd_sync_clock}    connection=${alias}
    sleep    2s
    Should Contain    ${output_sync_clock}    MitAaSysComFinalize ok
    ${output_sync_frame_clock}    csn.execute    ${cmd_sync_frame_clock}    connection=${alias}
    sleep    2s
    Should Contain    ${output_sync_frame_clock}    MitAaSysComFinalize ok

Cobham UE attach
    [Arguments]    ${BW}    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${type}=NSA    ${tma_path}=${TAM_APP_PATH}    ${ue_num}=1
    [Timeout]    10 min
    tm500.Precondition_SSH    TMA_PATH=${tma_path}
    wait until keyword succeeds    2 min    10 s    tm500.Connect    tm500_alias=${TMA_APP_ALIAS}
    tm500.Connect HW and Initialize    hw_connect_script_path=${e500_script_path}/Init_Config.txt    tm500_alias=${TMA_APP_ALIAS}
    tm500.Perform cell search    cell_search_script_path=${e500_script_path}/${type}_5G_Cell_Config_${BW}.txt    tm500_alias=${TMA_APP_ALIAS}
    5GC000480_common_keyword.Retry ue attach if failed    type=${type}    attach_script_path=${e500_script_path}/${type}_5G_${ue_num}UEattach.txt
    ...    detach_script_path=${e500_script_path}/${type}_5G_UEdetach.txt    e500_alias=${TMA_APP_ALIAS}
    Sleep    5s

Retry ue attach if failed
    [Arguments]    ${type}    ${attach_script_path}    ${detach_script_path}    ${retry_time}=${3}    ${e500_alias}=${TMA_APP_ALIAS}
    ${detach_time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
        ${attach_status}    run keyword and return status     5GC000480_common_keyword.E500 attach and verify
    ...    attach_script_path=${attach_script_path}    type=${type}    e500_alias=${e500_alias}
        Exit for loop if    ${attach_status}==${True}
        run keyword and ignore error    tm500.TM500 Detach    tm500_alias=${TMA_APP_ALIAS}    detach_script_path=${detach_script_path}
        ${detach_time}    Evaluate    ${detach_time}+1
        Log to console    Attached failed, retry detach time ${detach_time}
        ...    AND
    END
    Should be true    ${detach_time} < ${retry_time}    msg=Retry UE attach with ${retry_time} times and still failed

E500 attach and verify
    [Arguments]    ${attach_script_path}    ${type}    ${e500_alias}=${TMA_APP_ALIAS}
    Log to console    Sending attach_script from ${attach_script_path}
    ${response}=    tm500_remote.send script    ${attach_script_path}    alias=${e500_alias}
    Sleep    5s
    Should contain    ${response}    Random Access Complete    msg=UE attach failed, string "Random Access Complete" is not found
    run keyword if    '${type}'=='NSA'    NSA L3 call Check    response=${response}
    ${e500_ue_ip}    Get ue ip address    attach_response=${response}
    Set test variable    ${UE_IP}    ${e500_ue_ip}

attach multi power ue
    [Arguments]    ${ue_num}
    log to console       Prepare UE
    FOR    ${item}    IN RANGE    ${ue_num}
        ${status}    run keyword and return status    power ue attach again    ${item}
        run keyword if  not ${status}    power ue attach again    ${item}
    END
#    \    power_ue.Prepare UE    ue_index=${item}    ue_type=samsung
#    \    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${item}    ue_type=samsung    log_type=Aasyslog
#    \    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False

power ue attach again
    [Arguments]    ${ue_index}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False

start multi power ue traffic ul and dl
    [Arguments]    ${ue_num}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000    ${protocol}=udp
    ...    ${if_ul}=${True}    ${if_dl}=${True}
    log to console      Start traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
    ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
    ...    iperf_port=${ul_power_port_list}[${item}]    process_num=${1}
         sleep    1s
         run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
    ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung    protocol=${protocol}
    ...    iperf_port=${dl_power_port_list}[${item}]    process_num=${1}
    END


stop multi power ue traffic ul and dl
    [Arguments]    ${ue_num}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
    ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=samsung    protocol=${protocol}
    ...    iperf_port=${dl_power_port_list}[${item}]
    END

detach multi power ue
    [Arguments]    ${ue_num}=${4}
    log to console      UE Detach    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         power_ue.UE Detach    ue_index=${item}    ue_type=samsung
    END

Get ul and dl peak and ave throughput and return result
    [Documentation]    Get ul and dl peak and ave throughput and return result.
    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}

NSA L3 call Check
    [Arguments]    ${response}
    Should contain    ${response}    Attach Result: EPS Only    msg=UE attach failed, string "Attach Result: EPS Only" is not found
    ${response_verify_NR_attach}    tm500_remote.send command    command=forw mte Getstats [0] [0] [0]    alias=${TMA_APP_ALIAS}
    Should contain    ${response_verify_NR_attach}    L2 Random Access Complete
    ...    msg=UE attach failed, string "L2 Random Access Complete" is not found

Get ue ip address
    [Arguments]    ${attach_response}
    @{ue_ip_list}    Get regexp matches    ${attach_response}    IPv4 Address:(.*)    1
    ${ue_ip}    strip_string    ${ue_ip_list}[0]
    Set test variable    @{UE_IPs}    @{ue_ip_list}
    [Return]    ${ue_ip}

Kill tma process
    [Arguments]    ${tma_telnet_alias}=${TMA_TELNET_ALIAS}
    tm500_remote.create telnet runner    ${E500_IP}    ${E500_USER}    ${E500_PW}    alias=${tma_telnet_alias}
    sleep    5s
    ${status}    run keyword and return status    tm500.Postcodition    tma_alias=${tma_telnet_alias}
    run keyword if    ${status}==${True}    Sleep    5s

Cobham UE detach
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${type}=NSA
    [Timeout]    5 min
    ${log}=    tm500_remote.send script    ${e500_script_path}/${type}_5G_UEdetach.txt    alias=${TMA_APP_ALIAS}
    ${status}    run keyword and return status    Should contain    ${log}    DTRC
    Run Keyword If    '${status}'=='False'    tm500_remote.send command    command=#$$DISCONNECT    alias=${TMA_APP_ALIAS}
    tm500.Disconnect    tm500_alias=${TMA_APP_ALIAS}
    run keyword and ignore error  csn.disconnect    connection='BB1'

Connect to cobham ASC via ssh
    [Arguments]    ${tma_asc_alias}=${TMA_ASC_ALIAS}
    csn.Connect to    hostname=${E500_IP}    username=${E500_ASC_USER}    password=${E500_ASC_PW}    port=${E500_ASC_PORT}    alias=${tma_asc_alias}

Disconnect from cobham ASC via ssh
    [Arguments]    ${tma_asc_alias}=${TMA_ASC_ALIAS}
    csn.disconnect    connection=${tma_asc_alias}

Start DL traffic via iperf on Appserver to single UE
    [Arguments]    ${dl_throughput}    ${dl_time}=${99999}    ${dl_port}=${dl_port}    ${dl_length}=${1400}
    traffic_via_iperf.Start DL traffic via iperf on Appserver    ue_addr=${UE_IP}    dl_time=${dl_time}    dl_port=${dl_port}
    ...    dl_throughput=${dl_throughput}    dl_length=${dl_length}

Start DL traffic via iperf on Appserver to Multi UEs
    [Arguments]    ${dl_throughput}    ${dl_time}=${99999}    ${dl_port}=${dl_port}    ${dl_length}=${1400}
    FOR    ${UE_single_ip}    IN    @{UE_IPs}
        ${UE_single_ip}     strip_string    ${UE_single_ip}
        traffic_via_iperf.Start DL traffic via iperf on Appserver    ue_addr=${UE_single_ip}    dl_time=${dl_time}    dl_port=${dl_port}
    ...    dl_throughput=${dl_throughput}    dl_length=${dl_length}
    END

Stop DL traffic via iperf on Appserver to Multi UEs
    [Arguments]    ${ue_ip_list}
    FOR    ${UE_single_ip}    IN    @{ue_ip_list}
        ${UE_single_ip}     strip_string    ${UE_single_ip}
        traffic_via_iperf.Close the iperf process on APPserver    port=${UE_single_ip}
    END

Start UL traffic via iperf on VIAVI to single UE
    [Arguments]     ${throughput}    ${traffic_time}=${99999}    ${port}=5410
    traffic_via_iperf.Connect to cobham control pc via ssh
    ${cmd_start_iperf_client}    Catenate    ${iperf_path}/iperf -c 192.168.10.70 -u -b ${throughput}
    ...    -i 1 -l 1024  -t ${traffic_time} -p ${port}
    csn.send command     ${cmd_start_iperf_client}    connection=${tma_ssh_alias}

Start UL traffic via iperf to Multi UEs
    [Arguments]     ${ue_num}    ${ul_time}    ${ul_throughput}
    FOR    ${i}    IN RANGE    ${ue_num}
        Start UL traffic via iperf on VIAVI to single UE    traffic_time=${ul_time}    throughput=${ul_throughput}
    ...    port=${ul_port_list}[${i}]
    END

Close the iperf process on VIAVI
    wait until keyword succeeds    1 min    10 sec    Connect to cobham control pc via ssh
    ${output}=    csn.execute    ps -ef |grep iperf    connection=${tma_ssh_alias}
    ${len}=    Get length    ${output}
    ${iperf_pid_list}=    Run Keyword If     ${len}>0
    ...                csn.execute    ps -ef |grep iperf |awk '{print $2}'    connection=${tma_ssh_alias}
    @{iperf_pid_list}=    Split To Lines	   ${iperf_pid_list}
    FOR    ${iperf_pid}    IN    @{iperf_pid_list}
        csn.execute   kill -9 ${iperf_pid}    connection=${tma_ssh_alias}
    END

Get PARAM Value from Wireshark Log
    [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
    ${value}=    cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
    ...    default_value=${default_value}    condition_expression=${condition_expression}
    [Return]    ${value}

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${connection}   ${filter}
    ssh.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    ssh.await execution end  connection=${connection}  timeout=30min

Convert pcap file to txt
    [Arguments]    ${source}   ${target}   ${filter}    ${connection}=TEST_PC
    csn.Connect to     hostname=${TEST_PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
    [Teardown]  run keyword and ignore error  csn.Disconnect	connection=${connection}


Ping cobham asc ip
    [Arguments]    ${cobham_asc_ip}=192.168.10.10    ${tma_ssh_alias}=${TMA_SSH_ALIAS}
    Connect to cobham control pc via ssh    tma_ssh_alias=${tma_ssh_alias}
    ${response}    csn.execute    command=ping ${cobham_asc_ip}    connection=${tma_ssh_alias}
    Should Contain    ${response}    Reply from ${cobham_asc_ip}: bytes=32
    Disconnect from cobham control pc via ssh

Check L1 throughput on VIAVI
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${e500_alias}=e500
    ${response}=  tm500_remote.send script  ${e500_script_path}/L1_tput_check.txt  alias=${e500_alias}
    @{l1_tput_list}    Get regexp matches    ${response}    Average:(.*)Min:    1
    FOR    ${l1_tput}    IN    @{l1_tput_list}
        ${tput}=    Strip String    ${l1_tput}    mode=left    characters=${SPACE}0
        ${value}    Evaluate    float(${tput})/1048576
        Log to console    ${value}
    END

Check MAC throughput on VIAVI
    [Arguments]    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${e500_alias}=e500
    sleep    10s
    ${response}=  tm500_remote.send script  ${e500_script_path}/MAC_tput_check.txt  alias=${e500_alias}
    @{mac_tput_list}    Get regexp matches    ${response}    Average:(.*)Min:    1
    FOR    ${mac_tput}    IN    @{mac_tput_list}
        ${tput}=    Strip String    ${mac_tput}    mode=left    characters=${SPACE}0
        ${value}    Evaluate    float(${tput})/1048576
        Log to console    ${value}
    END

Caculate DL throughput from gnb L2Lo
   [Arguments]    ${dl_expect}    ${cellid}=1    ${location}=${16}
    wait until keyword succeeds     1 min     10 sec     Connect to Common Unit Master
    wait until keyword succeeds     1 min     10 sec     Connect to Capacity Unit Master
#    power_ue.check throughput
    ${statsu}    run keyword and return status    Calculate DL throughoutput trunk     location=${location}     alias=ABIL Master
    ${dl_tp_l2lo}    run keyword if    '${statsu}'=='True'    Calculate DL throughoutput trunk     location=${location}     alias=ABIL Master
    ...    ELSE    Calculate_DL_throughoutput_re    alias=aspa_l2lo    log_type=aasyslog
    should be true     ${dl_tp_l2lo} > ${dl_expect}
    [Teardown]     Run Keywords     run keyword and ignore error     csn.disconnect     connection=ABIL Master
    ...     AND     run keyword and ignore error     csn.disconnect     connection=ASIK Master

update counter parameters
    COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/NRBTS-${nrbtsID}/NRPMRNL-1    parameter=miNrF1CD     value=15min
    sleep    5s
    COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/MNL-1/MNLENT-1/PMCADM-1    parameter=reportingIntervalPm    value=15min
    sleep    5s
COAM Update Parameter
    [Arguments]   ${dist_name}   ${parameter}   ${value}   ${connection}=GNB_OAM
    coam.perform_parameter_recommissioning   dist_name=${dist_name}   parameter=${parameter}   value=${value}
    ...   operation=update
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=60
    ...   connection=${connection}

Wait for counter to be gathered after guard peroid
   [Arguments]  ${interval}
   ${list}=           Create List         00  15  30  45
   ${actualTime}=     Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ${time_check}    run keyword and return status   List Should Contain Value    ${list}    ${actualTime}
   run keyword if    ${time_check}   Sleep   ${interval} minutes
   PM Wait To Nearest Measurement Period


PM Wait To Nearest Measurement Period
   Log    PM Wait To Nearest Measurement Period    console=yes
   Wait Until Keyword Succeeds                     16 min
   ...                                            1 min
   ...                                             Wait For Right Period
   Sleep                                           60

Wait For Right Period
   ${list}=           Create List         00  15  30  45
   ${actualTime}=     Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
   ${actualHour}=     Get Current Date    result_format=%H
   ...                                    time_zone=UTC
    ...                                    increment=8 hours
   ${date}=     Get Current Date    result_format=%Y-%m-%d
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
    ${date_nodash}=    Get Current Date    result_format=%Y%m%d
   ...                                    time_zone=UTC
   ${actualEpoch}=    Convert Date	       ${date} ${actualHour}:${actualTime}:00.000	epoch
   List Should Contain Value	           ${list}  ${actualTime}
   Log                                    ${actualTime}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   ${integer_epoch}=   convert to integer  ${nopoint_epoch}
   ${epoch_minus_interval}=   Evaluate   ${integer_epoch}-15*60
   ${epoch_minus_interval_string}=   Convert To String   ${epoch_minus_interval}
   set test variable    ${epoch_minus_interval_string}

Check if counters value is correct
   [Documentation]  This keyword can be expanded for getting PM counters at the start of test case (after time slot
   ...   is correct) and collect all counters and iterate over dict here to improve performance.
   [Arguments]  ${counter_id}    ${expected_value}
   ${counter_values}=   coam.get pm counters   ${counter_id}    connection=GNB_OAM
   ${string_values}=   Convert To String   ${counter_values}
   Should Contain   ${string_values}  ${epoch_minus_interval_string}
   ${get_counter_value}    get_cell_counter_value    counter_values=${counter_values}    cellId=NRCELL-1
   ...     measType=RACCU    measId=${counter_id}     epochTime=${epoch_minus_interval_string}
   ${counter_sum}    set variable    ${0}
   FOR    ${item}    IN    @{get_counter_value}
        ${counter_sum}    evaluate       ${counter_sum}+${item}
   ${actual_counter_value}    set variable if    ${get_counter_value}[-1]>=${expected_value}    ${get_counter_value}[-1]    ${counter_sum}
   END
   Should Be Equal As Strings    ${actual_counter_value}    ${expected_value}

#Stop and Download Log
#    [Arguments]    ${filename}    ${asik}=ASIK Master
#    Connect to Common Unit Master
#    ${PID}  csn.Execute  command=ps -ef |grep tcpdump|awk '{{print $2}}'|head -n 1
#    ...    connection=${asik}
#    ${PID}    strip_string    ${PID}
#    csn.Execute    command=kill -2 ${PID}    connection=${asik}
#    csn.download_file    remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${output_dir}/${filename}
#    ...    connection=${asik}
#    sleep    2s
#    csn.execute    command=rm ${gnb_tmp_log_dir}/${filename}    connection=${asik}
#    Csn.Disconnect	connection=${asik}

#Start to Capture X2 Log on Asik
#    [Arguments]    ${filename}
#    Connect to Common Unit Master
#    csn.send command    command=killall tcpdump    connection=ASIK Master
#    Start to Capture wireshark Log    listen_port=fp0    log_dir=${gnb_tmp_log_dir}    filename=${filename}
#    ...    connection=ASIK Master

Stop and Download Log
    [Arguments]    ${filename}    ${asik}=ENB_Connection
    Connect to Common Unit ENB
    ${PID}  csn.Execute  command=ps -ef |grep tcpdump|awk '{{print $2}}'|head -n 1
    ...    connection=${asik}
    ${PID}    strip_string    ${PID}
    csn.Execute    command=kill -2 ${PID}    connection=${asik}
    csn.download_file    remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${output_dir}/${filename}
    ...    connection=${asik}
    sleep    2s
    csn.execute    command=rm ${gnb_tmp_log_dir}/${filename}    connection=${asik}
    Csn.Disconnect	connection=${asik}

Connect to Common Unit ENB
    [Arguments]  ${proxy}=OAM    ${alias}=ENB_Connection
    csn.Connect to    hostname=${eNB_ip}    username=${gNB_ssh_name}    password=${gNB_ssh_pass}
    ...    alias=${alias}

Start to Capture X2 Log on Asik
    [Arguments]    ${filename}
    Connect to Common Unit ENB
    csn.send command    command=killall tcpdump    connection=ENB_Connection
    Start to Capture wireshark Log    listen_port=br1    log_dir=${gnb_tmp_log_dir}    filename=${filename}
    ...    connection=ENB_Connection

Start to Capture wireshark Log
    [Arguments]    ${listen_port}    ${log_dir}    ${filename}    ${connection}
    csn.send command    command=tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &
    ...    connection=${connection}
    sleep    3s


Read Wireshark Log
    [Arguments]    ${filename}    ${filter}=${None}
    cap.Read Cap    cap_file=${output_dir}/${filename}    display_filter=${filter}

Login Page Via WebUI
    selenium.enable_virtual_display
    selenium.login    url=https://${WEBUI_HOST}    username=${WEBUI_USER}    password=${WEBUI_PWD}
    selenium.disable_message_box
    selenium.disable_screen_lock
