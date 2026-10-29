*** Settings ***
Documentation    Used for AASysLog neccessary operations.
...              Please do not modify the file without notification to author
...              Author: Krzysztof Wrobel, Jakub Kaszczyszyn
...              Contact: krzysztof.1.wrobel@nokia.com, jakub.kaszczyszyn@nokia.com

Library           taf.collectors.core      WITH NAME   core
Library           taf.collectors.btslog    WITH NAME   btslog

*** Variables ***


*** Keywords ***
BTSLOG Start btslog on local machine
    [Arguments]   ${name}=btslog5g
    ...           ${bts_logs_dir}=/tmp/btslog2
    Make empty BTS logs dir local machine      ${bts_logs_dir}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    ...    start_timeout=${20}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

BTSLOG Collect btslog on local machine
    [Arguments]    ${name}=btslog5g
    run keyword and ignore error    Stop and collect btslog on local machine     name=${name}

Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog5g
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

Make empty BTS logs dir local machine
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

Get Btslogs from Remote machine
    [Arguments]    ${name}=btslog4g    ${host_ip}=${tl.test_pcs[1].default_ssh_connection_details.addr}
    ...    ${user}=${tl.test_pcs[1].default_ssh_connection_details.username}    ${password}=${tl.test_pcs[1].default_ssh_connection_details.password}
    Make empty BTS logs dir remote
    ${executor_test_vm}=  Create Dictionary
    ...  host=${host_ip}
    ...  user=${user}
    ...  password=${password}
    btslog.create_btslog_collector
    ...   name=${name}
    ...   log_dir=/tmp/btslog2
    ...   executor=${executor_test_vm}
    ...   start_timeout=${20}
    core.setup_collectors      names=${name}
    core.start_collectors      names=${name}
    btslog.set_suite_alias     ${name}

Stop logs from remote machine
    [Arguments]    ${name}=btslog4g  ${target_dir}=None
    core.stop_collectors      names=${name}
    core.collect_collectors      names=${name}  target_dir=${target_dir}
    core.teardown_collectors      names=${name}

Make empty BTS logs dir remote
    [Arguments]  ${host_ip}=${tl.test_pcs[1].default_ssh_connection_details.addr}  ${user}=${tl.test_pcs[1].default_ssh_connection_details.username}
    ...    ${password}=${tl.test_pcs[1].default_ssh_connection_details.password}    ${alias}=4g
    ssh.connect_to    hostname=${host_ip}   username=${user}    password=${password}    alias=${alias}
    ssh.send_command    command=if [ ! -d /tmp/btslog2 ]; then mkdir /tmp/btslog2; else rm /tmp/btslog2/*; fi    connection=${alias}
    [Teardown]    ssh.disconnect      connection=${alias}

Collect logs
    [Documentation]  Collects logs when the test failed execution.
    ...              Use execution_status to custom logs collecting not during Test Teardown.
    ...              Collection of all logs can be forced (even if test pass) by using force_collection flag.
    ...              Collection of individual log type can be toggled on/off by using corresponding flag.
    ...              Individual log type must be toggled on to be affected by force_collection.
    ...              When used with default arguments:
    ...                 * when test pass no logs will be collected
    ...                 * when test fail following logs will be collected: snapshot, btslog, swconfig, scf and if logs
    ...                   are sratted tcpdump
    [Arguments]      ${status_execution}=${TEST STATUS}
    ...              ${collection_force}=${False}
    ...              ${snapshot}=${True}
    ...              ${btslog}=${True}
    ...              ${swconfig}=${True}
    ...              ${scf_file}=${True}
    ...              ${tcpdump}=${False}

    ${download_log}=     Evaluate    ${collection_force} or 'FAIL' in '${status_execution}'
    Run keyword if  not ${collection_force} and not ${download_log}    Run Keyword And Ignore Error    Stop logs colletion

    Run keyword if  ${download_log} and ${snapshot}          Run keyword and continue on failure   Download snapshot
    Run keyword if  ${download_log} and ${btslog}            Run keyword and continue on failure   Download btslog
    Run keyword if  ${download_log} and ${swconfig}          Run keyword and continue on failure   Download swconfig
    Run keyword if  ${download_log} and ${scf_file}          Run keyword and continue on failure   Download SCF file
    Run keyword if  ${download_log} and ${tcpdump}           Run keyword and continue on failure   Download tcpdump

    [Teardown]      Remove temp log dirs

Download snapshot
    [Arguments]    ${logs_path}=${OUTPUT DIR}    ${file_name}=5g_snapshot
    ${log_dir}=  Set variable                   ${logs_path}/snapshot
    Log to console                              Collecting snapshot to ${log_dir}
    create directory                            ${log_dir}
    coam_cli.collect_snapshot                   target_file_name=${file_name}  timeout=${600}   connection=${coam_cli_alias_gNB}
    run    mv ${file_name} ${log_dir}

Download btslog
    Log to console                              Collecting syslog
    Stop logs from remote machine
    BTSLOG Collect btslog on local machine    name=btslog5g

Download swconfig
    [Arguments]    ${gnb_index}=0    ${du_index}=0
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    ${ssh_alias}=asik
    ssh.connect_to    hostname=${host}   username=${username}    password=${password}    alias=${ssh_alias}
    Log to console                          Collecting swconfig
    ssh.download_file    local_path=${OUTPUT DIR}/swconfig.txt    remote_path=/ffs/run/swconfig.txt    connection=${ssh_alias}
    [Teardown]    ssh.disconnect    connection=${ssh_alias}

Download SCF file
    [Arguments]    ${logs_path}=${OUTPUT DIR}    ${file_name}=5g_SCFC
    Log to console                              Collecting config file
    coam_cli.collect_scf                        target_file_name=${file_name}  timeout=${600}   connection=${coam_cli_alias_gNB}
    run    mv ${file_name} ${logs_path}
    sleep   5s

Download tcpdump
    [Arguments]    ${log_dir}=/tmp    ${filename}=tcpdump_tcpdump
    Log to console      Collect tcpdump
    run    cd ${log_dir} && mv ${filename}.pcap ${OUTPUT DIR}
    sleep   5s

Stop logs colletion
    Log to console    Stop tcpdum and bts_syslog
    Run keyword and continue on failure    core.Stop Collectors    names=l2stream3
    Run keyword and continue on failure    core.Collect Collectors    names=l2stream3    target_dir=/tmp
    Run keyword and continue on failure    Stop logs from remote machine
    Run keyword and continue on failure    BTSLOG Collect btslog on local machine    name=btslog5g

Remove temp log dirs
    run    sudo rm -rf /tmp/*.pcap
    run    rm -rf /tmp/*tcpdump*
    run    rm -rf /tmp/l2stream3
    run    sudo rm /tmp/sherp*
