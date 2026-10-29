*** Settings ***
Documentation
...   This is for logs keywords

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Library     ./lib/check_tcpdump_msg_item.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/symptom_collectors_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/l1l2bip_collect.robot
Resource    ./tti_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Cloud_VRAN40/AiC_log_Collect.robot


*** Keywords ***
__Keywords only for searching should not use
    [Documentation]    this keyword only for searching keywords in the robot, should not use.
    Start X2 log capture from eNB   # start tcpdump process and save to file
    Stop X2 log capture from eNB    # kill tcpdump and download log
    Start X2 log capture from gNB   # start tcpdump process and save to file
    Stop X2 log capture from gNB    # kill tcpdump and download log
    Stop trace capturing
    Download file to testPC

    Start tcpdump log on CU    # use taf.collector tcpdump_collector
    Start tcpdump log on asik master    # use taf.collector tcpdump_collector
    Stop tcpdump log collection    # use taf.collector tcpdump_collector

    start btslog capture
    stop btslog and collect logs
    Start btslog capturing    # use taf.collector btslog_collector
    Stop btslog capturing     # use taf.collector btslog_collector

    CU Collect Snapshot
    Get pdml log                  # get pdml log path
    Delete pdml log file
    Get field value
    Check msg item in tcpdump

    Start capture F1AP log
    Stop capture F1AP log
    Is Dual Core Enabled

Start pcap trace capturing by tcpdump
    [Documentation]    Author: Cui Lingxue  MMW_SG1
    ...     Start tcpdump process on ${interface}, save to file ${remote_log_dir}/${log_name}.
    [Arguments]   ${log_name}    ${interface}    ${remote_log_dir}=/tmp    ${alias}=ASIK Master
    ${remote_log_path}    join path    ${remote_log_dir}    ${log_name}.pcap
    csn.send command    command=nohup tcpdump -i ${interface} -s 0 -w ${remote_log_path}     connection=${alias}
    sleep    2s    reason=wait for process to start.
    Trace capturing process should be triggered    log_prefix=${log_name}    connection_alias=${alias}

Start X2 log capture from eNB
    [Documentation]    Author: Wang Yixiang
    ...     Start X2 log capture from eNB
    [Arguments]     ${log_name}=enbX2    ${interface}=br1    ${enb_index}=${0}    ${alias}=ENB
    wait until keyword succeeds    2 min    10 sec    Connect to eNB    alias=${alias}    enb_index=${enb_index}
    Start pcap trace capturing by tcpdump    log_name=${log_name}    interface=${interface}    remote_log_dir=/tmp    alias=${alias}

Start X2 log capture from gNB
    [Documentation]    Author: Cui Lingxue  MMW_SG1
    ...    Description: Start X2 log capture on gNB.
    ...                 Will start tcpdump process to capture on interface which has the external IP addr.
    [Arguments]     ${log_name}=gnbX2    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
    ${external_ip_addr}    set variable    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    Connect to Common Unit Master    alias=${alias}    gnb_index=${gnb_index}    du_index=${du_index}
    ssh.send_command    command=ifconfig | grep -B1 "${external_ip_addr}" | head -n 1 | awk -F':' '{print $1}'    connection=${alias}
    ${external_ip_interface}    ssh.read_output    connection=${alias}
    ${external_ip_interface}    strip string    string=${external_ip_interface}
    Start pcap trace capturing by tcpdump    log_name=${log_name}    interface=${external_ip_interface}    remote_log_dir=/tmp    alias=${alias}

Stop X2 log capture from eNB
    [Documentation]    Author: Cui Lingxue  MMW_SG1
    [Arguments]    ${log_name}=enbX2    ${log_path}=${TS_CASE_LOG_PATH}    ${alias}=ENB    ${local_file_name}=${None}
    ...    ${overwrite_local_file}=${True}    ${remove_remote_file}=${True}
    ${local_log_path}    Stop X2 log capture from gNB    log_name=${log_name}    log_path=${log_path}    alias=${alias}
    ...    overwrite_local_file=${overwrite_local_file}    remove_remote_file=${remove_remote_file}    local_file_name=${local_file_name}
    [Return]    ${local_log_path}

Stop X2 log capture from gNB
    [Documentation]    Author: Cui Lingxue  MMW_SG1
    ...    Description: Stop X2 log capture on gNB, and download x2 log to testpc.
    ...                 X2log on gNB will be deleted if ${remove_remote_file} is set to True.
    ...                 If file already exist on testPC, and ${overwrite_local_file} is set to False, it won't be downloaded again.
    ...    :param ${local_dir}: dir on test pc to put downloaded file.
    ...    :param ${local_file_name}: if ${None}, downloaded file will use same file name from remote;
    ...                              if specified, downloaded file will be renamed to ${local_file_name}.
    ...    :return: file path on test pc.
    [Arguments]    ${log_name}=gnbX2    ${log_path}=${TS_CASE_LOG_PATH}    ${alias}=ASIK Master    ${local_file_name}=${None}
    ...    ${overwrite_local_file}=${True}    ${remove_remote_file}=${True}
    ${remote_log_path}    join path    /tmp    ${log_name}.pcap
    run keyword and continue on failure    Trace capturing process should be triggered    log_prefix=${log_name}    connection_alias=${alias}
    Stop trace capturing    log_prefix=${log_name}    connection_alias=${alias}
    ${local_log_path}    Download file to testPC    remote_file_path=${remote_log_path}    connection=${alias}    local_dir=${log_path}
    ...    local_file_name=${local_file_name}    overwrite_local_file=${overwrite_local_file}    remove_remote_file=${remove_remote_file}
    [Return]    ${local_log_path}

Download file to testPC
    [Documentation]    Author: Cui Lingxue  MMW_SG1
    ...    Download file to test pc. Remote file will be deleted if ${remove_remote_file} is set to True.
    ...    If file already exist on testPC, and ${overwrite_local_file} is set to False, it won't be downloaded again.
    ...    :param ${remote_file_path}: file path on remote connection.
    ...    :param ${local_dir}: dir on test pc to put downloaded file.
    ...    :param ${local_file_name}: if ${None}, downloaded file will use same file name from remote;
    ...                              if specified, downloaded file will be renamed to ${local_file_name}.
    ...    :return: file path on test pc.
    [Arguments]     ${remote_file_path}    ${connection}    ${local_dir}=${TS_CASE_LOG_PATH}    ${local_file_name}=${None}
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

Delete file on remote machine
    [Documentation]    Author: Cui Lingxue  MMW_SG1
    ...    Delete file ${file_path} on remote ${connection}, connection should be setup in advance.
    ...    Will verify if file is successfully removed.
    [Arguments]    ${file_path}    ${connection}
    csn.execute    command=rm ${file_path}    connection=${connection}
    sleep    1s    msg=Wait for removing file.
    ${check_file_existence}    csn.execute    command=ls ${file_path}    connection=${connection}
    should contain    container=${check_file_existence}    item=No such file or directory

########################################## F1AP ######################################
_start tcpdump collectors
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${tcpdump_collector_name}    ${executor}    ${options}
    tcpdump.create_tcpdump_collector    name=${tcpdump_collector_name}   options=-p ${options}   executor=${executor}
    tcpdump.Set Suite Alias             ${tcpdump_collector_name}
    core.setup_collectors               names=${tcpdump_collector_name}
    core.start_collectors               names=${tcpdump_collector_name}

Is Dual Core Enabled
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection_alias}=ASIK Master
    ${cpif_output}    csn.Execute    command=cat /ram/NrCellMappingInfo.txt |grep CP-IF |awk '{print $2}'    connection=${connection_alias}
    ${cprt_output}    csn.Execute    command=cat /ram/NrCellMappingInfo.txt |grep CP-RT |awk '{print $2}'    connection=${connection_alias}
    ${cpif_id}    Get Regexp Matches    ${cpif_output}    0x(..)    1
    ${cprt_id}    Get Regexp Matches    ${cprt_output}    0x(..)    1
    ${is_dual_core_enabled}    Set Variable If    ${cpif_id}[0]!=${cprt_id}[0]    ${True}    ${False}
    [Return]    ${is_dual_core_enabled}

Start tcpdump log on asik master
    [Arguments]         ${gnb_id}=0       ${du_id}=0    ${asik_alias}=ASIK Master    ${tcpdump_collector_name}=Asik_tcpdump    ${options}=-i any
    [Documentation]     Author: Wang Yixiang
    ...                 create tcpdump log collection on ASIK VM.
    ...                 gnb_id: gnb_id default value:0
    ...                 name: name of the collector. Ex: Asik_tcpdump
    ...                 options: (optional) tcpdump options (except for “-w”), default: empty string
    ...                 stop tcpdump can use:Stop tcpdump log collection (container_log_capturing.robot)
    ...                 2024-11-29 Ding Binmei: Refine keyword to support for dual core
    ${is_dual_core}    Is Dual Core Enabled    connection_alias=${asik_alias}
    ${is_amia_left}    If GNB In Left Side Of AMIA    connection=${asik_alias}
    ${host_ip}    Set variable    ${tl.gnbs[${gnb_id}].dus[${du_id}].f1_m_ip_addr}
    ${user_name}    Set variable    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[0].lmp_connection.username}
    ${password}    Set variable    ${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[0].lmp_connection.password}
    &{primary_core_config}    create dictionary    host=${host_ip}    user=${user_name}    password=${password}
    _start tcpdump collectors    tcpdump_collector_name=${tcpdump_collector_name}    executor=${primary_core_config}    options=${options}

#    Collect log on secondly core if env is dual core
    ${secondly_core_host_name}    Set variable if    ${is_amia_left}    fct4s0icom.local    fct0s0icom.local
    ${secondly_core_config}    Run keyword if    ${is_dual_core}
    ...    Create dictionary    host=${secondly_core_host_name}    user=${user_name}    password=${password}    proxy=${primary_core_config}
    ${tcpdump_collector_name_secondly_core}    Run keyword if    ${is_dual_core}    Set variable    ${tcpdump_collector_name}_secondly_core
    run keyword if    ${is_dual_core}
    ...    _start tcpdump collectors    tcpdump_collector_name=${tcpdump_collector_name_secondly_core}
    ...    executor=${secondly_core_config}    options=${options}

Start tcpdump log on asik slave
    [Arguments]         ${gnb_id}=0       ${tcpdump_collector_name}=slave_tcpdump    ${options}=-i any
    ...     ${asik_alias}=ASIK Master
    [Documentation]     Author: Wang Yixiang
    ...                 The keyword is same as capture container log on asik slave
    ...                 create tcpdump log collection on ASIK VM.
    ...                 gnb_id: gnb_id default value:0
    ...                 name: name of the collector. Ex: slave_tcpdump
    ...                 options: (optional) tcpdump options (except for “-w”), default: empty string
    ...                 stop tcpdump can use:Stop tcpdump log collection (container_log_capturing.robot)
    ${amia_left}    If GNB In Left Side Of AMIA    connection=${asik_alias}
    ${slave_host_ip}    set variable if    ${amia_left}    192.168.253.17     192.168.253.33
    &{oam_config}=   create dictionary     host=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ...                                    user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                                    password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    &{vm_config}=  create dictionary       host=${slave_host_ip}
    ...                                    user=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.username}
    ...                                    password=${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ...                                    proxy=${oam_config}
    tcpdump.create_tcpdump_collector    name=${tcpdump_collector_name}   options=-p ${options}   executor=${vm_config}
    tcpdump.Set Suite Alias             ${tcpdump_collector_name}
    core.setup_collectors               names=${tcpdump_collector_name}
    core.start_collectors               names=${tcpdump_collector_name}

Start capture F1AP log for classical
    [Arguments]         ${gnb_id}=0       ${tcpdump_collector_name}=f1ap    ${options}=-i any sctp
    ...     ${asik_alias}=ASIK Master
    Connect to Common Unit Master    alias=${asik_alias}    gnb_index=${gnb_id}
    ${smod_type}    Get hardware type    alias=${asik_alias}
    run keyword if    '${smod_type}'=='ASIK'    Start tcpdump log on asik slave    gnb_id=${gnb_id}
    ...    tcpdump_collector_name=${tcpdump_collector_name}    options=${options}    asik_alias=${asik_alias}
    ...    ELSE    Start tcpdump log on asik master   gnb_id=${gnb_id}    tcpdump_collector_name=${tcpdump_collector_name}
    ...            options=${options}    asik_alias=${asik_alias}

Start capture F1AP log
    [Documentation]  Author: Ding Binmei
    ...    Adapt for both classical and cloud
    [Arguments]         ${gnb_id}=0       ${tcpdump_collector_name}=gnb${gnb_id}_f1ap    ${options}=-i any sctp
    ...     ${asik_alias}=ASIK Master
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}    AIC_log_collect_via_webEM.Start F1AP log capture via webEM    gnb_index=${gnb_id}
    ...    ELSE    Start capture F1AP log for classical    gnb_id=${gnb_id}    tcpdump_collector_name=${tcpdump_collector_name}
    ...        options=${options}    asik_alias=${asik_alias}

Stop capture F1AP log
    [Documentation]    Author: Ding Binmei
    ...    Adapt for both classical and cloud.
    ...    Stop log capture and download log to ${target_dir}, return f1ap log path.
    [Arguments]    ${gnb_id}=0    ${tcpdump_collector_name}=gnb${gnb_id}_f1ap    ${asik_alias}=ASIK Master
    ...    ${target_dir}=${TS_CASE_LOG_PATH}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${f1ap_log_path}    Run keyword if    ${has_cbts}    AIC_log_collect_via_webEM.Stop F1AP log capture via webEM
    ...    gnb_index=${gnb_id}    target_dir=${target_dir}
    ...    ELSE    Stop capture F1AP log for classical    gnb_id=${gnb_id}
    ...    tcpdump_collector_name=${tcpdump_collector_name}    asik_alias=${asik_alias}    target_dir=${target_dir}
    [Return]    ${f1ap_log_path}

Teardown F1AP log capture
    [Documentation]    Author: Ding Binmei
    ...    Teardown keyword for F1AP log capture, consider for both classical and cloud.
    ...    Release resources in teardown, no return.
    [Arguments]    ${gnb_id}=0    ${tcpdump_collector_name}=gnb${gnb_id}_f1ap    ${asik_alias}=ASIK Master
    Connect to Common Unit Master    alias=${asik_alias}    gnb_index=${gnb_id}
    ${is_dual_core}    Is Dual Core Enabled    connection_alias=${asik_alias}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}    AIC_log_collect_via_webEM.Release IP traffic capture connections on vcu in teardown    gnb_index=${gnb_id}
    ...    ELSE    _Stop Tcpdump via collector consider for dual core    collector_name=${tcpdump_collector_name}
    ...    is_dual_core=${is_dual_core}

Stop capture F1AP log for classical
    [Documentation]    Author: Ding Binmei
    ...    2024-11-29    Extend keyword to support for dual core
    [Arguments]         ${gnb_id}=0       ${tcpdump_collector_name}=gnb${gnb_id}_f1ap    ${asik_alias}=ASIK Master
    ...    ${target_dir}=${TS_CASE_LOG_PATH}
    Connect to Common Unit Master    alias=${asik_alias}    gnb_index=${gnb_id}
    ${is_dual_core}    Is Dual Core Enabled    connection_alias=${asik_alias}
    ${f1ap_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}    target_dir=${target_dir}
    File Should Not Be Empty    ${f1ap_log_path}    msg=No F1AP log captured!
    Return from keyword if    ${is_dual_core}==${False}    ${f1ap_log_path}
    ${tcpdump_collector_name_secondly_core}    Run keyword if    ${is_dual_core}    Set variable    ${tcpdump_collector_name}_secondly_core
    ${f1ap_log_path_secondly_core}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name_secondly_core}
    ...    target_dir=${target_dir}
    ${f1ap_log_name_combined}    Set variable    ${tcpdump_collector_name}_combined.pcap
    ${f1ap_log_path_combined}    Join Path    ${target_dir}    ${f1ap_log_name_combined}
    OperatingSystem.Run   command=mergecap -w ${f1ap_log_path_combined} ${f1ap_log_path} ${f1ap_log_path_secondly_core}
    File Should Not Be Empty    ${f1ap_log_path_combined}    msg=No F1AP log captured!
    ${f1ap_log_name_primary_core}    Fetch From Right    ${f1ap_log_path}    marker=/
    ${f1ap_log_path_folder_primary_core}    Replace String    ${f1ap_log_path}    ${f1ap_log_name_primary_core}    ${EMPTY}
    ${f1ap_log_name_secondly_core}    Fetch From Right    ${f1ap_log_path_secondly_core}    marker=/
    ${f1ap_log_path_folder_secondly_core}    Replace String    ${f1ap_log_path_secondly_core}  ${f1ap_log_name_secondly_core}  ${EMPTY}
    Run Keyword And Ignore Error    Run keyword if    ${is_dual_core}    Run keywords
    ...    Remove Directory    ${f1ap_log_path_folder_primary_core}    recursive=${True}    AND
    ...    Remove Directory    ${f1ap_log_path_folder_secondly_core}    recursive=${True}
    [Return]     ${f1ap_log_path_combined}
    [Teardown]    Run Keyword And Ignore Error    _Stop Tcpdump via collector consider for dual core    collector_name=${tcpdump_collector_name}
    ...    is_dual_core=${is_dual_core}

_Stop Tcpdump via collector consider for dual core
    [Documentation]    Author: Ding Binmei
    [Arguments]      ${collector_name}    ${is_dual_core}=${False}
    Stop Tcpdump via collector    collector_name=${collector_name}
    ${tcpdump_collector_name_secondly_core}    Run keyword if    ${is_dual_core}    Set variable    ${tcpdump_collector_name}_secondly_core
    run keyword if    ${is_dual_core}    Stop Tcpdump via collector    collector_name=${tcpdump_collector_name_secondly_core}

Start X2 log capture on gNB CU
    [Documentation]    Author: Cui Lingxue
    ...                start tcpdump log collection to capture X2 log on interface-x2 of cpif vm on CU.
    ...                gnb_id: gnb_id default value:0
    ...                x2_log_name: name of the collector. Ex: x2_log_cu
    [Arguments]    ${x2_log_name}=x2_log_cu    ${gnb_id}=0
    Start tcpdump log on CU    tcpdump_collector_name=${x2_log_name}    vm_name=cpif-0.local    options=-i x2    gnb_id=${gnb_id}

Start F1 log capture on gNB CU
    [Documentation]    Author: Cui Lingxue
    ...                start tcpdump log collection to capture F1 log on interface-fronthaul of cpif vm on CU.
    ...                gnb_id: gnb_id default value:0
    ...                f1_log_name: name of the collector. Ex: f1_log_cu
    [Arguments]    ${f1_log_name}=f1_log_cu    ${gnb_id}=0
    Start tcpdump log on CU    tcpdump_collector_name=${f1_log_name}    vm_name=cpif-0.local    options=-i fronthaul    gnb_id=${gnb_id}

Get pdml log
    [Documentation]   author: Wang Yixiang
    ...    get pdml log path
    ...    tcpdump_log: should be like this: path/filename.pcap
    ...    [2021-12-07 Lingxue]: refactor this kw due to taf.ul.parser.pcap migrate to taf.analyzer.pcap.
    ...                          Pdml file will be converted from tcpdump pcap file with filter.
    [Arguments]    ${tcpdump_log}    ${filter}=f1ap||x2ap||e1ap||s1ap||ngap
    ${tcpdump_path_filename}    ${tcpdump_ext}    Split Extension     ${tcpdump_log}
    ${full_log_path}    set variable    ${tcpdump_path_filename}.pdml
    FOR    ${i}    IN RANGE    ${3}
        ${rc}    ${output}    Run And Return Rc And Output    tshark -r ${tcpdump_log} -Y '${filter}' -T pdml > ${full_log_path}
        exit for loop if    '${rc}' == '${0}'
    END
    run keyword and continue on failure    File Should Exist    ${full_log_path}
    ${file_exist}    run keyword and return status    File Should Exist    ${full_log_path}
    run keyword if    ${file_exist}     set test variable    ${PDML_LOG_PATH_TESTCASE}    ${full_log_path}
    should be equal    ${rc}    ${0}    msg=Pcap convert to pdml file failed!
    [Return]    ${full_log_path}

Delete pdml log file
    [Documentation]  Author: Ding Binmei
    ...    tcpdump_log_file_path: should be like this: path/filename.pcap
    [Arguments]    ${tcpdump_log_file_path}
    ${pdml_log_file_path}    Get pdml log     tcpdump_log=${tcpdump_log_file_path}
    Remove file    ${pdml_log_file_path}
    File should not exist  path=${pdml_log_file_path}

Load pcap file with filter
    [Documentation]    Author: Cui Lingxue  MMW_SG1
    ...    Convert pcap file to pdml format with user input filter.
    ...    :param ${log_path_pcap}: path of pcap file
    ...    :param ${filter}: filter that can be used in wireshark. Use ${None} if not needed.
    ...    :param ${tshark_path}: path of executable file tshark. Location is /usr/bin/tshark by default. Use ${None} if not needed.
    ...    :param ${lua_script}: path of luashark file, eg /opt/ute/luashark/generated_luashark/luashark.lua. Use ${None} if not needed.
    ...    :return: all packets in the pcap log with PdmlLogEntry format
    [Arguments]    ${log_path_pcap}    ${filter}=f1ap||x2ap||e1ap||s1ap||ngap    ${tshark_path}=${None}    ${lua_script}=${None}
    ${pdml_template}    set variable if    '${filter}'=='${None}' and '${lua_script}'=='${None}'
    ...        {tshark_path} -r {pcap_file} -T pdml
    ...    '${filter}'=='${None}' and '${lua_script}'!='${None}'
    ...        {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -T pdml
    ...    '${filter}'!='${None}' and '${lua_script}'=='${None}'
    ...        {tshark_path} -r {pcap_file} -Y \"${filter}\" -T pdml
    ...    '${filter}'!='${None}' and '${lua_script}'!='${None}'
    ...        {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y \"${filter}\" -T pdml
    ${pdml_list}    cap.load_pcap_file    pcap_file=${log_path_pcap}    command_template=${pdml_template}
    ...    luashark_path=${lua_script}    tshark_path=${tshark_path}
    [Return]    ${pdml_list}

start btslog capture
    [Documentation]    Author: Cui Lingxue
    ...    Description: all existing btslog process will be killed before starting btslog capturing.
    ...    :paras:${name}:
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
    ...    ${log_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}    ${start_timeout}=${60}
    kill btslog process
    Create_Btslog_log_collection_on_remote_machine    name=${name}    btslog_path=${btslog_path}    start_timeout=${start_timeout}
    ...    btslog_launcher_path=${btslog_launcher_path}    log_dir=${log_dir}    host=${host}
    wait until keyword succeeds    5s    100ms    btslog process should be started

stop btslog and collect logs
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${status}    ${name}=btslog    ${target_dir}=${TS_CASE_LOG_PATH}
    core.stop_collectors      names=${name}
    sleep    10 sec
    Run keyword if    '${status}' == 'FAIL'    core.collect_collectors   names=${name}    target_dir=${target_dir}
	core.teardown_collectors    names=${name}

is btslog process exist
    [Documentation]    Author: Cui Lingxue
    ...    Check if the btslog process exist.
    ${check_process}    run    ps -ef | grep btslog | grep -v grep
    ${check_process}    strip string    ${check_process}
    ${process_length}    get length     ${check_process}
    ${is_process_exist}    set variable if    ${process_length}!=0    ${True}    ${False}
    [Return]    ${is_process_exist}

btslog process should be killed
    [Documentation]    Author: Cui Lingxue
    ...    check if btslog process is killed.
    ${is_process_exist}    Is btslog process exist
    should be true    ${is_process_exist}==${False}

btslog process should be started
    [Documentation]    Author: Cui Lingxue
    ...    check if btslog process is started.
    ${is_process_exist}    Is btslog process exist
    should be true    ${is_process_exist}==${True}

kill btslog process
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${retry_time}=${10}
    FOR    ${i}    IN RANGE    ${retry_time}
        run    ps -ef | grep -v grep | grep btslog | awk '{print $2}' | xargs kill -9
        ${is_btslog_process_killed}    run keyword and return status    wait until keyword succeeds    5s    100ms
        ...    btslog process should be killed
        exit for loop if    ${is_btslog_process_killed}==${True}
    END
    should be true    ${is_btslog_process_killed}==${True}

Check msg item in tcpdump
    [Documentation]   author: Wang Yixiang
    ...    Check message item in tcpdump
    ...    xxx==1 means string appeared one time
    ...    ${msg_file} content should define like following:
    ...    sCellToAddModList: 1 item
    ...    nr-rrc.c1.*c1: rrcReconfigurationComplete
    ...    SgNBAdditionRequest==1
    ...    SgNBReconfigurationComplete>=2
    ...    SgNBReleaseRequest|SgNBReleaseRequired
    ...    SNStatusTransfer>1
    ...    !UEContextRelease
    [Arguments]    ${tcpdump_log}    ${msg_file}    ${filter}=f1ap||nr-rrc||ngap
    ${pdml_log_path}    Get pdml log    tcpdump_log=${tcpdump_log}    filter=${filter}
    check_msg_item_tcpdump    msg_file=${msg_file}   tcpdump_pdml=${pdml_log_path}

Verify msgs type and detail IEs in sequence in tcpdump log
    [Documentation]   Author: Cui Lingxue
    ...    :param msg_checkpoint: list of msgs to be verified, should be in desired order.
    ...       Each element represent the xpath which could find the corresponding msg.
    ...       eg: PSCELL_CHANGE_SRB1 = [xpath_x2ap_SgnbAddReq, xpath_f1ap_UeCxtSetupReq]
    ...       xpath_x2ap_SgnbAddReq = 'x2ap//..//x2ap.SgNBAdditionRequest_element'
    ...    :param ${log_path_pcap}: path of pcap file
    ...    :param ${filter}: filter that can be used in wireshark. Use ${None} if not needed.
    ...    :param ${tshark_path}: path of executable file tshark. Location is /usr/bin/tshark by default. Use ${None} if not needed.
    ...    :param ${lua_script}: path of luashark file, eg /opt/ute/luashark/generated_luashark/luashark.lua. Use ${None} if not needed.
    ...    :return: all packets in the pcap log with PdmlLogEntry format
    [Arguments]    ${msg_checkpoint}    ${log_path_pcap}    ${detail_ie_filters}=${None}
    ...    ${filter}=f1ap||x2ap||e1ap||s1ap||ngap||xnap||xnap_16_5_0_2103_n03||xnap_16_7_0_2109_n03
    ...    ${tshark_path}=${None}    ${lua_script}=${None}

    ${status}    ${log_path_pdml}    run keyword and ignore error    Get pdml log    tcpdump_log=${log_path_pcap}    filter=${filter}
    ${filter}    set variable if    '${status}'=='FAIL'    f1ap||x2ap||e1ap||s1ap||ngap||xnap||xnap_16_5_0_2103_n03
    ${log_path_pdml}    run keyword if    '${status}'=='FAIL'    Get pdml log    tcpdump_log=${log_path_pcap}    filter=${filter}
    ...    ELSE    set variable    ${log_path_pdml}
    ${packet_list}    run keyword and continue on failure    verify_msg_type_and_seq_in_pdml
    ...    log_path_pdml=${log_path_pdml}    filters=${msg_checkpoint}
    run keyword if    ${detail_ie_filters}!=${None}
    ...    verify_detail_msg_ie_in_packet    packet_list=${packet_list}  detail_ie_filters=${detail_ie_filters}

Prepare Preference file for wireshark
    [Documentation]    Author: Cui Lingxue
    [Arguments]    ${preference_filepath}
    run    sudo cp ${preference_filepath} /home/ute/.config/wireshark/preferences
    run    sudo cp ${preference_filepath} /usr/share/wireshark/preferences
    FOR    ${i}    IN RANGE    ${3}
        ${check_file_existence}    run    ls /home/ute/.config/wireshark/preferences /usr/share/wireshark/preferences
        ${file_exist}    run keyword and return status    should not contain    ${check_file_existence}    No such file or directory
        exit for loop if    ${file_exist}
        sleep    1s
    END
    should be true    ${file_exist}

Remove Preference file for wireshark
    [Documentation]    Author: Cui Lingxue
    run    sudo rm /home/ute/.config/wireshark/preferences
    run    sudo rm /usr/share/wireshark/preferences
    FOR    ${i}    IN RANGE    ${3}
        ${check_file_existence}    run    ls /home/ute/.config/wireshark/preferences /usr/share/wireshark/preferences
        ${file_removed}    run keyword and return status    should contain    ${check_file_existence}    No such file or directory
        exit for loop if    ${file_removed}
        sleep    1s
    END
    should be true    ${file_removed}

BIP log capture and download with new name
    [Documentation]    Author: Cui Lingxue
    ...    This kw is to capture BIP log and download them to control PC.
    ...    The downloaded BIP files will be renamed to user custom name defined by ${bip_log_name}.
    ...    Note: Capture on mix config of ABIL and ABIO(or ABIN) is not supported.
    [Arguments]    ${bip_log_name}    ${bb_slot_1}=true    ${bb_slot_2}=false
    ...    ${bip_capture_time}=10s    ${bip_file_number}=${2}    ${file_size_mbytes}=100    ${local_log_dir}=${TS_CASE_LOG_PATH}
    ...    ${asib_interface}=eth    ${asil_interface}=eth
    connect to common unit master
    log to console    Capture BIP log\n
    Bip Capture with gnbMirroring scripts with retry    bb_slot_1=${bb_slot_1}    bb_slot_2=${bb_slot_2}   add_mirror_port=true
    ...   number_of_files=${bip_file_number}    sleep_time=5s    file_size_mbytes=${file_size_mbytes}    check_times=${30}
    sleep    ${bip_capture_time}
    ${bip_log_list}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    asib_interface=${asib_interface}
    ...    asil_interface=${asil_interface}
    ${bip_log_list_renamed}    create list
    FOR    ${index}    ${bip_file}    IN ENUMERATE    @{bip_log_list}
        ${timestamp}    fetch from right    ${bip_file}    marker=_
        ${bip_log_path}    join_path    ${local_log_dir}    bip_log_${bip_log_name}_0${index}_${timestamp}
        run    mv ${bip_file} ${bip_log_path}
        run keyword and continue on failure    should_exist    ${bip_log_path}
        append to list    ${bip_log_list_renamed}    ${bip_log_path}
    END
    Connect to gnb coam via ssl
    [Return]    ${bip_log_list_renamed}

Start Bip Capture for different program
    [Documentation]  start bip cature by gnbMirroring.sh on branchs before 22R4;
    ...              Following paramters are needed:
    ...             ${connection}: default value is "ASIK Master"
    ...             ${mirroring_mode}: target path to store bip files
    ...             ${bb_slot_1}: default value is "true"
    ...             ${bb_slot_2}: default value is "false"
    ...             ${bb_slot_3}: default value is "false"
    ...             ${bb_slot_5}: default value is "false"
    ...             ${bb_slot_6}: default value is "false"
    ...             ${bb_slot_7}: default value is "false"
    ...             ${l2_l1_bip}: default value is "true"
    ...             ${syscom_mirroring}: default value is "true"
    ...             ${carrier_aggregation}: default value is "false"
    ...             ${gnb_index}: default value is 0
    ...             ${du_index}: default value is 0
    ...             ${backhaul_mirroring}: default value is "false"
    ...             ${l2hi_l2lo_mirroring}: default value is "false"
    ...             ${filtering}: default value is "off"
    ...             ${use_gulp}: default value is "false"
    ...             ${capturing_time_seconds}: default value is "infinite"
    ...             ${number_of_files}: default value is "1"
    ...             ${file_size_mbytes}=: default value is "100"
    ...             ${xtrace}: default value is "off"
    ...             ${retry_time}: default value is "10"
    ...             ${sleep_time}: default value is "10s"
    ...             ${add_mirror_port}: default value is "false"
    ...             ${bip_prefix}: generated bip file name prefix, default value is "tcpdump_L2L1"
    ...             ${oam_connection}: default value is "GNB_OAM"
    ...             ${check_times}: default value is 20
    ...             ${is_capture_right_bbmod}: default value is false
    ...
    ...             on branch 22R4 or after 22R4, will use admincli to capture bip logs.
    ...             Following paramters are needed:
    ...             ${target_file_name}: generated bip file name, default value is "l1l2bip_log"
    ...             ${nr_phy_cell_ids}: e.g. 50,51, (Select max 8 cells), default value is "None", means collect the logs of all cells.
    ...             ${gnb_index}: default value is 0
    ...             ${timeout}: mirroring time, default value is "600"
    ...             ${interface}: default value is "L1-L2"
    ...             ${destination}: default value is "Local"
    ...             ${host_ip}: gnb oam ip, default value is ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...             ${username}: gnb oam username, default value is ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...             ${password}: gnb oam password, default value is ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    [Arguments]        ${connection}=ASIK Master    ${mirroring_mode}=local    ${bb_slot_1}=true    ${bb_slot_2}=false
    ...                ${bb_slot_3}=false    ${bb_slot_5}=false    ${bb_slot_6}=false    ${bb_slot_7}=false
    ...                ${l2_l1_bip}=true    ${syscom_mirroring}=true    ${carrier_aggregation}=false    ${du_index}=${0}
    ...                ${backhaul_mirroring}=false    ${l2hi_l2lo_mirroring}=false    ${filtering}=off    ${use_gulp}=false
    ...                ${capturing_time_seconds}=infinite    ${number_of_files}=1    ${file_size_mbytes}=100
    ...                ${xtrace}=off    ${retry_time}=10    ${sleep_time}=10s    ${add_mirror_port}=false    ${bip_prefix}=tcpdump_L2L1
    ...                ${oam_connection}=GNB_OAM    ${check_times}=${20}   ${is_capture_right_bbmod}=${False}
    ...                ${target_file_name}=l1l2bip_log
    ...                ${nr_phy_cell_ids}=${None}    ${gnb_index}=0    ${timeout}=600    ${interface}=L1-L2    ${destination}=Local
    ...                ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...                ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...                ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}

    run keyword if    '${PROGRAM}'=='22R2' or '${PROGRAM}'=='22R3' or '${PROGRAM}'=='22R1'
    ...    Bip Capture with gnbMirroring scripts with retry
    ...                connection=${connection}    mirroring_mode=${mirroring_mode}    bb_slot_1=${bb_slot_1}    bb_slot_2=${bb_slot_2}
    ...                bb_slot_3=${bb_slot_3}    bb_slot_5=${bb_slot_5}    bb_slot_6=${bb_slot_6}    bb_slot_7=${bb_slot_7}
    ...                l2_l1_bip=${l2_l1_bip}    syscom_mirroring=${syscom_mirroring}    carrier_aggregation=${carrier_aggregation}
    ...                du_index=${du_index}    backhaul_mirroring=${backhaul_mirroring}    l2hi_l2lo_mirroring=${l2hi_l2lo_mirroring}
    ...                filtering=${filtering}   use_gulp=${use_gulp}    capturing_time_seconds=${capturing_time_seconds}
    ...                number_of_files=${number_of_files}    file_size_mbytes=${file_size_mbytes}    xtrace=${xtrace}
    ...                retry_time=${retry_time}    sleep_time=${sleep_time}    add_mirror_port=${add_mirror_port}
    ...                bip_prefix=${bip_prefix}    oam_connection=${oam_connection}    check_times=${check_times}
    ...                gnb_index=${gnb_index}     is_capture_right_bbmod=${is_capture_right_bbmod}
    ...    ELSE   Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}   nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                gnb_index=${gnb_index}    timeout=${timeout}    interface=${interface}    destination=${destination}
    ...                host_ip=${host_ip}    username=${username}    password=${password}


Stop Bip Capture and Collect logs for different program
    [Documentation]  stop bip cature by gnbMirroring.sh on branchs before 22R4;
    ...              Following paramters are needed:
    ...             ${interface}: default value is "pepbp1"
    ...             ${connection}: default value is "ASIK Master"
    ...             ${log_path}: target path to store bip files
    ...             ${download_type}: default value is "Download"
    ...             ${gnb_index}: default value is 0
    ...             ${du_index}: default value is 0
    ...             ${log_prefix}: default value is None
    ...             ${bip_prefix}: generated bip file name prefix, default value is "tcpdump_L2L1"
    ...             ${is_capture_right_bbmod}: default value is false
    ...             ${asib_interface}: default value is eths2
    ...             ${asil_interface}: default value is ethbp1
    ...             ${kill_type}: default value is 2
    ...
    ...             on branch 22R4 or after 22R4, will use admincli to stop bip log and collect logs.
    ...             Following paramters are needed:
    ...             ${target_file_name}: generated bip file name, default value is "l1l2bip_log"
    ...             ${pattern}: matched file pattern, default value is "*.pcap"
    ...             ${target_dir}: target dir to store bip files, default value is ${TS_CASE_LOG_PATH}
    [Arguments]     ${interface}=pepbp1    ${connection}=ASIK Master
    ...             ${log_path}=${TS_CASE_LOG_PATH}    ${download_type}=Download   ${gnb_index}=${0}   ${du_index}=${0}
    ...             ${log_prefix}=${None}    ${bip_prefix}=tcpdump_L2L1    ${is_capture_right_bbmod}=${False}
    ...             ${asib_interface}=eths2    ${asil_interface}=ethbp1    ${kill_type}=2
    ...             ${pattern}=*.pcap    ${target_dir}=${TS_CASE_LOG_PATH}    ${target_file_name}=l1l2bip_log    ${is_return_original_file}=${False}

     ${bip_log_list}    run keyword if    '${PROGRAM}'=='22R2' or '${PROGRAM}'=='22R3' or '${PROGRAM}'=='22R1'
    ...    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    interface=${interface}    connection=${connection}
    ...             log_path=${log_path}    download_type=${download_type}   gnb_index=${gnb_index}   du_index=${du_index}
    ...             log_prefix=${log_prefix}    bip_prefix=${bip_prefix}    is_capture_right_bbmod=${is_capture_right_bbmod}
    ...             asib_interface=${asib_interface}    asil_interface=${asil_interface}    kill_type=${kill_type}
    ...    ELSE   Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}   pattern=${pattern}
    ...             target_dir=${target_dir}    is_return_original_file=${is_return_original_file}

    [Return]    ${bip_log_list}

Check messageInfo in aasyslog
    [Documentation]     Author: Wang Yixiang
    ...    collect aasyslog and check message in aasyslog
    [Arguments]    ${messageInfo}   ${timeout}=60s    ${local_log_folder}=${TS_CASE_LOG_PATH}
    ...    ${aasyslog_name}=aasyslog_message.txt
    Connect to Common Unit Master
    Wait Until Keyword Succeeds    ${timeout}    5 sec    Check message in aasyslog    messageInfo=${messageInfo}
    ...    aasyslog_name=${aasyslog_name}
    [Teardown]    Wait Until Keyword Succeeds   1 min  5 sec   csn.Download file
    ...    remote_path=/tmp/${aasyslog_name}   local_path=${local_log_folder}/${aasyslog_name}    connection=ASIK Master

Check message in aasyslog
    [Documentation]  Author: Wang Yixiang
    ...      check message info in aasyslog
    [Arguments]    ${messageInfo}    ${aasyslog_name}=aasyslog_message.txt
    ${Aal2lo_cmd}=    catenate    cat /tmp/${aasyslog_name}| grep -a "${messageInfo}" | grep -av grep
    ${output}    csn.execute    command=${Aal2lo_cmd}    connection=ASIK Master
    @{list}    split string    ${output}    \n
    Remove Values From List    ${list}   ${empty}
    ${len}    Get Length    ${list}
    should be true    ${len}>0    ${messageInfo} not found in aasyslog
