*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com

Resource   common.robot
Library   taf.transport.ssh   WITH NAME   csn
Library   taf.collectors.btslog   WITH NAME   btslog
Library   taf.collectors.core   WITH NAME   core
Library    taf.collectors.l1l2bip   WITH NAME  l1l2bip


*** Keywords ***
COAM VDU Log Collection
    Wait Until Keyword Succeeds   15m   1m   COAM VDU Login

    COAM VDU Save Local Snapshot

    [Teardown]   Run Keyword And Ignore Error   COAM VDU Logout

COAM VCU Log Collection
    Wait Until Keyword Succeeds   15m   1m   COAM CU Login

    COAM CU Save Local Snapshot

    [Teardown]   Run Keyword And Ignore Error   COAM CU Logout

#Check no critical snapshot files is missing for vDU
#    Log To Console   Check no critical snapshot files is missing for vDU
#    VDU Snapshot Content Should Be Correct   snapshot=${SNAPSHOT}
#
#
Check no component crash in container log for vDU
    Log To Console   Check no component crash in container log for vDU
    Fatal Error Should Not Exist In Rcp Log   snapshot=${SNAPSHOT}


Remote Start Syslog Collection
    [Documentation]  Start BTSlogs Collection and get logs
    [Arguments]    ${test_pc_addr}=${btslog_pc_addr}
    ...   ${test_pc_username}=${btslog_pc_username}
    ...    ${test_pc_password}=${btslog_pc_password}


    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    Run Keyword And Ignore Error   csn.execute   command=rm -rf /tmp/btslog2/BTSLOG_TRACE_*.bin    connection=${test_pc_addr}
    Run Keyword And Ignore Error   csn.execute   command=rm -rf /tmp/btslog2/SYSLOG*.LOG   connection=${test_pc_addr}
    Run Keyword And Ignore Error   csn.execute   command=rm -rf /tmp/BTSLogCommandsLocalServer   connection=${test_pc_addr}
    Run Keyword And Ignore Error   csn.execute   command=mkdir /tmp/btslog2   connection=${test_pc_addr}
    run keyword and ignore Error   core.stop_collectors   names=btslog
    ${executor_btslog}    Create Dictionary    user=${test_pc_username}    password=${test_pc_password}
    ...   host=${test_pc_addr}    port=22
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   executor=${executor_btslog}
    ...   log_dir=/tmp/btslog2
    ...   start_timeout=${30}
    btslog.Set Global Alias   btslog
    core.setup_collectors   names=btslog
    core.start_collectors   names=btslog

    sleep  5s
    ${output}   csn.Execute   command=ls -al /tmp/btslog2/SYSLOG*.LOG   connection=${test_pc_addr}
    ${syslog_exist}   Run Keyword And Return Status   Should Not Contain   ${output}   No such file or directory
#    run Keyword If   not ${syslog_exist}    FAIL   msg=[FAIL]SYSLOG CANNOT COLLECTED!
    run Keyword If   not ${syslog_exist}    Recovery Remote Syslog Collection

    [Teardown]    Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}

Recovery Remote Syslog Collection
    [Documentation]  Recovery BTSlogs Collection and get logs
    COAM VDU Login
    ${original_value}    COAM VDU Get Parameter Online   mo_dn=MRBTS-11159/MNL-1/MNLENT-1/TRBLCADM-1
         ...    para_name=remoteSyslogConfig/0/remoteSyslogTransmitDuration
    ${output}    Convert To Integer    ${original_value}
    ${replace_param}    Evaluate    ${original_value}+1
    &{value_dict}    create Dictionary    remoteSyslogDSCP=4    remoteSyslogFormat=RFC5424
    ...    remoteSyslogServerHost=${btslog_pc_addr}   remoteSyslogServerPortNo=51000
    ...    remoteSyslogTransmitDuration=${replace_param}    remoteSyslogTransportProtocol=UDP
    ${value_list}    Create List    ${value_dict}
    COAM VDU Change Parameter Online    dist_name=MRBTS-11159/MNL-1/MNLENT-1/TRBLCADM-1
    ...    parameter=remoteSyslogConfig
    ...    operation=update
    ...    value=${value_list}
    [Teardown]    COAM VDU Logout


Remote Stop and Save Syslog Collection
    [Documentation]  Stop BTSlogs Collection and get logs
    [Arguments]    ${test_pc_addr}=${btslog_pc_addr}
    ...   ${test_pc_username}=${btslog_pc_username}
    ...    ${test_pc_password}=${btslog_pc_password}


    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    core.stop_collectors   names=btslog
    ${curr_date_str}   DateTime.Get Current Date
    ${curr_date}   DateTime.Convert Date   ${curr_date_str}   datetime
    ${date_str}   Set Variable   ${curr_date.year}${curr_date.month}${curr_date.day}_${curr_date.hour}${curr_date.minute}
    csn.execute   command=cd /tmp/btslog2; ls -al; zip SYSLOG_archive_${date_str}.zip SYSLOG_*.LOG   connection=${test_pc_addr}
    csn.Download File    remote_path=/tmp/btslog2/SYSLOG_archive_${date_str}.zip
    ...    local_path=${OUTPUT_DIR}/SYSLOG_archive_${date_str}.zip   connection=${test_pc_addr}
    csn.execute   command=cd /tmp/btslog2; ls -al; cat SYSLOG_*.LOG > SYSLOG_combine_${date_str}.LOG   connection=${test_pc_addr}
    csn.Download File    remote_path=/tmp/btslog2/SYSLOG_combine_${date_str}.LOG
    ...    local_path=${OUTPUT_DIR}/SYSLOG_combine_${date_str}.LOG   connection=${test_pc_addr}
    csn.execute   command=cd /tmp/btslog2; rm -rf SYSLOG_*   connection=${test_pc_addr}
    Set Suite Variable   ${ALL_SYSLOG_PATH}   ${OUTPUT_DIR}/SYSLOG_archive_${date_str}.zip
    [Return]   ${ALL_SYSLOG_PATH}
    [Teardown]    Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}

Remote Stop and Delete Syslog Collection
    [Documentation]  Delete BTSlogs in VM
    [Arguments]    ${test_pc_addr}=${btslog_pc_addr}
    ...   ${test_pc_username}=${btslog_pc_username}
    ...   ${test_pc_password}=${btslog_pc_password}


    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}
    Run Keyword And Ignore Error   core.stop_collectors      names=btslog
    csn.execute   rm -rf /tmp/btslog2/SYSLOG_*   connection=${test_pc_addr}
    [Teardown]    Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}


VDU Siso Common Check Syslog Error
    [Arguments]    ${test_pc_addr}=${btslog_pc_addr}
    ...   ${test_pc_username}=${btslog_pc_username}
    ...    ${test_pc_password}=${btslog_pc_password}
    Log To Console   //TODO: Siso Common Check Syslog Error
#    ${test_pc_addr}   Get Variable Value   ${tl.test_pc.default_ssh_connection_details.addr}   ${EMPTY}
#    ${test_pc_username}   Get Variable Value   ${tl.test_pc.default_ssh_connection_details.username}    ${EMPTY}
#    ${test_pc_password}   Get Variable Value   ${tl.test_pc.default_ssh_connection_details.password}   ${EMPTY}

    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    ${output}   csn.Execute   command=ls -al /tmp/btslog2/SYSLOG*.LOG   connection=${test_pc_addr}
    ${syslog_exist}   Run Keyword And Return Status   Should Not Contain   ${output}   No such file or directory
    Return From Keyword If   not ${syslog_exist}

    Log To Console   Check Syslog Error On TestPC: ${test_pc_addr}
    Log To Console   Syslog File List:
    Log To Console   ${output}

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'CELL NOTIFICATION 4329 Radio memory consumption exceeds abnormal threshold'
    ${status1}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'FaultId: 4329'
    ${status2}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'FaultId: 4330'
    ${status3}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'Detector 4329'
    ${status4}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'Detector 4330'
    ${status5}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'active 4329'
    ${status6}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep 'active 4330'
    ${status7}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep '4230 Radio memory consumption exceeds critical threshold'
    ${status8}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${offline_output}   csn.Execute   connection=${test_pc_addr}
    ...   command=cat /tmp/btslog2/SYSLOG*.LOG | grep '\\-\\=\\-\\='
    ${status9}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep 'Please contact the owner'
    ...   | grep -v '/ffs/run/logs'
    ...   | grep -v 'is not defined in SysinfoQuota.xml'
    ${offline_output}   csn.Execute   connection=${test_pc_addr}   command=${command}
    ${status10}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep 'ERR'
    ...   | grep '/ffs/run/logs'
    ...   | grep 'is not defined in SysinfoQuota.xml'
    ...   | grep 'Please contact the owner'
    ${offline_output}   csn.Execute   connection=${test_pc_addr}   command=${command}
    ${status11}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   Syslog Crash verification failed

    ${cmd_errorallowed}     Evaluate     '| '.join(@{SYSLOG_ERROR_allowed})
    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep -iE 'ERR/CP|ERR/L2'
#    ...   | grep -iE 'ERR/L2'
    ...   | ${cmd_errorallowed}
    ${offline_output}   csn.Execute   connection=${test_pc_addr}   command=${command}    timeout=10min
    ${status12}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   L2 or CP has error LOG!


#    ${cmd_errorallowed}     Evaluate     '| '.join(@{SYSLOG_ERROR_allowed})
#    ${command}   Catenate   SEPARATOR=
#    ...   cat /tmp/btslog2/SYSLOG*.LOG
#    ...   | grep 'ERR/CCS/AaSysMbServer'
##    ...   | grep -iE 'ERR/L2'
#    ...   | ${cmd_errorallowed}
#    ${offline_output}   csn.Execute   connection=${test_pc_addr}   command=${command}    timeout=10min
#    ${status13}   Run Keyword And Return Status   Should Be Empty   ${offline_output}   CCS has error LOG!


    ${status_list}   Create List   ${status1}   ${status2}   ${status3}   ${status4}   ${status5}   ${status6}
    ...   ${status7}   ${status8}   ${status9}   ${status10}   ${status11}    ${status12}
    Run Keyword And Continue On Failure   List Should Not Contain Value   ${status_list}   ${False}

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}


VDU Syslog Should Not Contain
    [Arguments]    ${filter}    ${shouldnotcontain_str}
    ...   ${test_pc_addr}=${btslog_pc_addr}
    ...   ${test_pc_username}=${btslog_pc_username}
    ...   ${test_pc_password}=${btslog_pc_password}

    Log To Console   //TODO: ${filter} VDU Syslog Should Not Contain ${shouldnotcontain_str}
#    ${test_pc_addr}   Get Variable Value   ${tl.test_pc.default_ssh_connection_details.addr}   ${EMPTY}
#    ${test_pc_username}   Get Variable Value   ${tl.test_pc.default_ssh_connection_details.username}    ${EMPTY}
#    ${test_pc_password}   Get Variable Value   ${tl.test_pc.default_ssh_connection_details.password}   ${EMPTY}

    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    ${output}   csn.Execute   command=ls -al /tmp/btslog2/SYSLOG*.LOG   connection=${test_pc_addr}
    ${syslog_exist}   Run Keyword And Return Status   Should Not Contain   ${output}   No such file or directory
    Return From Keyword If   not ${syslog_exist}

    Log To Console   VDU Syslog Should Contain On TestPC: ${test_pc_addr}
    Log To Console   Syslog File List:
    Log To Console   ${output}

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep ${filter}

    ${output}   csn.Execute   connection=${test_pc_addr}   command=${command}
    Should Not Be Empty   ${output}    ${filter} not in syslog!

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep ${filter}
    ...   | grep ${shouldnotcontain_str}

    ${output}   csn.Execute   connection=${test_pc_addr}   command=${command}
    Should Be Empty   ${output}    ${shouldnotcontain_str} happened in ${filter} syslog!


    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}


VDU Syslog Should Contain
    [Arguments]    ${filter}    ${shouldcontain_str}
    ...   ${test_pc_addr}=${btslog_pc_addr}
    ...   ${test_pc_username}=${btslog_pc_username}
    ...   ${test_pc_password}=${btslog_pc_password}

    Log To Console   //TODO: ${filter} VDU Syslog Should Contain ${shouldcontain_str}
#    ${test_pc_addr}   Get Variable Value   ${tl.test_pc.default_ssh_connection_details.addr}   ${EMPTY}
#    ${test_pc_username}   Get Variable Value   ${tl.test_pc.default_ssh_connection_details.username}    ${EMPTY}
#    ${test_pc_password}   Get Variable Value   ${tl.test_pc.default_ssh_connection_details.password}   ${EMPTY}

    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    ${output}   csn.Execute   command=ls -al /tmp/btslog2/SYSLOG*.LOG   connection=${test_pc_addr}
    ${syslog_exist}   Run Keyword And Return Status   Should Not Contain   ${output}   No such file or directory
    Return From Keyword If   not ${syslog_exist}

    Log To Console   VDU Syslog Should Contain On TestPC: ${test_pc_addr}
    Log To Console   Syslog File List:
    Log To Console   ${output}

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep ${filter}

    ${output}   csn.Execute   connection=${test_pc_addr}   command=${command}
    Should Not Be Empty   ${output}    ${filter} not in syslog!

    ${command}   Catenate   SEPARATOR=
    ...   cat /tmp/btslog2/SYSLOG*.LOG
    ...   | grep ${filter}
    ...   | grep ${shouldcontain_str}

    ${output}   csn.Execute   connection=${test_pc_addr}   command=${command}
    Should Not Be Empty   ${output}    ${shouldcontain_str} not happened in ${filter} syslog!


    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}


Clear Coredump files in OCP
    [Documentation]  Clear Coredump files in OCP
    [Arguments]
    ...  ${ocp_ip}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ...  ${ocp_username}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ...  ${ocp_password}=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    Log To Console   //TODO: Clear Coredump files in OCP
    csn.Connect to
    ...   hostname=${ocp_ip}   username=${ocp_username}   password=${ocp_password}   alias=${ocp_ip}   timeout=${10}
    csn.Execute   connection=${ocp_ip}   command=sudo rm -rf /var/lib/systemd/coredump/*
    ${output}    csn.Execute   connection=${ocp_ip}   command=ls /var/lib/systemd/coredump/
    Should Be Empty    ${output}    [warn]Coredump files still exist in OCP
    [Teardown]    Run Keyword And Ignore Error   csn.Disconnect   connection=${ocp_ip}


VDU Start Egen Log
    [Arguments]    ${egen_server}=10.71.219.82   ${egen_username}=ute   ${egen_password}=Ut3pa5s#ff97
    Log To Console    Start Egen Log
    csn.Connect to   hostname=${egen_server}   username=${egen_username}   password=${egen_password}  alias=egen
    ${command}   Catenate   SEPARATOR=
    ...   sudo egen --cores 0-6${SPACE}
    ...   --port 03:00.0 --port 03:00.1${SPACE}
    ...   --capture /tmp/AQQC_EGEN.pcap${SPACE}
    ...   --save-n-and-quit 1000000${SPACE}
    ...   &> /dev/null &
    csn.send command   command=${command}   timeout=60   connection=egen
    [Teardown]    csn.Disconnect       connection=egen


VDU Stop Egen Log
    [Arguments]    ${egen_server}=10.71.219.82   ${egen_username}=ute   ${egen_password}=Ut3pa5s#ff97
    Log To Console    Stop Egen Log
    csn.Connect to   hostname=${egen_server}   username=${egen_username}   password=${egen_password}  alias=egen
    ${output}   csn.Execute   command=ps -ef | grep "egen --cores 0-6 --port 03:00.0"   timeout=60   connection=egen
    ${pid_list}   Get Regexp Matches   ${output}   root\\s+(\\d+)   1
    FOR    ${pid}    IN   @{pid_list}
        csn.send command   command=sudo kill -9 ${pid}   timeout=60   connection=egen
    END
    [Teardown]    csn.Disconnect       connection=egen


VDU Stop Egen Log and Save to VM
    [Arguments]    ${egen_server}=10.71.219.82   ${egen_username}=ute   ${egen_password}=Ut3pa5s#ff97
    Log To Console    Stop Egen Log And Save To VM
    csn.Connect to   hostname=${egen_server}   username=${egen_username}   password=${egen_password}  alias=egen
    ${output}   csn.Execute   command=ps -ef | grep "egen --cores 0-6 --port 03:00.0"   timeout=60   connection=egen
    ${pid_list}   Get Regexp Matches   ${output}   root\\s+(\\d+)   1
    FOR    ${pid}    IN   @{pid_list}
        csn.send command   command=sudo kill -9 ${pid}   timeout=60   connection=egen
    END
    csn.Download File   remote_path=/tmp/AQQC_EGEN.pcap   local_path=${OUTPUT_DIR}/AQQC_EGEN.pcap   connection=egen
    [Teardown]    csn.Disconnect       connection=egen