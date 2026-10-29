*** Settings ***
Documentation
...    Author: yin.4.chen@nokia-sbell.com
...    Feature CNI-113670 Automation
Resource   Common.robot

*** Variables ***
${test_pc_addr}         ${tl.test_pc.default_ssh_connection_details.addr}
${test_pc_username}     ${tl.test_pc.default_ssh_connection_details.username}
${test_pc_password}     ${tl.test_pc.default_ssh_connection_details.password}


*** Keyword ***
# =================================================================================================================================================
# =================================================================================================================================================
# =================================================================================================================================================
# BTSLOG
Start Syslog Process
    [Arguments]   ${test_pc_addr}=${test_pc_addr}   ${test_pc_username}=${test_pc_username}   ${test_pc_password}=${test_pc_password}
    Log To Console   Start Syslog Process In PC: ${test_pc_addr}
    csn.Connect to   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}

    Run Keyword And Ignore Error   Clean BTSlog Process   connection=${test_pc_addr}
    Run Keyword And Ignore Error   Clean BTSlog File   connection=${test_pc_addr}

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


Stop Syslog Process
    [Arguments]   ${test_pc_addr}=${test_pc_addr}   ${test_pc_username}=${test_pc_username}   ${test_pc_password}=${test_pc_password}
    Log To Console   Stop Syslog Process In PC: ${test_pc_addr}
    Log To Console   ${test_pc_username}
    Log To Console   ${test_pc_password}
    Run Keyword And Ignore Error   core.stop_collectors   names=btslog_${test_pc_addr}


Save Syslog Process
    [Arguments]   ${test_pc_addr}=${test_pc_addr}   ${test_pc_username}=${test_pc_username}   ${test_pc_password}=${test_pc_password}
    Log To Console   Save Syslog Process In PC: ${test_pc_addr}
    csn.Connect to   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${test_pc_addr}   timeout=${10}

    ${btslog_name}   Set Variable   SYSLOG_${test_pc_addr}.zip
    Run Keyword And Ignore Error   csn.Execute   command=cd /tmp/btslog2; zip ${btslog_name} SYSLOG_*.LOG;   connection=${test_pc_addr}

    csn.Download File
    ...   remote_path=/tmp/btslog2/${btslog_name}
    ...   local_path=${OUTPUT_DIR}/${btslog_name}
    ...   connection=${test_pc_addr}
    ...   timeout=${300}
    # Run Keyword And Ignore Error   Clean BTSlog File   connection=${test_pc_addr}
    Log To Console   Syslog: ${OUTPUT_DIR}/${btslog_name}
    [Return]   ${OUTPUT_DIR}/${btslog_name}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${test_pc_addr}


Clean BTSlog Process
    [Arguments]   ${connection}

    Run Keyword And Ignore Error   csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog -NOGUI'     connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog -nogui'     connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=pkill -9 -f -x '/opt/btslog/btslog'            connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/BTSLogCommandsLocalServer          connection=${connection}   timeout=${60}

    ${status}   ${iptables_ruls}   Run Keyword And Ignore Error   csn.Execute    sudo iptables -L   connection=${connection}   timeout=${60}
    ${contain_100}   Run Keyword And Return Status   Should Contain   ${iptables_ruls}   192.168.100.0/24
    ${contain_101}   Run Keyword And Return Status   Should Contain   ${iptables_ruls}   192.168.101.0/24
    Run Keyword And Ignore Error   run keyword if  not ${contain_100}   csn.Execute
    ...   command=sudo iptables -I INPUT -p udp -s 192.168.100.1/24 -j ACCEPT   timeout=${60}   connection=${connection}
    Run Keyword And Ignore Error   run keyword if  not ${contain_101}    csn.Execute
    ...   command=sudo iptables -I INPUT -p udp -s 192.168.101.1/24 -j ACCEPT   timeout=${60}   connection=${connection}


Clean BTSlog File
    [Arguments]   ${connection}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/btslog2/BTSLOG_TRACE_*.bin         connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/btslog2/SYSLOG_*.LOG               connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=rm -rf /tmp/btslog2/SYSLOG_*.zip               connection=${connection}   timeout=${60}
    Run Keyword And Ignore Error   csn.Execute   command=mkdir /tmp/btslog2                             connection=${connection}   timeout=${60}
