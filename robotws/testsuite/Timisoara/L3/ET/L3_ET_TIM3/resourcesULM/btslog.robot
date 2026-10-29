*** Settings ***

Documentation     Keywords for btslog

Library    String
Library    Collections

Library    taf.collectors.btslog       WITH NAME   btslog
Library    python/connect.py           WITH NAME   connect_py

Resource   gnb.robot
Resource   testline.robot

*** Variables ***
${P_LOG_FORWARD_IP}         0x10042=0xc0a8ff7e    # IP_Adress in hex used for log forwarding 192.168.255.126
${P_OUTPUT_MODE}            0x10041=5
${P_LFS_LOG}                0x1007C=1
@{P_RAD_SYSLOG_FLAGS}       ${P_LOG_FORWARD_IP}  ${P_OUTPUT_MODE}  ${P_LFS_LOG}
@{P_RAD_CPLOG_FLAG_IDS}     0x66001b     # CP-NRT  log level
...                         0x890001     # CP-NB   log level
...                         0x890002     # CP-SB   log level
...                         0x890003     # CP-UE   log level
...                         0x890004     # CP-CL   log level
...                         0x890005     # CP-IF   log level
...                         0x890006     # CP-SCTP log level
${P_console}                ${False}

*** Keywords ***

Set Syslog Level in gNB swconfig
    [Documentation]
    ...    Set Syslog Level and neede configs in gNB swconfig. It requires reboot of gNB.
    ...
    ...    | gnb_id    | Id of gnb [0.. ] |
    ...    | du_id     | Id of DU [0.. ] |
    ...    | comu_id   | Id of Common Unit [0..1] |
    ...    | log_level | SYSLOG severity prints (0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable) |
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${log_level}=1
    Collections.Append To List   ${P_RAD_SYSLOG_FLAGS}   0x10040=${log_level}   0x1003F=${log_level}
    gnb.Update SW Config file on System Module   param_list=${P_RAD_SYSLOG_FLAGS}
    ...   gnb_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}


Prepare Cplane Component Log Level
    [Documentation]
    ...    This KW is the replacement of KW `Create cplane runtime file to gnb` as
    ...    cplane changed the log level setting towards RaD parameter flags.
    ...    The KW only changes the swconfig.txt file and a reset is needed to take affect aferwards.
    ...
    ...    | gnb_id  | Id of gnb          [0.. ] |
    ...    | du_id   | Id of DU           [0.. ] |
    ...    | comu_id | Id of Common Unit  [0..1] |
    ...    | level   | Trace level |
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${level}=debug
    ${level}        Get Cplane Log Level Value   level=${level}
    ${cplog_flags}  Create List
    FOR   ${cp_component_flag_id}   IN   @{P_RAD_CPLOG_FLAG_IDS}
       Collections.Append To List   ${cplog_flags}   ${cp_component_flag_id}=${level}
    END
    gnb.Update SW Config file on System Module   param_list=${cplog_flags} 
    ...   gnb_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}


Get Cplane Log Level Value
    [Documentation]
    ...    | level   | Trace level |
    ...     
    ...    *Returns* the trace level value/identifier
    ...
    [Arguments]   ${level}

    ${level}   String.Convert To Lower Case   ${level}
    Run Keyword If  $level not in ['trace','debug','info','warning','error','vip']
    ...   FAIL   Log level ${level} isn't in supported list (trace|debug|info|warning|error|vip)!
    ${level}   Set Variable If
    ...   '${level}'=='trace'     ${0}
    ...   '${level}'=='debug'     ${1}
    ...   '${level}'=='info'      ${2}
    ...   '${level}'=='warning'   ${3}
    ...   '${level}'=='error'     ${4}
    ...   '${level}'=='vip'       ${5}
    [Return]   ${level}


Create cplane runtime file to gnb
    [Documentation]
    ...    Enable cplane logging level. It requires reboot of gNB.
    ...
    ...    | gnb_id  | Id of gnb          [0.. ] |
    ...    | du_id   | Id of DU           [0.. ] |
    ...    | comu_id | Id of Common Unit  [0..1] |
    ...    | level   | Trace level |
    ...
    [Arguments]   ${gnb_id}=${0}   ${du_id}=${0}   ${comu_id}=${0}   ${level}=trace
    ${sw_branch}     testline.Get gNB SW Branch   gnb_id=${gnb_id}   du_id=${du_id}
    Run Keyword If   $sw_branch not in ['SBTS22R2','SBTS22R3']   Run Keywords
    ...        Prepare Cplane Component Log Level
    ...        gnb_id=${gnb_id}  du_id=${du_id}  comu_id=${comu_id}  level=${level}
    ...  AND   Return From Keyword

    ${comu_alias}      connect.Connect to Node Common Unit   node_id=${gnb_id}   du_id=${du_id}   comu_id=${comu_id}
    ssh.send_command   command=echo -e "[control]\n\nLoggingSeverity=${level}\n" > /ffs/run/cp_runtime.ini   connection=${comu_alias}


Create cplane runtime file to ap
    [Documentation]
    ...    Enable cplane logging level. It requires reboot of AP.
    ...
    ...    | ue_id   | Id of UE          [0.. ] |
    ...    | comu_id | Id of Common Unit [0..1] |
    ...    | level   | Trace level |
    ...
    [Arguments]   ${ue_id}=${0}   ${comu_id}=${0}   ${level}=trace
    ${comu_alias}   connect.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    ssh.send_command   command=echo -e "[control]\n\nLoggingSeverity=${level}\n" > /ffs/run/cp_runtime.ini    connection=${comu_alias}


Start Btslog
    [Documentation]
    ...
    ...     KW starts Btslog on Testpc with log-collector
    ...
    ...     https://confluence.int.net.nokia.com/display/EE/EE+BTSlog
    ...
    ...     *Note* KW works only on ute-vm
    ...    
    ...    | node_id   | Id of gNB|eNB      [0.. ] |
    ...    | node_type | either enb or gnb  [gnb|enb] |
    ...
    ...    *Returns*  btslog collector name
    ...
    [Arguments]   ${node_id}=${0}   ${node_type}=gnb
    Return From Keyword If   '${tl.test_pc.default_ssh_connection_details.username}'!='ute'   message=Works only on Cloud

    ${node_type}   String.Convert To Lower Case   ${node_type}
    ${nb_test_pc}   connect_py.get_test_pc_for_nodeb   ${tl}   ${tl.${node_type}s[${node_id}]}
    ${btslog_collector_name}   Set Variable   btslog_${node_type}${node_id}
    ${testpc_ssh_config}   Create Dictionary
    ...   host=${nb_test_pc.default_ssh_connection_details.addr}
    ...   user=${nb_test_pc.default_ssh_connection_details.username}
    ...   password=${nb_test_pc.default_ssh_connection_details.password}
    BuiltIn.Log     \n${testpc_ssh_config}    console=${P_console}
    #
    #   WA until Collectors take PID...
    #
    ssh.Connect_to   hostname=${nb_test_pc.default_ssh_connection_details.addr}
    ...   username=${nb_test_pc.default_ssh_connection_details.username}
    ...   password=${nb_test_pc.default_ssh_connection_details.password}
    ...   alias=vm_${node_type}${node_id} 
    ssh.send_command   command=pkill btslog   connection=vm_${node_type}${node_id}
    #
    #    END WA
    #
    btslog.create_btslog_collector
    ...   name=${btslog_collector_name}
    ...   executor=${testpc_ssh_config}
    btslog.setup_collectors   names=${btslog_collector_name}
    btslog.start_collectors   names=${btslog_collector_name}
    btslog.set_suite_alias    ${btslog_collector_name}
    [Return]   ${btslog_collector_name}


Stop Btslog
    [Documentation]
    ...    Stop and fetch btslog from Testpc
    ...
    ...    *Note:* KW works only on ute-vm
    ...
    ...    | node_id    | Id of gNB|eNB      [0.. ] |
    ...    | node_type  | either enb or gnb  [gnb|enb] |
    ...    | target_dir | Directory to store the btslog file |
    ...
    ...    *Returns*  Path to btslog file
    ...
    [Arguments]    ${node_id}=${0}  ${node_type}=gnb  ${target_dir}=None
    Return From Keyword If   '${tl.test_pc.default_ssh_connection_details.username}'!='ute'   message=Works only on Cloud

    ${node_type}   String.Convert to lower case   ${node_type}
    ${target_dir}   Run Keyword If   '${target_dir}'=='None'   testline.Get Testcase Log Directory
    ...   ELSE   Set Variable   ${target_dir}
    ${btslog_collector_name}   Set Variable   btslog_${node_type}${node_id}
    btslog.stop_collectors     names=${btslog_collector_name}

    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    Builtin.Sleep   15 sec  wait for btslog to close
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854

    btslog.collect_collectors    names=${btslog_collector_name}   target_dir=${target_dir}
    btslog.teardown_collectors   names=${btslog_collector_name}
    [Return]   ${target_dir}/${btslog_collector_name}/syslog_files.tgz

