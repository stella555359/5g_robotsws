*** Settings ***
Documentation     Author: debbie.wang@nokia-sbell.com
...               keywords used in all kinds of log
...               gnb snapshot and btslog keywords can be found in reources/Macro/bts/common/gnb_log.robot
...               enb snapshot and btslog keywords can be found in reources/Macro/bts/common/enb_log.robot
...    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
...               ASIB BIP log capture keyword can be found in RRM/Hangzhou/5GC002056-AGAJ-AGAI/Resources/5GC002056-AGAJ-AGAI_resources.robot
...    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot


*** Keywords ***
###################################X2#############################################################################
Start pcap trace capturing by tcpdump
    [Documentation]
    ...     Start tcpdump process on ${interface}, save to file ${remote_log_dir}/${log_name}.
    [Arguments]   ${log_name}    ${interface}    ${remote_log_dir}=/tmp    ${alias}=ASIK Master
    ${remote_log_path}    join path    ${remote_log_dir}    ${log_name}.pcap
    csn.send command    command=nohup tcpdump -i ${interface} -s 0 -w ${remote_log_path}     connection=${alias}
    sleep    2s    reason=wait for process to start.
    Trace capturing process should be triggered    log_prefix=${log_name}    connection_alias=${alias}

Start X2 log capture from eNB
    [Documentation]
    ...     Start X2 log capture from eNB
    [Arguments]     ${enb_ip}    ${enb_username}    ${enb_passowrd}    ${log_name}=enbX2    ${interface}=br1    ${enb_index}=${0}    ${alias}=ENB
    wait until keyword succeeds    2 min    10 sec    Login BaseStation By Ssh    hostname=${enb_ip}    username=${enb_username}
    ...    password=${enb_passowrd}    alias=${alias}
    Start pcap trace capturing by tcpdump    log_name=${log_name}    interface=${interface}    remote_log_dir=/tmp    alias=${alias}

Stop X2 log capture from eNB
    [Documentation]
    ...    :param ${local_file_name}: if ${None}, downloaded file will use same file name from remote;
    ...                              if specified, downloaded file will be renamed to ${local_file_name}.
    [Arguments]    ${log_name}=enbX2    ${local_log_path}=${output_dir}    ${alias}=ENB    ${local_file_name}=${None}
    ...    ${overwrite_local_file}=${True}    ${remove_remote_file}=${True}
    ${local_log_path}    Stop X2 log capture from gNB    log_name=${log_name}    log_path=${log_path}    alias=${alias}
    ...    overwrite_local_file=${overwrite_local_file}    remove_remote_file=${remove_remote_file}    local_file_name=${local_file_name}
    [Return]    ${local_log_path}

Start X2 log capture from gNB
    [Documentation]
    ...    Description: Start X2 log capture on gNB.
    ...                 Will start tcpdump process to capture on interface which has the external IP addr.
    [Arguments]     ${log_name}=gnbX2    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
    ${external_ip_addr}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    Connect to Common Unit Master    alias=${alias}    gnb_index=${gnb_index}    du_index=${du_index}
    ssh.send_command    command=ifconfig | grep -B1 "${external_ip_addr}" | head -n 1 | awk -F':' '{print $1}'    connection=${alias}
    ${external_ip_interface}    ssh.read_output    connection=${alias}
    ${external_ip_interface}    strip string    string=${external_ip_interface}
    Start pcap trace capturing by tcpdump    log_name=${log_name}    interface=${external_ip_interface}    remote_log_dir=/tmp    alias=${alias}

Stop X2 log capture from gNB
    [Documentation]
    ...    Description: Stop X2 log capture on gNB, and download x2 log to testpc.
    ...                 X2log on gNB will be deleted if ${remove_remote_file} is set to True.
    ...                 If file already exist on testPC, and ${overwrite_local_file} is set to False, it won't be downloaded again.
    ...    :param ${local_dir}: dir on test pc to put downloaded file.
    ...    :param ${local_file_name}: if ${None}, downloaded file will use same file name from remote;
    ...                              if specified, downloaded file will be renamed to ${local_file_name}.
    ...    :return: file path on test pc.
    [Arguments]    ${log_name}=gnbX2    ${log_path}=${output_dir}    ${alias}=ASIK Master    ${local_file_name}=${None}
    ...    ${overwrite_local_file}=${True}    ${remove_remote_file}=${True}
    ${remote_log_path}    join path    /tmp    ${log_name}.pcap
    run keyword and continue on failure    Trace capturing process should be triggered    log_prefix=${log_name}    connection_alias=${alias}
    Stop trace capturing    log_prefix=${log_name}    connection_alias=${alias}
    ${local_log_path}    Download file to testPC    remote_file_path=${remote_log_path}    connection=${alias}    local_dir=${log_path}
    ...    local_file_name=${local_file_name}    overwrite_local_file=${overwrite_local_file}    remove_remote_file=${remove_remote_file}
    [Return]    ${local_log_path}
    [Teardown]    ssh.disconnect    connection=${alias}

Download file to testPC
    [Documentation]
    ...    Download file to test pc. Remote file will be deleted if ${remove_remote_file} is set to True.
    ...    If file already exist on testPC, and ${overwrite_local_file} is set to False, it won't be downloaded again.
    ...    :param ${remote_file_path}: file path on remote connection.
    ...    :param ${local_dir}: dir on test pc to put downloaded file.
    ...    :param ${local_file_name}: if ${None}, downloaded file will use same file name from remote;
    ...                              if specified, downloaded file will be renamed to ${local_file_name}.
    ...    :return: file path on test pc.
    [Arguments]     ${remote_file_path}    ${connection}    ${local_dir}=${output_dir}    ${local_file_name}=${None}
    ...    ${overwrite_local_file}=${True}    ${remove_remote_file}=${True}
    ${log_name}    fetch_from_right    string=${remote_file_path}    marker=/
    ${local_file_path}    run keyword if    '${local_file_name}'=='${None}'
    ...            join path    ${local_dir}    ${log_name}
    ...    ELSE    join path    ${local_dir}    ${local_file_name}
    ${is_file_exist}    run keyword and return status     file should exist    ${local_file_path}
    run keyword if    '${overwrite_local_file}'=='${False}' and '${is_file_exist}'=='${True}'    run keywords
    ...    log to console    File already exist, will not download again, please be aware!    AND
    ...    return from keyword    ${local_file_path}
    run keyword if    '${overwrite_local_file}'=='${True}' and '${is_file_exist}'=='${True}'
    ...    log to console    File already exist, will be overwrited, please be aware!
    csn.download_file   remote_path=${remote_file_path}   local_path=${local_file_path}   connection=${connection}
    run keyword if    ${remove_remote_file}    Delete file on remote machine    file_path=${remote_file_path}    connection=${connection}
    [Return]    ${local_file_path}

############################################TTI####################################################################
start tti trace
    [Documentation]
    ...    you can find stop tti and download tti keyword in resources/common/TTI_Trace.robot
    [Arguments]  ${hw_slot}=${1}    ${connection_for_abil}=${None}
    log to console  start capture tti trace
    Create default connection    hw_slot=${hw_slot}
    Start TTI trace log capturing    hw_slot=${hw_slot}    connection_for_abil=${connection_for_abil}
