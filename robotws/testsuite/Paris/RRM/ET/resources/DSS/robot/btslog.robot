*** Settings ***

Documentation     Keywords for btslog

Library     taf.collectors.btslog       WITH NAME   btslog

*** Keywords ***

Connect to gNB Common Unit
    [Documentation]
    ...     setup ssh connection to Airscale (ASXX) and returns connection handle/alias
    ...
    ...     :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...     :param du_id:          Id of DU                        [0.. ]  default=0
    ...     :param comu_id:        Id of Common Unit               [0..1]  default=0
    ...     :param alias:       (optional) connection alias  !! should not be used
    ...
    ...     :returns alias:     alias for ssh connection to Common Unit
    ...
    ...     **Example:**
    ...
    ...     | ${asxx_alias}=   connect.Connect to gNB Common Unit    gnb_id=0  du_id=0  comu_id=0
    ...     | ssh.execute     command=uptime  connection=${asxx_alias}
    ...
    [Arguments]    ${gnb_id}=${0}  ${du_id}=${0}  ${comu_id}=${0}  ${alias}=ssh-gnb-${gnb_id}-${du_id}-${comu_id}
    ${test_pc_connection_count}=   Get Length    ${tl.test_pc.connections}
    # ${proxy}   Run keyword If   ${test_pc_connection_count}==0       Connect to test pc proxy    gnb_id=${gnb_id}
    # ...    ELSE    Set variable    ${None}
    ${proxy}  Set variable    ${None}
    ssh.Connect_to      hostname=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.addr}
    ...                 username=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.username}
    ...                 password=${tl.gnbs[${gnb_id}].dus[${du_id}].airscale.common_units[${comu_id}].lmp_connection.password}
    ...                 alias=${alias}
    ...                 proxy=${proxy}
    ssh.Force Reconnect    ${alias}
    [Return]    ${alias}

Create cplane runtime file to gnb
    [Documentation]
    ...    Enable cplane logging level. It requires reboot of gNB.
    ...
    ...    :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...    :param du_id:       Id of DU                        [0.. ]  default=0
    ...    :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...    :param level:       Trace level                     default=trace
    ...
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}    ${comu_id}=${0}    ${level}=trace
    ${comu_alias}=    btslog.Connect to gNB Common Unit    gnb_id=${gnb_id}    du_id=${du_id}    comu_id=${comu_id}
    ssh.send_command    command=echo -e "[control]\n\nLoggingSeverity=${level}\n" > /ffs/run/cp_runtime.ini    connection=${comu_alias}


Start Btslog
    [Documentation]    :
    ...
    ...     KW starts Btslog on Testpc with log-collector
    ...
    ...     https://confluence.int.net.nokia.com/display/EE/EE+BTSlog
    ...
    ...     *Note:* KW works only on ute-vm
    Return From Keyword If  '${tl.test_pc.default_ssh_connection_details.username}'!='ute'   message=Works only on Cloud
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    ${btslog_collector_name}=   Set Variable    btslog
    btslog.create_btslog_collector
    ...     name=${btslog_collector_name}
    ...     executor=${testpc_ssh_config}
    btslog.setup_collectors    names=${btslog_collector_name}
    btslog.start_collectors    names=${btslog_collector_name}
    btslog.set_suite_alias     ${btslog_collector_name}


Stop Btslog
    [Documentation]    :
    ...    Stop and fetch btslog from Testpc
    ...
    ...    *Note:* KW works only on ute-vm
    ...    :return path: Path to btslog file
    ...
    ...    :param target_dir: Directory to store the btslog file
    ...
    [Arguments]    ${target_dir}=None
    Return From Keyword If  '${tl.test_pc.default_ssh_connection_details.username}'!='ute'   message=Works only on Cloud
    IF    '${target_dir}'=='None'
        ${target_dir}=    common_Dss_Keywords.Get Testcase Log Directory
    END
    ${btslog_collector_name}=   Set Variable    btslog
    btslog.stop_collectors         names=${btslog_collector_name}
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    Builtin.Sleep   15 sec      # wait for btslog to close
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    btslog.collect_collectors      names=${btslog_collector_name}   target_dir=${target_dir}
    btslog.teardown_collectors     names=${btslog_collector_name}
    [RETURN]    ${target_dir}/${btslog_collector_name}/syslog_files.tgz


Start Sys Logs
    [Documentation]    :
    ...     old KW name from keywordbook.py which used fsyslog
    ...     use btslog now
    ...     *Note:* works only on ute-vm
    Start Btslog


Stop Sys Logs
    [Documentation]    :
    ...    old KW name from keywordbook.py which used fsyslog
    ...    use btslog now
    ...    *Note:* works only on ute-vm
    ...
    ...    :param target_dir: Directory to store the btslog file
    ...
    [Arguments]    ${target_dir}=None
    Stop Btslog    target_dir=${target_dir}
