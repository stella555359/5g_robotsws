*** Settings ***
Documentation    This is for logs related common keywords.
...              Please do not modify the file without notification to author
...              Author: Chen Jun
...              Squard: HZ SG6
Library    taf.analyzer.pcap    WITH NAME    pcap
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.btslog     WITH NAME    btslog
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/l1l2bip_collect.robot

*** Variables ***
${NSETAP_WEB_PATH}    https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/NSETAP_X
${nsetapx_bakck_version}    ${NSETAP_WEB_PATH}/nsetapx-1.13.1/nsetapx-4.0-0.6.1-1.13.1+buster.so

*** Keywords ***
Start Container Capture Wireshark Log
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]      ${cprt_collector_name}=cprt_tcpdump
    ...              ${tcpdump_collector_name}=cpif_tcpdump
    ...              ${asik_connection_alias}=ASIK Master
    ...              ${gnb_index}=${0}
    ...              ${du_index}=${0}
    ...              ${filter_ports}=port 38472 or port 38412 or port 38462 or port 36422 or port 38422 or port 29211
    ...              ${options}=-p -i any ${filter_ports} -s 0
    ${version}    gnb_classical_hangzhou.Get program version based on stream version
    ssh.connect_to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${asik_connection_alias}
    ${is_dual_core_enabled}    Is Dual Core Enabled    connection_alias=${asik_connection_alias}
    Run Keyword If    ${is_dual_core_enabled} and '${version}'!='24R3' and '${version}'!='24R2'    Start Wireshark Log Collection
    ...                                                                            cprt_collector_name=${cprt_collector_name}
    ...                                                                            tcpdump_collector_name=${tcpdump_collector_name}
    ...                                                                            asik_connection_alias=${asik_connection_alias}
    ...                                                                            gnb_index=${gnb_index}
    ...                                                                            du_index=${du_index}
    ...                                                                            options=${options}
    ...    ELSE    Start CP-IF Log Collection    tcpdump_collector_name=${tcpdump_collector_name}
    ...                                          asik_connection_alias=${asik_connection_alias}
    ...                                          gnb_index=${gnb_index}
    ...                                          du_index=${du_index}
    ...                                          container_name=CPIF
    ...                                          options=${options}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=${asik_connection_alias}

Stop Container Wireshark Log Collection
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${cprt_collector_name}=cprt_tcpdump
    ...            ${tcpdump_collector_name}=cpif_tcpdump
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${gnb_index}=${0}
    ...            ${du_index}=${0}
    ${version}    gnb_classical_hangzhou.Get program version based on stream version
    ssh.connect_to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${asik_connection_alias}
    ${is_dual_core_enabled}    Is Dual Core Enabled    connection_alias=${asik_connection_alias}
    ${log_path}    Run Keyword If    ${is_dual_core_enabled} and '${version}'!='24R3' and '${version}'!='24R2'
    ...    Stop Wireshark Log Collection    cprt_collector_name=${cprt_collector_name}
    ...                                     tcpdump_collector_name=${tcpdump_collector_name}
    ...                                     target_dir=${target_dir}
    ...    ELSE    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}
    [Return]     ${log_path}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=${asik_connection_alias}

Is Dual Core Enabled
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${connection_alias}=ASIK Master
    ${cpif_output}    csn.Execute    command=cat /ram/NrCellMappingInfo.txt |grep CP-IF |awk '{print $2}'    connection=${connection_alias}
    ${cprt_output}    csn.Execute    command=cat /ram/NrCellMappingInfo.txt |grep CP-RT |awk '{print $2}'    connection=${connection_alias}
    ${cpif_id}    Get Regexp Matches    ${cpif_output}    0x(..)    1
    ${cprt_id}    Get Regexp Matches    ${cprt_output}    0x(..)    1
    ${is_dual_core_enabled}    Set Variable If    ${cpif_id}[0]!=${cprt_id}[0]    ${True}    ${False}
    [Return]    ${is_dual_core_enabled}

Start CP-RT Log Collection
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]      ${tcpdump_collector_name}=cprt_tcpdump    ${asik_connection_alias}=ASIK Master
    ...              ${options}=-i any -s 0    ${gnb_index}=${0}    ${du_index}=${0}
    ${asib_flag}    If ASIB card used    gnb_index=${gnb_index}    du_index=${du_index}    alias=${asik_connection_alias}
    ${is_left_enabled}    If GNB In Left Side Of AMIA    connection=${asik_connection_alias}
    ${local_node_id}    Set Variable If   ${is_left_enabled}    0x1011     0x2011
    ${is_feature_1948_enabled}    Is Feature 1948 Enabled    connection_alias=${asik_connection_alias}    local_node_id=${local_node_id}
    &{master_config}   create dictionary
    ...    host=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    user=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${another_core_host}    Set Variable If    ${is_left_enabled}    fct-4a    fct-0a
    &{master_config_for_another_node}    create dictionary
    ...    host=${another_core_host}
    ...    user=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    proxy=${master_config}
    ${master_config}    Set Variable    ${master_config_for_another_node}
    ${slave_host_ip}    Set Variable If    ${is_left_enabled}    192.168.253.17    192.168.253.33
    &{slave_config}    create dictionary
    ...    host=${slave_host_ip}
    ...    user=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    proxy=${master_config}
    ${executor_oam_vm}    Set Variable If
    ...    ${asib_flag}    ${master_config}
    ...    '${asib_flag}'=='${False}' and '${is_feature_1948_enabled}'=='${True}'    ${slave_config}
    ...    '${asib_flag}'=='${False}' and '${is_feature_1948_enabled}'=='${False}'    ${master_config}
    tcpdump.create_tcpdump_collector    name=${tcpdump_collector_name}
    ...                                 options=${options}
    ...                                 executor=${executor_oam_vm}
    ...                                 container=CPRT
    tcpdump.Set Suite Alias    ${tcpdump_collector_name}
    core.setup_collectors    names=${tcpdump_collector_name}
    core.start_collectors    names=${tcpdump_collector_name}

Start Wireshark Log Collection
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cprt_collector_name}=cprt_tcpdump
    ...            ${tcpdump_collector_name}=cpif_tcpdump
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${options}=-i any -s 0
    ...            ${gnb_index}=${0}
    ...            ${du_index}=${0}
    Start CP-IF Log Collection    tcpdump_collector_name=${tcpdump_collector_name}
    ...                           asik_connection_alias=${asik_connection_alias}
    ...                           gnb_index=${gnb_index}
    ...                           du_index=${du_index}
    ...                           options=${options}
    Start CP-RT Log Collection    tcpdump_collector_name=${cprt_collector_name}
    ...                           asik_connection_alias=${asik_connection_alias}
    ...                           gnb_index=${gnb_index}
    ...                           du_index=${du_index}
    ...                           options=${options}


Stop Wireshark Log Collection
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]      ${cprt_collector_name}=cprt_tcpdump    ${tcpdump_collector_name}=cpif_tcpdump    ${target_dir}=${TS_CASE_LOG_PATH}
    ${cpif_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_collector_name}
    ${cprt_log_path}    Stop tcpdump log collection    tcpdump_collector_name=${cprt_collector_name}
    ${log_file}    Set Variable    cplane.pcap
    OperatingSystem.Run   command=cd ${target_dir}${/}${tcpdump_collector_name};mergecap -w ${log_file} ${cpif_log_path} ${cprt_log_path}
    ${log_path}    set variable    ${target_dir}${/}${tcpdump_collector_name}${/}${log_file}
    [Return]     ${log_path}

Start tcpdump Log On Enb
    [Documentation]    Author: Chen Jun
    ...                create tcpdump log collection on enb common card.
    ...                options: (optional) tcpdump options (except for “-w”), default: empty string
    ...                stop tcpdump can use:Stop tcpdump log collection
    [Arguments]      ${tcpdump_collector_name}=enb_wireshark_log    ${container_name}=${None}
    ...              ${options}=-p -i br1    ${enb_index}=${0}    ${common_unit_index}=${0}
    ...              ${is_multi_rat}=${False}
    ...              ${gnb_index}=${0}
    ...              ${du_index}=${0}
    ...              ${enb_host}=${tl.enbs[${enb_index}].airscale.common_units[${common_unit_index}].lmp_connection.addr}
    ...              ${enb_user}=${tl.enbs[${enb_index}].airscale.common_units[${common_unit_index}].lmp_connection.username}
    ...              ${enb_password}=${tl.enbs[${enb_index}].airscale.common_units[${common_unit_index}].lmp_connection.password}
    &{executor_oam_vm}   Run Keyword If    ${is_multi_rat}    Create Dictionary
    ...    host=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    user=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    ELSE    Create Dictionary    host=${enb_host}    user=${enb_user}    password=${enb_password}
    ${options}    Set Variable If    ${is_multi_rat}    -p -i any sctp    -p -i br1
    tcpdump.create_tcpdump_collector    name=${tcpdump_collector_name}
    ...                                 options=${options}
    ...                                 executor=${executor_oam_vm}
    ...                                 container=${container_name}
    tcpdump.Set Suite Alias    ${tcpdump_collector_name}
    core.setup_collectors    names=${tcpdump_collector_name}
    core.start_collectors    names=${tcpdump_collector_name}

Start To Collect Btslog
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               create btslog log collector on testvm
    ...               collector_name: name of the collector. Ex: btslog
    ...               btslog_path: (optional) path of the ‘btslog’ executable default value:”/opt/btslog/btslog”
    ...               btslog_launcher_path: (optional) path of ‘btslog_launcher’
    ...               executable default value:”/opt/btslog/btslog_launcher”
    ...               log_dir: path from where to get btslog files default value: “/tmp/btslog2”
    [Arguments]    ${btslog_collector_name}=btslog
    ...            ${btslog_path}=/opt/btslog/btslog
    ...            ${btslog_launcher_path}=/opt/btslog/btslog_launcher
    ...            ${log_dir}=/tmp/btslog2
    ...            ${btslog_configuration}=${None}
    Need To Kill Btslog Process
    ${executor_test_vm}=    Create Dictionary    host=${tl.test_pc.default_ssh_connection_details.addr}
    ...                                          user=${tl.test_pc.default_ssh_connection_details.username}
    ...                                          password=${tl.test_pc.default_ssh_connection_details.password}
    btslog.create_btslog_collector    name=${btslog_collector_name}
    ...                               btslog_path=${btslog_path}
    ...                               btslog_launcher_path=${btslog_launcher_path}
    ...                               executor=${executor_test_vm}
    ...                               log_dir=${log_dir}
    ...                               btslog_configuration=${btslog_configuration}
    core.setup_collectors    names=${btslog_collector_name}
    core.start_collectors    names=${btslog_collector_name}
    btslog.Set Suite Alias     ${btslog_collector_name}
    Wait Until Keyword Succeeds    5s    100ms    Check Btslog Process Should Be Started

Stop Btslog Collection
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${btslog_collector_name}=btslog    ${target_dir}=${TS_CASE_LOG_PATH}
    core.stop_collectors    names=${btslog_collector_name}
    core.collect_collectors    names=${btslog_collector_name}    target_dir=${target_dir}
    core.teardown_collectors    names=${btslog_collector_name}
    [Teardown]    Run Keywords    core.stop_collectors    names=${btslog_collector_name}    AND
    ...                           core.teardown_collectors    names=${btslog_collector_name}

Prepare And Start Aasyslog
    [Documentation]     jun.8.chen@nokia-sbell.com
    ...    Prepare and start aasyslog collection
    ...    :param filter: the save log can add filter to aviod too large
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${filter}=L2   ${gnb_path}=/tmp/
    ...            ${log_name}=aasyslog_for_testcase.txt    ${timeout}=15m
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                 filter=${filter}    gnb_path=${gnb_path}
    ...                                 log_name=${log_name}    timeout=${timeout}
    ${remote_aasyslog_path}    Set Variable    ${gnb_path}${log_name}
    [Return]    ${remote_aasyslog_path}

Stop Aasyslog Collection
    [Documentation]     jun.8.chen@nokia-sbell.com
    ...    Stop aasyslog collection
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}

Start Bip Capture
    [Documentation]     jun.8.chen@nokia-sbell.com
    ...                 :param add_mirror_port: if it is true, can capture the message between pcell and scell. if false, no other action.
    [Arguments]    ${connection}=ASIK Master    ${oam_connection}=GNB_OAM    ${gnb_index}=${0}    ${du_index}=${0}
    ...            ${bb_slot_1}=true    ${bb_slot_2}=false    ${bb_slot_3}=false
    ...            ${bb_slot_5}=false    ${bb_slot_6}=false    ${bb_slot_7}=false
    ...            ${l2_l1_bip}=true    ${syscom_mirroring}=false    ${add_mirror_port}=false
    ...            ${is_capture_right_bbmod}=False    ${connection_right}=ASIK Right
    Connect to gnb coam via ssl    connection=${oam_connection}    gnb_index=${gnb_index}
    Connect to Common Unit Master    alias=${connection}    gnb_index=${gnb_index}    du_index=${du_index}
    Run Keyword If    ${is_capture_right_bbmod}    csn.connect to
    ...               hostname=fct-4a
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection_right}
    ...               proxy=${connection}
    ${connection}    Set Variable If    ${is_capture_right_bbmod}    ${connection_right}    ${connection}
    Bip Capture with gnbMirroring scripts with retry    connection=${connection}    oam_connection=${oam_connection}
    ...                                                 bb_slot_1=${bb_slot_1}    bb_slot_2=${bb_slot_2}    bb_slot_3=${bb_slot_3}
    ...                                                 bb_slot_5=${bb_slot_5}    bb_slot_6=${bb_slot_6}    bb_slot_7=${bb_slot_7}
    ...                                                 l2_l1_bip=${l2_l1_bip}    syscom_mirroring=${syscom_mirroring}
    ...                                                 add_mirror_port=${add_mirror_port}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    ssh.disconnect    connection=${connection}    AND
    ...                           Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${oam_connection}

Stop Bip Capture
    [Documentation]     jun.8.chen@nokia-sbell.com
    [Arguments]     ${connection}=ASIK Master    ${gnb_index}=${0}    ${du_index}=${0}    ${log_prefix}=${None}
    ...             ${is_capture_right_bbmod}=False    ${connection_right}=ASIK Right    ${asib_interface}=eths2
    Connect to Common Unit Master    alias=${connection}    gnb_index=${gnb_index}    du_index=${du_index}
    Run Keyword If    ${is_capture_right_bbmod}    csn.connect to
    ...               hostname=fct-4a
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection_right}
    ...               proxy=${connection}
    ${connection}    Set Variable If    ${is_capture_right_bbmod}    ${connection_right}    ${connection}
    ${bip_log_list}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    connection=${connection}
    ...                                                                                      log_prefix=${log_prefix}
    ...                                                                                      asib_interface=${asib_interface}
    [Return]    ${bip_log_list}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=${connection}

Save Snapshot Log
    [Documentation]     jun.8.chen@nokia-sbell.com
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${timeout}=900
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Save snapshot via rest api    connection=${connection}    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Stop Aasyslog And Download To TestPC
    [Documentation]     stella.lin@nokia-sbell.com
    ...    Stop aasyslog collection and download it to testpc
    [Arguments]    ${log_prefix}    ${gnb_index}=0    ${du_index}=0    ${local_log_path}=/tmp     ${remote_log_path}=${TS_CASE_LOG_PATH}
    ...    ${connection}=ASIK Master    ${download_type}=Download
    Stop Aasyslog Collection    gnb_index=${gnb_index}    du_index=${du_index}
    Connect to Common Unit Master    alias=${connection}    gnb_index=${gnb_index}    du_index=${du_index}
    @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${local_log_path}   connection=${connection}
    ...    file_indicator=*${log_prefix}*.txt
    should not be empty  ${list_log_names}    msg=No aasyslog found with log prefix ${log_prefix} under asik ${local_log_path} folder
    @{aasyslog_log_list}    Create list
    FOR  ${log_name}  IN  @{list_log_names}
      Run Keyword If    '${download_type}'=='Download'    Wait Until Keyword Succeeds   2 min  5 sec   ssh.Download file
      ...                                                 remote_path=${local_log_path}/${log_name}
      ...                                                 local_path=${remote_log_path}/${log_name}
      ...                                                 connection=${connection}
      ...    ELSE IF    '${download_type}'=='SSHpass'    Wait Until Keyword Succeeds   2 min  5 sec    Run Process
      ...               sshpass -p ${asik_password} scp -r ${asik_username}@${asik_addr}:/tmp/${log_name} ${remote_log_path}/${log_name}
      ...               shell=yes
      ...    ELSE    Fail    msg=the value ${download_type} is not a valid value
      Append to list    ${aasyslog_log_list}    ${log_path}/${log_name}
      csn.execute      command=rm -rf ${local_log_path}/${log_name}    connection=${connection}
    END
    [Return]    ${aasyslog_log_list}
    [Teardown]    Run Keyword And Ignore Error    ssh.disconnect    connection=${connection}

Check Whether Is Btslog Process Exist
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ${check_process}    run    ps -ef | grep btslog | grep -v grep
    ${check_process}    strip string    ${check_process}
    ${process_length}    get length     ${check_process}
    ${is_process_exist}    set variable if    ${process_length}!=0    ${True}    ${False}
    [Return]    ${is_process_exist}

Check Btslog Process Should Be Killed
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ${is_process_exist}    Check Whether Is Btslog Process Exist
    should be true    ${is_process_exist}==${False}

Check Btslog Process Should Be Started
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ${is_process_exist}    Check Whether Is Btslog Process Exist
    should be true    ${is_process_exist}==${True}

Need To Kill Btslog Process
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${retry_time}=${10}
    FOR    ${i}    IN RANGE    ${retry_time}
        run    ps -ef | grep -v grep | grep btslog | awk '{print $2}' | xargs kill -9
        ${is_btslog_process_killed}    run keyword and return status    wait until keyword succeeds    5s    100ms
        ...    Check Btslog Process Should Be Killed
        exit for loop if    ${is_btslog_process_killed}==${True}
    END
    should be true    ${is_btslog_process_killed}==${True}


# --- For luashark ---
Convert CPIF Pcap To Pdml
    [Documentation]    author:jun.8.chen@nokia-sbell.com
    ...    Description: convert to cpif pcap to pdml format, pdml can be used for value check.
    [Arguments]    ${file_path}
    ...            ${tshark_path}=/usr/bin/tshark
    ...            ${filter}=nr-rrc
    ...            ${command_template}={tshark_path} -r {pcap_file} -Y \"${filter}\" -T pdml
    ...            ${alias}=parser
    Log    ${tshark_path}
    pcap.load_pcap_file    pcap_file=${file_path}    command_template=${command_template}    alias=${alias}

Convert Bip Pcap To Pdml
    [Documentation]    author:jun.8.chen@nokia-sbell.com
    ...    Description: convert to bip file to pdml format, pdml can be used for value check.
    [Arguments]    ${file_path}
    ...            ${tshark_path}=/usr/bin/tshark
    ...            ${filter}=dldata_pdschsendreq||dldata_pdcchsendreq
    ...            ${luashark_path}=/home/ute/luashark/luashark.lua
    ...            ${command_template}={tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y \"${filter}\" -T pdml
    ...            ${alias}=parser
    pcap.load_pcap_file    pcap_file=${file_path}
    ...                    tshark_path=${tshark_path}
    ...                    luashark_path=${luashark_path}
    ...                    command_template=${command_template}
    ...                    alias=${alias}


Setup Pcap File
    [Arguments]   ${file_path}   ${filter}=dldata_pdschsendreq||dldata_pdcchsendreq     ${alias}=parser
    ...            ${extension}=${None}   ${override_preference_setting}=${None}
    ...           ${disable_all_name_resolutions}=${None}   ${flush_standard_output}=${None}
    ...           ${tshark_path}=/usr/bin/tshark
    [Documentation]  Setup pcap_parser with tshark command options
   pcap.setup
    ...              infile=${file_path}
    ...              display_filter=${filter}
    ...              extension=${extension}
    ...              override_preference_setting=${override_preference_setting}
    ...              disable_all_name_resolutions=${disable_all_name_resolutions}
    ...              flush_standard_output=${flush_standard_output}
    ...              tshark_path=${tshark_path}
    ...              alias=${alias}

Get Field Value From PCAP
    [Arguments]   ${field_name}   ${filter_expression}    ${attribute_name}=show    ${alias}=parser
    [Documentation]  Get specified field’s values from filtered packets
#    pcap.get packets    filter=${filter}   pcap_parser=${alias}
    ${field_value_list}   pcap.get_field_value
    ...   field_name=${field_name}   fmt=${attribute_name}   filter=${filter_expression}   pcap_parser=${alias}
    [return]   ${field_value_list}

Get Field Value From Pdml
    [Documentation]    author:jun.8.chen@nokia-sbell.com
    ...    Description: get field value from pdml file.
    [Arguments]    ${filter_expression}    ${xpath}    ${attribute_name}=show    ${alias}=parser
    pcap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=${alias}
    ${field_value}=    pcap.get_field_value_by_xpath    xpath=${xpath}    attribute_name=${attribute_name}    pcap_parser=${alias}
    [Return]    ${field_value}

Filter Element On Syslog
    [Documentation]    author:Stella.lin@nokia-sbell.com
    ...    Description: filter info from Aasyslog or btslog
    ...    param:${pattern}, can be given any regexp expression.
    [Arguments]    ${log_path}    ${syslog_filter_pattern}
    ${file_output}    OperatingSystem.Get File    path=${log_path}    encoding_errors=ignore
    ${filter_output}     Get Lines Matching Regexp    string=${file_output}    pattern=${syslog_filter_pattern}    partial_match=True
    [Return]    ${filter_output}

Check Log Existence On Syslog
    [Documentation]    author:Stella.lin@nokia-sbell.com
    [Arguments]    ${log_path}    ${syslog_filter_pattern_list}    ${error_message}=${EMPTY}
    FOR  ${syslog_filter_pattern}  IN   @{syslog_filter_pattern_list}
      ${filter_output}   Filter Element On Syslog    log_path=${log_path}    syslog_filter_pattern=${syslog_filter_pattern}
      Run Keyword And Continue On Failure    Should Not Be Empty
      ...                                    ${filter_output}
      ...                                    msg=${error_message} log with pattern '${syslog_filter_pattern}' is not found on syslog.
    END

Check Target Item Value on CPIF Tcpdump
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                Description:check target item value on CPIF tcpdump log.
    [Arguments]    ${file_path}
    ...            ${filter_expression}
    ...            ${xpath}
    ...            ${tshark_path}=/usr/bin/tshark
    ...            ${filter}=f1ap||nr-rrc||ngap
    ...            ${command_template}={tshark_path} -r {pcap_file} -Y \"${filter}\" -T pdml
    ...            ${attribute_name}=show
    Convert CPIF Pcap To Pdml    file_path=${file_path}
    ...                          tshark_path=${tshark_path}
    ...                          filter=${filter}
    ...                          command_template=${command_template}
    ${filter_output}    Get Field Value From Pdml    filter_expression=${filter_expression}
    ...                                              xpath=${xpath}
    ...                                              attribute_name=${attribute_name}
    [Return]    ${filter_output}

Get NSETAP_X File And Copy To Wireshark Path
    [Documentation]    author:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${wireshark_install_path_UTE}=/usr/lib/x86_64-linux-gnu/wireshark/plugins
    ${install_version}      Run    ls ${wireshark_install_path_UTE}
    ${nsetapx_web_full_path}    Get NSETAP_X Download Path
    @{nsetapx_web_infor}    string.split string    ${nsetapx_web_full_path}    separator=/
    ${nsetapx_path_UTE}    Set Variable    ${wireshark_install_path_UTE}/${install_version}/epan/
    ${status}    Run Keyword And Return Status    File Should Exist    ${wireshark_install_path_UTE}/${install_version}/epan/${nsetapx_web_infor}[-1]
    return from keyword if    ${status}
    @{nsetapx_download_full_path}    Create list    ${nsetapx_web_full_path}    ${nsetapx_bakck_version}
    FOR  ${nsetapx_download}  IN  @{nsetapx_download_full_path}
        @{nsetapx_version}    string.split string    ${nsetapx_download}    separator=/
        Log To Console    start download ${nsetapx_version}[-1]
        Run Process
        ...     sudo wget ${nsetapx_download} -nv -P ${nsetapx_path_UTE}
        ...     shell=True
        ...     stdout=/home/ute/nsetapx_result.txt
        ${status}    Run Keyword And Return Status    File Should Exist
        ...                                                          ${wireshark_install_path_UTE}/${install_version}/epan/${nsetapx_version}[-1]
        Exit For Loop If 	${status}
    END
    Log To Console    ${nsetapx_version}[-1] download finish

Get NSETAP_X Download Path
    [Documentation]    author:xiaoxia.hao@nokia-sbell.com
    ${sw_version_on_wft}    Get gNB SW Version For WFT Download
    Run Keyword if    "${Active_SW_version}"==""    FAIL   Unknown gNB SW version
    ${nsetapx_cmd1}    Set Variable  curl -s https://wft.int.net.nokia.com/ext/build_content/${sw_version_on_wft} |
    ${nsetapx_cmd2}    Set Variable  grep 'sc="NSETAP-X"' | grep -v project | sed -e 's/^.*nsetap-x-\\([0-9.]*\\)".*$/\\1/'
    ${nsetapx_cmd}    Catenate  ${nsetapx_cmd1}  ${nsetapx_cmd2}
    ${nsetapx_version}      Run  ${nsetapx_cmd}
    ${nsetapx_infor}    Set Variable     curl -s ${NSETAP_WEB_PATH}/nsetapx-${nsetapx_version}/ |
    ${filter_infor}    Set Variable    grep -v project | grep -i 'nsetapx.*buster.so"'| awk -F '>|<' '{print$3}'
    ${nsetapx_cmd}    Catenate  ${nsetapx_infor}  ${filter_infor}
    ${nsetapx_sw}    Run  ${nsetapx_cmd}
    @{nsetapx_sw}    string.split string    ${nsetapx_sw}    separator=\n
    Run Keyword if    "${nsetapx_version}"==""    FAIL   get the  NSETAP-X fail
    [Return]    ${NSETAP_WEB_PATH}/nsetapx-${nsetapx_version}/${nsetapx_sw}[-1]

Get gNB SW Version For WFT Download
    [Documentation]    author:xiaoxia.hao@nokia-sbell.com
    @{gnb_version_on_gnb}    string.split string    ${Active_SW_version}    separator=_
    ${sw_version_on_wft}    Run Keyword if    "ENB_9999" in"${Active_SW_version}" or "ENB_9990" in"${Active_SW_version}"
    ...                                 String.Replace String    ${Active_SW_version}   ${gnb_version_on_gnb}[0]    SBTS00
    ...                         ELSE    set variable    ${Active_SW_version}
    [Return]    ${sw_version_on_wft}

Configure Wireshark NSETAP_X Protocol
    [Documentation]    author:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${port_number}   ${defragment}=TRUE
     ${status}    Run Keyword And Return Status    File Should Exist    /home/ute/.config/wireshark/preferences
    Run Keyword If    not ${status}     Run     mkdir /home/ute/.config/wireshark
    Run     echo 'ntrstr.port: ${port_number}'>>/home/ute/.config/wireshark/preferences
    Run Keyword If     '${defragment}'=='TRUE'    Run     echo "ntrstr.defragment: TRUE" >>/home/ute/.config/wireshark/preferences

