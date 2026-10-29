*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
CB012784 Catch All Logs
    ${log_status}   Get Variable Value   ${TEST_STATUS}   ${KEYWORD_STATUS}
    Return From Keyword If   "${log_status}"=="PASS"

    # ${fail_log_dir}   Set Variable   ${OUTPUT_DIR}/${DEFINE_TEST_NAME}
    # ${fail_log_dir_not_exist}   Run Keyword And Return Status   Directory Should Not Exist   ${fail_log_dir}
    # Run Keyword If   ${fail_log_dir_not_exist}   OperatingSystem.Create Directory   ${fail_log_dir}
    # Set Test Variable   ${FAIL_LOG_DIR}

    Run Keyword And Continue On Failure   CB012784 Catch Snapshot           log_dir=${fail_log_dir}
    Run Keyword And Continue On Failure   CB012784 Save Syslog Process      log_dir=${fail_log_dir}


# Snapshot
CB012784 Catch Snapshot
    [Arguments]   ${log_dir}=${OUTPUT_DIR}/${DEFINE_TEST_NAME}   ${timeout}=5400

    Wait Until Keyword Succeeds   10m   1m   COAM Login

    ${time}   DateTime.Get Current Date   UTC   + 8 hours   result_format=%Y-%m-%d-%H_%M_%S
    Log To Console  Start To Collect Snapshot!
    ${snapshot_name}   Set Variable   Snapshot_${time}.zip

    Run Keyword And Ignore Error   coam.Collect snapshot
    ...      target_file_name=${log_dir}/${snapshot_name}   coverage=Full   force=True   timeout=${timeout}   connection=COAM

    [Return]   ${log_dir}/${snapshot_name}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout


# BTS Log
CB012784 Start Syslog Process
    [Timeout]   5m
    ${test_pc_addr}   Get Variable Value
    ...   ${tl.gnbs[0].dus[0].airscale.common_units[0].test_pc.default_ssh_connection_details.addr}   ${EMPTY}
    ${test_pc_username}   Get Variable Value
    ...   ${tl.gnbs[0].dus[0].airscale.common_units[0].test_pc.default_ssh_connection_details.username}   ${EMPTY}
    ${test_pc_password}   Get Variable Value
    ...   ${tl.gnbs[0].dus[0].airscale.common_units[0].test_pc.default_ssh_connection_details.password}   ${EMPTY}

    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    Log To Console   Start Syslog Process In PC: ${test_pc_addr}

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    Clean BTSlog Process   connection=${test_pc_addr}
    Clean BTSlog File   connection=${test_pc_addr}

    &{executor}   Create Dictionary    host=${test_pc_addr}   user=${test_pc_username}   password=${test_pc_password}
    btslog.create_btslog_collector
    ...   name=btslog_${test_pc_addr}
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    ...   executor=${executor}
    btslog.Set Global Alias   btslog_${test_pc_addr}
    core.setup_collectors   names=btslog_${test_pc_addr}
    core.start_collectors   names=btslog_${test_pc_addr}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}


CB012784 Stop Syslog Process
    ${test_pc_addr}   Get Variable Value
    ...   ${tl.gnbs[0].dus[0].airscale.common_units[0].test_pc.default_ssh_connection_details.addr}   ${EMPTY}
    ${test_pc_username}   Get Variable Value
    ...   ${tl.gnbs[0].dus[0].airscale.common_units[0].test_pc.default_ssh_connection_details.username}   ${EMPTY}
    ${test_pc_password}   Get Variable Value
    ...   ${tl.gnbs[0].dus[0].airscale.common_units[0].test_pc.default_ssh_connection_details.password}   ${EMPTY}

    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    Log To Console   Stop Syslog Process In PC: ${test_pc_addr}

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    core.stop_collectors   names=btslog_${test_pc_addr}
    Clean BTSlog Process   connection=${test_pc_addr}


CB012784 Save Syslog Process
    [Arguments]   ${log_dir}=${OUTPUT_DIR}/${DEFINE_TEST_NAME}

    ${test_pc_addr}   Get Variable Value
    ...   ${tl.gnbs[0].dus[0].airscale.common_units[0].test_pc.default_ssh_connection_details.addr}   ${EMPTY}
    ${test_pc_username}   Get Variable Value
    ...   ${tl.gnbs[0].dus[0].airscale.common_units[0].test_pc.default_ssh_connection_details.username}   ${EMPTY}
    ${test_pc_password}   Get Variable Value
    ...   ${tl.gnbs[0].dus[0].airscale.common_units[0].test_pc.default_ssh_connection_details.password}   ${EMPTY}
    Return From Keyword If   "${test_pc_addr}"=="" or "${test_pc_addr}"=="${None}" or "${test_pc_addr}"=="1.1.1.1"

    Log To Console   Save Syslog Process In PC: ${test_pc_addr}

    ${connection_status}   Run Keyword And Return Status   csn.Connect to
    ...   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}
    Run Keyword If   not ${connection_status}   Log To Console   Test PC Can Not Connect: ${test_pc_addr}
    Return From Keyword If   not ${connection_status}

    ${btslog_name}   Set Variable   SYSLOG_${test_pc_addr}.zip
    Run Keyword And Ignore Error   csn.Execute   command=cd /tmp/btslog2; zip ${btslog_name} SYSLOG_*.LOG;   connection=${test_pc_addr}

    Run Keyword And Ignore Error   csn.Download File
    ...   remote_path=/tmp/btslog2/${btslog_name}
    ...   local_path=${log_dir}/${btslog_name}
    ...   connection=${test_pc_addr}
    ...   timeout=${300}
    Run Keyword And Ignore Error   Clean BTSlog File   connection=${test_pc_addr}
    Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}

    Log To Console   Syslog: ${OUTPUT_DIR}/${btslog_name}
    [Return]   ${OUTPUT_DIR}/${btslog_name}


Clean BTSlog Process
    [Arguments]   ${connection}

    Run Keyword And Ignore Error   csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog -NOGUI'     connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog -nogui'     connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog'            connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/BTSLogCommandsLocalServer          connection=${connection}   timeout=${60}

    # ${status}   ${iptables_ruls}   Run Keyword And Ignore Error   csn.Execute    sudo iptables -L   connection=${connection}   timeout=${60}
    # ${contain_100}   Run Keyword And Return Status   Should Contain   ${iptables_ruls}   192.168.100.0/24
    # ${contain_101}   Run Keyword And Return Status   Should Contain   ${iptables_ruls}   192.168.101.0/24
    # Run Keyword And Ignore Error   Run Keyword Unless    ${contain_100}   csn.Execute
    # ...   command=sudo iptables -I INPUT -p udp -s 192.168.100.1/24 -j ACCEPT   timeout=${60}   connection=${connection}
    # Run Keyword And Ignore Error   Run Keyword Unless    ${contain_101}    csn.Execute
    # ...   command=sudo iptables -I INPUT -p udp -s 192.168.101.1/24 -j ACCEPT   timeout=${60}   connection=${connection}


Clean BTSlog File
    [Arguments]   ${connection}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/btslog2/BTSLOG_TRACE_*.bin         connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/btslog2/SYSLOG_*.LOG               connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/btslog2/SYSLOG_*.zip               connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=mkdir /tmp/btslog2                             connection=${connection}   timeout=${60}

